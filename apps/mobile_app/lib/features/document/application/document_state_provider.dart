import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/auth/application/auth_providers.dart';
import 'package:mobile_app/features/document/application/document_controller.dart';
import 'package:mobile_app/features/document/application/document_providers.dart';
import 'package:mobile_app/features/document/domain/entities/app_document.dart';

final documentControllerProvider = Provider<DocumentController>((ref) {
  final documentService = ref.watch(documentServiceProvider);
  final documentRepository = ref.watch(documentRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return DocumentController(
    documentService,
    documentRepository,
    authRepository,
  );
});

final userDocumentsProvider = StreamProvider<List<AppDocument>>((ref) {
  final documentController = ref.watch(documentControllerProvider);
  return documentController.watchDocuments();
});
