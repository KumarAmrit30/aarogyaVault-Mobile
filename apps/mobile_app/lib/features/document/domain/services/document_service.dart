import 'dart:io';

import 'package:mobile_app/features/document/domain/enums/document_type.dart';

abstract class DocumentService {
  Future<void> uploadDocument({
    required File file,
    required DocumentType documentType,
  });

  Future<void> deleteDocument(String documentId);
}
