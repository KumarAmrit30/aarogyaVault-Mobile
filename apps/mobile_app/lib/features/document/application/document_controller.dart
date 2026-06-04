import 'dart:io';

import 'package:mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_app/features/document/domain/entities/app_document.dart';
import 'package:mobile_app/features/document/domain/enums/document_type.dart';
import 'package:mobile_app/features/document/domain/repositories/document_repository.dart';
import 'package:mobile_app/features/document/domain/services/document_service.dart';

class DocumentController {
  DocumentController(
    this._documentService,
    this._documentRepository,
    this._authRepository,
  );

  final DocumentService _documentService;
  final DocumentRepository _documentRepository;
  final AuthRepository _authRepository;

  Future<void> uploadDocument({
    required File file,
    required DocumentType documentType,
  }) {
    return _documentService.uploadDocument(
      file: file,
      documentType: documentType,
    );
  }

  Future<void> deleteDocument(String documentId) {
    return _documentService.deleteDocument(documentId);
  }

  Stream<List<AppDocument>> watchDocuments() {
    return Stream.fromFuture(_authRepository.getCurrentUser()).asyncExpand(
      (authUser) {
        if (authUser == null) {
          return Stream.value(<AppDocument>[]);
        }
        return _documentRepository.watchUserDocuments(authUser.id);
      },
    );
  }
}
