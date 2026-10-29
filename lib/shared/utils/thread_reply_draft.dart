import 'public_account_name.dart';

/// Hasil draft balas (GitHub-style quote + mention) untuk composer thread.
class ThreadReplyDraft {
  const ThreadReplyDraft({
    required this.text,
    required this.cursor,
    required this.prefix,
    this.quotePreview,
    this.mentionUsername,
  });

  /// Teks penuh yang diisi ke composer.
  final String text;

  /// Posisi kursor (biasanya akhir [text]).
  final int cursor;

  /// Prefiks otomatis (untuk [stripLeadingReplyDraft] saat dismiss/kirim).
  final String prefix;

  /// Cuplikan satu baris untuk chip "Membalas".
  final String? quotePreview;

  /// Username yang di-@ (null jika di-skip).
  final String? mentionUsername;
}

/// Bangun draft balas: blok `>` opsional + `@username ` opsional.
///
/// - Quote max [maxQuoteChars] / [maxQuoteLines]; body kosong/null → tanpa quote.
/// - Mention di-skip bila username tidak linkable atau sama [currentUsername].
ThreadReplyDraft buildThreadReplyDraft({
  String? username,
  String? body,
  String? currentUsername,
  int maxQuoteChars = 120,
  int maxQuoteLines = 3,
}) {
  final quoteSnippet = _snippetForQuote(
    body,
    maxQuoteChars: maxQuoteChars,
    maxQuoteLines: maxQuoteLines,
  );
  final quoteBlock = quoteSnippet == null
      ? ''
      : quoteSnippet
          .split('\n')
          .map((line) => line.isEmpty ? '>' : '> $line')
          .join('\n');

  final canMention = isLinkablePublicUsername(username) &&
      (currentUsername == null ||
          username!.toLowerCase() != currentUsername.toLowerCase());
  final mention = canMention ? '@$username ' : '';

  final buf = StringBuffer();
  if (quoteBlock.isNotEmpty) {
    buf.writeln(quoteBlock);
    buf.writeln();
  }
  buf.write(mention);
  final text = buf.toString();

  return ThreadReplyDraft(
    text: text,
    cursor: text.length,
    prefix: text,
    quotePreview: quoteSnippet?.split('\n').firstWhere(
          (l) => l.trim().isNotEmpty,
          orElse: () => quoteSnippet,
        ),
    mentionUsername: canMention ? username : null,
  );
}

/// Hapus [draftPrefix] dari awal [text] bila masih utuh; sisanya dipertahankan.
String stripLeadingReplyDraft(String text, String draftPrefix) {
  if (draftPrefix.isEmpty) return text;
  if (text.startsWith(draftPrefix)) {
    return text.substring(draftPrefix.length);
  }
  return text;
}

/// Pecah leading blockquote markdown (`>` / `> `) dari sisa body.
({String quote, String rest}) splitLeadingBlockquote(String body) {
  if (body.isEmpty) return (quote: '', rest: '');
  final lines = body.split('\n');
  final quoteLines = <String>[];
  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    final match = RegExp(r'^> ?(.*)$').firstMatch(line);
    if (match == null) break;
    quoteLines.add(match.group(1) ?? '');
    i++;
  }
  if (quoteLines.isEmpty) return (quote: '', rest: body);
  // Lewati satu baris kosong pemisah quote ↔ balasan (pola draft kita).
  if (i < lines.length && lines[i].trim().isEmpty) i++;
  final rest = lines.sublist(i).join('\n');
  return (quote: quoteLines.join('\n'), rest: rest);
}

String? _snippetForQuote(
  String? body, {
  required int maxQuoteChars,
  required int maxQuoteLines,
}) {
  final trimmed = body?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;

  // Jangan kutip ulang marker `>` mentah: rapikan tiap baris.
  final cleaned = trimmed
      .split('\n')
      .map((line) {
        final m = RegExp(r'^> ?(.*)$').firstMatch(line);
        return m != null ? (m.group(1) ?? '') : line;
      })
      .join('\n')
      .trim();
  if (cleaned.isEmpty) return null;

  final lines = cleaned.split('\n');
  final taken = <String>[];
  var chars = 0;
  for (final line in lines) {
    if (taken.length >= maxQuoteLines) break;
    final room = maxQuoteChars - chars;
    if (room <= 0) break;
    if (line.length <= room) {
      taken.add(line);
      chars += line.length + (taken.length > 1 ? 1 : 0);
    } else {
      taken.add('${line.substring(0, room).trimRight()}…');
      break;
    }
  }
  final snippet = taken.join('\n').trim();
  return snippet.isEmpty ? null : snippet;
}
