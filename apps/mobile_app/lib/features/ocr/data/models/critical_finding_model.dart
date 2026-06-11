import 'package:mobile_app/features/ocr/domain/entities/critical_finding.dart';

/// Firestore representation of a [CriticalFinding].
class CriticalFindingModel {
  const CriticalFindingModel({
    required this.title,
    required this.status,
    this.value,
  });

  final String title;
  final String status;
  final String? value;

  /// Parses a Firestore map entry; returns null when invalid.
  static CriticalFindingModel? fromMap(dynamic raw) {
    if (raw is! Map) {
      return null;
    }
    final map = Map<String, dynamic>.from(raw);
    final title = map['title'];
    final status = map['status'];
    if (title is! String || status is! String) {
      return null;
    }
    final value = map['value'];
    return CriticalFindingModel(
      title: title,
      status: status,
      value: value is String ? value : null,
    );
  }

  static List<CriticalFindingModel> listFromDynamic(dynamic raw) {
    if (raw is! List) {
      return const [];
    }
    return raw
        .map(CriticalFindingModel.fromMap)
        .whereType<CriticalFindingModel>()
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'status': status,
      if (value != null) 'value': value,
    };
  }

  CriticalFinding toEntity() {
    return CriticalFinding(
      title: title,
      status: _parseStatus(status),
      value: value,
    );
  }

  static CriticalFindingModel fromEntity(CriticalFinding finding) {
    return CriticalFindingModel(
      title: finding.title,
      status: finding.status.name,
      value: finding.value,
    );
  }

  static FindingStatus _parseStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'high':
        return FindingStatus.high;
      case 'low':
        return FindingStatus.low;
      case 'positive':
        return FindingStatus.positive;
      case 'negative':
        return FindingStatus.negative;
      default:
        return FindingStatus.abnormal;
    }
  }
}
