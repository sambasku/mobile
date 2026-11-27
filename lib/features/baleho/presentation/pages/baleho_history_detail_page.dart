import 'package:fl_chart/fl_chart.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../core/utils/format_number.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/baleho_api.dart';
import 'baleho_history_page.dart' show BalehoPerfStats, balehoHistoryProvider;

/// Detail performa satu pesanan Baleho (dari riwayat listing).
class BalehoHistoryDetailPage extends ConsumerWidget {
  const BalehoHistoryDetailPage({super.key, required this.placementId});

  final String placementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.balehoHistoryDetailTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/baleho'),
          ),
        ],
      ),
      child: ref
          .watch(balehoHistoryProvider)
          .when(
            skipLoadingOnReload: true,
            loading: () => const Center(child: FCircularProgress()),
            error: (_, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.balehoHistoryLoadFailed,
                    textAlign: TextAlign.center,
                  ),
                  const Gap(12),
                  FButton(
                    variant: FButtonVariant.outline,
                    onPress: () => ref.invalidate(balehoHistoryProvider),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            ),
            data: (items) {
              final item = items.where((e) => e.id == placementId).firstOrNull;
              if (item == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.balehoHistoryDetailNotFound,
                      textAlign: TextAlign.center,
                      style: context.theme.typography.body.sm.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                );
              }
              return _DetailBody(item: item);
            },
          ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.item});

  final BalehoPlacementHistoryItem item;

  String _statusLabel(AppLocalizations l10n, String status) => switch (status) {
    'pending_review' => l10n.balehoStatusPendingReview,
    'awaiting_payment' => l10n.balehoStatusAwaitingPayment,
    'live' => l10n.balehoStatusLive,
    'paused' => l10n.balehoStatusPaused,
    'rejected' => l10n.balehoStatusRejected,
    'cancelled' => l10n.balehoStatusCancelled,
    'expired' => l10n.balehoStatusExpired,
    _ => status,
  };

  /// `3 hari 5 jam`: rentang mulai-berakhir, atau mulai-sekarang saat live.
  String _durationLabel(AppLocalizations l10n) {
    final end = item.endsAt ?? DateTime.now();
    var dur = end.difference(item.createdAt);
    if (dur.isNegative) dur = Duration.zero;
    final d = dur.inDays;
    final h = dur.inHours % 24;
    if (d == 0 && h == 0) return l10n.balehoDurationMinutes(dur.inMinutes);
    if (d == 0) return l10n.balehoDurationHours(h);
    if (h == 0) return l10n.balehoDurationDays(d);
    return l10n.balehoDurationDaysHours(d, h);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final muted = theme.colors.mutedForeground;
    final title = (item.title?.trim().isNotEmpty ?? false)
        ? item.title!.trim()
        : l10n.balehoHistoryUntitled;
    final size = '${item.w}x${item.h}';
    final slideLabel = item.slide == 1
        ? l10n.balehoPromoSlide
        : l10n.balehoInternalSlide;
    final endText = item.endsAt == null
        ? null
        : '${formatDateTime(item.endsAt)} · ${_durationLabel(l10n)}';

    FTile metaTile(String label, String value) => FTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 13,
          color: muted,
        ),
      ),
      details: Text(
        value,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: theme.colors.foreground,
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      children: [
        // Header ringkas: identitas pesanan dalam satu tile.
        FTileGroup(
          children: [
            FTile(
              prefix: item.mediaUrl != null && item.mediaUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.mediaUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Icon(FLucideIcons.image, size: 20, color: muted),
                      ),
                    )
                  : Icon(FLucideIcons.layoutGrid, size: 20, color: muted),
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(slideLabel),
            ),
          ],
        ),
        const Gap(12),
        // Detail pesanan: label kiri, nilai kanan, satu layar tanpa scroll
        // berlebih.
        FTileGroup(
          children: [
            metaTile(
              l10n.balehoHistoryDetailStatus,
              _statusLabel(l10n, item.status),
            ),
            metaTile(
              l10n.balehoHistoryDetailPosition,
              l10n.balehoHistoryPosition(size, item.col + 1, item.row + 1),
            ),
            metaTile(
              l10n.balehoHistoryDetailCreated,
              formatDateTime(item.createdAt),
            ),
            if (endText != null) metaTile(l10n.balehoHistoryDetailEnd, endText),
          ],
        ),
        const Gap(12),
        Text(
          l10n.balehoHistoryPerfTitle,
          style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(8),
        _PerfKpiRow(
          impressions: item.impressions,
          taps: item.taps,
          actions: item.actions,
        ),
        const Gap(12),
        _PerfDailyChart(daily: item.daily),
        const Gap(12),
        Text(
          l10n.balehoHistoryStatsTitle,
          style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(8),
        BalehoPerfStats(item: item),
      ],
    );
  }
}

/// Kartu KPI 3 kolom: Dilihat, Tap baleho, Tap CTA.
class _PerfKpiRow extends StatelessWidget {
  const _PerfKpiRow({
    required this.impressions,
    required this.taps,
    required this.actions,
  });

  final int impressions;
  final int taps;
  final int actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final cells = <(String, int)>[
      (l10n.balehoHistoryStatImpressions, impressions),
      (l10n.balehoHistoryStatTaps, taps),
      (l10n.balehoHistoryStatActions, actions),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < cells.length; i++) ...[
              if (i > 0) Container(width: 0.5, color: theme.colors.border),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatRibuan(cells[i].$2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.lg.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const Gap(2),
                      Text(
                        cells[i].$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Grafik batang tayang 7 hari terakhir (WIB), tinggi tetap.
class _PerfDailyChart extends StatefulWidget {
  const _PerfDailyChart({required this.daily});

  final List<BalehoPlacementDailyBucket> daily;

  @override
  State<_PerfDailyChart> createState() => _PerfDailyChartState();
}

class _PerfDailyChartState extends State<_PerfDailyChart> {
  /// Tanggal (YYYY-MM-DD, WIB) yang dipilih. Null = hari ini (default).
  String? _selectedDate;

  String _todayWib() {
    final wib = DateTime.now().toUtc().add(const Duration(hours: 7));
    final m = wib.month.toString().padLeft(2, '0');
    final d = wib.day.toString().padLeft(2, '0');
    return '${wib.year.toString().padLeft(4, '0')}-$m-$d';
  }

  static const _chartHeight = 140.0;
  static const _windowDays = 7;

  String _shortDay(String ymd) {
    final parts = ymd.split('-');
    if (parts.length != 3) return ymd;
    return '${int.tryParse(parts[2]) ?? 0}/${int.tryParse(parts[1]) ?? 0}';
  }

  double _maxY(int rawMax) {
    if (rawMax <= 0) return 4;
    final padded = (rawMax * 1.2).ceil();
    return padded < 4 ? 4 : padded.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final muted = theme.colors.mutedForeground;
    final daily = widget.daily;
    final data = daily.length > _windowDays
        ? daily.sublist(daily.length - _windowDays)
        : daily;
    final rawMax = data.fold<int>(
      0,
      (max, p) => p.impressions > max ? p.impressions : max,
    );
    final maxY = _maxY(rawMax);
    final selDate = _selectedDate ?? _todayWib();
    final sel = data.firstWhere(
      (p) => p.date == selDate,
      orElse: () => BalehoPlacementDailyBucket(
        date: selDate,
        impressions: 0,
        taps: 0,
        actions: 0,
      ),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.balehoHistoryDailyTitle,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(8),
                SizedBox(
                  height: _chartHeight,
                  child: data.isEmpty
                      ? Center(
                          child: Text(
                            l10n.balehoHistoryDailyEmpty,
                            style: theme.typography.body.xs.copyWith(
                              color: muted,
                            ),
                          ),
                        )
                      : BarChart(
                          BarChartData(
                            minY: 0,
                            maxY: maxY,
                            alignment: BarChartAlignment.spaceAround,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: maxY / 2,
                              getDrawingHorizontalLine: (_) => FlLine(
                                color: theme.colors.border,
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(),
                              rightTitles: const AxisTitles(),
                              leftTitles: const AxisTitles(),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 18,
                                  getTitlesWidget: (value, meta) {
                                    final i = value.round();
                                    if (i < 0 || i >= data.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return SideTitleWidget(
                                      meta: meta,
                                      space: 4,
                                      child: Text(
                                        _shortDay(data[i].date),
                                        style: theme.typography.body.xs
                                            .copyWith(
                                              fontSize: 10,
                                              color: muted,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: [
                              for (var i = 0; i < data.length; i++)
                                BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: data[i].impressions.toDouble(),
                                      color: theme.colors.primary,
                                      width: 14,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ],
                                ),
                            ],
                            barTouchData: BarTouchData(
                              handleBuiltInTouches: false,
                              touchCallback: (event, response) {
                                final idx =
                                    response?.spot?.touchedBarGroupIndex;
                                if (event is! FlTapUpEvent || idx == null) {
                                  return;
                                }
                                setState(() => _selectedDate = data[idx].date);
                              },
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 34,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: theme.colors.secondary,
              border: Border(top: BorderSide(color: theme.colors.border)),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${_shortDay(sel.date)}  ·  '
                '${l10n.balehoHistoryStatImpressions} '
                '${formatRibuan(sel.impressions)}  ·  '
                '${l10n.balehoHistoryStatTaps} ${formatRibuan(sel.taps)}  ·  '
                '${l10n.balehoHistoryStatActions} '
                '${formatRibuan(sel.actions)}',
                maxLines: 1,
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.foreground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
