import '../../../core/constants/env.dart';

/// URL publik HTTPS detail acara. Kanonik web: `/id/acara/<slug>`.
///
/// Tanpa app, browser membuka halaman itu. App terpasang mengklaim path
/// yang sama lewat App Link, lalu router membuang prefix `/id`.
String? eventPublicUrl(String slug) {
  final base = Env.webAppUrl;
  if (base == null || base.isEmpty) return null;
  final clean = slug.trim();
  if (clean.isEmpty) return null;
  final trimmed = base.endsWith('/')
      ? base.substring(0, base.length - 1)
      : base;
  return '$trimmed/id/acara/${Uri.encodeComponent(clean)}';
}

/// `/id/acara` dan `/id/acara/<slug>` → route app `/acara...`.
///
/// Path yang sudah `/acara/...` mengembalikan null supaya redirect tidak
/// berulang. `kontribusi` dan `usulan` ikut diubah jadi `/acara/<kata>`;
/// route tetap (didaftar sebelum `:slug`) yang memutuskan halamannya.
String? nativeEventPathFromPublicLink(Uri uri) {
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.length < 2 || segments.length > 3) return null;
  if (segments[0] != 'id' || segments[1] != 'acara') return null;
  if (segments.length == 2) return '/acara';
  final slug = segments[2].trim();
  if (slug.isEmpty) return null;
  return '/acara/${Uri.encodeComponent(slug)}';
}
