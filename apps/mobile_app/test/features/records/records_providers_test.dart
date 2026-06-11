import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/ocr/domain/entities/ocr_result.dart';
import 'package:mobile_app/features/records/application/records_providers.dart';
import 'package:mobile_app/features/records/domain/enums/record_category_filter.dart';
import 'package:mobile_app/features/records/domain/enums/record_processing_status.dart';

void main() {
  final now = DateTime.utc(2026, 6, 11);

  group('resolveRecordProcessingStatus', () {
    test('null result is processing', () {
      expect(
        resolveRecordProcessingStatus(null),
        RecordProcessingStatus.processing,
      );
    });

    test('extraction warning is pending', () {
      final result = OcrResult(
        documentId: 'd1',
        extractedText: 'text',
        summary: 'summary',
        createdAt: now,
        extractionWarning: 'Low confidence',
      );
      expect(
        resolveRecordProcessingStatus(result),
        RecordProcessingStatus.pending,
      );
    });

    test('completed OCR is verified', () {
      final result = OcrResult(
        documentId: 'd1',
        extractedText: 'text',
        summary: 'summary',
        createdAt: now,
        processingVersion: 2,
      );
      expect(
        resolveRecordProcessingStatus(result),
        RecordProcessingStatus.verified,
      );
    });
  });

  group('recordCategoryFilterProvider', () {
    test('defaults to all', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(recordCategoryFilterProvider),
        RecordCategoryFilter.all,
      );
    });
  });
}
