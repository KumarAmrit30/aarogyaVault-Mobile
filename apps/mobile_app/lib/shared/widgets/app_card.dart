import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_radius.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

enum AppCardVariant { elevated, filled, outlined }

/// Stitch card container with elevation, fill, or dashed-outline variants.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.onTap,
    this.borderRadius,
  });

  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? AppRadius.radiusLg;
    final resolvedPadding =
        padding ?? const EdgeInsets.all(AppSpacing.cardPadding);
    final resolvedMargin = margin ?? EdgeInsets.zero;

    final Color bg = backgroundColor ??
        switch (variant) {
          AppCardVariant.filled => isDark
              ? AppColors.primaryBright
              : AppColors.primary,
          AppCardVariant.elevated => isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          AppCardVariant.outlined => isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
        };

    final decoration = BoxDecoration(
      color: bg,
      borderRadius: radius,
      border: variant == AppCardVariant.outlined
          ? Border.all(
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorderStrong,
            )
          : null,
      boxShadow: variant == AppCardVariant.elevated
          ? (isDark ? AppTheme.cardShadowDark : AppTheme.cardShadow)
          : null,
    );

    Widget content = Container(
      margin: resolvedMargin,
      padding: resolvedPadding,
      decoration: decoration,
      child: child,
    );

    if (variant == AppCardVariant.outlined) {
      content = Container(
        margin: resolvedMargin,
        padding: resolvedPadding,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorderStrong,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: child,
      );
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Dashed-outline empty-state container from Record Library designs.
class AppDashedCard extends StatelessWidget {
  const AppDashedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final resolvedPadding =
        padding ?? const EdgeInsets.all(AppSpacing.xl);

    return Container(
      margin: margin ?? EdgeInsets.zero,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorderStrong,
          radius: (borderRadius ?? AppRadius.radiusLg).topLeft.x,
        ),
        child: Padding(
          padding: resolvedPadding,
          child: child,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    canvas.drawPath(
      _dashPath(path, dashArray: const [6, 4]),
      paint,
    );
  }

  Path _dashPath(Path source, {required List<double> dashArray}) {
    final dashed = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      var dashIndex = 0;
      while (distance < metric.length) {
        final length = dashArray[dashIndex % dashArray.length];
        final end = distance + length;
        if (dashIndex.isEven) {
          dashed.addPath(
            metric.extractPath(distance, end.clamp(0, metric.length)),
            Offset.zero,
          );
        }
        distance = end;
        dashIndex++;
      }
    }
    return dashed;
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
