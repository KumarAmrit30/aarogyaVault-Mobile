import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/document/application/document_state_provider.dart';
import 'package:mobile_app/features/document/domain/entities/app_document.dart';
import 'package:mobile_app/features/document/domain/enums/document_type.dart';
import 'package:mobile_app/features/ocr/application/ocr_providers.dart';
import 'package:mobile_app/features/ocr/domain/entities/ocr_result.dart';
import 'package:mobile_app/features/records/domain/enums/record_category_filter.dart';
import 'package:mobile_app/features/records/domain/enums/record_processing_status.dart';

/// Selected category chip on the Record Library screen.
final recordCategoryFilterProvider =
    NotifierProvider<RecordCategoryFilterNotifier, RecordCategoryFilter>(
  RecordCategoryFilterNotifier.new,
);

class RecordCategoryFilterNotifier extends Notifier<RecordCategoryFilter> {
  @override
  RecordCategoryFilter build() => RecordCategoryFilter.all;

  void select(RecordCategoryFilter filter) {
    state = filter;
  }
}

/// User documents filtered by [recordCategoryFilterProvider], newest first.
final filteredDocumentsProvider = Provider<AsyncValue<List<AppDocument>>>(
  (ref) {
    final documentsAsync = ref.watch(userDocumentsProvider);
    final filter = ref.watch(recordCategoryFilterProvider);

    return documentsAsync.whenData((documents) {
      final active = documents.where((doc) => !doc.isDeleted).toList();

      final List<AppDocument> filtered = switch (filter) {
        RecordCategoryFilter.all => active,
        RecordCategoryFilter.prescriptions => active
            .where((doc) => doc.documentType == DocumentType.prescription)
            .toList(),
        RecordCategoryFilter.labReports => active
            .where((doc) => doc.documentType == DocumentType.labReport)
            .toList(),
      };

      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filtered;
    });
  },
);

/// Derives card processing status from the OCR stream for a document.
final recordProcessingStatusProvider =
    Provider.family<RecordProcessingStatus, String>((ref, documentId) {
  final ocrAsync = ref.watch(ocrResultProvider(documentId));

  return ocrAsync.when(
    loading: () => RecordProcessingStatus.processing,
    error: (_, _) => RecordProcessingStatus.pending,
    data: (result) => resolveRecordProcessingStatus(result),
  );
});

/// Maps an [OcrResult] (or absence) to a library card status.
RecordProcessingStatus resolveRecordProcessingStatus(OcrResult? result) {
  if (result == null) {
    return RecordProcessingStatus.processing;
  }
  if (result.hasExtractionWarning) {
    return RecordProcessingStatus.pending;
  }
  return RecordProcessingStatus.verified;
}
