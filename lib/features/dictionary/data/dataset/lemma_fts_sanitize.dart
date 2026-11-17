/// Sanitasi query user untuk FTS5 MATCH (cegah inject `"` / operator).
String sanitizeFtsMatchQuery(String raw, {int maxTokens = 8, int maxLen = 80}) {
  var input = raw.trim();
  if (input.isEmpty) return '';
  if (input.length > maxLen) {
    input = input.substring(0, maxLen);
  }

  // Hapus kontrol + karakter yang memecah sintaks FTS.
  input = input.replaceAll(RegExp(r'[\x00-\x1f]'), ' ');
  input = input.replaceAll(RegExp(r'''["*^:]'''), ' ');
  input = input.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (input.isEmpty) return '';

  final tokens = input
      .split(' ')
      .where((t) => t.isNotEmpty)
      .take(maxTokens)
      .toList(growable: false);
  if (tokens.isEmpty) return '';

  // Prefix per token: "kong"*
  return tokens.map((t) => '"$t"*').join(' ');
}
