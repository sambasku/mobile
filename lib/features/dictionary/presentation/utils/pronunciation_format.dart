/// Normalisasi value pelafalan: DB/API menyimpan raw tanpa slash tepi.
///
/// Data lama bisa masih `/makatn/` - strip berulang supaya display tidak
/// jadi `//makatn//`.
String pronunciationRaw(String? value) {
  var s = value?.trim() ?? '';
  while (s.startsWith('/')) {
    s = s.substring(1).trimLeft();
  }
  while (s.endsWith('/')) {
    s = s.substring(0, s.length - 1).trimRight();
  }
  return s.trim();
}

/// Bentuk tampilan kamus: `/raw/`. Kosong → string kosong (bukan `//`).
String pronunciationDisplay(String? value) {
  final raw = pronunciationRaw(value);
  if (raw.isEmpty) return '';
  return '/$raw/';
}

/// Gabung beberapa value untuk baris di bawah lemma.
String pronunciationsDisplayLine(Iterable<String> values) {
  final parts = <String>[];
  for (final v in values) {
    final d = pronunciationDisplay(v);
    if (d.isNotEmpty) parts.add(d);
  }
  return parts.join(' · ');
}
