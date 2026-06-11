/// Clinical significance of an individual finding from medical analysis.
enum FindingStatus {
  high,
  low,
  abnormal,
  positive,
  negative,
}

/// A clinically significant finding extracted from a medical document.
class CriticalFinding {
  const CriticalFinding({
    required this.title,
    required this.status,
    this.value,
  });

  final String title;
  final FindingStatus status;
  final String? value;
}
