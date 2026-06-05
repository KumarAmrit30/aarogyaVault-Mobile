import {Storage} from "@google-cloud/storage";
import {onObjectFinalized} from "firebase-functions/v2/storage";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {DocumentDownloadService} from "../services/document_download_service";
import {GeminiOcrProvider} from "../services/gemini_ocr_provider";
import {OcrResultStore} from "../services/ocr_result_store";
import {parseStoragePath} from "../utils/storage_path_parser";

const MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024;
const ALLOWED_CONTENT_TYPES = new Set([
  "application/pdf",
  "image/jpeg",
  "image/png",
]);

const storage = new Storage();
const downloadService = new DocumentDownloadService(storage);
const ocrProvider = new GeminiOcrProvider();
const ocrStore = new OcrResultStore(admin.firestore());

export const onDocumentUploaded = onObjectFinalized(
  {
    secrets: ["GEMINI_API_KEY"],
  },
  async (event) => {
    const storagePath = event.data.name;

    if (!storagePath) {
      logger.warn("Document upload ignored: missing storage object name");
      return;
    }

    const metadata = parseStoragePath(storagePath);
    if (!metadata) {
      logger.warn("Document upload ignored: invalid storage path", {storagePath});
      return;
    }

    metadata.contentType = event.data.contentType;

    const contentType = event.data.contentType;
    if (!contentType || !ALLOWED_CONTENT_TYPES.has(contentType)) {
      logger.warn("Unsupported document type", {
        documentId: metadata.documentId,
        contentType: contentType ?? null,
      });
      return;
    }

    const sizeBytes = event.data.size ? Number(event.data.size) : 0;
    if (sizeBytes > MAX_FILE_SIZE_BYTES) {
      logger.warn("Document exceeds size limit", {
        documentId: metadata.documentId,
        sizeBytes,
      });
      return;
    }
    if (sizeBytes <= 0) {
      logger.warn("Missing file size", {
        documentId: metadata.documentId,
      });
      return;
    }

    const existingOcrResult = await admin.firestore()
      .collection("ocr_results")
      .doc(metadata.documentId)
      .get();

    if (existingOcrResult.exists) {
      logger.info("OCR already exists. Skipping.", {
        documentId: metadata.documentId,
      });
      return;
    }

    try {
      logger.info("OCR processing started", {
        documentId: metadata.documentId,
      });

      const downloadedDocument = await downloadService.download(
        metadata.storagePath,
      );

      const result = await ocrProvider.extractText(
        downloadedDocument.localPath,
      );

      await ocrStore.saveResult(
        metadata.documentId,
        result.extractedText,
        result.summary,
      );

      logger.info("OCR processing completed", {
        documentId: metadata.documentId,
      });
    } catch (error) {
      logger.error("OCR processing failed", {
        documentId: metadata.documentId,
        error,
      });
      throw error;
    }
  },
);
