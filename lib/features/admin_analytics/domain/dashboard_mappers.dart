import 'entities/dashboard_stats.dart';

const _wibOffsetMs = 7 * 60 * 60 * 1000;
const _dailyWindowDays = 30;

String wibDateString([DateTime? now]) {
  final utc = (now ?? DateTime.now()).toUtc();
  final wib = utc.add(const Duration(milliseconds: _wibOffsetMs));
  final y = wib.year.toString().padLeft(4, '0');
  final m = wib.month.toString().padLeft(2, '0');
  final d = wib.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String shiftCalendarDate(String ymd, int deltaDays) {
  final parts = ymd.split('-');
  if (parts.length != 3) return ymd;
  final y = int.tryParse(parts[0]) ?? 1970;
  final m = int.tryParse(parts[1]) ?? 1;
  final d = int.tryParse(parts[2]) ?? 1;
  final shifted = DateTime.utc(y, m, d).add(Duration(days: deltaDays));
  final yy = shifted.year.toString().padLeft(4, '0');
  final mm = shifted.month.toString().padLeft(2, '0');
  final dd = shifted.day.toString().padLeft(2, '0');
  return '$yy-$mm-$dd';
}

int _asInt(Object? raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw) ?? 0;
  return 0;
}

Map<String, int> _asIntMap(Object? raw) {
  if (raw is! Map) return const {};
  final out = <String, int>{};
  for (final entry in raw.entries) {
    out[entry.key.toString()] = _asInt(entry.value);
  }
  return out;
}

Map<String, dynamic> _asMap(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return const {};
}

/// Selalu 30 titik WIB (today-29 … today). Payload pendek di-pad; kosong = 0.
List<ActivityDailyPoint> ensureDailyActivityLast30Days(
  Object? raw, {
  DateTime? now,
}) {
  final todayWib = wibDateString(now);
  final byDay = <String, ActivityDailyPoint>{};
  if (raw is List) {
    for (final item in raw) {
      final map = _asMap(item);
      final date = map['date']?.toString() ?? '';
      if (date.isEmpty) continue;
      byDay[date] = ActivityDailyPoint(
        date: date,
        contributions: _asInt(map['contributions']),
        votes: _asInt(map['votes']),
        comments: _asInt(map['comments']),
        newUsers: _asInt(map['new_users']),
        searches: _asInt(map['searches']),
      );
    }
  }

  final points = <ActivityDailyPoint>[];
  for (var i = _dailyWindowDays - 1; i >= 0; i -= 1) {
    final date = shiftCalendarDate(todayWib, -i);
    final hit = byDay[date];
    points.add(
      hit ??
          ActivityDailyPoint(
            date: date,
            contributions: 0,
            votes: 0,
            comments: 0,
            newUsers: 0,
            searches: 0,
          ),
    );
  }
  return points;
}

ProblemSourceCounts _sourceCounts(Object? raw) {
  final map = _asMap(raw);
  return ProblemSourceCounts(
    open: _asInt(map['open']),
    closed: _asInt(map['closed']),
  );
}

/// Normalisasi wire snake_case → [DashboardStats].
DashboardStats normalizeDashboardStats(
  Map<String, dynamic> wire, {
  DateTime? now,
}) {
  final words = _asMap(wire['words']);
  final contributions = _asMap(wire['contributions']);
  final users = _asMap(wire['users']);
  final activity = _asMap(wire['activity']);
  final problems = _asMap(wire['problems']);
  final bySource = _asMap(problems['by_source']);
  final verifier = _asMap(wire['verifier_applications']);

  return DashboardStats(
    words: WordsStats(
      total: _asInt(words['total']),
      verified: _asInt(words['verified']),
      deleted: _asInt(words['deleted']),
      byStatus: _asIntMap(words['by_status']),
    ),
    contributions: ContributionsStats(
      total: _asInt(contributions['total']),
      byStatus: _asIntMap(contributions['by_status']),
    ),
    users: UsersStats(
      active: _asInt(users['active']),
      onlineRecently: _asInt(users['online_recently']),
      byRole: _asIntMap(users['by_role']),
    ),
    activity: ActivityStats(
      auditLogsLast7Days: _asInt(activity['audit_logs_last_7_days']),
      dailyLast30Days: ensureDailyActivityLast30Days(
        activity['daily_last_30_days'],
        now: now,
      ),
    ),
    problems: ProblemsStats(
      open: _asInt(problems['open']),
      closed: _asInt(problems['closed']),
      bySource: ProblemSourceByKind(
        bugReports: _sourceCounts(bySource['bug_reports']),
        wordReports: _sourceCounts(bySource['word_reports']),
      ),
    ),
    verifierApplications: VerifierApplicationsStats(
      pending: _asInt(verifier['pending']),
      approved: _asInt(verifier['approved']),
      rejected: _asInt(verifier['rejected']),
    ),
  );
}
