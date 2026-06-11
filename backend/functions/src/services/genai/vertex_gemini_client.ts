import {GenerationConfig, VertexAI} from "@google-cloud/vertexai";
import {
  GeminiClient,
  GeminiGenerateRequest,
  GeminiGenerateResponse,
} from "./gemini_client";

export interface VertexGeminiClientOptions {
  project: string;
  location: string;
}

/**
 * {@link GeminiClient} backed by the Vertex AI SDK.
 *
 * Architecture-prep only: existing providers still call the Vertex SDK
 * directly. This client is the seam through which they will route once
 * the migration to the unified GenAI SDK begins.
 */
export class VertexGeminiClient implements GeminiClient {
  private readonly vertexAI: VertexAI;

  /**
   * @param {VertexGeminiClientOptions} options Project and location.
   */
  constructor(options: VertexGeminiClientOptions) {
    this.vertexAI = new VertexAI({
      project: options.project,
      location: options.location,
    });
  }

  /**
   * Generates content using the configured Vertex model.
   * @param {GeminiGenerateRequest} request Generation request.
   * @return {Promise<GeminiGenerateResponse>} Response text + finish.
   */
  async generateContent(
    request: GeminiGenerateRequest,
  ): Promise<GeminiGenerateResponse> {
    const model = this.vertexAI.getGenerativeModel({
      model: request.model,
      generationConfig: request.generationConfig as GenerationConfig,
    });

    const result = await model.generateContent({
      contents: [
        {
          role: "user",
          parts: request.parts,
        },
      ],
    });

    const candidate = result.response.candidates?.[0];
    const text = (candidate?.content?.parts ?? [])
      .map((part) => part.text ?? "")
      .join("")
      .trim();

    return {
      text,
      finishReason: candidate?.finishReason ?
        String(candidate.finishReason) :
        undefined,
    };
  }
}
