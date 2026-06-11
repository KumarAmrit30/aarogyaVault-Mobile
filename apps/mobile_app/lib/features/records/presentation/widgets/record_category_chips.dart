import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_radius.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/features/records/application/records_providers.dart';
import 'package:mobile_app/features/records/domain/enums/record_category_filter.dart';

/// Horizontal category filter chips (All, Prescriptions, Lab Reports).
class RecordCategoryChips extends ConsumerWidget {
  const RecordCategoryChips({super.key});

  static const _filters = RecordCategoryFilter.values;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(recordCategoryFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isActive = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: FilterChip(
              label: Text(filter.label),
              selected: isActive,
              showCheckmark: false,
              onSelected: (_) {
                ref
                    .read(recordCategoryFilterProvider.notifier)
                    .select(filter);
              },
              labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isActive
                        ? (isDark
                            ? AppColors.darkOnPrimary
                            : AppColors.lightSurface)
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightChipInactiveText),
                    fontWeight: FontWeight.w600,
                  ),
              backgroundColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.lightChipInactiveBg,
              selectedColor:
                  isDark ? AppColors.primaryBright : AppColors.primaryDark,
              side: BorderSide(
                color: isActive
                    ? (isDark
                        ? AppColors.primaryBright
                        : AppColors.primaryDark)
                    : (isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusPill,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
