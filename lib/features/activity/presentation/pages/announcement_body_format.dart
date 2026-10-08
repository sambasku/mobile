/// Deteksi format konten announcement (#123-style rich body).
/// Heuristik murah dan deterministik - konten admin, bukan input publik.
enum AnnouncementBodyFormat { html, markdown, plain }

/// - html: diawali tag block-level, ATAU >1 tag inline HTML.
/// - markdown: heading/list/emphasis/link MD.
/// - plain: sisanya (default aman).
AnnouncementBodyFormat detectAnnouncementBodyFormat(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return AnnouncementBodyFormat.plain;

  // HTML block-level di awal dokumen.
  if (RegExp(
    r'^<(p|div|section|article|h[1-6]|ul|ol|table|br)\b',
    caseSensitive: false,
  ).hasMatch(s)) {
    return AnnouncementBodyFormat.html;
  }

  // Tag inline HTML: >1 kemunculan = konten sengaja HTML.
  final inlineTags = RegExp(
    r'</?(b|strong|i|em|u|s|code|pre|a|img|span|blockquote|ul|ol|li|h[1-6]|p|div|table|tr|td|th|br)\b[^>]*>',
    caseSensitive: false,
  ).allMatches(s).length;
  if (inlineTags > 1) return AnnouncementBodyFormat.html;

  // Markdown.
  if (RegExp(r'^#{1,6}\s', multiLine: true).hasMatch(s) ||
      RegExp(r'^\s*[-*+]\s+', multiLine: true).hasMatch(s) ||
      RegExp(r'^\s*\d+\.\s+', multiLine: true).hasMatch(s) ||
      RegExp(r'\*\*[^*\n]+\*\*|__[^_\n]+__').hasMatch(s) ||
      RegExp(r'^\s*>', multiLine: true).hasMatch(s) ||
      RegExp(r'\[[^\]\n]+\]\([^)\n]+\)').hasMatch(s)) {
    return AnnouncementBodyFormat.markdown;
  }

  return AnnouncementBodyFormat.plain;
}
