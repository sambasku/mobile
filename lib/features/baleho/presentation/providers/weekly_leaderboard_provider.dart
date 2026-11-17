import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/leaderboard_api.dart';
import '../../domain/leaderboard_iso_week.dart';
import '../../domain/leaderboard_models.dart';

final leaderboardApiProvider = Provider<LeaderboardApi>(
  (ref) => LeaderboardApi(ref.watch(dioProvider)),
);

final weeklyLeaderboardCurrentProvider =
    FutureProvider.autoDispose<WeeklyLeaderboardViewData>((ref) async {
  return ref.watch(leaderboardApiProvider).fetchCurrentWeek();
});

final weeklyLeaderboardHistoryProvider = FutureProvider.autoDispose
    .family<LeaderboardWeekSnapshot?, String>((ref, weekId) async {
  if (weekId.isEmpty) return null;
  // Template dari meta minggu berjalan supaya staging/prod beda repo CDN.
  final current = await ref.watch(weeklyLeaderboardCurrentProvider.future);
  if (!ref.mounted) return null;
  return ref.watch(leaderboardApiProvider).fetchHistoryWeek(
        weekId,
        cdnWeeklyTemplate: current.cdnWeeklyPatternUrl,
      );
});

/// Opsi minggu riwayat (tanpa minggu berjalan).
final weeklyLeaderboardHistoryWeekOptionsProvider =
    Provider.autoDispose<List<String>>((ref) {
  return listPastIsoWeekIds(count: 24);
});