import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/features/document/data/mappers/app_document_mapper.dart';
import 'package:mobile_app/features/document/domain/entities/app_document.dart';
import 'package:mobile_app/features/document/domain/repositories/document_repository.dart';

class FirestoreDocumentRepository implements DocumentRepository {
  FirestoreDocumentRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const _documentsCollection = 'documents';

  CollectionReference<Map<String, dynamic>> get _documents =>
      _firestore.collection(_documentsCollection);

  @override
  Future<void> createDocument(AppDocument document) async {
    await _documents.doc(document.id).set(AppDocumentMapper.toMap(document));
  }

  @override
  Future<void> updateDocument(AppDocument document) async {
    await _documents.doc(document.id).update(AppDocumentMapper.toMap(document));
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    await _documents.doc(documentId).update({'isDeleted': true});
  }

  @override
  Future<AppDocument?> getDocument(String documentId) async {
    final snapshot = await _documents.doc(documentId).get();
    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();
    if (data == null) {
      return null;
    }

    return AppDocumentMapper.fromMap(documentId, data);
  }

  @override
  Stream<List<AppDocument>> watchUserDocuments(String ownerId) {
    return _documents
        .where('ownerId', isEqualTo: ownerId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppDocumentMapper.fromMap(doc.id, doc.data()))
          .toList();
    });
  }
}
