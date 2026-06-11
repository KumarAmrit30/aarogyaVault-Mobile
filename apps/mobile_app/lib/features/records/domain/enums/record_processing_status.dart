/// OCR processing status shown on record library cards.
enum RecordProcessingStatus {
  processing,
  verified,
  pending,
}

extension RecordProcessingStatusX on RecordProcessingStatus {
  String get badgeLabel => switch (this) {
        RecordProcessingStatus.processing => 'PENDING',
        RecordProcessingStatus.verified => 'VERIFIED',
        RecordProcessingStatus.pending => 'PENDING',
      };

  String get actionLabel => switch (this) {
        RecordProcessingStatus.processing => 'Track Status',
        RecordProcessingStatus.verified => 'View Details',
        RecordProcessingStatus.pending => 'Track Status',
      };
}
