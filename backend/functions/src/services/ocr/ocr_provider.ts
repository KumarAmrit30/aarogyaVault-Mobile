import {OcrResult} from "./types";

export interface OcrProvider {
  extractText(
    fileBuffer: Buffer,
    mimeType: string,
  ): Promise<OcrResult>;
}
