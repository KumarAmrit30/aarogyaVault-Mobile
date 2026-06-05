import {GoogleGenAI} from "@google/genai";
import {promises as fs} from "fs";
import * as path from "path";
import {OcrExtractionResult} from "../models/ocr_result";
import {OcrProvider} from "./ocr_provider";

const OCR_PROMPT = `You are an OCR engine for medical documents.

Extract all visible text exactly as written.

Then create a concise medical summary.

Return ONLY valid JSON:

{
  "extractedText": "...",
  "summary": "..."
}`;

const MIME_TYPES: Record<string, string> = {
  pdf: "application/pdf",
  jpg: "image/jpeg",
  jpeg: "image/jpeg",
  png: "image/png",
};

export class GeminiOcrProvider implements OcrProvider {
  constructor() {}

  async extractText(
    filePath: string,
  ): Promise<OcrExtractionResult> {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      throw new Error("GEMINI_API_KEY is not configured.");
    }

    const extension = path.extname(filePath).slice(1).toLowerCase();
    const mimeType = MIME_TYPES[extension];
    if (!mimeType) {
      throw new Error(`Unsupported file type: ${extension || "unknown"}`);
    }

    const fileBuffer = await fs.readFile(filePath);
    const fileBase64 = fileBuffer.toString("base64");

    const client = new GoogleGenAI({apiKey});

    const response = await client.models.generateContent({
      model: "gemini-2.5-flash",
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

    const responseText = response.text?.trim();
    if (!responseText) {
      throw new Error("Invalid Gemini response: empty response text.");
    }

    return parseGeminiJsonResponse(responseText);
  }
}

function parseGeminiJsonResponse(
  responseText: string,
): OcrExtractionResult {
  const fencedMatch = responseText.match(/```(?:json)?\s*([\s\S]*?)```/i);
  const jsonString = fencedMatch ? fencedMatch[1].trim() : responseText;

  let parsed: unknown;
  try {
    parsed = JSON.parse(jsonString);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    throw new Error(
      `Failed to parse Gemini JSON response: ${message}`,
    );
  }

  if (typeof parsed !== "object" || parsed === null) {
    throw new Error("Invalid Gemini response: expected JSON object.");
  }

  const record = parsed as Record<string, unknown>;
  const extractedText = record.extractedText;
  const summary = record.summary;

  if (typeof extractedText !== "string" || typeof summary !== "string") {
    throw new Error(
      "Invalid Gemini response: extractedText and summary are required.",
    );
  }

  return {
    extractedText,
    summary,
  };
}
