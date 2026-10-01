/// Format tanggal-waktu UI Indonesia.
/// Contoh: `17 Nov 2026 21:00`
///
/// Pola baku mobile (lihat docs/mobile/mobile-base-stack.md).
/// Bulan singkat: Jan Feb Mar Apr Mei Jun Jul Agu Sep Okt Nov Des.
library;

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String _pad2(int n) => n.toString().padLeft(2, '0');

/// Toleransi kemiringan jam zwischen server dan perangkat.
const _clockSkewTolerance = Duration(hours: 24);

/// Apakah [value] masuk akal sebagai "sesuatu yang sudah terjadi".
///
/// Feed menampilkan kejadian historis, jadi tidak ada aktivitas yang sah
/// berada di masa depan. Tanggal yang jauh di depan hampir selalu berarti ada
/// yang salah satuan: kolom `mode: 'timestamp'` di Drizzle menyimpan epoch
/// SECONDS, dan kalau diisi epoch MILLISECONDS nilainya dibaca sebagai
/// tahun 50.000-an (#47). Tanpa guard ini, selisih negatif di-clamp jadi nol
/// lalu dirender "baru" - dan baris korupnya terlihat seperti aktivitas
/// paling baru.
bool isPlausibleInstant(DateTime? value, {DateTime? now}) {
  if (value == null) return false;
  final clock = now ?? DateTime.now();
  if (value.isAfter(clock.add(_clockSkewTolerance))) return false;
  return true;
}

/// Format [DateTime] lokal: `17 Nov 2026 21:00`.
String formatDateTime(DateTime? value) {
  if (value == null) return '';
  final local = value.toLocal();
  return '${local.day} ${_months[local.month - 1]} ${local.year} '
      '${_pad2(local.hour)}:${_pad2(local.minute)}';
}

/// Parse ISO (UTC/offset) lalu format lokal. String kosong/invalid → `''`.
String formatDateTimeIso(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return '';
  return formatDateTime(dt);
}

/// Tanggal kalender `YYYY-MM-DD` tanpa geser zona. Contoh: `21 Sep 2026`.
String formatDateYmd(String? ymd) {
  if (ymd == null || ymd.isEmpty) return '';
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(ymd);
  if (match == null) return '';
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  if (month < 1 || month > 12) return '';
  return '$day ${_months[month - 1]} $year';
}

/// Jarak relatif singkat: `baru saja`, `5 menit lalu`, `2 jam lalu`,
/// `3 hari lalu`, lalu `21 Sep 2026` (≥7 hari).
String formatRelativeAgo(DateTime? value, {DateTime? now}) {
  if (value == null) return '';
  final clock = now ?? DateTime.now();
  if (!isPlausibleInstant(value, now: clock)) return '';
  final local = value.toLocal();
  var diff = clock.difference(value);
  if (diff.isNegative) diff = Duration.zero;
  if (diff.inMinutes < 1) return 'baru saja';
  if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
  if (diff.inDays < 1) return '${diff.inHours} jam lalu';
  if (diff.inDays < 7) return '${diff.inDays} hari lalu';
  return '${local.day} ${_months[local.month - 1]} ${local.year}';
}

/// Jarak singkat untuk feed / header thread: `baru saja`, `12 menit`,
/// `2 jam`, `3 hari`, lalu `21 Sep` (≥7 hari). Tanpa singkatan Inggris:
/// `1h` dibaca "1 hari", `1d` dibaca "1 detik".
String formatRelativeCompact(DateTime? value, {DateTime? now}) {
  if (value == null) return '';
  final clock = now ?? DateTime.now();
  if (!isPlausibleInstant(value, now: clock)) return '';
  final local = value.toLocal();
  var diff = clock.difference(value);
  if (diff.isNegative) diff = Duration.zero;
  if (diff.inMinutes < 1) return 'baru saja';
  if (diff.inHours < 1) return '${diff.inMinutes} menit';
  if (diff.inDays < 1) return '${diff.inHours} jam';
  if (diff.inDays < 7) return '${diff.inDays} hari';
  return '${local.day} ${_months[local.month - 1]}';
}
