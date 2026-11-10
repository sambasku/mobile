// Parse/merge CSV lemma untuk field relasi (sinonim, antonim, dll.).

List<String> parseLemmaCsv(String raw) => raw
    .split(',')
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .toList(growable: false);

String joinLemmaCsv(Iterable<String> lemmas) {
  final parts = [
    for (final l in lemmas)
      if (l.trim().isNotEmpty) l.trim(),
  ];
  if (parts.isEmpty) return '';
  return '${parts.join(', ')}, ';
}

/// Tambah [lemma] ke CSV bila belum ada (case-insensitive).
String appendLemmaCsv(String current, String lemma) {
  final next = lemma.trim();
  if (next.isEmpty) return current;
  final existing = parseLemmaCsv(current);
  final lower = {for (final e in existing) e.toLowerCase()};
  if (lower.contains(next.toLowerCase())) {
    return joinLemmaCsv(existing);
  }
  return joinLemmaCsv([...existing, next]);
}

/// Hapus [lemma] dari CSV (case-insensitive).
String removeLemmaCsv(String current, String lemma) {
  final target = lemma.trim().toLowerCase();
  if (target.isEmpty) return current;
  return joinLemmaCsv(
    parseLemmaCsv(current).where((e) => e.toLowerCase() != target),
  );
}
