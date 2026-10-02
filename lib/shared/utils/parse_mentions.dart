/// Helper mention @username untuk composer komentar/balasan.
///
/// Kontrak sama dengan parser backend (api): token `@[a-zA-Z0-9_.-]{3,30}`
/// (mobile memakai min 2 agar autocomplete muncul sejak ketik 2 huruf;
/// backend yang memvalidasi final). Username sistem `anonim` dikecualikan.
library;

final RegExp _mentionTokenRe = RegExp(r'@[a-zA-Z0-9_.\-]+');

const String _reservedAnonim = 'anonim';

/// Semua kandidat username yang disebut `@...` di [text].
///
/// [cursor] opsional: bila diisi, hanya token aktif (kursor masih di dalam
/// rentang token) yang dikembalikan — untuk memicu autocomplete.
List<String> parseMentionCandidates(String text, {int? cursor}) {
  final seen = <String>{};
  final out = <String>[];
  for (final m in _mentionTokenRe.allMatches(text)) {
    final start = m.start;
    final token = m.group(0)!; // '@abc...'
    final name = token.substring(1);
    // Cegah email/quoted-handle: char sebelum '@' harus bukan bagian kata.
    if (start > 0) {
      final prev = text.codeUnitAt(start - 1);
      final isWordChar = (prev >= 0x30 && prev <= 0x39) || // 0-9
          (prev >= 0x41 && prev <= 0x5A) || // A-Z
          (prev >= 0x61 && prev <= 0x7A) || // a-z
          prev == 0x5F || prev == 0x2E || prev == 0x2D || prev == 0x40; // _ . - @
      if (isWordChar) continue;
    }
    if (name.length < 2 || name.length > 30) continue;
    if (name.toLowerCase() == _reservedAnonim) continue;
    final end = start + token.length; // satu lewat char terakhir token
    if (cursor != null && !(start < cursor && cursor <= end)) continue;
    if (seen.add(name.toLowerCase())) out.add(name);
  }
  return out;
}

/// Hasil sisip mention: teks baru + posisi kursor.
class MentionInsertion {
  const MentionInsertion({required this.text, required this.cursor});
  final String text;
  final int cursor;
}

/// Ganti token `@` aktif di [cursor] dengan `@[username]` + spasi.
/// Spasi selalu ditambah di ujung mention (kecuali sudah ada spasi), biar
/// ketikan lanjutan tidak menempel ke username.
/// Tanpa token aktif → teks utuh, kursor tidak berubah.
MentionInsertion insertMention(String text, int cursor, String username) {
  for (final m in _mentionTokenRe.allMatches(text)) {
    final start = m.start;
    final end = start + m.group(0)!.length;
    if (start < cursor && cursor <= end) {
      final replacement = '@$username';
      final needsSpace = end >= text.length || text[end] != ' ';
      final next = needsSpace ? ' ' : '';
      final inserted =
          text.substring(0, start) + replacement + next + text.substring(end);
      // Kursor setelah spasi (yang ditambah atau yang sudah ada di teks).
      final spaceAfter = next.length + (needsSpace ? 0 : 1);
      return MentionInsertion(
        text: inserted,
        cursor: start + replacement.length + spaceAfter,
      );
    }
  }
  return MentionInsertion(text: text, cursor: cursor);
}
