import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../domain/leaderboard_models.dart';
import '../providers/weekly_leaderboard_provider.dart';
import '../widgets/weekly_leaderboard_entry_tile.dart';

enum _LeaderboardTab { current, history }

class BalehoWeeklyLeaderboardPage extends HookConsumerWidget {
  const BalehoWeeklyLeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final tab = useState(_LeaderboardTab.current);
    final weekOptions = ref.watch(weeklyLeaderboardHistoryWeekOptionsProvider);
    final selectedWeek = useState<String?>(
      weekOptions.isNotEmpty ? weekOptions.first : null,
    );

    final currentAsync = ref.watch(weeklyLeaderboardCurrentProvider);
  final historyWeekId = selectedWeek.value ?? '';
    final historyAsync = ref.watch(
      weeklyLeaderboardHistoryProvider(historyWeekId),
    );

    ref.listen(weeklyLeaderboardCurrentProvider, (prev, next) {
      if (next.hasError && context.mounted) {
        final err = next.error;
        final message = err is Exception
            ? err.toString()
            : l10n.balehoLeaderboardLoadFailed;
        showAppErrorSheet(context, message: message);
      }
    });

    ref.listen(weeklyLeaderboardHistoryProvider(historyWeekId), (prev, next) {
      if (next.hasError && context.mounted) {
        final err = next.error;
        final message = err is Exception
            ? err.toString()
            : l10n.balehoLeaderboardLoadFailed;
        showAppErrorSheet(context, message: message);
      }
    });

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.balehoWeeklyLeaderboardTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/baleho'),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: FButton(
                  variant: tab.value == _LeaderboardTab.current
                      ? FButtonVariant.primary
                      : FButtonVariant.ghost,
                  onPress: () => tab.value = _LeaderboardTab.current,
                  child: Text(l10n.balehoLeaderboardTabCurrent),
                ),
              ),
              const Gap(8),
              Expanded(
                child: FButton(
                  variant: tab.value == _LeaderboardTab.history
                      ? FButtonVariant.primary
                      : FButtonVariant.ghost,
                  onPress: () => tab.value = _LeaderboardTab.history,
                  child: Text(l10n.balehoLeaderboardTabHistory),
                ),
              ),
            ],
          ),
          const Gap(12),
          if (tab.value == _LeaderboardTab.current)
            Expanded(
              child: _CurrentTabBody(
                async: currentAsync,
                l10n: l10n,
                theme: theme,
                onRefresh: () async {
                  ref.invalidate(weeklyLeaderboardCurrentProvider);
                  await ref.read(weeklyLeaderboardCurrentProvider.future);
                },
              ),
            )
          else
            Expanded(
              child: _HistoryTabBody(
                weekOptions: weekOptions,
                selectedWeekId: selectedWeek.value,
                onWeekChanged: (id) => selectedWeek.value = id,
                async: historyAsync,
                l10n: l10n,
                theme: theme,
                onRefresh: () async {
                  if (historyWeekId.isEmpty) return;
                  ref.invalidate(weeklyLeaderboardHistoryProvider(historyWeekId));
                  await ref.read(
                    weeklyLeaderboardHistoryProvider(historyWeekId).future,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _CurrentTabBody extends HookWidget {
  const _CurrentTabBody({
    required this.async,
    required this.l10n,
    required this.theme,
    required this.onRefresh,
  });

  final AsyncValue<WeeklyLeaderboardViewData> async;
  final AppLocalizations l10n;
  final FThemeData theme;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final resetsAt = async.asData?.value.resetsAt;
    final tick = useState(0);

    useEffect(() {
      if (resetsAt == null) return null;
      final timer = Timer.periodic(const Duration(seconds: 30), (_) {
        tick.value++;
      });
      return timer.cancel;
    }, [resetsAt?.millisecondsSinceEpoch]);

    return async.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: FCircularProgress(size: .md)),
      error: (_, _) => _ErrorScroll(
        message: l10n.balehoLeaderboardLoadFailed,
        retryLabel: l10n.commonRetry,
        onRetry: () => onRefresh(),
      ),
      data: (view) {
        final _ = tick.value;
        final countdown = _formatCountdown(l10n, view.resetsAt);
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: _EntryList(
            entries: view.entries,
            l10n: l10n,
            theme: theme,
            header: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (view.weekId != null && view.weekId!.isNotEmpty)
                  Text(
                    l10n.balehoLeaderboardWeekLabel(view.weekId!),
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (countdown != null) ...[
                  const Gap(4),
                  Text(
                    countdown,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ] else if (view.resetsAt != null) ...[
                  const Gap(4),
                  Text(
                    l10n.balehoLeaderboardResetsAt(
                      formatDateTime(view.resetsAt),
                    ),
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
                const Gap(8),
              ],
            ),
            emptyMessage: l10n.balehoLeaderboardEmpty,
          ),
        );
      },
    );
  }

  String? _formatCountdown(AppLocalizations l10n, DateTime? resetsAt) {
    if (resetsAt == null) return null;
    final now = DateTime.now();
    var diff = resetsAt.toLocal().difference(now);
    if (diff.isNegative) {
      return l10n.balehoLeaderboardResetsAt(formatDateTime(resetsAt));
    }
    final days = diff.inDays;
    diff -= Duration(days: days);
    final hours = diff.inHours;
    diff -= Duration(hours: hours);
    final minutes = diff.inMinutes;
    if (days >= 1) {
      return l10n.balehoLeaderboardResetsInDaysHours(days, hours);
    }
    if (hours >= 1) {
      return l10n.balehoLeaderboardResetsInHoursMinutes(hours, minutes);
    }
    if (minutes >= 1) {
      return l10n.balehoLeaderboardResetsInMinutes(minutes);
    }
    return l10n.balehoLeaderboardResetsSoon;
  }
}

class _HistoryTabBody extends StatelessWidget {
  const _HistoryTabBody({
    required this.weekOptions,
    required this.selectedWeekId,
    required this.onWeekChanged,
    required this.async,
    required this.l10n,
    required this.theme,
    required this.onRefresh,
  });

  final List<String> weekOptions;
  final String? selectedWeekId;
  final ValueChanged<String> onWeekChanged;
  final AsyncValue<LeaderboardWeekSnapshot?> async;
  final AppLocalizations l10n;
  final FThemeData theme;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final weekId = selectedWeekId ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (weekOptions.isNotEmpty)
          FSelectMenuTile<String>(
            title: Text(l10n.balehoLeaderboardPickWeek),
            details: Text(weekId.isEmpty ? l10n.profileNotFilled : weekId),
            selectControl: FMultiValueControl.managedRadio(
              initial: weekId,
              onChange: (values) {
                if (values.length != 1) return;
                onWeekChanged(values.first);
              },
            ),
            menu: [
              for (final id in weekOptions)
                FSelectTile(value: id, title: Text(id)),
            ],
          ),
        const Gap(8),
        Expanded(
          child: async.when(
            skipLoadingOnReload: true,
            loading: () => const Center(child: FCircularProgress(size: .md)),
            error: (_, _) => _ErrorScroll(
              message: l10n.balehoLeaderboardLoadFailed,
              retryLabel: l10n.commonRetry,
              onRetry: onRefresh,
            ),
            data: (snap) {
              if (snap == null || snap.entries.isEmpty) {
                return RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.balehoLeaderboardHistoryEmpty,
                          textAlign: TextAlign.center,
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: onRefresh,
                child: _EntryList(
                  entries: snap.entries,
                  l10n: l10n,
                  theme: theme,
                  header: snap.weekId.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            l10n.balehoLeaderboardWeekLabel(snap.weekId),
                            style: theme.typography.body.sm.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : null,
                  emptyMessage: l10n.balehoLeaderboardHistoryEmpty,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EntryList extends StatelessWidget {
  const _EntryList({
    required this.entries,
    required this.l10n,
    required this.theme,
    this.header,
    required this.emptyMessage,
  });

  final List<LeaderboardEntry> entries;
  final AppLocalizations l10n;
  final FThemeData theme;
  final Widget? header;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ?header,
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: entries.length + (header != null ? 1 : 0),
      separatorBuilder: (_, index) {
        if (header != null && index == 0) return const Gap(8);
        return const Gap(8);
      },
      itemBuilder: (context, index) {
        if (header != null && index == 0) return header!;
        final entryIndex = header != null ? index - 1 : index;
        final entry = entries[entryIndex];
        return FTileGroup(
          children: [
            leaderboardEntryTile(
              context: context,
              entry: entry,
              l10n: l10n,
            ),
          ],
        );
      },
    );
  }
}

class _ErrorScroll extends StatelessWidget {
  const _ErrorScroll({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const Gap(12),
              FButton(
                variant: FButtonVariant.outline,
                onPress: onRetry,
                child: Text(retryLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}