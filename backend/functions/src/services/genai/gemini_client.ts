/**
 * Vendor-neutral abstraction over a Gemini generative model.
 *
 * This adapter layer decouples our medical-analysis / OCR code from the
 * concrete SDK (currently Vertex AI). It exists to prepare for a future
 * migration to the unified Google GenAI SDK without behavior changes.
 */

export interface GeminiGenerationConfig {
  responseMimeType?: string;
  responseSchema?: unknown;
  maxOutputTokens?: number;
  temperature?: number;
}

export interface GeminiTextPart {
  text: string;
}

export interface GeminiInlineDataPart {
  inlineData: {
    mimeType: string;
    data: string;
  };
}

export type GeminiPart = GeminiTextPart | GeminiInlineDataPart;

export interface GeminiGenerateRequest {
  model: string;
  parts: GeminiPart[];
  generationConfig?: GeminiGenerationConfig;
}

export interface GeminiGenerateResponse {
  /** Concatenated text of all response parts. */
  text: string;
  /** Raw finish reason string, if reported. */
  finishReason?: string;
}

/**
 * Minimal client contract for generating content from Gemini.
 */
export interface GeminiClient {
  generateContent(
    request: GeminiGenerateRequest,
  ): Promise<GeminiGenerateResponse>;
}
