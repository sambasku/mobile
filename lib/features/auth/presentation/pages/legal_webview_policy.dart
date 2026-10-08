/// Kebijakan navigasi WebView dokumen legal (#75):
/// - hanya izinkan host yang sama dengan URL awal (dokumen statis, in-app)
/// - host lain harus dibuka eksternal (url_launcher), bukan di dalam WebView
library;

/// True bila [target] satu host dengan [initial] (case-insensitive).
bool isSameNavigationHost(Uri initial, Uri target) {
  final a = initial.host.toLowerCase();
  final b = target.host.toLowerCase();
  return a.isNotEmpty && a == b;
}

/// True bila navigasi harus tetap di dalam WebView (dokumen legal).
/// Skema non-http(s) (mailto:, tel:, intent:) tidak pernah in-app.
bool shouldAllowInAppNavigation(Uri initial, Uri target) {
  final scheme = target.scheme.toLowerCase();
  if (scheme != 'https' && scheme != 'http') return false;
  return isSameNavigationHost(initial, target);
}
