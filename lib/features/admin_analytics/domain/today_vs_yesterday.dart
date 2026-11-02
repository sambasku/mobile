import '../../../../l10n/app_localizations.dart';
import 'entities/dashboard_stats.dart';
import 'format_analytics_count.dart';

enum TodayMetricKey { contributions, votes, comments, newUsers }

class TodayVsYesterdayMetric {
  const TodayVsYesterdayMetric({
    required this.key,
    required this.label,
    required this.today,
    required this.yesterday,
    required this.delta,
  });

  final TodayMetricKey key;
  final String label;
  final int today;
  final int? yesterday;
  final int? delta;
}

const _metrics = <TodayMetricKey>[
  TodayMetricKey.contributions,
  TodayMetricKey.votes,
  TodayMetricKey.comments,
  TodayMetricKey.newUsers,
];

String _metricLabel(AppLocalizations l10n, TodayMetricKey key) => switch (key) {
  TodayMetricKey.contributions => l10n.analyticsSeriesContributions,
  TodayMetricKey.votes => l10n.analyticsSeriesVotes,
  TodayMetricKey.comments => l10n.analyticsSeriesComments,
  TodayMetricKey.newUsers => l10n.analyticsSeriesUsers,
};

int _valueFor(ActivityDailyPoint point, TodayMetricKey key) => switch (key) {
  TodayMetricKey.contributions => point.contributions,
  TodayMetricKey.votes => point.votes,
  TodayMetricKey.comments => point.comments,
  TodayMetricKey.newUsers => point.newUsers,
};

/// Bandingkan titik terakhir (hari ini WIB) dengan hari sebelumnya.
/// Kurang dari 2 titik → delta null.
List<TodayVsYesterdayMetric> buildTodayVsYesterday(
  AppLocalizations l10n,
  List<ActivityDailyPoint> points,
) {
  if (points.isEmpty) {
    return [
      for (final m in _metrics)
        TodayVsYesterdayMetric(
          key: m,
          label: _metricLabel(l10n, m),
          today: 0,
          yesterday: null,
          delta: null,
        ),
    ];
  }

  final todayPoint = points.last;
  final yesterdayPoint = points.length >= 2 ? points[points.length - 2] : null;

  return [
    for (final m in _metrics)
      TodayVsYesterdayMetric(
        key: m,
        label: _metricLabel(l10n, m),
        today: _valueFor(todayPoint, m),
        yesterday: yesterdayPoint == null ? null : _valueFor(yesterdayPoint, m),
        delta: yesterdayPoint == null
            ? null
            : _valueFor(todayPoint, m) - _valueFor(yesterdayPoint, m),
      ),
  ];
}

String formatDelta(int delta) {
  if (delta == 0) return '0';
  final formatted = formatAnalyticsCount(delta.abs());
  return delta > 0 ? '+$formatted' : '-$formatted';
}
