import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_radius.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outline, text }

enum AppButtonSize { sm, md, lg }

/// Stitch primary / secondary / outline button.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.leading,
    this.trailing,
    this.isExpanded = true,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? leading;
  final Widget? trailing;
  final bool isExpanded;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final height = switch (size) {
      AppButtonSize.sm => 40.0,
      AppButtonSize.md => AppSpacing.buttonHeight,
      AppButtonSize.lg => 56.0,
    };

    final style = _resolveStyle(context, brightness);
    final child = _buildChild(context, style.foreground);

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: style.background,
        foregroundColor: style.foreground,
        disabledBackgroundColor: style.background.withValues(alpha: 0.5),
        disabledForegroundColor: style.foreground.withValues(alpha: 0.5),
        minimumSize: Size(isExpanded ? double.infinity : 0, height),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusPill,
          side: style.border,
        ),
      ),
      child: child,
    );

    if (variant == AppButtonVariant.text) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: style.foreground,
          minimumSize: Size(isExpanded ? double.infinity : 0, height),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusPill),
        ),
        child: child,
      );
    }

    return button;
  }

  Widget _buildChild(BuildContext context, Color foreground) {
    if (isLoading) {
      return SizedBox(
        height: AppSpacing.iconSizeSm,
        width: AppSpacing.iconSizeSm,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: foreground,
        ),
      );
    }

    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        );

    return Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          IconTheme(
            data: IconThemeData(color: foreground, size: AppSpacing.iconSizeSm),
            child: leading!,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(label, style: textStyle),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.xs),
          IconTheme(
            data: IconThemeData(color: foreground, size: AppSpacing.iconSizeSm),
            child: trailing!,
          ),
        ],
      ],
    );
  }

  _ButtonStyle _resolveStyle(BuildContext context, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return switch (variant) {
      AppButtonVariant.primary => _ButtonStyle(
          background: isDark ? AppColors.primaryBrightAlt : AppColors.primary,
          foreground:
              isDark ? AppColors.darkOnPrimary : AppColors.lightSurface,
        ),
      AppButtonVariant.secondary => _ButtonStyle(
          background:
              isDark ? AppColors.darkSurfaceElevated : AppColors.primaryLight,
          foreground:
              isDark ? AppColors.darkTextPrimary : AppColors.lightSurface,
        ),
      AppButtonVariant.outline => _ButtonStyle(
          background: Colors.transparent,
          foreground: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          border: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorderStrong,
          ),
        ),
      AppButtonVariant.text => _ButtonStyle(
          background: Colors.transparent,
          foreground:
              isDark ? AppColors.primaryBright : AppColors.primary,
        ),
    };
  }
}

class _ButtonStyle {
  const _ButtonStyle({
    required this.background,
    required this.foreground,
    this.border = BorderSide.none,
  });

  final Color background;
  final Color foreground;
  final BorderSide border;
}
