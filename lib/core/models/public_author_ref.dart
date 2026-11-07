import 'package:flutter/foundation.dart';

/// Pengusul live dari wire API (`author: { id, username, display_name }`).
@immutable
class PublicAuthorRef {
  const PublicAuthorRef({
    required this.id,
    required this.username,
    required this.displayName,
  });

  final String id;
  final String username;
  final String displayName;

  /// Null bila objek absen / username kosong / anonim.
  static PublicAuthorRef? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    String? str(String snake, [String? camel]) {
      final a = map[snake];
      if (a is String && a.trim().isNotEmpty) return a.trim();
      if (camel != null) {
        final b = map[camel];
        if (b is String && b.trim().isNotEmpty) return b.trim();
      }
      return null;
    }

    final id = str('id');
    final username = str('username');
    if (id == null || username == null || username == 'anonim') return null;
    final display = str('display_name', 'displayName') ?? username;
    return PublicAuthorRef(id: id, username: username, displayName: display);
  }
}
