import '../entities/analytics_activity_item.dart';
import '../entities/dashboard_stats.dart';

export '../entities/analytics_activity_item.dart';

/// Kontrak repository agregat + list widget Analitik.
abstract class DashboardRepository {
  Future<DashboardStats> getStats({DateTime? now});

  /// Feed campuran (komentar, vote, diskusi, search-miss tayang).
  Future<List<AnalyticsActivityItem>> latestActivity({int perSource = 8});
}
