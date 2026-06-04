import 'package:mobile_app/features/ocr/domain/entities/ocr_result.dart';

abstract class OcrRepository {
  Future<OcrResult?> getOcrResult(String documentId);

  Stream<OcrResult?> watchOcrResult(String documentId);
}
