import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/ocr/data/models/critical_finding_model.dart';
import 'package:mobile_app/features/ocr/domain/entities/critical_finding.dart';

void main() {
  group('CriticalFindingModel', () {
    test('fromMap parses valid finding', () {
      final model = CriticalFindingModel.fromMap({
        'title': 'Glucose',
        'status': 'high',
        'value': '180 mg/dL',
      });

      expect(model, isNotNull);
      expect(model!.title, 'Glucose');
      expect(model.status, 'high');
      expect(model.value, '180 mg/dL');
    });

    test('fromMap returns null for invalid entries', () {
      expect(CriticalFindingModel.fromMap(null), isNull);
      expect(CriticalFindingModel.fromMap({'title': 1}), isNull);
      expect(CriticalFindingModel.fromMap({'status': 'high'}), isNull);
    });

    test('listFromDynamic skips invalid items', () {
      final list = CriticalFindingModel.listFromDynamic([
        {'title': 'A', 'status': 'low'},
        'invalid',
        {'title': 'B', 'status': 'abnormal'},
      ]);

      expect(list, hasLength(2));
      expect(list[0].title, 'A');
      expect(list[1].title, 'B');
    });

    test('toEntity maps all status values', () {
      expect(
        CriticalFindingModel(title: 'x', status: 'high').toEntity().status,
        FindingStatus.high,
      );
      expect(
        CriticalFindingModel(title: 'x', status: 'positive').toEntity().status,
        FindingStatus.positive,
      );
      expect(
        CriticalFindingModel(title: 'x', status: 'unknown').toEntity().status,
        FindingStatus.abnormal,
      );
    });

    test('round-trips through fromEntity and toMap', () {
      const entity = CriticalFinding(
        title: 'HbA1c',
        status: FindingStatus.low,
        value: '4.2%',
      );
      final map = CriticalFindingModel.fromEntity(entity).toMap();

      expect(map, {
        'title': 'HbA1c',
        'status': 'low',
        'value': '4.2%',
      });
    });
  });
}
