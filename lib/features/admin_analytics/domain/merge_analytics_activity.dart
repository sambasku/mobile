import 'entities/analytics_activity_item.dart';

/// Batas default feed setelah merge (plan: 12).
const analyticsActivityFeedLimit = 12;

/// Cap per jenis sebelum mengambil top-N global (plan: 5).
const analyticsActivityPerKindCap = 5;

DateTime? _parseCreatedAt(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  return DateTime.tryParse(trimmed);
}

int _compareNewestFirst(AnalyticsActivityItem a, AnalyticsActivityItem b) {
  final aAt = _parseCreatedAt(a.createdAt);
  final bAt = _parseCreatedAt(b.createdAt);
  if (aAt != null && bAt != null) {
    final byTime = bAt.compareTo(aAt);
    if (byTime != 0) return byTime;
  } else if (aAt != null) {
    return -1;
  } else if (bAt != null) {
    return 1;
  }
  // Fallback string DESC (ISO / ULID-friendly) lalu id.
  final byCreated = b.createdAt.compareTo(a.createdAt);
  if (byCreated != 0) return byCreated;
  return b.id.compareTo(a.id);
}

/// Gabung sumber aktivitas: sort waktu desc → cap per kind → top [limit].
List<AnalyticsActivityItem> mergeAnalyticsActivity(
  Iterable<AnalyticsActivityItem> items, {
  int perKindCap = analyticsActivityPerKindCap,
  int limit = analyticsActivityFeedLimit,
}) {
  final sorted = List<AnalyticsActivityItem>.from(items)
    ..sort(_compareNewestFirst);

  final counts = <AnalyticsActivityKind, int>{};
  final capped = <AnalyticsActivityItem>[];
  for (final item in sorted) {
    final n = counts[item.kind] ?? 0;
    if (n >= perKindCap) continue;
    counts[item.kind] = n + 1;
    capped.add(item);
    if (capped.length >= limit) break;
  }
  return capped;
}
