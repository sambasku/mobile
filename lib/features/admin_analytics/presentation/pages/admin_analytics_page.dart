import 'package:flutter/material.dart' show RefreshIndicator, Theme;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../domain/entities/dashboard_stats.dart';
import '../providers/admin_analytics_providers.dart';
import '../widgets/activity_daily_chart.dart';
import '../widgets/analytics_activity_feed_section.dart';
import '../widgets/kpi_cards.dart';
import '../widgets/overview_strip.dart';
import '../widgets/status_bars_panel.dart';

/// Halaman Analitik - layout padat untuk layar mobile.
class AdminAnalyticsPage extends ConsumerWidget {
  const AdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return FScaffold(
      // ListView mengatur padding sendiri.
      childPad: false,
      header: FHeader.nested(
        title: const Text('Analitik'),
        prefixes: [
          FHeaderAction.back(
            onPress: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/profile');
              }
            },
          ),
        ],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.refreshCw),
            onPress: () => refreshAdminAnalytics(ref),
          ),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: () => refreshAdminAnalytics(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            statsAsync.when(
              loading: () => const _AnalyticsStatsSkeleton(),
              error: (_, _) => FAlert(
                variant: .destructive,
                title: const Text('Statistik gagal dimuat'),
                subtitle: const Text('Periksa koneksi lalu coba lagi.'),
                icon: const Icon(FLucideIcons.circleAlert),
              ),
              data: (stats) => _AnalyticsStatsBody(stats: stats),
            ),
            const Gap(14),
            const AnalyticsActivityFeedSection(),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsStatsBody extends StatelessWidget {
  const _AnalyticsStatsBody({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnalyticsKpiCards(stats: stats),
        const Gap(8),
        AnalyticsOverviewStrip(stats: stats),
        const Gap(8),
        AnalyticsActivityDailyChart(points: stats.activity.dailyLast30Days),
        const Gap(8),
        AnalyticsCombinedStatusBars(stats: stats),
      ],
    );
  }
}

class _AnalyticsStatsSkeleton extends StatelessWidget {
  const _AnalyticsStatsSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = context.theme.colors.muted;
    final shimmer = ShimmerEffect(
      baseColor: isDark
          ? muted.withValues(alpha: 0.35)
          : const Color(0xFFE7E7EA),
      highlightColor: isDark
          ? muted.withValues(alpha: 0.55)
          : const Color(0xFFF4F4F5),
      duration: const Duration(milliseconds: 1500),
    );

    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effect: shimmer),
      child: const IgnorePointer(
        child: Skeletonizer(
          enabled: true,
          child: _AnalyticsStatsBody(stats: _placeholderStats),
        ),
      ),
    );
  }
}

const _placeholderStats = DashboardStats(
  words: WordsStats(
    total: 1280,
    verified: 860,
    deleted: 4,
    byStatus: {
      'pending_review': 12,
      'draft': 8,
      'published': 900,
      'rejected': 3,
    },
  ),
  contributions: ContributionsStats(
    total: 240,
    byStatus: {'pending': 6},
  ),
  users: UsersStats(
    active: 80,
    onlineRecently: 5,
    byRole: {},
  ),
  activity: ActivityStats(
    auditLogsLast7Days: 42,
    dailyLast30Days: [
      ActivityDailyPoint(
        date: '2026-09-24',
        contributions: 2,
        votes: 4,
        comments: 1,
        newUsers: 1,
      ),
      ActivityDailyPoint(
        date: '2026-09-25',
        contributions: 3,
        votes: 2,
        comments: 2,
        newUsers: 0,
      ),
      ActivityDailyPoint(
        date: '2026-09-26',
        contributions: 1,
        votes: 5,
        comments: 1,
        newUsers: 2,
      ),
      ActivityDailyPoint(
        date: '2026-09-27',
        contributions: 4,
        votes: 1,
        comments: 3,
        newUsers: 1,
      ),
      ActivityDailyPoint(
        date: '2026-09-28',
        contributions: 2,
        votes: 3,
        comments: 2,
        newUsers: 0,
      ),
      ActivityDailyPoint(
        date: '2026-09-29',
        contributions: 5,
        votes: 2,
        comments: 1,
        newUsers: 1,
      ),
      ActivityDailyPoint(
        date: '2026-09-30',
        contributions: 1,
        votes: 1,
        comments: 2,
        newUsers: 0,
      ),
    ],
  ),
  problems: ProblemsStats(
    open: 2,
    closed: 10,
    bySource: ProblemSourceByKind(
      bugReports: ProblemSourceCounts(open: 1, closed: 4),
      wordReports: ProblemSourceCounts(open: 1, closed: 6),
    ),
  ),
  verifierApplications: VerifierApplicationsStats(
    pending: 1,
    approved: 4,
    rejected: 1,
  ),
);
