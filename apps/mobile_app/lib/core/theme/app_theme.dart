import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_radius.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/core/theme/app_typography.dart';

/// Application theme assembled from Stitch design tokens.
abstract final class AppTheme {
  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.lightSurface,
          secondary: AppColors.primaryLight,
          onSecondary: AppColors.lightSurface,
          error: AppColors.error,
          onError: AppColors.lightSurface,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightTextPrimary,
          surfaceContainerHighest: AppColors.lightSurfaceMuted,
          outline: AppColors.lightBorder,
          outlineVariant: AppColors.lightBorderStrong,
        ),
        scaffoldBackground: AppColors.lightBackground,
        appBarBackground: AppColors.lightBackground,
        appBarForeground: AppColors.primary,
        textTheme: AppTypography.textTheme(Brightness.light),
        divider: AppColors.lightBorder,
        cardColor: AppColors.lightSurface,
        inputFill: AppColors.lightSurface,
        systemOverlay: SystemUiOverlayStyle.dark,
      );

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.primaryBright,
          onPrimary: AppColors.darkOnPrimary,
          secondary: AppColors.primaryBrightAlt,
          onSecondary: AppColors.darkOnPrimary,
          error: AppColors.error,
          onError: AppColors.darkTextPrimary,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          surfaceContainerHighest: AppColors.darkSurfaceElevated,
          outline: AppColors.darkBorder,
          outlineVariant: AppColors.darkBorder,
        ),
        scaffoldBackground: AppColors.darkBackground,
        appBarBackground: AppColors.darkBackground,
        appBarForeground: AppColors.primaryBright,
        textTheme: AppTypography.textTheme(Brightness.dark),
        divider: AppColors.darkBorder,
        cardColor: AppColors.darkSurface,
        inputFill: AppColors.darkSurfaceInput,
        systemOverlay: SystemUiOverlayStyle.light,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color appBarBackground,
    required Color appBarForeground,
    required TextTheme textTheme,
    required Color divider,
    required Color cardColor,
    required Color inputFill,
    required SystemUiOverlayStyle systemOverlay,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      dividerColor: divider,
      cardColor: cardColor,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          color: appBarForeground,
          fontSize: 18,
        ),
        systemOverlayStyle: systemOverlay,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLg,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: divider,
      ),
    );
  }

  /// Card shadow used on elevated surfaces (light mode).
  static List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ];

  /// Card shadow for dark mode surfaces.
  static List<BoxShadow> get cardShadowDark => const [
        BoxShadow(
          color: AppColors.shadowDark,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ];
}
