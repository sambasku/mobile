import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../review/review_router.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/format_analytics_count.dart';

String _primaryMeta(Iterable<String?> parts, {required String fallback}) {
  for (final part in parts) {
    if (part != null && part.isNotEmpty) return part;
  }
  return fallback;
}

/// Empat metrik KPI sebagai baris: judul + subtitle kiri, nilai kanan.
class AnalyticsKpiCards extends StatelessWidget {
  const AnalyticsKpiCards({super.key, required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final words = stats.words;
    final contributions = stats.contributions;
    final users = stats.users;
    final pending = contributions.byStatus['pending'] ?? 0;
    final hasPending = pending > 0;

    final rows = <_KpiRowData>[
      _KpiRowData(
        label: 'Kata',
        subtitle: _primaryMeta([
          if (words.verified > 0)
            'Verif ${formatAnalyticsCount(words.verified)}',
          if ((words.byStatus['published'] ?? 0) > 0)
            'Tayang ${formatAnalyticsCount(words.byStatus['published']!)}',
        ], fallback: 'Total entri kamus'),
        value: words.total,
      ),
      _KpiRowData(
        label: 'Kontribusi',
        subtitle: hasPending
            ? '${formatAnalyticsCount(pending)} menunggu review'
            : 'Tidak ada antrean',
        value: contributions.total,
        attention: hasPending,
        // Langsung ke deck swipe Tinder-like.
        onTap: hasPending
            ? () => context.push(ReviewRouter.sessionPath())
            : null,
      ),
      _KpiRowData(
        label: 'Pengguna',
        subtitle:
            'Online 15 mnt ${formatAnalyticsCount(users.onlineRecently)}',
        value: users.active,
      ),
      _KpiRowData(
        label: 'Mutasi 7 hari',
        subtitle: 'Entri audit log',
        value: stats.activity.auditLogsLast7Days,
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              DecoratedBox(
                decoration: BoxDecoration(color: theme.colors.border),
                child: const SizedBox(height: 1, width: double.infinity),
              ),
            _KpiRow(data: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _KpiRowData {
  const _KpiRowData({
    required this.label,
    required this.subtitle,
    required this.value,
    this.attention = false,
    this.onTap,
  });

  final String label;
  final String subtitle;
  final int value;
  final bool attention;
  final VoidCallback? onTap;
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.data});

  final _KpiRowData data;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xs.copyWith(
                    color: data.attention
                        ? const Color(0xFFD97706)
                        : theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatAnalyticsCount(data.value),
            style: theme.typography.lg.copyWith(
              fontWeight: FontWeight.w700,
              color: data.attention
                  ? const Color(0xFFD97706)
                  : theme.colors.foreground,
            ),
          ),
        ],
      ),
    );

    if (data.onTap == null) return row;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: data.onTap,
      child: row,
    );
  }
}
