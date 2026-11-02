import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../shared/utils/info_bottom_sheet.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/failures/achievement_failure.dart';
import '../providers/achievement_providers.dart';
import '../widgets/achievement_badge_grid.dart';
import '../widgets/achievement_tile.dart';
import '../../../../l10n/app_localizations.dart';

/// Semua pencapaian milik user login: lencana terbuka (grid) + katalog
/// lengkap (dimiliki / belum dibuka). Pengganti sub-tab FTabs di profil
/// yang pecah karena label multiline.
class MyAchievementsPage extends ConsumerWidget {
  const MyAchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(myAchievementsProvider());
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.achievementTitle),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: async.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (err, _) => _ErrorState(
          message: err is AchievementFailure
              ? err.message
              : l10n.achievementLoadFailed,
          onRetry: () => ref.invalidate(myAchievementsProvider),
        ),
        data: (items) => _Body(items: items),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.items});

  final List<Achievement> items;

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
    showAppInfoSheet(context, title: item.title, message: message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final owned = items.where((e) => e.isOwned).toList(growable: false);
    final locked = items.where((e) => !e.isOwned).toList(growable: false);
    final badges = AchievementBadgeGrid.topTierPerFamily(
      owned.where((e) => e.isBadge).toList(growable: false),
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (badges.isNotEmpty) ...[
          Text(
            l10n.achievementOpenBadges,
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
          AchievementBadgeGrid(items: badges),
          const Gap(16),
        ],
        if (owned.isNotEmpty) ...[
          Text(
            l10n.achievementOwnedSection,
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(4),
          FTileGroup(
            children: [
              for (final item in owned)
                AchievementTile(
                  item: item,
                  onTap: () => _openDetail(context, item),
                ),
            ],
          ),
          const Gap(16),
        ],
        if (locked.isNotEmpty) ...[
          Text(
            l10n.achievementLockedSection,
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(4),
          FTileGroup(
            children: [
              for (final item in locked)
                AchievementTile(
                  item: item,
                  onTap: () => _openDetail(context, item),
                ),
            ],
          ),
        ],
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              l10n.achievementCatalogEmpty,
              textAlign: TextAlign.center,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FAlert(variant: FAlertVariant.destructive, title: Text(message)),
            const Gap(8),
            FButton(
              variant: FButtonVariant.outline,
              onPress: onRetry,
              child: Text(AppLocalizations.of(context).commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
