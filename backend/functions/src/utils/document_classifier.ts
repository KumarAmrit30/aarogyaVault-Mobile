export type DocumentCategory =
  | "lab_report"
  | "prescription"
  | "discharge_summary"
  | "invoice"
  | "other";

const LAB_PATTERNS = [
  /^lab(?:oratory)?\s*report$/i,
  /^laboratory\s*report$/i,
  /^blood\s*test\s*report$/i,
  /lab|pathology|blood test|diagnostic|radiology|scan/i,
];

const PRESCRIPTION_PATTERNS = [
  /^prescription$/i,
  /^doctor\s*prescription$/i,
  /^rx$/i,
  /prescri|medication list/i,
];

const DISCHARGE_PATTERNS = [
  /^discharge\s*summary$/i,
  /discharge/i,
];

const INVOICE_PATTERNS = [
  /^invoice$/i,
  /^medical\s*invoice$/i,
  /^bill$/i,
  /receipt|payment/i,
];

/**
 * Maps a free-form document type label (from Gemini analysis) to a
 * canonical document category used for downstream logic.
 * @param {string} documentType Free-form document type label.
 * @return {DocumentCategory} Canonical document category.
 */
export function classifyDocumentType(
  documentType: string,
): DocumentCategory {
  const normalized = documentType.trim();
  if (!normalized) {
    return "other";
  }

  if (matchesAny(normalized, PRESCRIPTION_PATTERNS)) {
    return "prescription";
  }
  if (matchesAny(normalized, DISCHARGE_PATTERNS)) {
    return "discharge_summary";
  }
  if (matchesAny(normalized, LAB_PATTERNS)) {
    return "lab_report";
  }
  if (matchesAny(normalized, INVOICE_PATTERNS)) {
    return "invoice";
  }

  return "other";
}

/**
 * Returns true when any pattern matches the document type label.
 * @param {string} value Document type label.
 * @param {RegExp[]} patterns Patterns to test.
 * @return {boolean} Whether a pattern matched.
 */
function matchesAny(value: string, patterns: RegExp[]): boolean {
  return patterns.some((pattern) => pattern.test(value));
}
