import {DocumentMetadata} from "../models/document_metadata";

const STORAGE_PATH_PATTERN =
  /^documents\/([^/]+)\/([^/.]+)\.([^.]+)$/;

export function parseStoragePath(path: string): DocumentMetadata | null {
  const match = STORAGE_PATH_PATTERN.exec(path);
  if (!match) {
    return null;
  }

  const ownerId = match[1];
  const documentId = match[2];
  const extension = match[3];

  if (!ownerId || !documentId || !extension) {
    return null;
  }

  return {
    ownerId,
    documentId,
    storagePath: path,
  };
}
