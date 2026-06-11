import * as admin from "firebase-admin";
import {Firestore} from "firebase-admin/firestore";
import {CriticalFinding} from "./medical/medical_analysis_provider";

export interface AnalyzedOcrRecord {
  documentId: string;
  ocrProvider: string;
  ocrConfidence?: number;
  pageCount?: number;
  documentType: string;
  ocrTextPath: string;
  ocrCharacterCount: number;
  summary: string;
  criticalFindings: CriticalFinding[];
  normalFindings: string[];
  recommendedFollowUp: string[];
  handwritingDetected?: boolean;
  extractionWarning?: string;
}

/**
 * Persists OCR results to the Firestore `ocr_results` collection.
 * Supports both the legacy v1 record shape and the analyzed v2 shape.
 */
export class OcrResultStore {
  /**
   * @param {Firestore} firestore Firestore instance.
   */
  constructor(private readonly firestore: Firestore) {}

  /**
   * Saves a legacy (v1) OCR result. Kept unchanged for backward
   * compatibility with the Gemini OCR pipeline.
   * @param {string} documentId Document identifier.
   * @param {string} extractedText Full extracted text.
   * @param {string} summary AI-generated summary.
   * @return {Promise<void>} Resolves when saved.
   */
  async saveResult(
    documentId: string,
    extractedText: string,
    summary: string,
  ): Promise<void> {
    await this.firestore
      .collection("ocr_results")
      .doc(documentId)
      .set({
        documentId,
        extractedText,
        summary,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
  }

  /**
   * Saves an analyzed (v2) OCR result. Full OCR text lives in Storage
   * (`ocrTextPath`); Firestore holds metadata and analysis fields.
   * v1 clients resolve text via `ocrTextPath` or legacy `extractedText`.
   * @param {AnalyzedOcrRecord} record Analyzed OCR record.
   * @return {Promise<void>} Resolves when saved.
   */
  async saveAnalyzedResult(record: AnalyzedOcrRecord): Promise<void> {
    // Storage-text safety: v2 records must reference OCR text in
    // Storage and must never inline the full extracted text in
    // Firestore (which would risk the 1 MiB document limit).
    if (!record.ocrTextPath || record.ocrTextPath.trim().length === 0) {
      throw new Error(
        "Refusing to save analyzed OCR result without ocrTextPath. " +
        "OCR text must be persisted to Storage first.",
      );
    }
    if (
      typeof record.ocrCharacterCount !== "number" ||
      !Number.isFinite(record.ocrCharacterCount) ||
      record.ocrCharacterCount < 0
    ) {
      throw new Error(
        "Refusing to save analyzed OCR result with invalid " +
        "ocrCharacterCount.",
      );
    }

    const document: Record<string, unknown> = {
      documentId: record.documentId,
      ocrProvider: record.ocrProvider,
      documentType: record.documentType,
      ocrTextPath: record.ocrTextPath,
      ocrCharacterCount: record.ocrCharacterCount,
      summary: record.summary,
      criticalFindings: record.criticalFindings,
      normalFindings: record.normalFindings,
      recommendedFollowUp: record.recommendedFollowUp,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      processingVersion: 2,
    };

    if (record.ocrConfidence !== undefined) {
      document.ocrConfidence = record.ocrConfidence;
    }
    if (record.pageCount !== undefined) {
      document.pageCount = record.pageCount;
    }
    if (record.handwritingDetected !== undefined) {
      document.handwritingDetected = record.handwritingDetected;
    }
    if (record.extractionWarning !== undefined) {
      document.extractionWarning = record.extractionWarning;
    }

    await this.firestore
      .collection("ocr_results")
      .doc(record.documentId)
      .set(document);
  }
}
