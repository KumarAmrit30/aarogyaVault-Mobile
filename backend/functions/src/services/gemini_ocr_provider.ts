import {
  FinishReason,
  SchemaType,
  VertexAI,
} from "@google-cloud/vertexai";
import * as logger from "firebase-functions/logger";
import {promises as fs} from "fs";
import * as path from "path";
import {OcrExtractionResult} from "../models/ocr_result";
import {OcrProvider} from "./ocr_provider";

// With structured output (responseSchema) enforcing the JSON shape,
// the prompt only needs to describe the task — not the output format.
const OCR_PROMPT = `You are an OCR engine for medical documents.

Extract all visible text from the document exactly as written,
preserving medical terminology, values, and units.

Then write a concise, patient-friendly medical summary of the document.`;

const MIME_TYPES: Record<string, string> = {
  pdf: "application/pdf",
  jpg: "image/jpeg",
  jpeg: "image/jpeg",
  png: "image/png",
};

const VERTEX_PROJECT_ID = "aarogya-vault-dev";
const VERTEX_LOCATION = "asia-south1";
const GEMINI_MODEL = "gemini-2.5-flash";

// gemini-2.5-flash supports up to 65,535 output tokens. Multi-page
// medical PDFs produce large extractedText payloads; the default
// output cap truncates JSON mid-string and breaks parsing.
const MAX_OUTPUT_TOKENS = 65535;

const vertexAI = new VertexAI({
  project: VERTEX_PROJECT_ID,
  location: VERTEX_LOCATION,
});

const generativeModel = vertexAI.getGenerativeModel({
  model: GEMINI_MODEL,
  generationConfig: {
    responseMimeType: "application/json",
    responseSchema: {
      type: SchemaType.OBJECT,
      properties: {
        extractedText: {
          type: SchemaType.STRING,
        },
        summary: {
          type: SchemaType.STRING,
        },
      },
      required: [
        "extractedText",
        "summary",
      ],
    },
    maxOutputTokens: MAX_OUTPUT_TOKENS,
    temperature: 0,
  },
});

/**
 * Extracts medical text and a summary from a document file using
 * Vertex AI Gemini with schema-enforced JSON output.
 */
export class GeminiOcrProvider implements OcrProvider {
  /**
   * Runs OCR on the file at the given local path.
   * @param {string} filePath Local path of the downloaded document.
   * @return {Promise<OcrExtractionResult>} Extracted text and summary.
   */
  async extractText(
    filePath: string,
  ): Promise<OcrExtractionResult> {
    const extension = path.extname(filePath).slice(1).toLowerCase();
    const mimeType = MIME_TYPES[extension];
    if (!mimeType) {
      throw new Error(`Unsupported file type: ${extension || "unknown"}`);
    }

    const fileBuffer = await fs.readFile(filePath);
    const fileBase64 = fileBuffer.toString("base64");

    const result = await generativeModel.generateContent({
      contents: [
        {
          role: "user",
          parts: [
            {text: OCR_PROMPT},
            {
              inlineData: {
                mimeType,
                data: fileBase64,
              },
            },
          ],
        },
      ],
    });

    const candidate = result.response.candidates?.[0];
    const finishReason = candidate?.finishReason;

    // A truncated response is guaranteed-invalid JSON. Fail with a
    // precise error instead of a confusing parse failure.
    if (finishReason === FinishReason.MAX_TOKENS) {
      logger.error("Gemini response truncated at output token limit", {
        finishReason,
        maxOutputTokens: MAX_OUTPUT_TOKENS,
      });
      throw new Error(
        "Gemini response truncated (MAX_TOKENS): document text exceeds " +
        "the output limit. Consider chunked OCR for this document.",
      );
    }

    // Concatenate all text parts; structured output may split content.
    const responseText = (candidate?.content?.parts ?? [])
      .map((part) => part.text ?? "")
      .join("")
      .trim();

    if (!responseText) {
      logger.error("Empty Gemini response", {
        finishReason: finishReason ?? null,
        candidateCount: result.response.candidates?.length ?? 0,
      });
      throw new Error("Invalid Gemini response: empty response text.");
    }

    return parseGeminiJsonResponse(responseText);
  }
}

/**
 * Parses the Gemini JSON response into an OcrExtractionResult,
 * tolerating markdown fences and logging diagnostics on failure.
 * @param {string} responseText Raw response text from Gemini.
 * @return {OcrExtractionResult} Validated extraction result.
 */
function parseGeminiJsonResponse(
  responseText: string,
): OcrExtractionResult {
  // Structured output should never be fenced, but tolerate it anyway.
  const fencedMatch = responseText.match(/```(?:json)?\s*([\s\S]*?)```/i);
  let jsonString = (fencedMatch ? fencedMatch[1] : responseText).trim();

  // Trim any stray prose before/after the outermost JSON object.
  const firstBrace = jsonString.indexOf("{");
  const lastBrace = jsonString.lastIndexOf("}");
  if (firstBrace > 0 || (lastBrace !== -1 && lastBrace < jsonString.length - 1)) {
    if (firstBrace !== -1 && lastBrace > firstBrace) {
      jsonString = jsonString.slice(firstBrace, lastBrace + 1);
    }
  }

  let parsed: unknown;
  try {
    parsed = JSON.parse(jsonString);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    logger.error("Failed JSON Parse", {
      parseError: message,
      jsonLength: jsonString.length,
    });
    throw new Error("Gemini returned malformed JSON");
  }

  if (typeof parsed !== "object" || parsed === null) {
    logger.error("Gemini response is not a JSON object", {
      parsedType: typeof parsed,
      jsonLength: jsonString.length,
    });
    throw new Error("Invalid Gemini response: expected JSON object.");
  }

  const record = parsed as Record<string, unknown>;
  const extractedText = record.extractedText;
  const summary = record.summary;

  if (typeof extractedText !== "string" || typeof summary !== "string") {
    logger.error("Gemini response missing required fields", {
      hasExtractedText: typeof extractedText,
      hasSummary: typeof summary,
      keys: Object.keys(record),
    });
    throw new Error(
      "Invalid Gemini response: extractedText and summary are required.",
    );
  }

  return {
    extractedText,
    summary,
  };
}
