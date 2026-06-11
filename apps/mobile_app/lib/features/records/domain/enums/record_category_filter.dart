/// Category filter chips on the Record Library screen.
enum RecordCategoryFilter {
  all,
  prescriptions,
  labReports,
}

extension RecordCategoryFilterX on RecordCategoryFilter {
  String get label => switch (this) {
        RecordCategoryFilter.all => 'All',
        RecordCategoryFilter.prescriptions => 'Prescriptions',
        RecordCategoryFilter.labReports => 'Lab Reports',
      };
}
