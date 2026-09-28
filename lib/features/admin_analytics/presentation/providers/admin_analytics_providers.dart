import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepositoryImpl(ref.watch(dioProvider)),
);

final dashboardStatsProvider =
    FutureProvider.autoDispose<DashboardStats>((ref) async {
  return ref.watch(dashboardRepositoryProvider).getStats();
});

final analyticsActivityFeedProvider =
    FutureProvider.autoDispose<List<AnalyticsActivityItem>>((ref) async {
  // Tetap hidup di halaman Analitik saat scroll / rebuild.
  ref.keepAlive();
  return ref.watch(dashboardRepositoryProvider).latestActivity();
});

Future<void> refreshAdminAnalytics(WidgetRef ref) async {
  ref.invalidate(dashboardStatsProvider);
  ref.invalidate(analyticsActivityFeedProvider);
  await Future.wait([
    ref.read(dashboardStatsProvider.future),
    ref.read(analyticsActivityFeedProvider.future),
  ]);
}
