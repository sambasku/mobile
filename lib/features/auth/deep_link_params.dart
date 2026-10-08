/// Sanitasi parameter query deep link (#70).
///
/// Link eksternal (custom scheme / App Link) bisa membawa `email` dan
/// `token` apa pun. Server tetap validator utama; ini defense-in-depth
/// supaya halaman tidak membuka state menyesatkan dari parameter rusak
/// (enum/injection teks, bukan cuma `contains('@')`).
library;

final _emailRe = RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
// Server: randomBytes(48).toString('hex') = 96 hex. Cukup longgar utk
// perubahan format nanti (alnum 32..256), tapi tolak charset injeksi.
final _tokenRe = RegExp(r'^[A-Za-z0-9]{32,256}$');

/// Email dari query → valid format, selain itu `''`.
String sanitizeEmailParam(String raw) => _emailRe.hasMatch(raw) ? raw : '';

/// Token reset dari query → alnum 32..256, selain itu `''`.
String sanitizeResetTokenParam(String raw) => _tokenRe.hasMatch(raw) ? raw : '';
