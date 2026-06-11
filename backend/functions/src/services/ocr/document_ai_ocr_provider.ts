import {
  DocumentProcessorServiceClient,
  protos,
} from "@google-cloud/documentai";
import * as logger from "firebase-functions/logger";
import {DocumentAiConfig} from "../../config/document_ai_config";
import {OcrProvider} from "./ocr_provider";
import {OcrResult} from "./types";

type IPage = protos.google.cloud.documentai.v1.Document.IPage;
type IToken = protos.google.cloud.documentai.v1.Document.Page.IToken;
type IProcessRequest =
  protos.google.cloud.documentai.v1.IProcessRequest;

// Tokens flagged as handwritten must exceed this share of all tokens
// for the document to be considered handwritten via style info.
const HANDWRITING_TOKEN_RATIO = 0.3;

// Below this confidence, a prescription is treated as likely
// handwritten even when style info is unavailable.
export const LOW_CONFIDENCE_HANDWRITING_THRESHOLD = 0.75;

/**
 * Clamps a confidence value into the [0, 1] range.
 * @param {number} value Raw confidence value.
 * @return {number} Clamped confidence.
 */
function clampConfidence(value: number): number {
  if (value < 0) return 0;
  if (value > 1) return 1;
  return value;
}

/**
 * Computes the average page-layout confidence across all pages.
 * Returns undefined when no page reports a confidence value.
 * @param {IPage[]} pages Document AI pages.
 * @return {number | undefined} Average confidence in [0, 1].
 */
export function computeAverageConfidence(
  pages: IPage[],
): number | undefined {
  const confidences = pages
    .map((page) => page.layout?.confidence)
    .filter((value): value is number => typeof value === "number");

  if (confidences.length === 0) {
    return undefined;
  }

  const total = confidences.reduce((sum, value) => sum + value, 0);
  return clampConfidence(total / confidences.length);
}

/**
 * Returns the character length covered by a token, derived from its
 * text-anchor segments. Falls back to 1 so every token carries weight.
 * @param {IToken} token Document AI token.
 * @return {number} Token weight (>= 1).
 */
function tokenWeight(token: IToken): number {
  const segments = token.layout?.textAnchor?.textSegments ?? [];
  let length = 0;
  for (const segment of segments) {
    const start = Number(segment.startIndex ?? 0);
    const end = Number(segment.endIndex ?? 0);
    if (end > start) {
      length += end - start;
    }
  }
  return length > 0 ? length : 1;
}

/**
 * Computes a token-weighted confidence using per-token layout
 * confidence, weighting each token by the number of characters it
 * covers. Falls back to the page-average confidence when token-level
 * confidence is unavailable (standard OCR tier).
 * @param {IPage[]} pages Document AI pages.
 * @return {number | undefined} Weighted confidence in [0, 1].
 */
export function computeWeightedConfidence(
  pages: IPage[],
): number | undefined {
  let weightedSum = 0;
  let weightTotal = 0;

  for (const page of pages) {
    for (const token of page.tokens ?? []) {
      const confidence = token.layout?.confidence;
      if (typeof confidence !== "number") {
        continue;
      }
      const weight = tokenWeight(token);
      weightedSum += confidence * weight;
      weightTotal += weight;
    }
  }

  if (weightTotal > 0) {
    return clampConfidence(weightedSum / weightTotal);
  }

  return computeAverageConfidence(pages);
}

/**
 * Detects handwriting from token style info reported by Document AI.
 * Returns false when style info is unavailable (standard OCR tier).
 * @param {IPage[]} pages Document AI pages.
 * @return {boolean} True when handwriting dominates the document.
 */
export function detectHandwriting(pages: IPage[]): boolean {
  let totalTokens = 0;
  let handwrittenTokens = 0;

  for (const page of pages) {
    for (const token of page.tokens ?? []) {
      totalTokens += 1;
      if (token.styleInfo?.handwritten === true) {
        handwrittenTokens += 1;
      }
    }
  }

  if (totalTokens === 0) {
    return false;
  }

  return handwrittenTokens / totalTokens >= HANDWRITING_TOKEN_RATIO;
}

/**
 * Resolves the final handwriting flag combining two signals:
 *   A) style-info handwriting detection, OR
 *   B) low OCR confidence on a prescription (style info often missing
 *      on handwritten prescriptions).
 * @param {object} params Detection inputs.
 * @param {boolean} params.styleInfoDetected Style-info handwriting flag.
 * @param {number | undefined} params.confidence Average OCR confidence.
 * @param {boolean} params.isPrescription Whether doc is a prescription.
 * @return {boolean} Final handwriting flag.
 */
export function resolveHandwriting(params: {
  styleInfoDetected: boolean;
  confidence?: number;
  isPrescription: boolean;
}): boolean {
  if (params.styleInfoDetected) {
    return true;
  }
  if (
    params.isPrescription &&
    params.confidence !== undefined &&
    params.confidence < LOW_CONFIDENCE_HANDWRITING_THRESHOLD
  ) {
    return true;
  }
  return false;
}

/**
 * OCR provider backed by a Google Document AI OCR processor.
 * Uses synchronous (online) processing, suitable for files within the
 * online processing size limits (the app enforces a 10 MB cap).
 */
export class DocumentAiOcrProvider implements OcrProvider {
  private readonly client: DocumentProcessorServiceClient;
  private readonly processorName: string;
  private readonly processorId: string;

  /**
   * @param {DocumentAiConfig} config Validated Document AI settings.
   */
  constructor(config: DocumentAiConfig) {
    this.client = new DocumentProcessorServiceClient({
      apiEndpoint: `${config.location}-documentai.googleapis.com`,
    });
    this.processorId = config.processorId;
    this.processorName =
      `projects/${config.projectId}` +
      `/locations/${config.location}` +
      `/processors/${config.processorId}`;
  }

  /**
   * Sends the file to the Document AI OCR processor and returns the
   * full extracted text with confidence and page metadata.
   * @param {Buffer} fileBuffer Raw file contents (PDF or image).
   * @param {string} mimeType MIME type of the file.
   * @return {Promise<OcrResult>} Extracted text and metadata.
   */
  async extractText(
    fileBuffer: Buffer,
    mimeType: string,
  ): Promise<OcrResult> {
    const document = await this.processWithPremiumOptions(
      fileBuffer,
      mimeType,
    );

    const text = document?.text ?? "";
    const pages = (document?.pages ?? []) as IPage[];
    const pageCount = pages.length;
    const confidence = computeWeightedConfidence(pages);
    const handwritingDetected = detectHandwriting(pages);

    logger.info("Document AI OCR completed", {
      ocrProvider: "document_ai",
      processorId: this.processorId,
      pageCount,
      confidence: confidence ?? null,
      handwritingDetected,
    });

    if (!text) {
      throw new Error(
        "Document AI returned no text for the document. The file may " +
        "be empty, corrupted, or unreadable by the OCR processor.",
      );
    }

    return {
      text,
      confidence,
      pageCount,
      handwritingDetected,
    };
  }

  /**
   * Runs processDocument with premium OCR options enabled. If the API
   * rejects the options (older processor/SDK), retries once without
   * process options so OCR still succeeds.
   * @param {Buffer} fileBuffer Raw file contents.
   * @param {string} mimeType MIME type of the file.
   * @return {Promise<protos.google.cloud.documentai.v1.IDocument | null
   *   | undefined>} The processed document.
   */
  private async processWithPremiumOptions(
    fileBuffer: Buffer,
    mimeType: string,
  ) {
    const baseRequest: IProcessRequest = {
      name: this.processorName,
      rawDocument: {
        content: fileBuffer.toString("base64"),
        mimeType,
      },
    };

    try {
      const [response] = await this.client.processDocument({
        ...baseRequest,
        processOptions: {
          ocrConfig: {
            enableNativePdfParsing: true,
            enableImageQualityScores: true,
            computeStyleInfo: true,
          },
        },
      });
      return response.document;
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      logger.warn(
        "Document AI premium OCR options unavailable; retrying without",
        {processorId: this.processorId, reason: message},
      );
      const [response] = await this.client.processDocument(baseRequest);
      return response.document;
    }
  }
}
