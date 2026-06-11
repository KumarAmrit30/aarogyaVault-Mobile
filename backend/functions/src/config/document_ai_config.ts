export interface DocumentAiConfig {
  projectId: string;
  location: string;
  processorId: string;
}

/**
 * Returns true when the Document AI OCR pipeline is enabled via the
 * USE_DOCUMENT_AI_OCR feature flag. Defaults to false (legacy Gemini
 * OCR path) so rollback requires no code change.
 * @return {boolean} Whether Document AI OCR is enabled.
 */
export function isDocumentAiOcrEnabled(): boolean {
  return process.env.USE_DOCUMENT_AI_OCR === "true";
}

/**
 * Loads and validates Document AI configuration from the environment.
 * Only throws for missing variables when Document AI mode is enabled.
 * @return {DocumentAiConfig} Validated Document AI configuration.
 */
export function getDocumentAiConfig(): DocumentAiConfig {
  if (!isDocumentAiOcrEnabled()) {
    throw new Error(
      "Document AI OCR is disabled (USE_DOCUMENT_AI_OCR is not \"true\"). " +
      "Enable the flag before requesting Document AI configuration.",
    );
  }
  return readDocumentAiConfig();
}

/**
 * Alias for {@link getDocumentAiConfig}.
 * @return {DocumentAiConfig} Validated Document AI configuration.
 */
export function loadDocumentAiConfig(): DocumentAiConfig {
  return readDocumentAiConfig();
}

/**
 * Reads Document AI env vars and throws descriptive errors for any
 * that are missing. Intended for callers on the Document AI code path.
 * @return {DocumentAiConfig} Validated Document AI configuration.
 */
function readDocumentAiConfig(): DocumentAiConfig {
  const projectId = process.env.DOCUMENT_AI_PROJECT_ID;
  if (!projectId) {
    throw new Error(
      "DOCUMENT_AI_PROJECT_ID is not configured. Set it in the " +
      "functions environment (.env) before enabling Document AI OCR.",
    );
  }

  const location = process.env.DOCUMENT_AI_LOCATION;
  if (!location) {
    throw new Error(
      "DOCUMENT_AI_LOCATION is not configured. Set it in the " +
      "functions environment (.env), e.g. \"us\" or \"eu\".",
    );
  }

  const processorId = process.env.DOCUMENT_AI_PROCESSOR_ID;
  if (!processorId) {
    throw new Error(
      "DOCUMENT_AI_PROCESSOR_ID is not configured. Create an Enterprise " +
      "Document OCR processor in the Document AI console and set its ID " +
      "in the functions environment (.env).",
    );
  }

  return {projectId, location, processorId};
}
