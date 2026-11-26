/// Logika murni badge chat belum dibaca di chip Diskusi (#360).
///
/// Badge hybrid: titik untuk pesan umum, angka merah hanya untuk reply atau
/// mention ke akun sendiri. Tanpa dependensi Flutter/Riverpod supaya mudah
/// diuji.
library;

import 'chat_models.dart';

/// Penanda "terakhir dibaca" per akun: pesan terbaru yang sudah dilihat.
///
/// [createdAtRaw] disimpan persis seperti dari server (bukan di-serialize
/// ulang) supaya cocok dengan format cursor `after_created_at` API.
class ChatReadCursor {
  const ChatReadCursor({required this.createdAtRaw, required this.id});

  final String createdAtRaw;
  final String id;

  DateTime? get time => DateTime.tryParse(createdAtRaw)?.toUtc();

  Map<String, String> toJson() => {'t': createdAtRaw, 'i': id};

  /// Null bila payload korup/tidak lengkap (anggap belum ada cursor).
  static ChatReadCursor? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final t = raw['t'];
    final i = raw['i'];
    if (t is! String || i is! String || t.isEmpty || i.isEmpty) return null;
    if (DateTime.tryParse(t) == null) return null;
    return ChatReadCursor(createdAtRaw: t, id: i);
  }

  static ChatReadCursor? fromMessage(ChatMessage m) {
    if (m.pending || m.id.isEmpty) return null;
    if (DateTime.tryParse(m.createdAt) == null) return null;
    return ChatReadCursor(createdAtRaw: m.createdAt, id: m.id);
  }

  /// True bila [other] lebih baru dari cursor ini (waktu, lalu id).
  bool isOlderThan(ChatReadCursor other) {
    final a = time;
    final b = other.time;
    if (a == null || b == null) return false;
    final cmp = a.compareTo(b);
    if (cmp != 0) return cmp < 0;
    return id.compareTo(other.id) < 0;
  }
}

/// True bila [m] lebih baru dari [cursor]; tanpa cursor, lebih baru dari
/// [fallbackCutoff] (jendela run pertama).
bool isChatMessageNewer(
  ChatMessage m, {
  required ChatReadCursor? cursor,
  required DateTime fallbackCutoff,
}) {
  final at = DateTime.tryParse(m.createdAt)?.toUtc();
  if (at == null) return false;
  if (cursor == null) return at.isAfter(fallbackCutoff);
  final from = ChatReadCursor.fromMessage(m);
  if (from == null) return false;
  return cursor.isOlderThan(from);
}

/// Pesan yang layak dihitung: bukan milik sendiri, belum dihapus, bukan
/// pesan lokal. Pesan sistem hanya PING (join/leave voice = noise).
bool isChatUnreadEligible(ChatMessage m, {required String? myUserId}) {
  if (m.pending || m.id.isEmpty || m.isDeleted) return false;
  if (myUserId != null && myUserId.isNotEmpty && m.userId == myUserId) {
    return false;
  }
  if (m.kind == ChatMessageKind.system) return m.body == kChatPingBody;
  return true;
}

/// Reply atau mention ke [myUsername]. Tamu (tanpa username) selalu false.
bool isPersonalChatMessage(ChatMessage m, String? myUsername) {
  final me = myUsername?.trim().toLowerCase();
  if (me == null || me.isEmpty) return false;

  final replyTo = m.replyUsername?.trim().toLowerCase();
  if (replyTo != null && replyTo == me) return true;

  final body = m.body;
  if (body == null || body.isEmpty) return false;
  return chatBodyMentions(body, me);
}

/// `@username` utuh (bukan awalan username lain, bukan bagian email).
/// Titik di akhir kalimat (`@budi.`) tetap dihitung.
bool chatBodyMentions(String body, String lowerUsername) {
  final lower = body.toLowerCase();
  final needle = '@$lowerUsername';
  var from = 0;
  while (true) {
    final start = lower.indexOf(needle, from);
    if (start < 0) return false;
    from = start + needle.length;

    if (start > 0 && _isHandleChar(lower.codeUnitAt(start - 1))) continue;

    final end = start + needle.length;
    if (end >= lower.length) return true;
    final next = lower.codeUnitAt(end);
    if (_isWordChar(next) || next == 0x2D) continue; // 0-9 a-z _ -
    if (next == 0x2E && end + 1 < lower.length) {
      // "@budi.santoso" = username lain; "@budi. halo" = akhir kalimat.
      if (_isWordChar(lower.codeUnitAt(end + 1))) continue;
    }
    return true;
  }
}

bool _isWordChar(int c) =>
    (c >= 0x30 && c <= 0x39) ||
    (c >= 0x61 && c <= 0x7A) ||
    (c >= 0x41 && c <= 0x5A) ||
    c == 0x5F;

bool _isHandleChar(int c) =>
    _isWordChar(c) || c == 0x2E || c == 0x2D || c == 0x40;

/// Hitungan badge. [total] = semua pesan baru layak; [personal] = subset
/// reply/mention ke akun sendiri.
class ChatUnreadState {
  const ChatUnreadState({this.total = 0, this.personal = 0});

  final int total;
  final int personal;

  bool get hasUnread => total > 0 || personal > 0;

  @override
  bool operator ==(Object other) =>
      other is ChatUnreadState &&
      other.total == total &&
      other.personal == personal;

  @override
  int get hashCode => Object.hash(total, personal);
}
