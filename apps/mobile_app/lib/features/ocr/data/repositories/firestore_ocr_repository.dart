import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mobile_app/features/ocr/data/mappers/ocr_result_mapper.dart';
import 'package:mobile_app/features/ocr/domain/entities/ocr_result.dart';
import 'package:mobile_app/features/ocr/domain/repositories/ocr_repository.dart';

class FirestoreOcrRepository implements OcrRepository {
  FirestoreOcrRepository(this._firestore, this._firebaseStorage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _firebaseStorage;

  static const _ocrResultsCollection = 'ocr_results';

  CollectionReference<Map<String, dynamic>> get _ocrResults =>
      _firestore.collection(_ocrResultsCollection);

  @override
  Future<OcrResult?> getOcrResult(String documentId) async {
    final snapshot = await _ocrResults.doc(documentId).get();
    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();
    if (data == null) {
      return null;
    }

    return _mapSnapshot(documentId, data);
  }

  @override
  Stream<OcrResult?> watchOcrResult(String documentId) async* {
    await for (final snapshot in _ocrResults.doc(documentId).snapshots()) {
      if (!snapshot.exists) {
        yield null;
        continue;
      }

      final data = snapshot.data();
      if (data == null) {
        yield null;
        continue;
      }

      yield await _mapSnapshot(documentId, data);
    }
  }

  Future<OcrResult> _mapSnapshot(
    String documentId,
    Map<String, dynamic> data,
  ) async {
    String? resolvedText;
    if (OcrResultMapper.requiresStorageTextLoad(data)) {
      resolvedText = await _loadOcrTextFromStorage(
        data['ocrTextPath'] as String,
      );
    }

    return OcrResultMapper.fromMap(
      documentId,
      data,
      resolvedExtractedText: resolvedText,
    );
  }

  Future<String> _loadOcrTextFromStorage(String storagePath) async {
    final ref = _firebaseStorage.ref(storagePath);
    final bytes = await ref.getData();
    if (bytes == null) {
      throw StateError('OCR text not found in storage: $storagePath');
    }
    return utf8.decode(bytes);
  }
}
