import 'dart:io';

abstract class StorageService {
  Future<String> uploadFile({
    required File file,
    required String storagePath,
  });

  Future<void> deleteFile(String storagePath);
}
