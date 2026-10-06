import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../domain/entities/dashboard_stats.dart';
import '../../domain/format_analytics_count.dart';

/// Chart aktivitas 7 hari dengan tinggi tetap (tidak melompat saat pilih hari).
class AnalyticsActivityDailyChart extends StatefulWidget {
  const AnalyticsActivityDailyChart({
    super.key,
    required this.points,
    this.windowDays = 7,
  });

  final List<ActivityDailyPoint> points;
  final int windowDays;

  @override
  State<AnalyticsActivityDailyChart> createState() =>
      _AnalyticsActivityDailyChartState();
}

class _AnalyticsActivityDailyChartState
    extends State<AnalyticsActivityDailyChart> {
  static const _series = <({String key, String short, Color color})>[
    (key: 'contributions', short: 'Kontribusi', color: Color(0xFF2563EB)),
    (key: 'votes', short: 'Vote', color: Color(0xFF16A34A)),
    (key: 'comments', short: 'Komentar', color: Color(0xFFF59E0B)),
    (key: 'newUsers', short: 'User', color: Color(0xFF0EA5E9)),
    (key: 'searches', short: 'Cari', color: Color(0xFF8B5CF6)),
  ];

  /// Tinggi area plot tetap - jangan biarkan fl_chart / ringkasan mengubah layout.
  static const _chartHeight = 140.0;

  /// 36px ternyata 1px kurang untuk 2 baris ringkasan (label 10px + angka
  /// sm) → RenderFlex overflow. 40px lega; tetap konstan supaya layout
  /// tidak melompat saat ganti hari.
  static const _summaryHeight = 40.0;

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _defaultIndex(_window);
  }

  @override
  void didUpdateWidget(covariant AnalyticsActivityDailyChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _window;
    if (_selectedIndex >= next.length) {
      _selectedIndex = _defaultIndex(next);
    }
  }

  List<ActivityDailyPoint> get _window {
    final points = widget.points;
    if (points.isEmpty) return const [];
    if (points.length <= widget.windowDays) return points;
    return points.sublist(points.length - widget.windowDays);
  }

  int _defaultIndex(List<ActivityDailyPoint> data) =>
      data.isEmpty ? 0 : data.length - 1;

  int _valueFor(ActivityDailyPoint point, String key) => switch (key) {
    'contributions' => point.contributions,
    'votes' => point.votes,
    'comments' => point.comments,
    'newUsers' => point.newUsers,
    'searches' => point.searches,
    _ => 0,
  };

  List<FlSpot> _spots(List<ActivityDailyPoint> data, String key) => [
    for (var i = 0; i < data.length; i++)
      FlSpot(i.toDouble(), _valueFor(data[i], key).toDouble()),
  ];

  String _shortDay(String ymd) {
    final parts = ymd.split('-');
    if (parts.length != 3) return ymd;
    return '${int.tryParse(parts[2]) ?? 0}/${int.tryParse(parts[1]) ?? 0}';
  }

  /// Skala Y dibulatkan supaya stabil antar rebuild.
  double _stableMaxY(int rawMax) {
    if (rawMax <= 0) return 4;
    final padded = (rawMax * 1.2).ceil();
    if (padded <= 4) return 4;
    if (padded <= 10) return 10;
    final step = padded <= 50 ? 5 : 10;
    return ((padded + step - 1) ~/ step) * step.toDouble();
  }

  void _selectIndex(int index, int length) {
    if (index < 0 || index >= length || index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final data = _window;
    final rawMax = [
      for (final p in data) ...[
        p.contributions,
        p.votes,
        p.comments,
        p.newUsers,
        p.searches,
      ],
    ].fold<int>(0, (a, b) => a > b ? a : b);
    final chartMaxY = _stableMaxY(rawMax);
    final lastIndex = data.isEmpty ? 0.0 : (data.length - 1).toDouble();
    final selected = data.isEmpty
        ? null
        : data[_selectedIndex.clamp(0, data.length - 1)];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Aktivitas ${widget.windowDays} hari',
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 40,
                  child: Text(
                    selected == null ? '' : _shortDay(selected.date),
                    textAlign: TextAlign.end,
                    style: theme.typography.xs.copyWith(
                      color: theme.colors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(6),
            SizedBox(
              height: _summaryHeight,
              child: selected == null
                  ? const SizedBox.expand()
                  : Row(
                      children: [
                        for (final s in _series)
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: s.color,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const SizedBox(
                                        width: 6,
                                        height: 6,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        s.short,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.typography.xs.copyWith(
                                          color: theme.colors.mutedForeground,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  formatAnalyticsCount(
                                    _valueFor(selected, s.key),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.typography.sm.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            const Gap(6),
            SizedBox(
              height: _chartHeight,
              child: data.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada data.',
                        style: theme.typography.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: lastIndex,
                        minY: 0,
                        maxY: chartMaxY,
                        clipData: const FlClipData.all(),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: chartMaxY / 2,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: theme.colors.border,
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        extraLinesData: ExtraLinesData(
                          verticalLines: [
                            VerticalLine(
                              x: _selectedIndex.toDouble(),
                              color: theme.colors.primary.withValues(
                                alpha: 0.3,
                              ),
                              strokeWidth: 1,
                              dashArray: const [3, 3],
                            ),
                          ],
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          leftTitles: const AxisTitles(),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 18,
                              getTitlesWidget: (value, meta) {
                                final i = value.round();
                                if (i < 0 || i >= data.length) {
                                  return const SizedBox.shrink();
                                }
                                // Selalu tampilkan label dengan tinggi tetap.
                                if (data.length > 5 &&
                                    i % 2 != 0 &&
                                    i != data.length - 1) {
                                  return const SizedBox(height: 14);
                                }
                                final isSelected = i == _selectedIndex;
                                return SizedBox(
                                  height: 14,
                                  child: Center(
                                    child: Text(
                                      _shortDay(data[i].date),
                                      style: theme.typography.xs.copyWith(
                                        fontSize: 10,
                                        height: 1,
                                        color: isSelected
                                            ? theme.colors.foreground
                                            : theme.colors.mutedForeground,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          handleBuiltInTouches: false,
                          touchSpotThreshold: 28,
                          getTouchedSpotIndicator: (barData, spotIndexes) => [
                            for (final _ in spotIndexes)
                              TouchedSpotIndicatorData(
                                const FlLine(color: Color(0x00000000)),
                                FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, bar, index) =>
                                      FlDotCirclePainter(
                                        radius: 3.5,
                                        color:
                                            bar.color ?? theme.colors.primary,
                                        strokeWidth: 1.5,
                                        strokeColor: theme.colors.background,
                                      ),
                                ),
                              ),
                          ],
                          touchCallback: (event, response) {
                            if (!event.isInterestedForInteractions) return;
                            final spot = response?.lineBarSpots?.firstOrNull;
                            if (spot == null) return;
                            _selectIndex(spot.x.round(), data.length);
                          },
                          touchTooltipData: const LineTouchTooltipData(
                            getTooltipItems: _emptyTooltipItems,
                          ),
                        ),
                        lineBarsData: [
                          for (final s in _series)
                            LineChartBarData(
                              spots: _spots(data, s.key),
                              isCurved: true,
                              preventCurveOverShooting: true,
                              color: s.color,
                              barWidth: 1.8,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, index) {
                                  final isSelected =
                                      spot.x.round() == _selectedIndex;
                                  return FlDotCirclePainter(
                                    radius: isSelected ? 3.5 : 1.8,
                                    color: s.color,
                                    strokeWidth: isSelected ? 1.5 : 0,
                                    strokeColor: theme.colors.background,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(show: false),
                            ),
                        ],
                      ),
                      duration: Duration.zero,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

List<LineTooltipItem?> _emptyTooltipItems(List<LineBarSpot> _) =>
    const <LineTooltipItem?>[];
