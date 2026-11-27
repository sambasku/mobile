import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/chat_unread.dart';

/// Cursor "terakhir dibaca" chat, satu key per akun (#360).
///
/// Akun login: `chat_last_seen_v1:<userId>`. Tamu: `chat_last_seen_v1:guest`.
/// Dua akun di satu HP tidak saling menimpa state badge.
class ChatReadCursorStore {
  const ChatReadCursorStore(this._prefs);

  final SharedPreferences _prefs;

  static const keyPrefix = 'chat_last_seen_v1:';

  static String keyFor(String? userId) {
    final id = userId?.trim();
    return '$keyPrefix${(id == null || id.isEmpty) ? 'guest' : id}';
  }

  /// Payload korup/tidak lengkap = null (anggap belum ada cursor).
  ChatReadCursor? read(String? userId) {
    final raw = _prefs.getString(keyFor(userId));
    if (raw == null || raw.isEmpty) return null;
    try {
      return ChatReadCursor.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String? userId, ChatReadCursor cursor) =>
      _prefs.setString(keyFor(userId), jsonEncode(cursor.toJson()));
}
