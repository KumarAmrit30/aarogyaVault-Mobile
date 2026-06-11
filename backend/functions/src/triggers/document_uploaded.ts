import {Storage} from "@google-cloud/storage";
import {onObjectFinalized} from "firebase-functions/v2/storage";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {promises as fs} from "fs";
import {
  getDocumentAiConfig,
  isDocumentAiOcrEnabled,
} from "../config/document_ai_config";
import {DocumentDownloadService} from "../services/document_download_service";
import {GeminiOcrProvider} from "../services/gemini_ocr_provider";
import {
  MedicalAnalysisProvider,
} from "../services/medical/medical_analysis_provider";
import {
  validateOcrProcessor,
} from "../services/ocr/document_ai_processor_validator";
import {
  DocumentAiOcrProvider,
  resolveHandwriting,
} from "../services/ocr/document_ai_ocr_provider";
import {OcrResultStore} from "../services/ocr_result_store";
import {OcrTextStore} from "../services/storage/ocr_text_store";
import {classifyDocumentType} from "../utils/document_classifier";
import {parseStoragePath} from "../utils/storage_path_parser";

const MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024;
const ALLOWED_CONTENT_TYPES = new Set([
  "application/pdf",
  "image/jpeg",
  "image/png",
]);

// Below this average OCR confidence, extracted content (especially
// medicines on prescriptions) must be verified manually.
const LOW_CONFIDENCE_THRESHOLD = 0.75;
const LOW_CONFIDENCE_WARNING =
  "Low OCR confidence. Verify extracted medicines and values manually.";

const storage = new Storage();
const downloadService = new DocumentDownloadService(storage);
const ocrTextStore = new OcrTextStore(storage);
const legacyOcrProvider = new GeminiOcrProvider();
const ocrStore = new OcrResultStore(admin.firestore());

// Lazily constructed so the legacy path never requires Document AI
// environment configuration.
let documentAiProvider: DocumentAiOcrProvider | undefined;
let medicalAnalysisProvider: MedicalAnalysisProvider | undefined;

/**
 * Returns the singleton Document AI OCR provider, constructing it on
 * first use from environment configuration.
 * @return {DocumentAiOcrProvider} Document AI OCR provider.
 */
async function getDocumentAiProvider(): Promise<DocumentAiOcrProvider> {
  if (!documentAiProvider) {
    const config = getDocumentAiConfig();
    await validateOcrProcessor(config);
    documentAiProvider = new DocumentAiOcrProvider(config);
  }
  return documentAiProvider;
}

/**
 * Returns the singleton Gemini medical analysis provider.
 * @return {MedicalAnalysisProvider} Medical analysis provider.
 */
function getMedicalAnalysisProvider(): MedicalAnalysisProvider {
  if (!medicalAnalysisProvider) {
    medicalAnalysisProvider = new MedicalAnalysisProvider();
  }
  return medicalAnalysisProvider;
}

/**
 * Processes a document through the Document AI OCR + Gemini medical
 * analysis pipeline and saves a v2 record to Firestore.
 *
 * Logging policy: never log extracted medical text or summaries —
 * only documentId, pageCount, confidence, and documentType.
 * @param {string} documentId Document identifier.
 * @param {string} localPath Local path of the downloaded file.
 * @param {string} contentType MIME type of the file.
 * @return {Promise<void>} Resolves when processing completes.
 */
async function processWithDocumentAi(
  documentId: string,
  localPath: string,
  contentType: string,
): Promise<void> {
  logger.info("OCR_STARTED", {
    documentId,
    ocrProvider: "document_ai",
  });

  const fileBuffer = await fs.readFile(localPath);
  const ocrResult = await (await getDocumentAiProvider()).extractText(
    fileBuffer,
    contentType,
  );

  logger.info("OCR_COMPLETED", {
    documentId,
    pageCount: ocrResult.pageCount ?? null,
  });
  logger.info("OCR_CONFIDENCE", {
    documentId,
    confidence: ocrResult.confidence ?? null,
  });

  logger.info("MEDICAL_ANALYSIS_STARTED", {documentId});

  const analysis = await getMedicalAnalysisProvider().analyze(
    ocrResult.text,
  );

  logger.info("MEDICAL_ANALYSIS_COMPLETED", {
    documentId,
    documentType: analysis.documentType,
  });

  const category = classifyDocumentType(analysis.documentType);
  const isPrescription = category === "prescription";

  const lowConfidence =
    ocrResult.confidence !== undefined &&
    ocrResult.confidence < LOW_CONFIDENCE_THRESHOLD;

  const handwritingDetected = resolveHandwriting({
    styleInfoDetected: ocrResult.handwritingDetected ?? false,
    confidence: ocrResult.confidence,
    isPrescription,
  });

  const savedText = await ocrTextStore.saveText(documentId, ocrResult.text);

  await ocrStore.saveAnalyzedResult({
    documentId,
    ocrProvider: "document_ai",
    ocrConfidence: ocrResult.confidence,
    pageCount: ocrResult.pageCount,
    documentType: analysis.documentType,
    ocrTextPath: savedText.ocrTextPath,
    ocrCharacterCount: savedText.ocrCharacterCount,
    summary: analysis.summary,
    criticalFindings: analysis.criticalFindings,
    normalFindings: analysis.normalFindings,
    recommendedFollowUp: analysis.recommendedFollowUp,
    ...(isPrescription ? {handwritingDetected} : {}),
    ...(lowConfidence ? {extractionWarning: LOW_CONFIDENCE_WARNING} : {}),
  });
}

/**
 * Processes a document through the legacy Gemini OCR pipeline and
 * saves a v1 record to Firestore. Unchanged behavior; retained as the
 * rollback path behind the USE_DOCUMENT_AI_OCR flag.
 * @param {string} documentId Document identifier.
 * @param {string} localPath Local path of the downloaded file.
 * @return {Promise<void>} Resolves when processing completes.
 */
async function processWithLegacyGeminiOcr(
  documentId: string,
  localPath: string,
): Promise<void> {
  const result = await legacyOcrProvider.extractText(localPath);

  await ocrStore.saveResult(
    documentId,
    result.extractedText,
    result.summary,
  );
}

export const onDocumentUploaded = onObjectFinalized(
  {
    // Observed OCR runs take ~105s; the Gen2 default (60s) would kill
    // them mid-flight. 300s gives headroom for large multi-page PDFs.
    timeoutSeconds: 300,
    // Headroom for a 10 MB file buffer + ~13 MB base64 copy + large
    // Gemini responses, instead of the 256 MiB default.
    memory: "1GiB",
    // One OCR job per instance: each request holds large buffers in
    // memory and runs minutes long; parallel events get own instances.
    concurrency: 1,
  },
  async (event) => {
    const storagePath = event.data.name;

    if (!storagePath) {
      logger.warn("Document upload ignored: missing storage object name");
      return;
    }

    const metadata = parseStoragePath(storagePath);
    if (!metadata) {
      logger.warn("Document upload ignored: invalid storage path", {storagePath});
      return;
    }

    metadata.contentType = event.data.contentType;

    const contentType = event.data.contentType;
    if (!contentType || !ALLOWED_CONTENT_TYPES.has(contentType)) {
      logger.warn("Unsupported document type", {
        documentId: metadata.documentId,
        contentType: contentType ?? null,
      });
      return;
    }

    const sizeBytes = event.data.size ? Number(event.data.size) : 0;
    if (sizeBytes > MAX_FILE_SIZE_BYTES) {
      logger.warn("Document exceeds size limit", {
        documentId: metadata.documentId,
        sizeBytes,
      });
      return;
    }
    if (sizeBytes <= 0) {
      logger.warn("Missing file size", {
        documentId: metadata.documentId,
      });
      return;
    }

    const existingOcrResult = await admin.firestore()
      .collection("ocr_results")
      .doc(metadata.documentId)
      .get();

    if (existingOcrResult.exists) {
      logger.info("OCR already exists. Skipping.", {
        documentId: metadata.documentId,
      });
      return;
    }

    const useDocumentAi = isDocumentAiOcrEnabled();

    try {
      logger.info("OCR processing started", {
        documentId: metadata.documentId,
        pipeline: useDocumentAi ? "document_ai_v2" : "gemini_legacy_v1",
      });

      const downloadedDocument = await downloadService.download(
        metadata.storagePath,
      );

      if (useDocumentAi) {
        await processWithDocumentAi(
          metadata.documentId,
          downloadedDocument.localPath,
          contentType,
        );
      } else {
        await processWithLegacyGeminiOcr(
          metadata.documentId,
          downloadedDocument.localPath,
        );
      }

      logger.info("OCR processing completed", {
        documentId: metadata.documentId,
      });
    } catch (error) {
      logger.error("OCR processing failed", {
        documentId: metadata.documentId,
        error,
      });
      throw error;
    }
  },
);
