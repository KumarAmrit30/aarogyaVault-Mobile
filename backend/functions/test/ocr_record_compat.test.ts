import {
  hasInlineExtractedText,
  isStorageBackedOcrRecord,
  resolveOcrText,
} from "../src/services/ocr/ocr_record_compat";
import {OcrTextStore} from "../src/services/storage/ocr_text_store";

describe("OCR record backward compatibility", () => {
  const v1Record = {
    documentId: "doc-v1",
    extractedText: "Inline v1 OCR text",
    summary: "Summary",
    createdAt: new Date(),
  };

  const v2Record = {
    documentId: "doc-v2",
    ocrTextPath: "ocr-results/doc-v2/full_text.txt",
    ocrCharacterCount: 24,
    summary: "Summary",
    processingVersion: 2,
  };

  it("detects v1 inline records", () => {
    expect(hasInlineExtractedText(v1Record)).toBe(true);
    expect(isStorageBackedOcrRecord(v1Record)).toBe(false);
  });

  it("detects v2 storage-backed records", () => {
    expect(hasInlineExtractedText(v2Record)).toBe(false);
    expect(isStorageBackedOcrRecord(v2Record)).toBe(true);
  });

  it("resolves v1 extractedText without Storage", async () => {
    const mockStore = {
      loadTextFromPath: jest.fn(),
    } as unknown as OcrTextStore;

    const text = await resolveOcrText(v1Record, mockStore);
    expect(text).toBe("Inline v1 OCR text");
    expect(mockStore.loadTextFromPath).not.toHaveBeenCalled();
  });

  it("resolves v2 text from Storage", async () => {
    const mockStore = {
      loadTextFromPath: jest.fn().mockResolvedValue("Storage OCR text"),
    } as unknown as OcrTextStore;

    const text = await resolveOcrText(v2Record, mockStore);
    expect(text).toBe("Storage OCR text");
    expect(mockStore.loadTextFromPath)
      .toHaveBeenCalledWith("ocr-results/doc-v2/full_text.txt");
  });

  it("returns null when neither source is available", async () => {
    const mockStore = {
      loadTextFromPath: jest.fn(),
    } as unknown as OcrTextStore;

    const text = await resolveOcrText({summary: "only summary"}, mockStore);
    expect(text).toBeNull();
  });

  it("prefers inline extractedText over ocrTextPath", async () => {
    const hybrid = {
      extractedText: "Inline wins",
      ocrTextPath: "ocr-results/doc/full_text.txt",
    };
    const mockStore = {
      loadTextFromPath: jest.fn(),
    } as unknown as OcrTextStore;

    const text = await resolveOcrText(hybrid, mockStore);
    expect(text).toBe("Inline wins");
    expect(mockStore.loadTextFromPath).not.toHaveBeenCalled();
  });
});
