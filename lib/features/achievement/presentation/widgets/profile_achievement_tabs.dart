import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/info_bottom_sheet.dart';
import '../../../achievement/achievement_router.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/failures/achievement_failure.dart';
import '../providers/achievement_providers.dart';
import 'achievement_badge_grid.dart';

/// Ringkasan lencana profil: maksimal 3 baris rapat di [FTileGroup].
///
/// Tanpa subtitle: deskripsi 2 baris membuat baris lebih tinggi dari gambar
/// dan menyisakan ruang kosong di bawah lencana (prefix Forui di-center).
/// Belum ada lencana = widget ini ciut, tanpa judul dan tanpa kotak kosong.
///
/// Dipakai tab Profil (profil sendiri, data `/me/achievements`) dan profil
/// publik (lencana milik user lain).
///
/// Lebih dari 3: baris "Lihat lainnya". Profil sendiri membuka halaman
/// Pencapaian. Profil orang lain membuka sheet daftar lengkap.
/// Border tetap diatur via `showBorderPickerSheet`.
class ProfileAchievementTabs extends ConsumerWidget {
  const ProfileAchievementTabs({
    super.key,
    this.username,
    this.title,
    this.showAllButton = true,
    this.showTitle = true,
  });

  /// Null = lencana milik user yang sedang login.
  final String? username;
  final String? title;
  final bool showAllButton;
  final bool showTitle;

  static const previewCount = 3;

  /// Padding baris profil. Default FTile (14.5) + subtitle membuat baris
  /// jauh lebih tinggi dari gambar 28.
  static const rowPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 6);
  static const thumbSize = 28.0;

  void _openAll(BuildContext context) {
    AnalyticsService.instance.logAchievementsView(tab: 'all');
    context.push(AchievementRouter.list.path);
  }

  void _openDetail(BuildContext context, Achievement item) {
    AnalyticsService.instance.logAchievementBadgeView(code: item.code);
    showAppInfoSheet(
      context,
      title: item.title,
      message: AppLocalizations.of(
        context,
      ).achievementDetailOwned(item.description),
    );
  }

  void _showAllBadges(
    BuildContext context,
    List<Achievement> badges,
    String heading,
  ) {
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
                heading,
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
                        _ProfileBadgeTile(
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
    final l10n = AppLocalizations.of(context);
    final heading = title ?? l10n.achievementBadgesTitle;
    final async = username == null
        ? ref.watch(myAchievementsProvider())
        : ref.watch(userAchievementsProvider(username!));

    return async.when(
      loading: () =>
          _AchievementTabsSkeleton(showTitle: showTitle, title: heading),
      error: (err, _) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FAlert(
              variant: FAlertVariant.destructive,
              title: Text(
                err is AchievementFailure
                    ? err.message
                    : l10n.achievementLoadFailed,
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
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
      data: (items) {
        final badges = AchievementBadgeGrid.topTierPerFamily(
          items.where((e) => e.isOwned && e.isBadge).toList(growable: false),
        );
        if (badges.isEmpty) return const SizedBox.shrink();
        final overflow = badges.length > previewCount;
        final preview = overflow ? badges.sublist(0, previewCount) : badges;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(12),
            if (showTitle) ...[
              Text(
                heading,
                style: context.theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(8),
            ],
            FTileGroup(
              children: [
                for (final item in preview)
                  _ProfileBadgeTile(
                    item: item,
                    onTap: () => _openDetail(context, item),
                  ),
                if (overflow)
                  FTile(
                    style: _profileBadgeRowStyle,
                    title: Text(
                      l10n.achievementSeeMore,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    suffix: const Icon(FLucideIcons.chevronRight, size: 14),
                    onPress: () {
                      if (username == null) {
                        _openAll(context);
                      } else {
                        _showAllBadges(context, badges, heading);
                      }
                    },
                  ),
              ],
            ),
            if (showAllButton && badges.isNotEmpty && !overflow) ...[
              const Gap(8),
              Align(
                alignment: Alignment.center,
                child: FButton(
                  size: FButtonSizeVariant.xs,
                  variant: FButtonVariant.outline,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => _openAll(context),
                  child: Text(l10n.achievementSeeAll),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Placeholder shimmer: satu baris. Tiga baris akan menyisakan kotak
/// kosong kalau user ternyata belum punya lencana.
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(12),
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
                FTile(
                  style: _profileBadgeRowStyle,
                  prefix: const Bone.square(
                    size: ProfileAchievementTabs.thumbSize,
                  ),
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

const _profileBadgeRowStyle = FItemStyleDelta.delta(
  contentStyle: FItemContentStyleDelta.delta(
    suffixedPadding: EdgeInsetsGeometryDelta.value(
      ProfileAchievementTabs.rowPadding,
    ),
    unsuffixedPadding: EdgeInsetsGeometryDelta.value(
      ProfileAchievementTabs.rowPadding,
    ),
  ),
);

/// Satu lencana di ringkasan profil: gambar + judul, tanpa deskripsi.
class _ProfileBadgeTile extends StatelessWidget with FTileMixin {
  const _ProfileBadgeTile({required this.item, required this.onTap});

  final Achievement item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final url = displayImageUrl(item.badgeUrl, width: 96) ?? item.badgeUrl;
    final Widget thumb;
    if (url == null) {
      thumb = Icon(
        FLucideIcons.award,
        size: 18,
        color: theme.colors.mutedForeground,
      );
    } else {
      thumb = Image.network(
        url,
        width: ProfileAchievementTabs.thumbSize,
        height: ProfileAchievementTabs.thumbSize,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => Icon(
          FLucideIcons.award,
          size: 18,
          color: theme.colors.mutedForeground,
        ),
      );
    }

    return FTile(
      style: _profileBadgeRowStyle,
      prefix: SizedBox(
        width: ProfileAchievementTabs.thumbSize,
        height: ProfileAchievementTabs.thumbSize,
        child: thumb,
      ),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      suffix: const Icon(FLucideIcons.chevronRight, size: 14),
      onPress: onTap,
    );
  }
}
