import '../../../core/constants/env.dart';

/// URL publik HTTPS untuk detail kata (share caption + deep link).
/// Kanonik web: `/{locale}/words/<lemma>`, locale default `id`.
String? wordPublicUrl(String lemma) {
  final base = Env.webAppUrl;
  if (base == null || base.isEmpty) return null;
  final clean = lemma.trim();
  if (clean.isEmpty) return null;
  final trimmed = base.endsWith('/')
      ? base.substring(0, base.length - 1)
      : base;
  return '$trimmed/id/words/${Uri.encodeComponent(clean)}';
}

/// Pesan teks untuk share tautan (WhatsApp, grup, aplikasi lain).
String wordShareLinkMessage(String lemma) {
  final clean = lemma.trim();
  final url = wordPublicUrl(clean);
  if (url == null) return clean;
  return '$clean\n$url';
}

/// `/id/words/<lemma>` (link publik) → `/words/<lemma>` (route app).
/// Null kalau path bukan detail kata ber-locale.
String? nativeWordPathFromPublicLink(Uri uri) {
  final segments = uri.pathSegments;
  if (segments.length != 3) return null;
  if (segments[0] != 'id' || segments[1] != 'words') return null;
  final lemma = segments[2].trim();
  if (lemma.isEmpty) return null;
  return '/words/${Uri.encodeComponent(lemma)}';
}
