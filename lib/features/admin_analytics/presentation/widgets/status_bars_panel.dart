import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/dashboard_stats.dart';
import '../../domain/format_analytics_count.dart';

enum _StatusTab { words, problems, verifier }

class _StatusItem {
  const _StatusItem({
    required this.label,
    required this.value,
    this.attention = false,
  });

  final String label;
  final int value;
  final bool attention;
}

/// Status breakdown - chip + baris label/nilai (tanpa bar warna).
class AnalyticsCombinedStatusBars extends HookConsumerWidget {
  const AnalyticsCombinedStatusBars({super.key, required this.stats});

  final DashboardStats stats;

  static const _tabs = <(_StatusTab, String)>[
    (_StatusTab.words, 'Kata'),
    (_StatusTab.problems, 'Masalah'),
    (_StatusTab.verifier, 'Verifikator'),
  ];

  List<_StatusItem> _itemsFor(_StatusTab tab) {
    final byStatus = stats.words.byStatus;
    final problems = stats.problems;
    final verifier = stats.verifierApplications;

    return switch (tab) {
      _StatusTab.words => [
        _StatusItem(
          label: 'Menunggu review',
          value: byStatus['pending_review'] ?? 0,
          attention: (byStatus['pending_review'] ?? 0) > 0,
        ),
        _StatusItem(label: 'Draft (tidak tayang)', value: byStatus['draft'] ?? 0),
        _StatusItem(label: 'Tayang', value: byStatus['published'] ?? 0),
        _StatusItem(label: 'Ditolak', value: byStatus['rejected'] ?? 0),
      ],
      _StatusTab.problems => [
        _StatusItem(
          label: 'Perlu tindakan',
          value: problems.open,
          attention: problems.open > 0,
        ),
        _StatusItem(label: 'Selesai', value: problems.closed),
        _StatusItem(
          label: 'Laporan bug',
          value: problems.bySource.bugReports.open +
              problems.bySource.bugReports.closed,
        ),
        _StatusItem(
          label: 'Laporan kata',
          value: problems.bySource.wordReports.open +
              problems.bySource.wordReports.closed,
        ),
      ],
      _StatusTab.verifier => [
        _StatusItem(
          label: 'Menunggu',
          value: verifier.pending,
          attention: verifier.pending > 0,
        ),
        _StatusItem(label: 'Disetujui', value: verifier.approved),
        _StatusItem(label: 'Ditolak', value: verifier.rejected),
      ],
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final selected = useState(_StatusTab.words);
    final items = _itemsFor(selected.value);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < _tabs.length; i++) ...[
                        if (i > 0) const Gap(6),
                        GestureDetector(
                          onTap: () => selected.value = _tabs[i].$1,
                          child: FBadge(
                            variant: selected.value == _tabs[i].$1
                                ? FBadgeVariant.primary
                                : FBadgeVariant.secondary,
                            child: Text(_tabs[i].$2),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Gap(4),
              ],
            ),
          ),
          for (var i = 0; i < items.length; i++) ...[
            DecoratedBox(
              decoration: BoxDecoration(color: theme.colors.border),
              child: const SizedBox(height: 1, width: double.infinity),
            ),
            _StatusRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.item});

  final _StatusItem item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accent = item.attention
        ? const Color(0xFFD97706)
        : theme.colors.foreground;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w500,
                color: item.attention
                    ? accent
                    : theme.colors.foreground,
              ),
            ),
          ),
          Text(
            formatAnalyticsCount(item.value),
            style: theme.typography.md.copyWith(
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
