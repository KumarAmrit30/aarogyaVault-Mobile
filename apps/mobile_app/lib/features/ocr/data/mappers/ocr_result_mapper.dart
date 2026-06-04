import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/features/ocr/domain/entities/ocr_result.dart';

class OcrResultMapper {
  OcrResultMapper._();

  static OcrResult fromMap(String documentId, Map<String, dynamic> map) {
    return OcrResult(
      documentId: documentId,
      extractedText: map['extractedText'] as String,
      summary: map['summary'] as String,
      createdAt: _toDateTime(map['createdAt']),
    );
  }

  static Map<String, dynamic> toMap(OcrResult result) {
    return {
      'documentId': result.documentId,
      'extractedText': result.extractedText,
      'summary': result.summary,
      'createdAt': Timestamp.fromDate(result.createdAt),
    };
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    throw FormatException('Expected Timestamp or DateTime, got ${value.runtimeType}.');
  }
}
