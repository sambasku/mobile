import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../shared/utils/info_bottom_sheet.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/failures/achievement_failure.dart';
import '../providers/achievement_providers.dart';
import '../../../achievement/achievement_router.dart';
import 'achievement_badge_grid.dart';
import 'achievement_tile.dart';
import '../../../../l10n/app_localizations.dart';

/// Ringkasan lencana profil: max 3 baris [AchievementTile] (pola inbox notif).
///
/// Dipakai tab Profil (profil sendiri, data `/me/achievements`) dan profil
/// publik. Pengganti grid kartu compact. Border tetap diatur via
/// `showBorderPickerSheet`.
///
/// Lebih dari 3 lencana: tombol "Lihat lainnya". Profil sendiri membuka
/// halaman Pencapaian. Profil orang lain membuka sheet daftar penuh.
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

  static const int previewLimit = 3;

  void _openAll(BuildContext context) {
    AnalyticsService.instance.logAchievementsView(tab: 'all');
    context.push(AchievementRouter.list.path);
  }

  void _openDetail(BuildContext context, Achievement item) {
    final l10n = AppLocalizations.of(context);
    AnalyticsService.instance.logAchievementBadgeView(code: item.code);
    final String message;
    if (item.isOwned) {
      message = l10n.achievementDetailOwned(item.description);
    } else if (item.progress != null) {
      message = l10n.achievementDetailLockedProgress(
        item.description,
        item.progress!.current,
        item.progress!.target,
      );
    } else {
      message = l10n.achievementDetailLocked(item.description);
    }
    showAppInfoSheet(
      context,
      title: item.title,
      message: message,
      leading: AchievementBadgeArt(item: item),
    );
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
                  child: FTileGroup(
                    children: [
                      for (final item in badges)
                        AchievementTile(
                          item: item,
                          onTap: () => _openDetail(sheetContext, item),
                        ),
                    ],
                  ),
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
        final l10n = AppLocalizations.of(context);
        final badges = AchievementBadgeGrid.topTierPerFamily(
          items.where((e) => e.isOwned && e.isBadge).toList(growable: false),
        );
        final overflow = badges.length > previewLimit;
        final visible = overflow
            ? badges.sublist(0, previewLimit)
            : badges;

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
            if (badges.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.achievementEmpty,
                  textAlign: TextAlign.center,
                  style: context.theme.typography.body.sm.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
              )
            else
              FTileGroup(
                children: [
                  for (final item in visible)
                    AchievementTile(
                      item: item,
                      dense: true,
                      onTap: () => _openDetail(context, item),
                    ),
                ],
              ),
            if (overflow || (showAllButton && badges.isNotEmpty)) ...[
              const Gap(8),
              Align(
                alignment: Alignment.center,
                child: FButton(
                  size: FButtonSizeVariant.xs,
                  variant: FButtonVariant.outline,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () {
                    if (username == null) {
                      _openAll(context);
                    } else {
                      _showAllBadges(context, badges);
                    }
                  },
                  child: Text(
                    overflow
                        ? l10n.achievementSeeMore
                        : l10n.achievementSeeAll,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Placeholder shimmer: 3 baris tile padat (ikon kecil + judul).
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
            FTileGroup(
              children: [
                for (var i = 0; i < ProfileAchievementTabs.previewLimit; i++)
                  FTile(
                    prefix: const Bone.circle(size: 28),
                    title: const Bone.text(words: 2),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
