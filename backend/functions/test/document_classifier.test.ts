import {classifyDocumentType} from "../src/utils/document_classifier";

describe("classifyDocumentType", () => {
  it("classifies lab reports", () => {
    expect(classifyDocumentType("Lab Report")).toBe("lab_report");
    expect(classifyDocumentType("Laboratory Report")).toBe("lab_report");
    expect(classifyDocumentType("Blood Test Report")).toBe("lab_report");
    expect(classifyDocumentType("Pathology Report")).toBe("lab_report");
  });

  it("classifies prescriptions", () => {
    expect(classifyDocumentType("Prescription")).toBe("prescription");
    expect(classifyDocumentType("Doctor Prescription")).toBe("prescription");
    expect(classifyDocumentType("Rx")).toBe("prescription");
    expect(classifyDocumentType("Handwritten prescription")).toBe(
      "prescription",
    );
  });

  it("classifies discharge summaries", () => {
    expect(classifyDocumentType("Discharge Summary")).toBe(
      "discharge_summary",
    );
    expect(classifyDocumentType("Hospital discharge note")).toBe(
      "discharge_summary",
    );
  });

  it("classifies invoices", () => {
    expect(classifyDocumentType("Invoice")).toBe("invoice");
    expect(classifyDocumentType("Medical Invoice")).toBe("invoice");
    expect(classifyDocumentType("Bill")).toBe("invoice");
    expect(classifyDocumentType("Payment Receipt")).toBe("invoice");
  });

  it("falls back to other", () => {
    expect(classifyDocumentType("Insurance Card")).toBe("other");
    expect(classifyDocumentType("")).toBe("other");
    expect(classifyDocumentType("   ")).toBe("other");
  });

  it("prefers prescription over lab keywords", () => {
    expect(classifyDocumentType("Prescription with blood pressure meds"))
      .toBe("prescription");
  });
});
