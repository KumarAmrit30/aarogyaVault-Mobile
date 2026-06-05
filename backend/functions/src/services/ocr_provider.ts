import {OcrExtractionResult} from "../models/ocr_result";

export interface OcrProvider {
  extractText(
    filePath: string,
  ): Promise<OcrExtractionResult>;
}
