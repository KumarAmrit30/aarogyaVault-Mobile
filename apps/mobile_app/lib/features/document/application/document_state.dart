import 'package:mobile_app/features/document/domain/entities/app_document.dart';

abstract class DocumentState {}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentLoaded extends DocumentState {
  DocumentLoaded(this.documents);

  final List<AppDocument> documents;
}

class DocumentError extends DocumentState {
  DocumentError(this.message);

  final String message;
}
