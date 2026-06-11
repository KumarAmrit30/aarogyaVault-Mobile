import {
  GeminiClient,
  GeminiGenerateRequest,
  GeminiGenerateResponse,
} from "./gemini_client";

/**
 * Placeholder {@link GeminiClient} for the future unified Google GenAI
 * SDK (`@google/genai`). Not yet implemented — exists to lock in the
 * adapter seam so the migration is a drop-in replacement.
 */
export class GenAiGeminiClient implements GeminiClient {
  /**
   * @param {GeminiGenerateRequest} request Generation request.
   * @return {Promise<GeminiGenerateResponse>} Never resolves.
   */
  async generateContent(
    request: GeminiGenerateRequest,
  ): Promise<GeminiGenerateResponse> {
    void request;
    throw new Error(
      "GenAiGeminiClient is not implemented yet. Use VertexGeminiClient " +
      "until the @google/genai migration is completed.",
    );
  }
}
