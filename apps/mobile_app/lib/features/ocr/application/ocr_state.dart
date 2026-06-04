import 'package:mobile_app/features/ocr/domain/entities/ocr_result.dart';

abstract class OcrState {}

class OcrInitial extends OcrState {}

class OcrLoading extends OcrState {}

class OcrLoaded extends OcrState {
  OcrLoaded(this.result);

  final OcrResult result;
}

class OcrError extends OcrState {
  OcrError(this.message);

  final String message;
}
