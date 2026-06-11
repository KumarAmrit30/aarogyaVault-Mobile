import {
  MEDICAL_DISCLAIMER,
  parseMedicalAnalysisResponse,
  repairAndParseJson,
} from "../src/services/medical/medical_analysis_provider";

const VALID_RESPONSE = JSON.stringify({
  documentType: "Lab Report",
  summary: "Your blood sugar is higher than the normal range.",
  criticalFindings: [
    {
      title: "Fasting Glucose",
      status: "high",
      value: "180 mg/dL",
    },
  ],
  normalFindings: ["Hemoglobin is within the normal range."],
  recommendedFollowUp: ["Discuss glucose levels with your doctor."],
});

describe("parseMedicalAnalysisResponse", () => {
  it("parses a valid structured response", () => {
    const result = parseMedicalAnalysisResponse(VALID_RESPONSE);

    expect(result.documentType).toBe("Lab Report");
    expect(result.criticalFindings).toHaveLength(1);
    expect(result.criticalFindings[0].title).toBe("Fasting Glucose");
    expect(result.criticalFindings[0].status).toBe("high");
    expect(result.criticalFindings[0].value).toBe("180 mg/dL");
    expect(result.normalFindings).toEqual([
      "Hemoglobin is within the normal range.",
    ]);
    expect(result.recommendedFollowUp).toHaveLength(1);
  });

  it("appends the disclaimer to the summary", () => {
    const result = parseMedicalAnalysisResponse(VALID_RESPONSE);
    expect(result.summary).toContain(MEDICAL_DISCLAIMER);
  });

  it("does not duplicate an existing disclaimer", () => {
    const withDisclaimer = JSON.stringify({
      documentType: "Lab Report",
      summary: `All good. ${MEDICAL_DISCLAIMER}`,
      criticalFindings: [],
      normalFindings: [],
      recommendedFollowUp: [],
    });

    const result = parseMedicalAnalysisResponse(withDisclaimer);
    const occurrences = result.summary.split(MEDICAL_DISCLAIMER).length - 1;
    expect(occurrences).toBe(1);
  });

  it("coerces unknown finding status to abnormal", () => {
    const response = JSON.stringify({
      documentType: "Lab Report",
      summary: "Summary.",
      criticalFindings: [
        {title: "TSH", status: "elevated", value: "9.1 mIU/L"},
      ],
      normalFindings: [],
      recommendedFollowUp: [],
    });

    const result = parseMedicalAnalysisResponse(response);
    expect(result.criticalFindings[0].status).toBe("abnormal");
  });

  it("drops malformed findings instead of failing", () => {
    const response = JSON.stringify({
      documentType: "Lab Report",
      summary: "Summary.",
      criticalFindings: [
        {title: "Valid", status: "high", value: "1"},
        {title: "Missing status"},
        "not an object",
      ],
      normalFindings: ["keep", 42],
      recommendedFollowUp: ["keep", null],
    });

    const result = parseMedicalAnalysisResponse(response);
    expect(result.criticalFindings).toHaveLength(1);
    expect(result.normalFindings).toEqual(["keep"]);
    expect(result.recommendedFollowUp).toEqual(["keep"]);
  });

  it("throws when required fields are missing", () => {
    const response = JSON.stringify({summary: "no documentType"});
    expect(() => parseMedicalAnalysisResponse(response))
      .toThrow("documentType and summary");
  });
});

describe("repairAndParseJson", () => {
  it("parses fenced JSON", () => {
    const fenced = "```json\n{\"a\":1}\n```";
    expect(repairAndParseJson(fenced)).toEqual({a: 1});
  });

  it("extracts JSON object from surrounding prose", () => {
    const wrapped = "Here is the result: {\"a\":1} thanks.";
    expect(repairAndParseJson(wrapped)).toEqual({a: 1});
  });

  it("repairs trailing commas in objects and arrays", () => {
    const malformed = "{\"a\":1,\"b\":2,}";
    expect(repairAndParseJson(malformed)).toEqual({a: 1, b: 2});

    const arrayMalformed = "{\"items\":[1,2,],}";
    expect(repairAndParseJson(arrayMalformed)).toEqual({items: [1, 2]});
  });

  it("repairs single-quoted keys/values via jsonrepair", () => {
    const malformed = "{'documentType': 'Lab Report', 'summary': 'ok'}";
    expect(repairAndParseJson(malformed)).toEqual({
      documentType: "Lab Report",
      summary: "ok",
    });
  });

  it("repairs unquoted keys via jsonrepair", () => {
    const malformed = "{documentType: \"Lab Report\"}";
    expect(repairAndParseJson(malformed)).toEqual({
      documentType: "Lab Report",
    });
  });

  it("throws on empty/unrecoverable input", () => {
    expect(() => repairAndParseJson("")).toThrow("malformed");
    expect(() => repairAndParseJson("   ")).toThrow("malformed");
  });

  it("rejects non-object JSON at the analysis layer", () => {
    // jsonrepair coerces bare prose into a JSON string; the analysis
    // parser must then reject it as a non-object.
    expect(() => parseMedicalAnalysisResponse("this is not json at all"))
      .toThrow("expected JSON object");
  });
});
