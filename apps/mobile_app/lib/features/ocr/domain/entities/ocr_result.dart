class OcrResult {
  const OcrResult({
    required this.documentId,
    required this.extractedText,
    required this.summary,
    required this.createdAt,
  });

  final String documentId;
  final String extractedText;
  final String summary;
  final DateTime createdAt;
}
