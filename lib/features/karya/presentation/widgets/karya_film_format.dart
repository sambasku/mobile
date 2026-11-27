import '../../domain/karya.dart';

/// Format `film_runtime_min` ke angka menit (label ARB di UI).
int? karyaFilmRuntimeMinutes(int? runtimeMin) {
  if (runtimeMin == null || runtimeMin <= 0) return null;
  return runtimeMin.clamp(1, 1000);
}

/// Nama utama film: kredit `director` pertama, fallback kredit pertama.
String? karyaPrimaryDirectorName(List<KaryaCredit> credits) {
  for (final credit in credits) {
    final name = credit.nameText.trim();
    if (credit.role == 'director' && name.isNotEmpty) return name;
  }
  for (final credit in credits) {
    final name = credit.nameText.trim();
    if (name.isNotEmpty) return name;
  }
  return null;
}
