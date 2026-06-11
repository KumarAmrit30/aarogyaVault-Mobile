import {
  getDocumentAiConfig,
  isDocumentAiOcrEnabled,
  loadDocumentAiConfig,
} from "../src/config/document_ai_config";

describe("document_ai_config", () => {
  const originalEnv = process.env;

  beforeEach(() => {
    process.env = {...originalEnv};
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  describe("isDocumentAiOcrEnabled", () => {
    it("returns true only when flag is exactly \"true\"", () => {
      process.env.USE_DOCUMENT_AI_OCR = "true";
      expect(isDocumentAiOcrEnabled()).toBe(true);
    });

    it("returns false for any other value", () => {
      process.env.USE_DOCUMENT_AI_OCR = "false";
      expect(isDocumentAiOcrEnabled()).toBe(false);

      delete process.env.USE_DOCUMENT_AI_OCR;
      expect(isDocumentAiOcrEnabled()).toBe(false);

      process.env.USE_DOCUMENT_AI_OCR = "1";
      expect(isDocumentAiOcrEnabled()).toBe(false);
    });
  });

  describe("getDocumentAiConfig", () => {
    it("throws when Document AI is disabled", () => {
      process.env.USE_DOCUMENT_AI_OCR = "false";
      expect(() => getDocumentAiConfig()).toThrow("disabled");
    });

    it("throws descriptive error for missing project ID", () => {
      process.env.USE_DOCUMENT_AI_OCR = "true";
      delete process.env.DOCUMENT_AI_PROJECT_ID;
      process.env.DOCUMENT_AI_LOCATION = "us";
      process.env.DOCUMENT_AI_PROCESSOR_ID = "abc";

      expect(() => getDocumentAiConfig()).toThrow("DOCUMENT_AI_PROJECT_ID");
    });

    it("returns config when all variables are set", () => {
      process.env.USE_DOCUMENT_AI_OCR = "true";
      process.env.DOCUMENT_AI_PROJECT_ID = "aarogya-vault-dev";
      process.env.DOCUMENT_AI_LOCATION = "us";
      process.env.DOCUMENT_AI_PROCESSOR_ID = "4209e8cabb4da203";

      expect(getDocumentAiConfig()).toEqual({
        projectId: "aarogya-vault-dev",
        location: "us",
        processorId: "4209e8cabb4da203",
      });
    });
  });

  describe("loadDocumentAiConfig", () => {
    it("loads config without requiring the feature flag", () => {
      process.env.DOCUMENT_AI_PROJECT_ID = "aarogya-vault-dev";
      process.env.DOCUMENT_AI_LOCATION = "us";
      process.env.DOCUMENT_AI_PROCESSOR_ID = "4209e8cabb4da203";

      expect(loadDocumentAiConfig()).toEqual({
        projectId: "aarogya-vault-dev",
        location: "us",
        processorId: "4209e8cabb4da203",
      });
    });
  });
});
