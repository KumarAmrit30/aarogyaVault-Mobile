import {Storage} from "@google-cloud/storage";
import * as os from "os";
import * as path from "path";

export interface DownloadedDocument {
  localPath: string;
  fileName: string;
}

export class DocumentDownloadService {
  constructor(private readonly storage: Storage) {}

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

  async download(storagePath: string): Promise<DownloadedDocument> {
    const fileName = path.basename(storagePath);
    const localPath = path.join(os.tmpdir(), fileName);

    try {
      const bucket = this.storage.bucket(this.getDefaultBucketName());
      const file = bucket.file(storagePath);
      const [exists] = await file.exists();

      if (!exists) {
        throw new Error(`Storage object not found: ${storagePath}`);
      }

      await file.download({destination: localPath});

      return {
        localPath,
        fileName,
      };
    } catch (error) {
      if (error instanceof Error && error.message.startsWith("Storage object not found")) {
        throw error;
      }

      const message = error instanceof Error ? error.message : String(error);
      throw new Error(
        `Failed to download storage object '${storagePath}': ${message}`,
      );
    }
  }
}
