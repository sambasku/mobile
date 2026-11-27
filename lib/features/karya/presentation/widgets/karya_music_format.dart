import '../../domain/karya.dart';

/// Format `music_duration_ms` ke `m:ss` (mis. 125000 → `2:05`).
String formatKaryaMusicDuration(int durationMs) {
  final totalSec = (durationMs / 1000).round().clamp(0, 24 * 60 * 60);
  final minutes = totalSec ~/ 60;
  final seconds = totalSec % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// Nama artis utama: kredit `vocal` pertama, fallback kredit pertama.
String? karyaPrimaryArtistName(List<KaryaCredit> credits) {
  for (final credit in credits) {
    final name = credit.nameText.trim();
    if (credit.role == 'vocal' && name.isNotEmpty) return name;
  }
  for (final credit in credits) {
    final name = credit.nameText.trim();
    if (name.isNotEmpty) return name;
  }
  return null;
}
