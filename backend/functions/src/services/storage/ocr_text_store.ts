import {Storage} from "@google-cloud/storage";

export interface SavedOcrText {
  ocrTextPath: string;
  ocrCharacterCount: number;
}

/**
 * Stores and retrieves full OCR text in Firebase Storage so large
 * extractions do not inflate Firestore documents (1 MiB limit).
 */
export class OcrTextStore {
  /**
   * @param {Storage} storage Google Cloud Storage client.
   */
  constructor(private readonly storage: Storage) {}

  /**
   * Builds the canonical storage path for a document's OCR text.
   * @param {string} documentId Document identifier.
   * @return {string} Storage object path.
   */
  static buildStoragePath(documentId: string): string {
    return `ocr-results/${documentId}/full_text.txt`;
  }

  /**
   * Resolves the default Firebase Storage bucket from environment.
   * @return {string} Storage bucket name.
   */
  private getDefaultBucketName(): string {
    if (process.env.FIREBASE_CONFIG) {
      const config = JSON.parse(process.env.FIREBASE_CONFIG) as {
        storageBucket?: string;
      };
      if (config.storageBucket) {
        return config.storageBucket;
      }
    }

    if (process.env.GCLOUD_PROJECT) {
      return `${process.env.GCLOUD_PROJECT}.appspot.com`;
    }

    throw new Error("Unable to resolve default storage bucket.");
  }

  /**
   * Persists OCR text to Storage and returns metadata for Firestore.
   * @param {string} documentId Document identifier.
   * @param {string} text Full OCR-extracted text.
   * @return {Promise<SavedOcrText>} Storage path and character count.
   */
  async saveText(
    documentId: string,
    text: string,
  ): Promise<SavedOcrText> {
    const ocrTextPath = OcrTextStore.buildStoragePath(documentId);
    const bucket = this.storage.bucket(this.getDefaultBucketName());
    const file = bucket.file(ocrTextPath);

    await file.save(text, {
      contentType: "text/plain; charset=utf-8",
      metadata: {
        documentId,
        purpose: "ocr_full_text",
      },
      resumable: false,
    });

    return {
      ocrTextPath,
      ocrCharacterCount: text.length,
    };
  }

  /**
   * Loads OCR text using the canonical path for a document.
   * @param {string} documentId Document identifier.
   * @return {Promise<string>} Full OCR text.
   */
  async loadText(documentId: string): Promise<string> {
    return this.loadTextFromPath(OcrTextStore.buildStoragePath(documentId));
  }

  /**
   * Loads OCR text from an explicit storage path (v2 records store the
   * path in Firestore as `ocrTextPath`).
   * @param {string} storagePath Storage object path.
   * @return {Promise<string>} Full OCR text.
   */
  async loadTextFromPath(storagePath: string): Promise<string> {
    const bucket = this.storage.bucket(this.getDefaultBucketName());
    const file = bucket.file(storagePath);
    const [exists] = await file.exists();

    if (!exists) {
      throw new Error(`OCR text not found in storage: ${storagePath}`);
    }

    const [buffer] = await file.download();
    return buffer.toString("utf-8");
  }
}
