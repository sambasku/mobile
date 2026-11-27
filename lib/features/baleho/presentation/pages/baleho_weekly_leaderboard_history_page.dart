import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart' show RefreshIndicator;

import '../../../../l10n/app_localizations.dart';
import '../../domain/baleho_models.dart';
import '../providers/weekly_leaderboard_provider.dart';
import '../widgets/weekly_leaderboard_list.dart';

/// Detail peringkat satu minggu riwayat (dibuka dari daftar minggu).
class BalehoWeeklyLeaderboardHistoryPage extends ConsumerWidget {
  const BalehoWeeklyLeaderboardHistoryPage({
    super.key,
    required this.weekId,
  });

  final String weekId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final async = ref.watch(weeklyLeaderboardHistoryProvider(weekId));

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.balehoLeaderboardWeekLabel(weekId)),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(BalehoBoard.weeklyLeaderboardPath),
          ),
        ],
      ),
      child: async.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: FCircularProgress(size: .md)),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.balehoLeaderboardLoadFailed,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: () {
                    ref.invalidate(weeklyLeaderboardHistoryProvider(weekId));
                  },
                  child: Text(l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
        data: (snap) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(weeklyLeaderboardHistoryProvider(weekId));
              await ref.read(weeklyLeaderboardHistoryProvider(weekId).future);
            },
            child: WeeklyLeaderboardEntryList(
              entries: snap?.entries ?? const [],
              l10n: l10n,
              theme: theme,
              header: WeeklyLeaderboardMetaCard(
                theme: theme,
                weekLabel: snap != null && snap.weekId.isNotEmpty
                    ? l10n.balehoLeaderboardWeekLabel(snap.weekId)
                    : l10n.balehoLeaderboardWeekLabel(weekId),
                subtitle: snap?.finalized == true
                    ? null
                    : l10n.balehoLeaderboardHistoryEmpty,
                icon: FLucideIcons.history,
              ),
              emptyMessage: l10n.balehoLeaderboardHistoryEmpty,
            ),
          );
        },
      ),
    );
  }
}
