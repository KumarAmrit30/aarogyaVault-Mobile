import {DocumentProcessorServiceClient} from "@google-cloud/documentai";
import {DocumentAiConfig} from "../../config/document_ai_config";

/**
 * API processor type for Enterprise Document OCR.
 *
 * NOTE: Google Document AI returns `type = "OCR_PROCESSOR"` for the
 * Enterprise Document OCR processor. The string "ENTERPRISE_DOCUMENT_OCR"
 * does NOT appear in the API response — do not validate against it.
 */
export const OCR_PROCESSOR_TYPE = "OCR_PROCESSOR";

/** Processor state value (string or enum number) meaning enabled. */
const ENABLED_STATE_STRING = "ENABLED";
const ENABLED_STATE_NUMBER = 1;

/**
 * Verifies the configured processor is a usable OCR processor.
 *
 * Checks, in order:
 *   1. The processor exists (getProcessor succeeds).
 *   2. The processor state is ENABLED.
 *   3. The processor type is OCR_PROCESSOR (Enterprise Document OCR).
 *
 * Throws a descriptive error otherwise so a misconfigured processor
 * cannot silently deploy.
 * @param {DocumentAiConfig} config Validated Document AI configuration.
 * @param {DocumentProcessorServiceClient} client Optional client override
 *   for testing.
 * @return {Promise<void>} Resolves when the processor is valid.
 */
export async function validateOcrProcessor(
  config: DocumentAiConfig,
  client?: DocumentProcessorServiceClient,
): Promise<void> {
  const docAiClient = client ?? new DocumentProcessorServiceClient({
    apiEndpoint: `${config.location}-documentai.googleapis.com`,
  });

  const processorName =
    `projects/${config.projectId}` +
    `/locations/${config.location}` +
    `/processors/${config.processorId}`;

  let processor;
  try {
    [processor] = await docAiClient.getProcessor({name: processorName});
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    throw new Error(
      `Document AI processor not found or inaccessible: ${processorName}. ` +
      `Underlying error: ${message}`,
    );
  }

  if (!processor) {
    throw new Error(
      `Document AI processor not found: ${processorName}.`,
    );
  }

  if (!isEnabled(processor.state)) {
    throw new Error(
      "Document AI processor is not ENABLED. " +
      `Received state: ${String(processor.state ?? "unknown")}. ` +
      "Enable the processor in the Document AI console before deploying.",
    );
  }

  const receivedType = processor.type ?? "unknown";
  if (receivedType !== OCR_PROCESSOR_TYPE) {
    throw new Error(
      `Expected ${OCR_PROCESSOR_TYPE}. ` +
      `Received: ${receivedType}. ` +
      "Use an Enterprise Document OCR processor (API type OCR_PROCESSOR), " +
      "not a Form Parser, Layout Parser, Invoice, or other processor.",
    );
  }
}

/**
 * Returns true when the processor state represents ENABLED, tolerating
 * both the string ("ENABLED") and enum-number (1) representations the
 * SDK may return depending on transport.
 * @param {unknown} state Processor state from the API.
 * @return {boolean} Whether the processor is enabled.
 */
function isEnabled(state: unknown): boolean {
  return state === ENABLED_STATE_STRING || state === ENABLED_STATE_NUMBER;
}

/**
 * Backward-compatible alias. Prefer {@link validateOcrProcessor}.
 * @param {DocumentAiConfig} config Validated Document AI configuration.
 * @param {DocumentProcessorServiceClient} client Optional client override.
 * @return {Promise<void>} Resolves when the processor is valid.
 */
export async function validateEnterpriseOcrProcessor(
  config: DocumentAiConfig,
  client?: DocumentProcessorServiceClient,
): Promise<void> {
  return validateOcrProcessor(config, client);
}
