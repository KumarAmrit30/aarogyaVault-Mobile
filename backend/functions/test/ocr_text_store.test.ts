import {OcrTextStore} from "../src/services/storage/ocr_text_store";

describe("OcrTextStore", () => {
  const documentId = "1781116388351";
  const sampleText = "Patient: John Doe\nHbA1c: 11.2%";

  let savedContent: string | undefined;
  let mockFile: {
    save: jest.Mock;
    exists: jest.Mock;
    download: jest.Mock;
  };
  let mockBucket: {file: jest.Mock};
  let store: OcrTextStore;

  beforeEach(() => {
    savedContent = undefined;
    mockFile = {
      save: jest.fn(async (content: string) => {
        savedContent = content;
      }),
      exists: jest.fn(async () => [true]),
      download: jest.fn(async () => [Buffer.from(savedContent ?? "", "utf-8")]),
    };
    mockBucket = {
      file: jest.fn(() => mockFile),
    };
    const mockStorage = {
      bucket: jest.fn(() => mockBucket),
    };
    store = new OcrTextStore(mockStorage as never);
    process.env.GCLOUD_PROJECT = "aarogya-vault-dev";
  });

  afterEach(() => {
    delete process.env.GCLOUD_PROJECT;
  });

  it("builds the canonical storage path", () => {
    expect(OcrTextStore.buildStoragePath(documentId))
      .toBe("ocr-results/1781116388351/full_text.txt");
  });

  it("saveText writes to Storage and returns metadata", async () => {
    const result = await store.saveText(documentId, sampleText);

    expect(result.ocrTextPath)
      .toBe("ocr-results/1781116388351/full_text.txt");
    expect(result.ocrCharacterCount).toBe(sampleText.length);
    expect(mockFile.save).toHaveBeenCalledWith(
      sampleText,
      expect.objectContaining({
        contentType: "text/plain; charset=utf-8",
      }),
    );
  });

  it("loadText reads from the canonical path", async () => {
    await store.saveText(documentId, sampleText);
    const loaded = await store.loadText(documentId);
    expect(loaded).toBe(sampleText);
  });

  it("loadTextFromPath reads from an explicit path", async () => {
    const customPath = "ocr-results/custom-doc/full_text.txt";
    savedContent = "Custom OCR content";
    const loaded = await store.loadTextFromPath(customPath);
    expect(loaded).toBe("Custom OCR content");
    expect(mockBucket.file).toHaveBeenCalledWith(customPath);
  });

  it("loadTextFromPath throws when file is missing", async () => {
    mockFile.exists.mockResolvedValueOnce([false]);
    await expect(store.loadTextFromPath("ocr-results/missing/full_text.txt"))
      .rejects.toThrow("OCR text not found in storage");
  });
});
