import 'dart:convert';

/// Decode payload JWT access token (tanpa verifikasi tanda tangan).
/// Dipakai untuk sync klaim publik seperti `username` ke sesi lokal.
Map<String, dynamic>? decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final normalized = base64Url.normalize(parts[1]);
    final json = utf8.decode(base64Url.decode(normalized));
    final decoded = jsonDecode(json);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}

String? usernameFromAccessToken(String? accessToken) {
  if (accessToken == null || accessToken.isEmpty) return null;
  final payload = decodeJwtPayload(accessToken);
  final username = payload?['username'];
  if (username is! String) return null;
  final trimmed = username.trim();
  return trimmed.isEmpty ? null : trimmed;
}
