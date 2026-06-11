import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/features/ocr/domain/entities/ocr_result.dart';

class OcrResultMapper {
  OcrResultMapper._();

  /// Builds an [OcrResult] from Firestore data.
  ///
  /// v1 records include inline [extractedText]. v2 records store text in
  /// Storage ([ocrTextPath]); pass [resolvedExtractedText] when loaded
  /// from Storage by the repository.
  static OcrResult fromMap(
    String documentId,
    Map<String, dynamic> map, {
    String? resolvedExtractedText,
  }) {
    final inlineText = map['extractedText'] as String?;
    final extractedText = inlineText ?? resolvedExtractedText ?? '';

    return OcrResult(
      documentId: documentId,
      extractedText: extractedText,
      summary: map['summary'] as String,
      createdAt: _toDateTime(map['createdAt']),
      ocrTextPath: map['ocrTextPath'] as String?,
      ocrCharacterCount: map['ocrCharacterCount'] as int?,
      riskLevel: map['riskLevel'] as String?,
      documentType: map['documentType'] as String?,
      processingVersion: map['processingVersion'] as int?,
    );
  }

  /// Returns true when OCR text must be loaded from Storage (v2).
  static bool requiresStorageTextLoad(Map<String, dynamic> map) {
    return map['extractedText'] == null &&
        map['ocrTextPath'] is String &&
        (map['ocrTextPath'] as String).isNotEmpty;
  }

  static Map<String, dynamic> toMap(OcrResult result) {
    return {
      'documentId': result.documentId,
      'extractedText': result.extractedText,
      'summary': result.summary,
      'createdAt': Timestamp.fromDate(result.createdAt),
      if (result.ocrTextPath != null) 'ocrTextPath': result.ocrTextPath,
      if (result.ocrCharacterCount != null)
        'ocrCharacterCount': result.ocrCharacterCount,
      if (result.riskLevel != null) 'riskLevel': result.riskLevel,
      if (result.documentType != null) 'documentType': result.documentType,
      if (result.processingVersion != null)
        'processingVersion': result.processingVersion,
    };
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    throw FormatException(
      'Expected Timestamp or DateTime, got ${value.runtimeType}.',
    );
  }
}
