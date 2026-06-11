export interface OcrResult {
  text: string;
  confidence?: number;
  pageCount?: number;
  handwritingDetected?: boolean;
}
