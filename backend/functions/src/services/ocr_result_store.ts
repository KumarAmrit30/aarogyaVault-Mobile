import * as admin from "firebase-admin";
import {Firestore} from "firebase-admin/firestore";

export class OcrResultStore {
  constructor(private readonly firestore: Firestore) {}

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
}
