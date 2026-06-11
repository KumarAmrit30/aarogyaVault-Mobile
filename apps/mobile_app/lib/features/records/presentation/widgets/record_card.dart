import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_radius.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/features/document/domain/entities/app_document.dart';
import 'package:mobile_app/features/document/domain/extensions/document_type_display.dart';
import 'package:mobile_app/features/records/application/records_providers.dart';
import 'package:mobile_app/features/records/domain/enums/record_processing_status.dart';
import 'package:mobile_app/features/records/presentation/utils/record_formatters.dart';
import 'package:mobile_app/shared/widgets/app_card.dart';

/// Stitch record list card with type icon, status badge, and action link.
class RecordCard extends ConsumerWidget {
  const RecordCard({
    super.key,
    required this.document,
    required this.onTap,
  });

  final AppDocument document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final status = ref.watch(recordProcessingStatusProvider(document.id));

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TypeIcon(document: document, isDark: isDark),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            recordDisplayTitle(document),
                            style: textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _StatusBadge(status: status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${document.documentType.displayName} • '
                      '${formatRecordDate(document.createdAt)}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                status.actionLabel,
                style: textTheme.labelMedium?.copyWith(
                  color: isDark
                      ? AppColors.primaryBright
                      : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: AppSpacing.iconSizeSm,
                color: isDark ? AppColors.primaryBright : AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.document, required this.isDark});

  final AppDocument document;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.iconContainerSize,
      height: AppSpacing.iconContainerSize,
      decoration: BoxDecoration(
        color: document.documentType.iconTintBackground(isDark),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Icon(
        document.documentType.icon,
        color: document.documentType.iconTintForeground(isDark),
        size: AppSpacing.iconSize,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final RecordProcessingStatus status;

  @override
  Widget build(BuildContext context) {
    final isVerified = status == RecordProcessingStatus.verified;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: isVerified
            ? AppColors.lightBadgeVerifiedBg
            : AppColors.lightBadgePendingBg,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Text(
        status.badgeLabel,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isVerified
                  ? AppColors.lightBadgeVerifiedText
                  : AppColors.lightBadgePendingText,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
      ),
    );
  }
}
