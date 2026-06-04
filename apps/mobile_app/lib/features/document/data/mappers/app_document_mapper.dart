import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/features/document/domain/entities/app_document.dart';
import 'package:mobile_app/features/document/domain/enums/document_type.dart';

class AppDocumentMapper {
  AppDocumentMapper._();

  static AppDocument fromMap(String id, Map<String, dynamic> map) {
    return AppDocument(
      id: id,
      ownerId: map['ownerId'] as String,
      fileName: map['fileName'] as String,
      documentType: DocumentType.values.byName(map['documentType'] as String),
      storagePath: map['storagePath'] as String,
      downloadUrl: map['downloadUrl'] as String,
      createdAt: _toDateTime(map['createdAt']),
      updatedAt: _toDateTime(map['updatedAt']),
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> toMap(AppDocument document) {
    return {
      'id': document.id,
      'ownerId': document.ownerId,
      'fileName': document.fileName,
      'documentType': document.documentType.name,
      'storagePath': document.storagePath,
      'downloadUrl': document.downloadUrl,
      'createdAt': Timestamp.fromDate(document.createdAt),
      'updatedAt': Timestamp.fromDate(document.updatedAt),
      'isDeleted': document.isDeleted,
    };
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    throw FormatException('Expected Timestamp or DateTime, got ${value.runtimeType}.');
  }
}
