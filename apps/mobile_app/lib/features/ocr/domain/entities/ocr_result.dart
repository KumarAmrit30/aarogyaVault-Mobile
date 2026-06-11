class OcrResult {
  const OcrResult({
    required this.documentId,
    required this.extractedText,
    required this.summary,
    required this.createdAt,
    this.ocrTextPath,
    this.ocrCharacterCount,
    this.riskLevel,
    this.documentType,
    this.processingVersion,
  });

  final String documentId;
  final String extractedText;
  final String summary;
  final DateTime createdAt;

  /// v2: Storage path when text is not inline in Firestore.
  final String? ocrTextPath;

  /// v2: Character count of OCR text in Storage.
  final int? ocrCharacterCount;

  /// v2: Overall medical urgency — low, moderate, or high.
  final String? riskLevel;

  /// v2: Document type from medical analysis.
  final String? documentType;

  /// 1 = legacy Gemini OCR, 2 = Document AI + medical analysis.
  final int? processingVersion;

  bool get isStorageBacked => ocrTextPath != null && ocrTextPath!.isNotEmpty;
}
