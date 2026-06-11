import 'package:mobile_app/features/document/domain/entities/app_document.dart';

/// Display title derived from the uploaded file name.
String recordDisplayTitle(AppDocument document) {
  final dotIndex = document.fileName.lastIndexOf('.');
  if (dotIndex > 0) {
    return document.fileName.substring(0, dotIndex);
  }
  return document.fileName;
}

/// Stitch-style upload date label (e.g. "Oct 28, 2023").
String formatRecordDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
