import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/app/router/app_routes.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/features/document/application/document_state_provider.dart';
import 'package:mobile_app/features/records/application/records_providers.dart';
import 'package:mobile_app/features/records/presentation/widgets/record_card.dart';
import 'package:mobile_app/features/records/presentation/widgets/record_category_chips.dart';
import 'package:mobile_app/shared/widgets/app_button.dart';
import 'package:mobile_app/shared/widgets/app_empty_state.dart';
import 'package:mobile_app/shared/widgets/app_loading_indicator.dart';
import 'package:mobile_app/shared/widgets/app_text_field.dart';

/// Record Library tab — Stitch layout wired to Firebase document + OCR data.
class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  Future<void> _onRefresh(WidgetRef ref) async {
    ref.invalidate(userDocumentsProvider);
    await ref.read(userDocumentsProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(filteredDocumentsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.upload),
        backgroundColor:
            isDark ? AppColors.primaryBright : AppColors.primaryDark,
        foregroundColor:
            isDark ? AppColors.darkOnPrimary : AppColors.lightSurface,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _onRefresh(ref),
          color: isDark ? AppColors.primaryBright : AppColors.primary,
          child: CustomScrollView(
            key: const PageStorageKey<String>('records_scroll'),
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _RecordsHeader(isDark: isDark)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppTextField(
                        hintText: 'Search your health records...',
                        readOnly: true,
                        prefixIcon: Icon(Icons.search),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const RecordCategoryChips(),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Newest First',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Icon(
                            Icons.import_export,
                            size: AppSpacing.iconSizeSm,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ),
              documentsAsync.when(
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: Column(
                      children: [
                        AppSkeletonCard(height: 120),
                        SizedBox(height: AppSpacing.cardGap),
                        AppSkeletonCard(height: 120),
                        SizedBox(height: AppSpacing.cardGap),
                        AppSkeletonCard(height: 120),
                      ],
                    ),
                  ),
                ),
                error: (error, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                    child: AppEmptyState(
                      title: 'Unable to load records',
                      subtitle: error.toString(),
                      icon: const Icon(Icons.error_outline),
                      actionLabel: 'Try Again',
                      onAction: () => _onRefresh(ref),
                      actionVariant: AppButtonVariant.primary,
                    ),
                  ),
                ),
                data: (documents) {
                  if (documents.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: AppEmptyState(
                          title: 'Your library is empty',
                          subtitle:
                              "You haven't uploaded any medical records yet. "
                              'Add your first document to keep your health '
                              'history organized.',
                          icon: const Icon(Icons.folder_off_outlined),
                          actionLabel: 'Add New Record',
                          onAction: () => context.go(AppRoutes.upload),
                          actionVariant: AppButtonVariant.primary,
                          useDashedBorder: true,
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final document = documents[index];
                          return RecordCard(
                            document: document,
                            onTap: () => context.push(
                              AppRoutes.recordDetail(document.id),
                            ),
                          );
                        },
                        childCount: documents.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordsHeader extends StatelessWidget {
  const _RecordsHeader({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isDark
                ? AppColors.darkSurfaceElevated
                : AppColors.lightIconTintTeal,
            child: Icon(
              Icons.person_outline,
              size: AppSpacing.iconSizeSm,
              color: isDark ? AppColors.primaryBright : AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Aarogya Vault',
            style: textTheme.titleLarge?.copyWith(
              color: isDark ? AppColors.primaryBright : AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: null,
            icon: Icon(
              Icons.search,
              color: isDark ? AppColors.primaryBright : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
