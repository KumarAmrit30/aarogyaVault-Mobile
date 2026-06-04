import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/features/ocr/data/mappers/ocr_result_mapper.dart';
import 'package:mobile_app/features/ocr/domain/entities/ocr_result.dart';
import 'package:mobile_app/features/ocr/domain/repositories/ocr_repository.dart';

class FirestoreOcrRepository implements OcrRepository {
  FirestoreOcrRepository(this._firestore);

  final FirebaseFirestore _firestore;

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

    return OcrResultMapper.fromMap(documentId, data);
  }

  @override
  Stream<OcrResult?> watchOcrResult(String documentId) {
    return _ocrResults.doc(documentId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data();
      if (data == null) {
        return null;
      }

      return OcrResultMapper.fromMap(documentId, data);
    });
  }
}
