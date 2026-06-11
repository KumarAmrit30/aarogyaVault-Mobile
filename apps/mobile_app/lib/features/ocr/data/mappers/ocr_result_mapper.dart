import 'package:mobile_app/features/ocr/data/models/ocr_result_model.dart';
import 'package:mobile_app/features/ocr/domain/entities/ocr_result.dart';

/// Maps Firestore `ocr_results` documents to [OcrResult] domain entities.
///
/// Delegates parsing to [OcrResultModel] for v1/v2 field compatibility.
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
    return OcrResultModel.fromMap(documentId, map)
        .toEntity(resolvedExtractedText: resolvedExtractedText);
  }

  /// Returns true when OCR text must be loaded from Storage (v2).
  static bool requiresStorageTextLoad(Map<String, dynamic> map) {
    return OcrResultModel.mapRequiresStorageTextLoad(map);
  }

  static Map<String, dynamic> toMap(OcrResult result) {
    return OcrResultModel.fromEntity(result).toMap();
  }
}
