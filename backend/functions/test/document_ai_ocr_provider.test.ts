import {
  computeAverageConfidence,
  computeWeightedConfidence,
  detectHandwriting,
  resolveHandwriting,
} from "../src/services/ocr/document_ai_ocr_provider";

describe("computeAverageConfidence", () => {
  it("averages page layout confidences", () => {
    const pages = [
      {layout: {confidence: 0.9}},
      {layout: {confidence: 0.8}},
    ];
    expect(computeAverageConfidence(pages)).toBeCloseTo(0.85);
  });

  it("ignores pages without confidence", () => {
    const pages = [
      {layout: {confidence: 0.9}},
      {layout: {}},
      {},
    ];
    expect(computeAverageConfidence(pages)).toBeCloseTo(0.9);
  });

  it("returns undefined when no page has confidence", () => {
    expect(computeAverageConfidence([])).toBeUndefined();
    expect(computeAverageConfidence([{}, {layout: {}}])).toBeUndefined();
  });
});

describe("computeWeightedConfidence", () => {
  it("weights token confidence by covered character length", () => {
    const pages = [
      {
        tokens: [
          {
            layout: {
              confidence: 0.5,
              textAnchor: {textSegments: [{startIndex: 0, endIndex: 2}]},
            },
          },
          {
            layout: {
              confidence: 1.0,
              textAnchor: {textSegments: [{startIndex: 2, endIndex: 10}]},
            },
          },
        ],
      },
    ];
    // (0.5*2 + 1.0*8) / 10 = 0.9
    expect(computeWeightedConfidence(pages)).toBeCloseTo(0.9);
  });

  it("treats tokens without segments as weight 1", () => {
    const pages = [
      {
        tokens: [
          {layout: {confidence: 0.6}},
          {layout: {confidence: 0.8}},
        ],
      },
    ];
    expect(computeWeightedConfidence(pages)).toBeCloseTo(0.7);
  });

  it("falls back to page average when no token confidence", () => {
    const pages = [
      {layout: {confidence: 0.95}, tokens: [{}, {}]},
    ];
    expect(computeWeightedConfidence(pages)).toBeCloseTo(0.95);
  });

  it("clamps out-of-range confidence", () => {
    const pages = [{tokens: [{layout: {confidence: 1.5}}]}];
    expect(computeWeightedConfidence(pages)).toBe(1);
  });
});

describe("detectHandwriting", () => {
  it("detects predominantly handwritten documents", () => {
    const pages = [
      {
        tokens: [
          {styleInfo: {handwritten: true}},
          {styleInfo: {handwritten: true}},
          {styleInfo: {handwritten: false}},
        ],
      },
    ];
    expect(detectHandwriting(pages)).toBe(true);
  });

  it("returns false for printed documents", () => {
    const pages = [
      {
        tokens: [
          {styleInfo: {handwritten: false}},
          {styleInfo: {handwritten: false}},
        ],
      },
    ];
    expect(detectHandwriting(pages)).toBe(false);
  });

  it("returns false when style info is unavailable", () => {
    const pages = [{tokens: [{}, {}]}, {}];
    expect(detectHandwriting(pages)).toBe(false);
  });

  it("returns false for empty documents", () => {
    expect(detectHandwriting([])).toBe(false);
  });
});

describe("resolveHandwriting", () => {
  it("returns true when style info detected handwriting", () => {
    expect(resolveHandwriting({
      styleInfoDetected: true,
      confidence: 0.99,
      isPrescription: false,
    })).toBe(true);
  });

  it("flags low-confidence prescriptions without style info", () => {
    expect(resolveHandwriting({
      styleInfoDetected: false,
      confidence: 0.6,
      isPrescription: true,
    })).toBe(true);
  });

  it("does not flag low-confidence non-prescriptions", () => {
    expect(resolveHandwriting({
      styleInfoDetected: false,
      confidence: 0.6,
      isPrescription: false,
    })).toBe(false);
  });

  it("does not flag high-confidence prescriptions", () => {
    expect(resolveHandwriting({
      styleInfoDetected: false,
      confidence: 0.95,
      isPrescription: true,
    })).toBe(false);
  });

  it("does not flag when confidence is unknown", () => {
    expect(resolveHandwriting({
      styleInfoDetected: false,
      confidence: undefined,
      isPrescription: true,
    })).toBe(false);
  });
});
