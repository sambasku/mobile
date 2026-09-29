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

/// Jarak singkat untuk feed: `baru saja`, `12 mnt`, `3 jam`, `2 hr`,
/// lalu tanggal-waktu penuh.
String formatRelative(DateTime? value, {DateTime? now}) {
  if (value == null) return '';
  final clock = now ?? DateTime.now();
  var diff = clock.difference(value);
  if (diff.isNegative) diff = Duration.zero;
  if (diff.inMinutes < 1) return 'baru saja';
  if (diff.inHours < 1) return '${diff.inMinutes} mnt';
  if (diff.inDays < 1) return '${diff.inHours} jam';
  if (diff.inDays < 7) return '${diff.inDays} hr';
  return formatDateTime(value);
}

/// Humanize ultra-singkat untuk header thread: `baru`, `12m`, `2h`, `3d`,
/// lalu `21 Sep` (≥7 hari).
String formatRelativeCompact(DateTime? value, {DateTime? now}) {
  if (value == null) return '';
  final clock = now ?? DateTime.now();
  final local = value.toLocal();
  var diff = clock.difference(value);
  if (diff.isNegative) diff = Duration.zero;
  if (diff.inMinutes < 1) return 'baru';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${local.day} ${_months[local.month - 1]}';
}
