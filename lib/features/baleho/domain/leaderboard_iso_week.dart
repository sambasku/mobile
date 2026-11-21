/// ISO 8601 week id (`YYYY-Www`) untuk pilihan riwayat lokal.
library;

/// Minggu ISO untuk [date] dalam zona lokal.
(int year, int week) isoWeekYearAndNumber(DateTime date) {
  final local = date.toLocal();
  final thursday = local.add(Duration(days: 4 - local.weekday));
  final year = thursday.year;
  final jan4 = DateTime(year, 1, 4);
  final week1Monday = jan4.subtract(Duration(days: jan4.weekday - 1));
  final week =
      1 + ((thursday.difference(week1Monday).inDays) / 7).floor();
  return (year, week);
}

String formatIsoWeekId(DateTime date) {
  final (year, week) = isoWeekYearAndNumber(date);
  return '$year-W${week.toString().padLeft(2, '0')}';
}

/// Minggu ISO pertama fitur papan live (riwayat tidak menampilkan sebelum ini).
/// Staging seed mulai W46 supaya preview minggu lalu tersedia saat W47 masih jalan.
const kLeaderboardHistoryEarliestWeekId = '2026-W46';

/// Daftar [count] minggu sebelum minggu [anchor] (default: sekarang).
/// Hanya week_id >= [earliestWeekId] (default: [kLeaderboardHistoryEarliestWeekId]).
List<String> listPastIsoWeekIds({
  int count = 20,
  DateTime? anchor,
  String earliestWeekId = kLeaderboardHistoryEarliestWeekId,
}) {
  if (count < 1) return const [];
  final base = (anchor ?? DateTime.now()).toLocal();
  final ids = <String>[];
  var cursor = base.subtract(const Duration(days: 7));
  for (var i = 0; i < count; i++) {
    final id = formatIsoWeekId(cursor);
    if (id.compareTo(earliestWeekId) < 0) break;
    ids.add(id);
    cursor = cursor.subtract(const Duration(days: 7));
  }
  return ids;
}

/// URL CDN weekly. Pakai [templateWeeklyUrl] dari `meta.cdn.weekly` (staging/prod
/// beda owner/repo); fallback prod bila template kosong.
String weeklyLeaderboardCdnUrl(String weekId, {String? templateWeeklyUrl}) {
  final template = templateWeeklyUrl?.trim();
  if (template != null && template.contains('/weekly/')) {
    return template.replaceFirst(
      RegExp(r'/weekly/[^/?#]+\.json'),
      '/weekly/$weekId.json',
    );
  }
  return 'https://cdn.jsdelivr.net/gh/sambasku/leaderboard@main/weekly/$weekId.json';
}