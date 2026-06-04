import 'package:mobile_app/features/document/domain/entities/app_document.dart';

abstract class DocumentRepository {
  Future<void> createDocument(AppDocument document);

  Future<void> updateDocument(AppDocument document);

  Future<void> deleteDocument(String documentId);

  Future<AppDocument?> getDocument(String documentId);

  Stream<List<AppDocument>> watchUserDocuments(String ownerId);
}
