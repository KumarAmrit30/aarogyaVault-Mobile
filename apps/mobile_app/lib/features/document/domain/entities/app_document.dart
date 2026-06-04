import 'package:mobile_app/features/document/domain/enums/document_type.dart';

class AppDocument {
  const AppDocument({
    required this.id,
    required this.ownerId,
    required this.fileName,
    required this.documentType,
    required this.storagePath,
    required this.downloadUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String ownerId;
  final String fileName;
  final DocumentType documentType;
  final String storagePath;
  final String downloadUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
}
