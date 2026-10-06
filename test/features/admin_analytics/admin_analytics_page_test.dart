import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/features/admin_analytics/domain/entities/dashboard_stats.dart';
import 'package:sambasku_mobile/features/admin_analytics/presentation/pages/admin_analytics_page.dart';
import 'package:sambasku_mobile/features/admin_analytics/presentation/providers/admin_analytics_providers.dart';

void main() {
  testWidgets('halaman analitik render tanpa RenderFlex overflow', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardStatsProvider.overrideWith((ref) async => _stats),
          analyticsActivityFeedProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp.router(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          routerConfig: GoRouter(
            initialLocation: '/admin/analytics',
            routes: [
              GoRoute(
                path: '/admin/analytics',
                builder: (_, _) => const AdminAnalyticsPage(),
              ),
            ],
          ),
          builder: (context, child) => FTheme(
            data: FThemes.zinc.light.touch,
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final exception = tester.takeException();
    expect(exception, isNull, reason: '\$exception');
    expect(find.text('Analitik'), findsOneWidget);
  });
}

const _stats = DashboardStats(
  words: WordsStats(
    total: 1280,
    verified: 860,
    deleted: 4,
    byStatus: {'pending_review': 12, 'draft': 8, 'published': 900, 'rejected': 3},
  ),
  contributions: ContributionsStats(total: 240, byStatus: {'pending': 6}),
  users: UsersStats(active: 80, onlineRecently: 5, byRole: {}),
  activity: ActivityStats(
    auditLogsLast7Days: 42,
    dailyLast30Days: [
      ActivityDailyPoint(date: '2026-10-01', contributions: 2, votes: 4, comments: 1, newUsers: 1, searches: 0),
      ActivityDailyPoint(date: '2026-10-02', contributions: 3, votes: 2, comments: 2, newUsers: 0, searches: 1),
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
  verifierApplications: VerifierApplicationsStats(pending: 1, approved: 4, rejected: 1),
);
