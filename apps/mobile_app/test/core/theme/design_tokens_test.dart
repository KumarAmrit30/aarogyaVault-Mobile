import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_radius.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppColors', () {
    test('light primary matches Stitch export sampling', () {
      expect(AppColors.primary, const Color(0xFF0F766E));
      expect(AppColors.primaryDark, const Color(0xFF005C55));
      expect(AppColors.lightBackground, const Color(0xFFF7FAF8));
    });

    test('dark primary matches Stitch export sampling', () {
      expect(AppColors.primaryBright, const Color(0xFF14B8A6));
      expect(AppColors.primaryBrightAlt, const Color(0xFF4FD1C5));
      expect(AppColors.darkBackground, const Color(0xFF131313));
    });

    test('semantic colors', () {
      expect(AppColors.error, const Color(0xFFBA1A1A));
      expect(AppColors.success, const Color(0xFF00AA55));
    });
  });

  group('AppSpacing', () {
    test('uses 4px base grid', () {
      expect(AppSpacing.xs, AppSpacing.unit * 2);
      expect(AppSpacing.md, AppSpacing.unit * 4);
      expect(AppSpacing.buttonHeight, 52);
    });
  });

  group('AppRadius', () {
    test('card and pill radii', () {
      expect(AppRadius.lg, 16);
      expect(AppRadius.md, 12);
      expect(AppRadius.pill, 100);
    });
  });

  group('AppTheme', () {
    test('light theme uses extracted palette', () {
      final theme = AppTheme.lightTheme;
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.scaffoldBackgroundColor, AppColors.lightBackground);
      expect(theme.textTheme.bodyLarge?.fontFamily, 'Inter');
    });

    test('dark theme uses extracted palette', () {
      final theme = AppTheme.darkTheme;
      expect(theme.colorScheme.primary, AppColors.primaryBright);
      expect(theme.scaffoldBackgroundColor, AppColors.darkBackground);
    });
  });
}
