import {
  FinishReason,
  SchemaType,
  VertexAI,
} from "@google-cloud/vertexai";
import * as logger from "firebase-functions/logger";
import {jsonrepair} from "jsonrepair";

export type FindingStatus =
  | "high"
  | "low"
  | "abnormal"
  | "positive"
  | "negative";

export interface CriticalFinding {
  title: string;
  status: FindingStatus;
  value?: string;
}

export interface MedicalAnalysisResult {
  documentType: string;
  summary: string;
  criticalFindings: CriticalFinding[];
  normalFindings: string[];
  recommendedFollowUp: string[];
}

const VERTEX_PROJECT_ID = "aarogya-vault-dev";
const VERTEX_LOCATION = "asia-south1";
const GEMINI_MODEL = "gemini-2.5-flash";
const MAX_OUTPUT_TOKENS = 8192;

export const MEDICAL_DISCLAIMER =
  "This AI-generated summary is for informational purposes only and is " +
  "not medical advice. Please consult a qualified healthcare professional.";

const FINDING_STATUSES: ReadonlySet<string> = new Set([
  "high",
  "low",
  "abnormal",
  "positive",
  "negative",
]);

const ANALYSIS_PROMPT = `You are a medical report assistant.

Analyze the OCR text extracted from a medical document.

Tasks:

1. Identify document type.
2. Generate a patient-friendly summary.
3. Highlight clinically significant findings in criticalFindings.
4. List important normal findings as plain strings in normalFindings.
5. Suggest follow-up actions in recommendedFollowUp.
6. Do not diagnose.
7. Do not prescribe treatment.
8. Explain abnormal findings in plain language.
9. Produce structured JSON matching the provided schema only.

The summary must be understandable by a non-medical person.
Do not include any disclaimer in the summary field.`;

const CRITICAL_FINDING_SCHEMA = {
  type: SchemaType.OBJECT,
  properties: {
    title: {type: SchemaType.STRING},
    status: {
      type: SchemaType.STRING,
      enum: ["high", "low", "abnormal", "positive", "negative"],
    },
    value: {type: SchemaType.STRING},
  },
  required: ["title", "status"],
};

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
        documentType: {type: SchemaType.STRING},
        summary: {type: SchemaType.STRING},
        criticalFindings: {
          type: SchemaType.ARRAY,
          items: CRITICAL_FINDING_SCHEMA,
        },
        normalFindings: {
          type: SchemaType.ARRAY,
          items: {type: SchemaType.STRING},
        },
        recommendedFollowUp: {
          type: SchemaType.ARRAY,
          items: {type: SchemaType.STRING},
        },
      },
      required: [
        "documentType",
        "summary",
        "criticalFindings",
        "normalFindings",
        "recommendedFollowUp",
      ],
    },
    maxOutputTokens: MAX_OUTPUT_TOKENS,
    temperature: 0,
  },
});

/**
 * Analyzes OCR-extracted medical text with Gemini and returns
 * structured, patient-friendly medical insights.
 */
export class MedicalAnalysisProvider {
  /**
   * Runs medical analysis on extracted document text.
   * @param {string} extractedText OCR text of the medical document.
   * @return {Promise<MedicalAnalysisResult>} Structured insights.
   */
  async analyze(
    extractedText: string,
  ): Promise<MedicalAnalysisResult> {
    const firstResponse = await this.generate(extractedText);
    try {
      return parseMedicalAnalysisResponse(firstResponse);
    } catch (firstError) {
      const message = firstError instanceof Error ?
        firstError.message :
        String(firstError);
      logger.warn("Medical analysis parse failed; retrying Gemini once", {
        reason: message,
      });

      const retryResponse = await this.generate(extractedText);
      // Let the second failure propagate — parsing is exhausted.
      return parseMedicalAnalysisResponse(retryResponse);
    }
  }

  /**
   * Calls Gemini and returns the raw response text. Throws on
   * truncation or empty output.
   * @param {string} extractedText OCR text of the medical document.
   * @return {Promise<string>} Raw model response text.
   */
  private async generate(extractedText: string): Promise<string> {
    const result = await generativeModel.generateContent({
      contents: [
        {
          role: "user",
          parts: [
            {text: ANALYSIS_PROMPT},
            {text: `OCR text:\n\n${extractedText}`},
          ],
        },
      ],
    });

    const candidate = result.response.candidates?.[0];
    const finishReason = candidate?.finishReason;

    if (finishReason === FinishReason.MAX_TOKENS) {
      logger.error("Medical analysis truncated at output token limit", {
        finishReason,
        maxOutputTokens: MAX_OUTPUT_TOKENS,
      });
      throw new Error("Medical analysis truncated (MAX_TOKENS).");
    }

    const responseText = (candidate?.content?.parts ?? [])
      .map((part) => part.text ?? "")
      .join("")
      .trim();

    if (!responseText) {
      logger.error("Empty medical analysis response", {
        finishReason: finishReason ?? null,
      });
      throw new Error(
        "Invalid medical analysis response: empty response text.",
      );
    }

    return responseText;
  }
}

/**
 * Robustly parses a JSON value from a model response using a layered
 * strategy. Exported for unit testing.
 *
 *   1. JSON.parse on the raw text.
 *   2. Extract the outermost JSON object (drop fences/prose) and parse.
 *   3. Repair with the jsonrepair library and parse.
 *
 * Throws a descriptive error only when all strategies fail. (A single
 * Gemini retry is layered on top of this in {@link MedicalAnalysisProvider}.)
 * @param {string} responseText Raw response text.
 * @return {unknown} Parsed JSON value.
 */
export function repairAndParseJson(responseText: string): unknown {
  // Strategy 1: parse the raw text directly.
  try {
    return JSON.parse(responseText);
  } catch {
    // Fall through to extraction.
  }

  // Strategy 2: extract the outermost JSON object (strip fences/prose).
  const extracted = extractJsonBlock(responseText);
  if (extracted) {
    try {
      return JSON.parse(extracted);
    } catch {
      // Fall through to repair.
    }
  }

  // Strategy 3: repair with jsonrepair.
  const candidate = extracted ?? responseText;
  try {
    return JSON.parse(jsonrepair(candidate));
  } catch (repairError) {
    const repairMessage = repairError instanceof Error ?
      repairError.message :
      String(repairError);
    logger.error("Failed to repair medical analysis JSON", {
      repairError: repairMessage,
      responseLength: responseText.length,
    });
    throw new Error("Gemini returned malformed medical analysis JSON");
  }
}

/**
 * Extracts the outermost JSON object from text, removing markdown
 * fences and surrounding prose. Returns null when no object is found.
 * @param {string} text Raw response text.
 * @return {string | null} Extracted JSON object string, if any.
 */
function extractJsonBlock(text: string): string | null {
  const fencedMatch = text.match(/```(?:json)?\s*([\s\S]*?)```/i);
  const source = (fencedMatch ? fencedMatch[1] : text).trim();

  const firstBrace = source.indexOf("{");
  const lastBrace = source.lastIndexOf("}");
  if (firstBrace !== -1 && lastBrace > firstBrace) {
    return source.slice(firstBrace, lastBrace + 1);
  }
  return null;
}

/**
 * Parses and validates the Gemini medical analysis JSON response.
 * @param {string} responseText Raw JSON response text.
 * @return {MedicalAnalysisResult} Validated analysis result.
 */
export function parseMedicalAnalysisResponse(
  responseText: string,
): MedicalAnalysisResult {
  const parsed = repairAndParseJson(responseText);

  if (typeof parsed !== "object" || parsed === null) {
    throw new Error(
      "Invalid medical analysis response: expected JSON object.",
    );
  }

  const record = parsed as Record<string, unknown>;
  const documentType = record.documentType;
  const summary = record.summary;

  if (typeof documentType !== "string" || typeof summary !== "string") {
    logger.error("Medical analysis response missing required fields", {
      keys: Object.keys(record),
    });
    throw new Error(
      "Invalid medical analysis response: documentType and summary " +
      "are required.",
    );
  }

  return {
    documentType,
    summary: appendDisclaimer(summary),
    criticalFindings: parseCriticalFindings(record.criticalFindings),
    normalFindings: parseStringArray(record.normalFindings),
    recommendedFollowUp: parseStringArray(record.recommendedFollowUp),
  };
}

/**
 * Appends the medical disclaimer unless already present.
 * @param {string} summary Patient-friendly summary text.
 * @return {string} Summary ending with the disclaimer.
 */
function appendDisclaimer(summary: string): string {
  if (summary.includes(MEDICAL_DISCLAIMER)) {
    return summary;
  }
  return `${summary}\n\n${MEDICAL_DISCLAIMER}`;
}

/**
 * Parses critical findings, dropping malformed entries.
 * @param {unknown} value Candidate findings array.
 * @return {CriticalFinding[]} Validated findings.
 */
function parseCriticalFindings(value: unknown): CriticalFinding[] {
  if (!Array.isArray(value)) {
    return [];
  }

  const findings: CriticalFinding[] = [];
  for (const item of value) {
    if (typeof item !== "object" || item === null) {
      continue;
    }
    const finding = item as Record<string, unknown>;
    const title = finding.title;
    const rawStatus = finding.status;
    const findingValue = finding.value;

    if (typeof title !== "string" || typeof rawStatus !== "string") {
      logger.warn("Dropping malformed critical finding", {
        keys: Object.keys(finding),
      });
      continue;
    }

    let status = rawStatus.toLowerCase();
    if (!FINDING_STATUSES.has(status)) {
      logger.warn("Coercing unknown finding status to abnormal", {status});
      status = "abnormal";
    }

    const parsed: CriticalFinding = {
      title,
      status: status as FindingStatus,
    };
    if (typeof findingValue === "string" && findingValue.length > 0) {
      parsed.value = findingValue;
    }
    findings.push(parsed);
  }

  return findings;
}

/**
 * Parses an unknown value into a string array, dropping non-strings.
 * @param {unknown} value Candidate string array.
 * @return {string[]} Validated string array.
 */
function parseStringArray(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [];
  }
  return value.filter((item): item is string => typeof item === "string");
}
