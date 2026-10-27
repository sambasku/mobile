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
    final async = ref.watch(myAchievementsProvider());
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(AppLocalizations.of(context).achievementTitle),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: async.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (err, _) => _ErrorState(
          message: err is AchievementFailure
              ? err.message
              : 'Gagal memuat pencapaian',
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
    AnalyticsService.instance.logAchievementBadgeView(code: item.code);
    showAppInfoSheet(
      context,
      title: item.title,
      message: item.isOwned
          ? '${item.description}\n\nSudah kamu miliki'
          : '${item.description}\n\nBelum dibuka',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
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
            'Lencana terbuka',
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
            'Dimiliki',
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
            'Belum dibuka',
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
              'Belum ada pencapaian tersedia.',
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
