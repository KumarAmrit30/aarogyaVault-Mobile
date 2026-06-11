import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/app/providers/firebase_providers.dart';
import 'package:mobile_app/features/ocr/application/ocr_controller.dart';
import 'package:mobile_app/features/ocr/data/repositories/firestore_ocr_repository.dart';
import 'package:mobile_app/features/ocr/domain/entities/ocr_result.dart';
import 'package:mobile_app/features/ocr/domain/repositories/ocr_repository.dart';

final ocrRepositoryProvider = Provider<OcrRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final storage = ref.watch(firebaseStorageProvider);
  return FirestoreOcrRepository(firestore, storage);
});

final ocrControllerProvider = Provider<OcrController>((ref) {
  final ocrRepository = ref.watch(ocrRepositoryProvider);
  return OcrController(ocrRepository);
});

/// Live stream of OCR results for a document. `null` while processing.
final ocrResultProvider = StreamProvider.family<OcrResult?, String>(
  (ref, documentId) {
    final controller = ref.watch(ocrControllerProvider);
    return controller.watchOcrResult(documentId);
  },
);

/// One-shot fetch of an OCR result.
final ocrResultFutureProvider = FutureProvider.family<OcrResult?, String>(
  (ref, documentId) {
    final controller = ref.watch(ocrControllerProvider);
    return controller.getOcrResult(documentId);
  },
);

/// True while the backend has not yet written an `ocr_results` document.
final ocrIsProcessingProvider = Provider.family<bool, String>(
  (ref, documentId) {
    final async = ref.watch(ocrResultProvider(documentId));
    return async.when(
      data: (result) => result == null,
      loading: () => true,
      error: (_, _) => false,
    );
  },
);

/// True when the record was produced by the v2 Document AI pipeline.
final ocrIsV2Provider = Provider.family<bool, String>(
  (ref, documentId) {
    return ref.watch(ocrResultProvider(documentId)).value?.isAnalyzedRecord ??
        false;
  },
);

/// True when the backend flagged low OCR confidence or similar.
final ocrHasExtractionWarningProvider = Provider.family<bool, String>(
  (ref, documentId) {
    return ref
            .watch(ocrResultProvider(documentId))
            .value
            ?.hasExtractionWarning ??
        false;
  },
);
