import {OcrTextStore} from "../storage/ocr_text_store";

/**
 * Returns true when the record stores OCR text in Storage (v2) rather
 * than inline in Firestore (v1).
 * @param {Record<string, unknown>} record Firestore OCR result data.
 * @return {boolean} Whether the record is storage-backed.
 */
export function isStorageBackedOcrRecord(
  record: Record<string, unknown>,
): boolean {
  return typeof record.ocrTextPath === "string";
}

/**
 * Returns true when the record has inline extracted text (v1).
 * @param {Record<string, unknown>} record Firestore OCR result data.
 * @return {boolean} Whether extractedText is present inline.
 */
export function hasInlineExtractedText(
  record: Record<string, unknown>,
): boolean {
  return typeof record.extractedText === "string";
}

/**
 * Resolves full OCR text from either a v1 inline field or a v2 Storage
 * path. Returns null when neither source is available.
 * @param {Record<string, unknown>} record Firestore OCR result data.
 * @param {OcrTextStore} textStore Storage client for v2 text retrieval.
 * @return {Promise<string | null>} Resolved OCR text, if available.
 */
export async function resolveOcrText(
  record: Record<string, unknown>,
  textStore: OcrTextStore,
): Promise<string | null> {
  if (hasInlineExtractedText(record)) {
    return record.extractedText as string;
  }

  const ocrTextPath = record.ocrTextPath;
  if (typeof ocrTextPath === "string") {
    return textStore.loadTextFromPath(ocrTextPath);
  }

  return null;
}
