import 'package:flutter/material.dart' show RefreshIndicator;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: FCircularProgress()),
              ),
              error: (_, _) => FAlert(
                variant: .destructive,
                title: const Text('Statistik gagal dimuat'),
                subtitle: const Text('Periksa koneksi lalu coba lagi.'),
                icon: const Icon(FLucideIcons.circleAlert),
              ),
              data: (stats) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnalyticsKpiCards(stats: stats),
                  const Gap(8),
                  AnalyticsOverviewStrip(stats: stats),
                  const Gap(8),
                  AnalyticsActivityDailyChart(
                    points: stats.activity.dailyLast30Days,
                  ),
                  const Gap(8),
                  AnalyticsCombinedStatusBars(stats: stats),
                ],
              ),
            ),
            const Gap(14),
            const AnalyticsActivityFeedSection(),
          ],
        ),
      ),
    );
  }
}
