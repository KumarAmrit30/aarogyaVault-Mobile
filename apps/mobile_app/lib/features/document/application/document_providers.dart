import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/app/providers/firebase_providers.dart';
import 'package:mobile_app/features/auth/application/auth_providers.dart';
import 'package:mobile_app/features/document/data/repositories/firestore_document_repository.dart';
import 'package:mobile_app/features/document/data/services/firebase_storage_service.dart';
import 'package:mobile_app/features/document/data/services/firestore_document_service.dart';
import 'package:mobile_app/features/document/domain/repositories/document_repository.dart';
import 'package:mobile_app/features/document/domain/services/document_service.dart';
import 'package:mobile_app/features/document/domain/services/storage_service.dart';

final documentRepositoryProvider =
    Provider<DocumentRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreDocumentRepository(firestore);
});

final documentServiceProvider =
    Provider<DocumentService>((ref) {
  final documentRepository = ref.watch(documentRepositoryProvider);
  final storageService = ref.watch(storageServiceProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return FirestoreDocumentService(
    documentRepository,
    storageService,
    authRepository,
  );
});

final storageServiceProvider =
    Provider<StorageService>((ref) {
  final firebaseStorage = ref.watch(firebaseStorageProvider);
  return FirebaseStorageService(firebaseStorage);
});
