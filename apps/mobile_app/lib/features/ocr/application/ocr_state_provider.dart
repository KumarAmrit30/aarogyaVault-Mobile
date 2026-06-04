import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/ocr/application/ocr_controller.dart';
import 'package:mobile_app/features/ocr/application/ocr_providers.dart';
import 'package:mobile_app/features/ocr/domain/entities/ocr_result.dart';

final ocrControllerProvider = Provider<OcrController>((ref) {
  final ocrRepository = ref.watch(ocrRepositoryProvider);
  return OcrController(ocrRepository);
});

final ocrResultProvider = StreamProvider.family<OcrResult?, String>(
  (ref, documentId) {
    final ocrController = ref.watch(ocrControllerProvider);
    return ocrController.watchOcrResult(documentId);
  },
);
