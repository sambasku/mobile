/// Checker rima pantun - port 1:1 dari
/// `api/src/modules/pantun/application/utils/rhyme-check.ts`.
/// ponytail: substring suffix, bukan fonetis; upgrade bersama API bila
/// pindah ke phoneme-group (jaga dua implementasi tetap identik).
library;

typedef RhymeScheme = String; // 'ABAB' | 'AAAA'

sealed class RhymeCheckResult {
  const RhymeCheckResult();
}

class RhymeOk extends RhymeCheckResult {
  const RhymeOk({this.warning});
  final String? warning;
}

class RhymeLastWordUndetected extends RhymeCheckResult {
  const RhymeLastWordUndetected(this.lineIndex);
  final int lineIndex;
}

class RhymeMismatch extends RhymeCheckResult {
  const RhymeMismatch(this.pairs);

  /// Pasangan baris (1-based) yang belum berima.
  final List<(int, int)> pairs;
}

const Map<String, List<(int, int)>> _schemePairs = {
  'ABAB': [(0, 2), (1, 3)],
  'AAAA': [(0, 1), (0, 2), (0, 3)],
};

final _trailingPunct = RegExp(r'[^\p{L}\p{N}]+$', unicode: true);

/// Kata terakhir baris: strip tanda baca trailing + lowercase; null bila
/// baris tanpa kata.
String? extractLastWord(String line) {
  final words = line
      .trim()
      .split(RegExp(r'\s+'))
      .map((w) => w.replaceAll(_trailingPunct, ''))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return null;
  return words.last.toLowerCase();
}

bool suffixRhymes(String a, String b) {
  if (a == b) return true;
  final maxLen = a.length < b.length ? a.length : b.length;
  if (maxLen < 2) return a == b;
  for (var len = maxLen; len >= 2; len--) {
    if (a.endsWith(b.substring(b.length - len)) ||
        b.endsWith(a.substring(a.length - len))) {
      return true;
    }
  }
  return false;
}

int _matchedSuffixLen(String a, String b) {
  final maxLen = a.length < b.length ? a.length : b.length;
  for (var len = maxLen; len >= 1; len--) {
    if (a.endsWith(b.substring(b.length - len)) &&
        b.endsWith(a.substring(a.length - len))) {
      return len;
    }
  }
  return 0;
}

/// Cek 4 baris terhadap skema. Ambigu (match hanya via suffix pendek)
/// tetap ok + warning - UI peringatkan, tidak memblokir.
RhymeCheckResult detectRhyme(List<String> lines, RhymeScheme scheme) {
  final lastWords = <String>[];
  for (var i = 0; i < lines.length; i++) {
    final w = extractLastWord(i < lines.length ? lines[i] : '');
    if (w == null) return RhymeLastWordUndetected(i);
    lastWords.add(w);
  }
  final pairs = <(int, int)>[];
  var minMatchLen = 0x7FFFFFFFFFFFFFFF;
  for (final (i, j) in _schemePairs[scheme] ?? const <(int, int)>[]) {
    if (!suffixRhymes(lastWords[i], lastWords[j])) {
      pairs.add((i + 1, j + 1));
      continue;
    }
    final len = _matchedSuffixLen(lastWords[i], lastWords[j]);
    if (len < minMatchLen) minMatchLen = len;
  }
  if (pairs.isNotEmpty) return RhymeMismatch(pairs);
  final ambiguous = minMatchLen <= 2;
  return RhymeOk(
    warning: ambiguous
        ? 'Rima terdeteksi dari akhiran teks pendek; pemeriksa bunyi bisa keliru'
        : null,
  );
}

/// Tebak skema rima tanpa user memilih: AAAA dulu (semua baris berima =
/// paling ketat), lalu ABAB. null = tak ada yang cocok. Sama dengan
/// `pickRhymeScheme` di API.
String? pickRhymeScheme(List<String> lines) {
  for (final scheme in const ['AAAA', 'ABAB']) {
    if (detectRhyme(lines, scheme) is RhymeOk) return scheme;
  }
  return null;
}
