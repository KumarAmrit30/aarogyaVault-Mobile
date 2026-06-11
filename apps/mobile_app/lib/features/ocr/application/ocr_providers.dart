import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/app/providers/firebase_providers.dart';
import 'package:mobile_app/features/ocr/data/repositories/firestore_ocr_repository.dart';
import 'package:mobile_app/features/ocr/domain/repositories/ocr_repository.dart';

final ocrRepositoryProvider = Provider<OcrRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final storage = ref.watch(firebaseStorageProvider);
  return FirestoreOcrRepository(firestore, storage);
});
