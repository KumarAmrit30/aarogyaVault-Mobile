import 'package:flutter/material.dart';

/// Color tokens extracted from Stitch design exports.
///
/// Values are sampled from the attached PNG source files (light + dark sets).
abstract final class AppColors {
  // --- Shared brand ---
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryDark = Color(0xFF005C55);
  static const Color primaryLight = Color(0xFF127870);
  static const Color primaryBright = Color(0xFF14B8A6);
  static const Color primaryBrightAlt = Color(0xFF4FD1C5);

  static const Color success = Color(0xFF00AA55);
  static const Color error = Color(0xFFBA1A1A);
  static const Color warning = Color(0xFFE7D394);

  // --- Light theme ---
  static const Color lightBackground = Color(0xFFF7FAF8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF5F8F6);
  static const Color lightBorder = Color(0xFFE5EEEE);
  static const Color lightBorderStrong = Color(0xFFBDC9C6);
  static const Color lightTextPrimary = Color(0xFF181C1C);
  static const Color lightTextSecondary = Color(0xFF6C7573);
  static const Color lightTextMuted = Color(0xFF9AA19F);
  static const Color lightIconTintTeal = Color(0xFFEFF5F3);
  static const Color lightIconTintPeach = Color(0xFFF2EBE9);
  static const Color lightBadgeVerifiedBg = Color(0xFFE0F2F1);
  static const Color lightBadgeVerifiedText = Color(0xFF0F766E);
  static const Color lightBadgePendingBg = Color(0xFFFFF8E1);
  static const Color lightBadgePendingText = Color(0xFF8B6914);
  static const Color lightChipInactiveBg = Color(0xFFE5E9E7);
  static const Color lightChipInactiveText = Color(0xFF6C7573);

  // Splash gradient (light)
  static const Color splashGradientTop = Color(0xFFE0F7F5);
  static const Color splashGradientMid = Color(0xFFE1F0F0);
  static const Color splashGradientBottom = Color(0xFFFFFFFF);
  static const Color splashGlow = Color(0xFFCEF8F4);
  static const Color splashSecurityBadgeBg = Color(0xFFEBF2F4);

  // --- Dark theme ---
  static const Color darkBackground = Color(0xFF131313);
  static const Color darkSurface = Color(0xFF201F1F);
  static const Color darkSurfaceElevated = Color(0xFF2A2A2A);
  static const Color darkSurfaceInput = Color(0xFF2F3231);
  static const Color darkBorder = Color(0xFF343332);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFBBCAC6);
  static const Color darkTextMuted = Color(0xFF919C99);
  static const Color darkNavActivePill = Color(0xFF1A3E3A);
  static const Color darkOnPrimary = Color(0xFF131313);

  // Upload failed (light) background wash
  static const Color lightErrorWash = Color(0xFFF5E5E3);

  // Shadows
  static const Color shadowLight = Color(0x0D0F172A);
  static const Color shadowDark = Color(0x33000000);
}
