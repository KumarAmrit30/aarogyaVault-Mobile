import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:mobile_app/features/document/domain/services/storage_service.dart';

class FirebaseStorageService implements StorageService {
  FirebaseStorageService(this._firebaseStorage);

  final FirebaseStorage _firebaseStorage;

  @override
  Future<String> uploadFile({
    required File file,
    required String storagePath,
  }) async {
    final ref = _firebaseStorage.ref(storagePath);
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  @override
  Future<void> deleteFile(String storagePath) async {
    await _firebaseStorage.ref(storagePath).delete();
  }
}
