import 'dart:io';

import 'package:mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_app/features/document/domain/entities/app_document.dart';
import 'package:mobile_app/features/document/domain/enums/document_type.dart';
import 'package:mobile_app/features/document/domain/repositories/document_repository.dart';
import 'package:mobile_app/features/document/domain/services/document_service.dart';
import 'package:mobile_app/features/document/domain/services/storage_service.dart';

class FirestoreDocumentService implements DocumentService {
  FirestoreDocumentService(
    this._documentRepository,
    this._storageService,
    this._authRepository,
  );

  final DocumentRepository _documentRepository;
  final StorageService _storageService;
  final AuthRepository _authRepository;

  @override
  Future<void> uploadDocument({
    required File file,
    required DocumentType documentType,
  }) async {
    final authUser = await _authRepository.getCurrentUser();
    if (authUser == null) {
      throw Exception('User not authenticated.');
    }

    final documentId = DateTime.now().millisecondsSinceEpoch.toString();
    final storagePath = 'documents/${authUser.id}/$documentId';

    final downloadUrl = await _storageService.uploadFile(
      file: file,
      storagePath: storagePath,
    );

    final now = DateTime.now();
    final document = AppDocument(
      id: documentId,
      ownerId: authUser.id,
      fileName: file.path.split(Platform.pathSeparator).last,
      documentType: documentType,
      storagePath: storagePath,
      downloadUrl: downloadUrl,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );

    await _documentRepository.createDocument(document);
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    final document = await _documentRepository.getDocument(documentId);
    if (document == null) {
      return;
    }

    await _storageService.deleteFile(document.storagePath);
    await _documentRepository.deleteDocument(documentId);
  }
}
