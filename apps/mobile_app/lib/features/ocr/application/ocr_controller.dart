import 'package:mobile_app/features/ocr/domain/entities/ocr_result.dart';
import 'package:mobile_app/features/ocr/domain/repositories/ocr_repository.dart';

class OcrController {
  OcrController(this._ocrRepository);

  final OcrRepository _ocrRepository;

  Future<OcrResult?> getOcrResult(String documentId) {
    return _ocrRepository.getOcrResult(documentId);
  }

  Stream<OcrResult?> watchOcrResult(String documentId) {
    return _ocrRepository.watchOcrResult(documentId);
  }
}
