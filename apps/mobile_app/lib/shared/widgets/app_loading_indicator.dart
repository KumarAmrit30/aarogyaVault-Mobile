import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_radius.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';

enum AppLoadingVariant { circular, linear, skeleton }

/// Stitch loading indicators: splash progress, skeleton placeholders.
class AppLoadingIndicator extends StatefulWidget {
  const AppLoadingIndicator({
    super.key,
    this.variant = AppLoadingVariant.circular,
    this.value,
    this.message,
    this.skeletonLines = 3,
  });

  final AppLoadingVariant variant;
  final double? value;
  final String? message;
  final int skeletonLines;

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        switch (widget.variant) {
          AppLoadingVariant.circular => SizedBox(
              height: AppSpacing.iconSize,
              width: AppSpacing.iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: isDark
                    ? AppColors.primaryBright
                    : AppColors.primary,
              ),
            ),
          AppLoadingVariant.linear => _LinearProgress(
              value: widget.value,
              isDark: isDark,
            ),
          AppLoadingVariant.skeleton => _SkeletonBlock(
              lines: widget.skeletonLines,
              isDark: isDark,
              animation: _shimmerController,
            ),
        },
        if (widget.message != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.message!,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _LinearProgress extends StatelessWidget {
  const _LinearProgress({required this.isDark, this.value});

  final bool isDark;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.radiusPill,
      child: SizedBox(
        height: 4,
        width: double.infinity,
        child: LinearProgressIndicator(
          value: value,
          backgroundColor:
              isDark ? AppColors.darkBorder : AppColors.lightBorder,
          color: isDark ? AppColors.primaryBright : AppColors.primary,
          minHeight: 4,
        ),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.lines,
    required this.isDark,
    required this.animation,
  });

  final int lines;
  final bool isDark;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final base = isDark ? AppColors.darkSurfaceElevated : AppColors.lightBorder;
    final highlight =
        isDark ? AppColors.darkBorder : AppColors.lightSurfaceMuted;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(lines, (index) {
            final widthFactor = index.isEven ? 1.0 : 0.65;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == lines - 1 ? 0 : AppSpacing.sm,
              ),
              child: FractionallySizedBox(
                widthFactor: widthFactor,
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.radiusSm,
                    gradient: LinearGradient(
                      begin: Alignment(-1 + animation.value * 2, 0),
                      end: Alignment(animation.value * 2, 0),
                      colors: [base, highlight, base],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Skeleton card placeholder matching dashboard / library loading screens.
class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: const AppLoadingIndicator(
        variant: AppLoadingVariant.skeleton,
        skeletonLines: 3,
      ),
    );
  }
}
