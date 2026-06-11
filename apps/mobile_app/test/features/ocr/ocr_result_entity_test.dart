import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/ocr/domain/entities/critical_finding.dart';
import 'package:mobile_app/features/ocr/domain/entities/ocr_result.dart';

void main() {
  group('OcrResult', () {
    test('isLegacyRecord for null and v1 processingVersion', () {
      final v1 = OcrResult(
        documentId: 'd',
        extractedText: 't',
        summary: 's',
        createdAt: _date,
        processingVersion: 1,
      );
      final unversioned = OcrResult(
        documentId: 'd',
        extractedText: 't',
        summary: 's',
        createdAt: _date,
      );

      expect(v1.isLegacyRecord, isTrue);
      expect(unversioned.isLegacyRecord, isTrue);
    });

    test('isAnalyzedRecord and hasMedicalAnalysis for v2', () {
      final v2 = OcrResult(
        documentId: 'd',
        extractedText: 't',
        summary: 's',
        createdAt: _date,
        processingVersion: 2,
        documentType: 'Lab Report',
        criticalFindings: const [
          CriticalFinding(title: 'Glucose', status: FindingStatus.high),
        ],
      );

      expect(v2.isAnalyzedRecord, isTrue);
      expect(v2.hasMedicalAnalysis, isTrue);
    });

    test('isLowConfidence below threshold', () {
      final low = OcrResult(
        documentId: 'd',
        extractedText: 't',
        summary: 's',
        createdAt: _date,
        ocrConfidence: 0.5,
      );
      final ok = OcrResult(
        documentId: 'd',
        extractedText: 't',
        summary: 's',
        createdAt: _date,
        ocrConfidence: 0.9,
      );

      expect(low.isLowConfidence, isTrue);
      expect(ok.isLowConfidence, isFalse);
    });

    test('hasExtractionWarning', () {
      final warned = OcrResult(
        documentId: 'd',
        extractedText: 't',
        summary: 's',
        createdAt: _date,
        extractionWarning: 'Handwriting detected',
      );
      final clean = OcrResult(
        documentId: 'd',
        extractedText: 't',
        summary: 's',
        createdAt: _date,
      );

      expect(warned.hasExtractionWarning, isTrue);
      expect(clean.hasExtractionWarning, isFalse);
    });
  });
}

final _date = DateTime.utc(2026, 6, 11);
