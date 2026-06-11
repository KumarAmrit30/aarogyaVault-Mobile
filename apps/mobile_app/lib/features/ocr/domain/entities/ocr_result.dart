import 'package:mobile_app/features/ocr/domain/entities/critical_finding.dart';

/// OCR and medical analysis result for a document.
///
/// Supports v1 records (inline [extractedText], summary only) and v2
/// records (Storage-backed text, structured medical analysis).
class OcrResult {
  const OcrResult({
    required this.documentId,
    required this.extractedText,
    required this.summary,
    required this.createdAt,
    this.ocrTextPath,
    this.ocrCharacterCount,
    this.documentType,
    this.processingVersion,
    this.ocrProvider,
    this.ocrConfidence,
    this.pageCount,
    this.criticalFindings = const [],
    this.normalFindings = const [],
    this.recommendedFollowUp = const [],
    this.handwritingDetected,
    this.extractionWarning,
    this.riskLevel,
  });

  final String documentId;
  final String extractedText;
  final String summary;
  final DateTime createdAt;

  /// v2: Storage path when text is not inline in Firestore.
  final String? ocrTextPath;

  /// v2: Character count of OCR text in Storage.
  final int? ocrCharacterCount;

  /// v2: Document type label from medical analysis (e.g. "Lab Report").
  final String? documentType;

  /// `1` = legacy Gemini OCR, `2` = Document AI + medical analysis.
  /// Null on older v1 records written before versioning.
  final int? processingVersion;

  /// v2: OCR backend identifier (e.g. `document_ai`).
  final String? ocrProvider;

  /// v2: Average OCR confidence in [0, 1].
  final double? ocrConfidence;

  /// v2: Number of pages processed by Document AI.
  final int? pageCount;

  /// v2: Clinically significant findings.
  final List<CriticalFinding> criticalFindings;

  /// v2: Important normal findings as plain-language strings.
  final List<String> normalFindings;

  /// v2: Suggested follow-up actions.
  final List<String> recommendedFollowUp;

  /// v2: Whether handwriting was detected (prescriptions).
  final bool? handwritingDetected;

  /// v2: Low-confidence or handwriting warning for manual verification.
  final String? extractionWarning;

  /// Optional urgency label when present on record (not all backends write it).
  final String? riskLevel;

  /// True when full OCR text is stored in Firebase Storage.
  bool get isStorageBacked =>
      ocrTextPath != null && ocrTextPath!.isNotEmpty;

  /// True for legacy Gemini OCR records (inline text, no analysis fields).
  bool get isLegacyRecord =>
      processingVersion == null || processingVersion! < 2;

  /// True for Document AI + medical analysis pipeline records.
  bool get isAnalyzedRecord => processingVersion == 2;

  /// True when structured medical analysis fields are populated.
  bool get hasMedicalAnalysis =>
      criticalFindings.isNotEmpty ||
      normalFindings.isNotEmpty ||
      recommendedFollowUp.isNotEmpty ||
      (documentType != null && documentType!.isNotEmpty);

  /// True when the backend flagged low OCR confidence or similar.
  bool get hasExtractionWarning =>
      extractionWarning != null && extractionWarning!.isNotEmpty;

  /// True when OCR confidence is below the app's verification threshold.
  bool get isLowConfidence =>
      ocrConfidence != null && ocrConfidence! < 0.75;
}
