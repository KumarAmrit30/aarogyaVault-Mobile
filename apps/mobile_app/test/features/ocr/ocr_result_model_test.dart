import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/ocr/data/models/ocr_result_model.dart';
import 'package:mobile_app/features/ocr/domain/entities/critical_finding.dart';
import 'package:mobile_app/features/ocr/domain/entities/ocr_result.dart';

void main() {
  final createdAt = DateTime.utc(2026, 6, 11, 12);

  group('OcrResultModel', () {
    test('fromMap parses v1 legacy record', () {
      final model = OcrResultModel.fromMap('doc-1', {
        'summary': 'Normal CBC',
        'extractedText': 'WBC 7.2',
        'createdAt': Timestamp.fromDate(createdAt),
      });

      expect(model.documentId, 'doc-1');
      expect(model.summary, 'Normal CBC');
      expect(model.extractedText, 'WBC 7.2');
      expect(model.processingVersion, isNull);
      expect(model.criticalFindings, isEmpty);
      expect(model.requiresStorageTextLoad, isFalse);
    });

    test('fromMap parses v2 analyzed record', () {
      final model = OcrResultModel.fromMap('doc-2', {
        'summary': 'Elevated glucose',
        'createdAt': Timestamp.fromDate(createdAt),
        'ocrTextPath': 'ocr-results/doc-2/full_text.txt',
        'ocrCharacterCount': 1200,
        'documentType': 'Lab Report',
        'processingVersion': 2,
        'ocrProvider': 'document_ai',
        'ocrConfidence': 0.91,
        'pageCount': 2,
        'handwritingDetected': false,
        'extractionWarning': 'Low confidence on page 2',
        'criticalFindings': [
          {'title': 'Glucose', 'status': 'high', 'value': '180 mg/dL'},
        ],
        'normalFindings': ['Hemoglobin within range'],
        'recommendedFollowUp': ['Repeat fasting glucose in 2 weeks'],
      });

      expect(model.processingVersion, 2);
      expect(model.ocrProvider, 'document_ai');
      expect(model.ocrConfidence, 0.91);
      expect(model.criticalFindings, hasLength(1));
      expect(model.normalFindings, ['Hemoglobin within range']);
      expect(model.recommendedFollowUp, hasLength(1));
      expect(model.requiresStorageTextLoad, isTrue);
    });

    test('mapRequiresStorageTextLoad static helper', () {
      expect(
        OcrResultModel.mapRequiresStorageTextLoad({
          'ocrTextPath': 'ocr-results/x/full_text.txt',
        }),
        isTrue,
      );
      expect(
        OcrResultModel.mapRequiresStorageTextLoad({
          'extractedText': 'inline',
          'ocrTextPath': 'ocr-results/x/full_text.txt',
        }),
        isFalse,
      );
    });

    test('toEntity resolves Storage text when provided', () {
      final model = OcrResultModel.fromMap('doc-2', {
        'summary': 'Summary',
        'createdAt': Timestamp.fromDate(createdAt),
        'ocrTextPath': 'ocr-results/doc-2/full_text.txt',
        'processingVersion': 2,
      });

      final entity = model.toEntity(resolvedExtractedText: 'Full OCR text');

      expect(entity.extractedText, 'Full OCR text');
      expect(entity.isStorageBacked, isTrue);
      expect(entity.isAnalyzedRecord, isTrue);
    });

    test('toEntity defaults empty text when Storage text missing', () {
      final model = OcrResultModel.fromMap('doc-2', {
        'summary': 'Summary',
        'createdAt': Timestamp.fromDate(createdAt),
        'ocrTextPath': 'ocr-results/doc-2/full_text.txt',
      });

      expect(model.toEntity().extractedText, '');
    });

    test('fromEntity omits inline text for Storage-backed records', () {
      final entity = OcrResult(
        documentId: 'doc-3',
        extractedText: 'loaded from storage',
        summary: 'Summary',
        createdAt: createdAt,
        ocrTextPath: 'ocr-results/doc-3/full_text.txt',
        processingVersion: 2,
        criticalFindings: const [
          CriticalFinding(title: 'A', status: FindingStatus.high),
        ],
      );

      final map = OcrResultModel.fromEntity(entity).toMap();

      expect(map.containsKey('extractedText'), isFalse);
      expect(map['ocrTextPath'], 'ocr-results/doc-3/full_text.txt');
      expect(map['processingVersion'], 2);
      expect(map['criticalFindings'], hasLength(1));
    });
  });
}
