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
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/leaderboard_api.dart';
import '../../domain/baleho_models.dart';
import '../../domain/leaderboard_models.dart';
import '../providers/weekly_leaderboard_provider.dart';
import '../widgets/weekly_leaderboard_list.dart';

const _kHistoryPageSize = 10;

/// Papan Peringkat Mingguan (Baleho).
class BalehoWeeklyLeaderboardPage extends HookConsumerWidget {
  const BalehoWeeklyLeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final weekOptions = ref.watch(weeklyLeaderboardHistoryWeekOptionsProvider);
    final currentAsync = ref.watch(weeklyLeaderboardCurrentProvider);

    ref.listen(weeklyLeaderboardCurrentProvider, (prev, next) {
      if (next.hasError && context.mounted) {
        final err = next.error;
        final message = err is Exception
            ? err.toString()
            : l10n.balehoLeaderboardLoadFailed;
        showAppErrorSheet(context, message: message);
      }
    });

    final isAuth = ref.watch(authStatusProvider).value?.isAuth ?? false;

    return FScaffold(
      childPad: true,
      footer: isAuth ? const _ShareRankFooter() : null,
      header: FHeader.nested(
        title: Text(l10n.balehoWeeklyLeaderboardTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/baleho'),
          ),
        ],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.info),
            semanticsLabel: l10n.balehoPointsGuideOpenSemantics,
            onPress: () =>
                context.push(BalehoBoard.weeklyLeaderboardPointsPath),
          ),
        ],
      ),
      child: FTabs(
        expands: true,
        children: [
          FTabEntry.entry(
            label: Text(l10n.balehoLeaderboardTabCurrent),
            child: _CurrentTabBody(
              async: currentAsync,
              weekOptions: weekOptions,
              l10n: l10n,
              theme: theme,
              onRefresh: () async {
                ref.invalidate(weeklyLeaderboardCurrentProvider);
                await ref.read(weeklyLeaderboardCurrentProvider.future);
              },
            ),
          ),
          FTabEntry.entry(
            label: Text(l10n.balehoLeaderboardTabHistory),
            child: _HistoryWeekListTab(
              weekOptions: weekOptions,
              l10n: l10n,
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }
}

/// CTA bagikan posisi minggu berjalan ke feed. Kelayakan (peringkat 1-25)
/// diputuskan server dari user token.
class _ShareRankFooter extends HookConsumerWidget {
  const _ShareRankFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final busy = useState(false);

    Future<void> onShare() async {
      busy.value = true;
      try {
        final rank = await ref.read(leaderboardApiProvider).shareMyRank();
        if (!context.mounted) return;
        showFToast(
          context: context,
          title: Text(l10n.balehoLeaderboardShareSuccess(rank)),
        );
      } on LeaderboardApiException catch (e) {
        if (!context.mounted) return;
        switch (e.code) {
          case 'RATE_LIMITED':
            showFToast(context: context, title: Text(e.message));
          case 'LEADERBOARD_NOT_IN_TOP':
            await showAppErrorSheet(
              context,
              message: l10n.balehoLeaderboardShareNotInTop,
            );
          case 'UNAUTHORIZED':
            await showAppErrorSheet(
              context,
              message: l10n.balehoLeaderboardShareLoginRequired,
            );
          default:
            await showAppErrorSheet(
              context,
              message: l10n.balehoLeaderboardShareFailed,
            );
        }
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: FButton(
          onPress: busy.value ? null : onShare,
          prefix: busy.value
              ? const FCircularProgress()
              : const Icon(FLucideIcons.share2),
          child: Text(
            busy.value
                ? l10n.balehoLeaderboardShareBusy
                : l10n.balehoLeaderboardShareCta,
          ),
        ),
      ),
    );
  }
}

class _CurrentTabBody extends HookConsumerWidget {
  const _CurrentTabBody({
    required this.async,
    required this.weekOptions,
    required this.l10n,
    required this.theme,
    required this.onRefresh,
  });

  final AsyncValue<WeeklyLeaderboardViewData> async;
  final List<String> weekOptions;
  final AppLocalizations l10n;
  final FThemeData theme;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resetsAt = async.asData?.value.resetsAt;
    final tick = useState(0);
    final lastWeekId = weekOptions.isNotEmpty ? weekOptions.first : null;
    final lastWeekAsync = lastWeekId == null
        ? null
        : ref.watch(weeklyLeaderboardHistoryProvider(lastWeekId));

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
        final showLastWeek =
            view.entries.isEmpty && lastWeekId != null && lastWeekAsync != null;
        final lastSnap = lastWeekAsync?.asData?.value;
        final lastEntries = lastSnap?.entries ?? const <LeaderboardEntry>[];
        final lastWeekReady = showLastWeek && lastEntries.isNotEmpty;

        return RefreshIndicator(
          onRefresh: () async {
            await onRefresh();
            if (lastWeekId != null) {
              ref.invalidate(weeklyLeaderboardHistoryProvider(lastWeekId));
              await ref.read(
                weeklyLeaderboardHistoryProvider(lastWeekId).future,
              );
            }
          },
          child: WeeklyLeaderboardEntryList(
            entries: view.entries,
            l10n: l10n,
            theme: theme,
            header: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WeeklyLeaderboardMetaCard(
                  theme: theme,
                  weekLabel: view.weekId != null && view.weekId!.isNotEmpty
                      ? l10n.balehoLeaderboardWeekLabel(view.weekId!)
                      : null,
                  subtitle: countdown ??
                      (view.resetsAt != null
                          ? l10n.balehoLeaderboardResetsAt(
                              formatDateTime(view.resetsAt),
                            )
                          : null),
                  icon: FLucideIcons.timer,
                ),
                const Gap(8),
                WeeklyLeaderboardMetaCard(
                  theme: theme,
                  icon: FLucideIcons.circleHelp,
                  weekLabel: l10n.balehoPointsGuideTitle,
                  subtitle: l10n.balehoPointsGuideEntrySubtitle,
                  onPress: () =>
                      context.push(BalehoBoard.weeklyLeaderboardPointsPath),
                ),
              ],
            ),
            emptyMessage: lastWeekReady
                ? l10n.balehoLeaderboardLastWeekHint
                : l10n.balehoLeaderboardEmpty,
            trailing: lastWeekReady
                ? [
                    const Gap(8),
                    WeeklyLeaderboardMetaCard(
                      theme: theme,
                      icon: FLucideIcons.history,
                      weekLabel: l10n.balehoLeaderboardLastWeekTitle,
                      subtitle: l10n.balehoLeaderboardWeekLabel(lastWeekId),
                      onPress: () => context.push(
                        BalehoBoard.weeklyLeaderboardHistoryWeekPath(
                          lastWeekId,
                        ),
                      ),
                    ),
                    const Gap(12),
                    ...weeklyLeaderboardEntryChildren(
                      context: context,
                      entries: lastEntries,
                      l10n: l10n,
                      theme: theme,
                      emptyMessage: l10n.balehoLeaderboardHistoryEmpty,
                    ),
                    const Gap(12),
                    FButton(
                      variant: FButtonVariant.outline,
                      onPress: () => context.push(
                        BalehoBoard.weeklyLeaderboardHistoryWeekPath(
                          lastWeekId,
                        ),
                      ),
                      child: Text(l10n.balehoLeaderboardOpenWeek),
                    ),
                  ]
                : null,
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

/// Daftar minggu riwayat (data saja) + paginasi; tap membuka detail.
class _HistoryWeekListTab extends HookWidget {
  const _HistoryWeekListTab({
    required this.weekOptions,
    required this.l10n,
    required this.theme,
  });

  final List<String> weekOptions;
  final AppLocalizations l10n;
  final FThemeData theme;

  @override
  Widget build(BuildContext context) {
    final visibleCount = useState(
      weekOptions.isEmpty
          ? 0
          : weekOptions.length.clamp(0, _kHistoryPageSize),
    );

    useEffect(() {
      if (weekOptions.isEmpty) {
        visibleCount.value = 0;
      } else if (visibleCount.value == 0) {
        visibleCount.value = weekOptions.length.clamp(0, _kHistoryPageSize);
      } else if (visibleCount.value > weekOptions.length) {
        visibleCount.value = weekOptions.length;
      }
      return null;
    }, [weekOptions.length]);

    if (weekOptions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
        children: [
          WeeklyLeaderboardMetaCard(
            theme: theme,
            weekLabel: l10n.balehoLeaderboardTabHistory,
            subtitle: l10n.balehoLeaderboardHistoryNoWeeks,
            icon: FLucideIcons.history,
          ),
        ],
      );
    }

    final shown = weekOptions.take(visibleCount.value).toList();
    final hasMore = visibleCount.value < weekOptions.length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
      children: [
        WeeklyLeaderboardMetaCard(
          theme: theme,
          weekLabel: l10n.balehoLeaderboardTabHistory,
          subtitle: l10n.balehoLeaderboardHistoryWeekHint,
          icon: FLucideIcons.history,
        ),
        const Gap(12),
        FTileGroup(
          children: [
            for (final weekId in shown)
              FTile(
                prefix: Icon(
                  FLucideIcons.calendarDays,
                  size: 18,
                  color: theme.colors.mutedForeground,
                ),
                title: Text(l10n.balehoLeaderboardWeekLabel(weekId)),
                subtitle: Text(l10n.balehoLeaderboardHistoryWeekHint),
                suffix: Icon(
                  FLucideIcons.chevronRight,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
                onPress: () => context.push(
                  BalehoBoard.weeklyLeaderboardHistoryWeekPath(weekId),
                ),
              ),
          ],
        ),
        if (hasMore) ...[
          const Gap(12),
          FButton(
            variant: FButtonVariant.outline,
            onPress: () {
              final next = visibleCount.value + _kHistoryPageSize;
              visibleCount.value = next.clamp(0, weekOptions.length);
            },
            child: Text(l10n.balehoLeaderboardHistoryLoadMore),
          ),
        ],
      ],
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
