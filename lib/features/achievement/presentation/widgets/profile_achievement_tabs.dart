import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/services/analytics_service.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/failures/achievement_failure.dart';
import '../providers/achievement_providers.dart';
import '../../../achievement/achievement_router.dart';
import 'achievement_badge_grid.dart';
import '../../../../l10n/app_localizations.dart';

/// Ringkasan lencana profil: 1 baris, 4 lencana kecil.
///
/// Dipakai tab Profil (profil sendiri, data `/me/achievements`) dan profil
/// publik (lencana milik user lain). Pengganti sub-tab FTabs
/// "Badge | Border | Pencapaian" yang pecah (label multiline merusak area).
/// Border tetap diatur via `showBorderPickerSheet`.
///
/// Lebih dari 4 lencana: sel ujung overlay "Lihat lainnya". Profil sendiri
/// membuka halaman Pencapaian. Profil orang lain membuka sheet grid penuh.
class ProfileAchievementTabs extends ConsumerWidget {
  const ProfileAchievementTabs({
    super.key,
    this.username,
    this.title = 'Lencana',
    this.showAllButton = true,
    this.showTitle = true,
  });

  /// Null = lencana milik user yang sedang login.
  final String? username;
  final String title;
  final bool showAllButton;
  final bool showTitle;

  void _openAll(BuildContext context) {
    AnalyticsService.instance.logAchievementsView(tab: 'all');
    context.push(AchievementRouter.list.path);
  }

  void _showAllBadges(BuildContext context, List<Achievement> badges) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final theme = sheetContext.theme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: AchievementBadgeGrid(items: badges),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = username == null
        ? ref.watch(myAchievementsProvider())
        : ref.watch(userAchievementsProvider(username!));

    return async.when(
      loading: () =>
          _AchievementTabsSkeleton(showTitle: showTitle, title: title),
      error: (err, _) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          children: [
            FAlert(
              variant: FAlertVariant.destructive,
              title: Text(
                err is AchievementFailure
                    ? err.message
                    : 'Gagal memuat pencapaian',
              ),
            ),
            const Gap(8),
            FButton(
              variant: FButtonVariant.outline,
              size: .xs,
              onPress: () => ref.invalidate(
                username == null
                    ? myAchievementsProvider()
                    : userAchievementsProvider(username!),
              ),
              child: Text(AppLocalizations.of(context).commonRetry),
            ),
          ],
        ),
      ),
      data: (items) {
        final badges = AchievementBadgeGrid.topTierPerFamily(
          items.where((e) => e.isOwned && e.isBadge).toList(growable: false),
        );
        const previewColumns = 4;
        const previewRows = 1;
        final overflow = badges.length > previewColumns * previewRows;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showTitle) ...[
              Text(
                title,
                style: context.theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(8),
            ],
            AchievementBadgeGrid(
              items: badges,
              maxRows: previewRows,
              columns: previewColumns,
              compact: true,
              onOverflow: overflow
                  ? () {
                      if (username == null) {
                        _openAll(context);
                      } else {
                        _showAllBadges(context, badges);
                      }
                    }
                  : null,
            ),
            if (showAllButton && badges.isNotEmpty && !overflow) ...[
              const Gap(8),
              // Shrink-wrap supaya sejajar tombol kecil lain (pola FButton
              // default .max = full width).
              Align(
                alignment: Alignment.center,
                child: FButton(
                  size: FButtonSizeVariant.xs,
                  variant: FButtonVariant.outline,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => _openAll(context),
                  child: Text(AppLocalizations.of(context).achievementSeeAll),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Placeholder shimmer: 4 lencana kecil, satu baris.
class _AchievementTabsSkeleton extends StatelessWidget {
  const _AchievementTabsSkeleton({
    required this.showTitle,
    required this.title,
  });

  final bool showTitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.colors.background.computeLuminance() < 0.5;
    final muted = theme.colors.muted;

    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: isDark
            ? muted.withValues(alpha: 0.35)
            : const Color(0xFFE7E7EA),
        highlightColor: isDark
            ? muted.withValues(alpha: 0.55)
            : const Color(0xFFF4F4F5),
        duration: const Duration(milliseconds: 1500),
      ),
      child: IgnorePointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showTitle) ...[
              Text(
                title,
                style: theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(8),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = AchievementBadgeGrid.compactSpacing;
                final cellWidth = (constraints.maxWidth - spacing * 3) / 4;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (var i = 0; i < 4; i++)
                      SizedBox(
                        width: cellWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AchievementBadgeGrid.compactRadius,
                            ),
                            border: Border.all(color: theme.colors.border),
                          ),
                          padding: const EdgeInsets.all(
                            AchievementBadgeGrid.compactPadding,
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: AchievementBadgeGrid.compactImageSize,
                                height: AchievementBadgeGrid.compactImageSize,
                                child: Bone.square(),
                              ),
                              Gap(AchievementBadgeGrid.compactImageGap),
                              Bone.text(words: 1),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
