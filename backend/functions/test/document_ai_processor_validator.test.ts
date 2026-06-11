import {
  OCR_PROCESSOR_TYPE,
  validateOcrProcessor,
} from "../src/services/ocr/document_ai_processor_validator";

describe("validateOcrProcessor", () => {
  const config = {
    projectId: "aarogya-vault-dev",
    location: "us",
    processorId: "4209e8cabb4da203",
  };

  function mockClient(processor: unknown) {
    return {
      getProcessor: jest.fn().mockResolvedValue([processor]),
    };
  }

  it("accepts an ENABLED OCR_PROCESSOR (Enterprise Document OCR)", async () => {
    const client = mockClient({type: OCR_PROCESSOR_TYPE, state: "ENABLED"});
    await expect(
      validateOcrProcessor(config, client as never),
    ).resolves.toBeUndefined();
  });

  it("accepts ENABLED state expressed as enum number 1", async () => {
    const client = mockClient({type: OCR_PROCESSOR_TYPE, state: 1});
    await expect(
      validateOcrProcessor(config, client as never),
    ).resolves.toBeUndefined();
  });

  it("rejects a disabled processor", async () => {
    const client = mockClient({type: OCR_PROCESSOR_TYPE, state: "DISABLED"});
    await expect(
      validateOcrProcessor(config, client as never),
    ).rejects.toThrow("not ENABLED");
  });

  it("rejects FORM_PARSER_PROCESSOR", async () => {
    const client = mockClient({
      type: "FORM_PARSER_PROCESSOR",
      state: "ENABLED",
    });
    await expect(
      validateOcrProcessor(config, client as never),
    ).rejects.toThrow("Expected OCR_PROCESSOR");
    await expect(
      validateOcrProcessor(config, client as never),
    ).rejects.toThrow("FORM_PARSER_PROCESSOR");
  });

  it("rejects LAYOUT_PARSER_PROCESSOR", async () => {
    const client = mockClient({
      type: "LAYOUT_PARSER_PROCESSOR",
      state: "ENABLED",
    });
    await expect(
      validateOcrProcessor(config, client as never),
    ).rejects.toThrow("Expected OCR_PROCESSOR");
  });

  it("rejects INVOICE_PROCESSOR", async () => {
    const client = mockClient({type: "INVOICE_PROCESSOR", state: "ENABLED"});
    await expect(
      validateOcrProcessor(config, client as never),
    ).rejects.toThrow("INVOICE_PROCESSOR");
  });

  it("throws a descriptive error when the processor is missing", async () => {
    const client = {
      getProcessor: jest.fn().mockRejectedValue(new Error("NOT_FOUND")),
    };
    await expect(
      validateOcrProcessor(config, client as never),
    ).rejects.toThrow("not found or inaccessible");
  });
});
