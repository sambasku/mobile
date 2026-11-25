import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/format_number.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../baleho/domain/points_history_models.dart';
import '../../../baleho/presentation/providers/weekly_leaderboard_provider.dart';

/// Layar riwayat pergerakan poin mingguan dan snapshot EXP akun.
class ExpHistoryPage extends ConsumerWidget {
  const ExpHistoryPage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final historyAsync = ref.watch(userPointsHistoryProvider(username));

    ref.listen(userPointsHistoryProvider(username), (prev, next) {
      if (next.hasError && context.mounted) {
        final err = next.error;
        showAppErrorSheet(
          context,
          message: err is Exception ? err.toString() : 'Gagal memuat riwayat.',
        );
      }
    });

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.expHistoryTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      child: historyAsync.when(
        loading: () => const Center(
          child: FCircularProgress(size: .md),
        ),
        error: (_, _) => Center(
          child: FButton(
            onPress: () => ref.invalidate(userPointsHistoryProvider(username)),
            child: Text(l10n.commonRetry),
          ),
        ),
        data: (viewData) {
          final items = viewData.history;
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FLucideIcons.history,
                      size: 40,
                      color: theme.colors.mutedForeground,
                    ),
                    const Gap(12),
                    Text(
                      l10n.expHistoryEmpty,
                      textAlign: TextAlign.center,
                      style: theme.typography.body.md.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Gap(8),
            itemBuilder: (context, index) {
              final item = items[index];
              return _HistoryCard(item: item);
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});

  final UserWeekPointHistory item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.weekId,
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l10n.expHistoryWeeklyPoints(formatRibuan(item.combined)),
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colors.primary,
                  ),
                ),
              ],
            ),
            const Gap(4),
            Text(
              l10n.expHistoryWeekEndXp(item.xpAtWeekEnd),
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const Gap(6),
            Text(
              l10n.expHistoryBreakdown(
                item.submittedPoints,
                item.approvedPoints,
                item.verificationPoints,
              ),
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
