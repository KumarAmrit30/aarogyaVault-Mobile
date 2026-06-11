import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/ocr/data/mappers/ocr_result_mapper.dart';
import 'package:mobile_app/features/ocr/domain/entities/critical_finding.dart';
import 'package:mobile_app/features/ocr/domain/entities/ocr_result.dart';

void main() {
  final createdAt = DateTime.utc(2026, 6, 11, 12);

  group('OcrResultMapper', () {
    test('fromMap maps v1 record with inline text', () {
      final result = OcrResultMapper.fromMap('doc-v1', {
        'summary': 'Legacy summary',
        'extractedText': 'Inline OCR text',
        'createdAt': Timestamp.fromDate(createdAt),
      });

      expect(result.documentId, 'doc-v1');
      expect(result.extractedText, 'Inline OCR text');
      expect(result.isLegacyRecord, isTrue);
      expect(result.hasMedicalAnalysis, isFalse);
    });

    test('fromMap maps v2 record with resolved Storage text', () {
      final result = OcrResultMapper.fromMap(
        'doc-v2',
        {
          'summary': 'Analyzed summary',
          'createdAt': Timestamp.fromDate(createdAt),
          'ocrTextPath': 'ocr-results/doc-v2/full_text.txt',
          'processingVersion': 2,
          'documentType': 'Prescription',
          'ocrConfidence': 0.82,
          'handwritingDetected': true,
          'criticalFindings': [
            {'title': 'Metformin', 'status': 'positive'},
          ],
          'normalFindings': ['No allergies noted'],
          'recommendedFollowUp': ['Take with meals'],
        },
        resolvedExtractedText: 'Handwritten prescription text',
      );

      expect(result.extractedText, 'Handwritten prescription text');
      expect(result.isAnalyzedRecord, isTrue);
      expect(result.documentType, 'Prescription');
      expect(result.handwritingDetected, isTrue);
      expect(result.criticalFindings, hasLength(1));
      expect(result.criticalFindings.first.status, FindingStatus.positive);
      expect(result.hasMedicalAnalysis, isTrue);
    });

    test('requiresStorageTextLoad delegates to model', () {
      expect(
        OcrResultMapper.requiresStorageTextLoad({
          'ocrTextPath': 'ocr-results/x/full_text.txt',
        }),
        isTrue,
      );
    });

    test('toMap round-trips v2 entity fields', () {
      final entity = OcrResult(
        documentId: 'doc-v2',
        extractedText: 'text',
        summary: 'Summary',
        createdAt: createdAt,
        ocrTextPath: 'ocr-results/doc-v2/full_text.txt',
        processingVersion: 2,
        ocrConfidence: 0.88,
        extractionWarning: 'Verify dosage',
        normalFindings: const ['Kidney function normal'],
      );

      final map = OcrResultMapper.toMap(entity);

      expect(map['processingVersion'], 2);
      expect(map['ocrConfidence'], 0.88);
      expect(map['extractionWarning'], 'Verify dosage');
      expect(map['normalFindings'], ['Kidney function normal']);
      expect(map.containsKey('extractedText'), isFalse);
    });
  });
}
