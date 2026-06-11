import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/features/document/domain/enums/document_type.dart';

extension DocumentTypeDisplay on DocumentType {
  String get displayName => switch (this) {
        DocumentType.prescription => 'Prescription',
        DocumentType.labReport => 'Lab Report',
        DocumentType.vaccination => 'Vaccination',
        DocumentType.insurance => 'Insurance',
        DocumentType.dischargeSummary => 'Discharge Summary',
        DocumentType.medicalCertificate => 'Medical Certificate',
        DocumentType.other => 'Medical Document',
      };

  IconData get icon => switch (this) {
        DocumentType.prescription => Icons.medication_outlined,
        DocumentType.labReport => Icons.biotech_outlined,
        DocumentType.vaccination => Icons.vaccines_outlined,
        DocumentType.insurance => Icons.health_and_safety_outlined,
        DocumentType.dischargeSummary => Icons.description_outlined,
        DocumentType.medicalCertificate => Icons.assignment_outlined,
        DocumentType.other => Icons.folder_open_outlined,
      };

  Color iconTintBackground(bool isDark) {
    if (isDark) {
      return AppColors.darkSurfaceElevated;
    }
    return switch (this) {
      DocumentType.prescription ||
      DocumentType.labReport ||
      DocumentType.medicalCertificate =>
        AppColors.lightIconTintTeal,
      DocumentType.vaccination || DocumentType.insurance =>
        AppColors.lightIconTintPeach,
      DocumentType.dischargeSummary || DocumentType.other =>
        AppColors.lightSurfaceMuted,
    };
  }

  Color iconTintForeground(bool isDark) =>
      isDark ? AppColors.primaryBright : AppColors.primary;
}
