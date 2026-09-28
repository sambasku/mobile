import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../review/review_router.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/format_analytics_count.dart';
import '../../domain/today_vs_yesterday.dart';

/// Satu kartu padat: antrean perlu tindakan + ringkasan hari ini.
class AnalyticsOverviewStrip extends StatelessWidget {
  const AnalyticsOverviewStrip({super.key, required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final attention = <({String label, int count, VoidCallback? onTap})>[
      (
        label: 'Kontribusi',
        count: stats.contributions.byStatus['pending'] ?? 0,
        onTap: () => context.push(ReviewRouter.sessionPath()),
      ),
      (
        label: 'Review kata',
        count: stats.words.byStatus['pending_review'] ?? 0,
        onTap: null,
      ),
      (
        label: 'Laporan',
        count: stats.problems.open,
        onTap: null,
      ),
      (
        label: 'Verifikator',
        count: stats.verifierApplications.pending,
        onTap: null,
      ),
    ].where((e) => e.count > 0).toList();

    final today = buildTodayVsYesterday(stats.activity.dailyLast30Days);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perlu tindakan',
              style: theme.typography.sm.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(6),
            if (attention.isEmpty)
              Text(
                'Tidak ada antrean.',
                style: theme.typography.xs.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final item in attention)
                    _Chip(
                      label:
                          '${item.label} ${formatAnalyticsCount(item.count)}',
                      onTap: item.onTap,
                    ),
                ],
              ),
            const Gap(8),
            Text(
              'Hari ini',
              style: theme.typography.sm.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(4),
            Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                for (final m in today)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${m.label} ',
                          style: theme.typography.xs.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                        TextSpan(
                          text: formatAnalyticsCount(m.today),
                          style: theme.typography.xs.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (m.delta != null)
                          TextSpan(
                            text: ' ${formatDelta(m.delta!)}',
                            style: theme.typography.xs.copyWith(
                              fontWeight: FontWeight.w600,
                              color: m.delta! > 0
                                  ? const Color(0xFF16A34A)
                                  : m.delta! < 0
                                      ? const Color(0xFFDC2626)
                                      : theme.colors.mutedForeground,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final child = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.secondary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(label, style: theme.typography.xs),
      ),
    );
    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, child: child);
  }
}
