import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/pantun_compose_args.dart';

/// Draf 4 baris pantun di SharedPreferences, key per target quote.
///
/// ```text
/// tmp_pantun:v1:new
/// tmp_pantun:v1:reply:{rootId}:quote:root
/// tmp_pantun:v1:reply:{rootId}:quote:{replyId}
/// ```
class PantunDraftStore {
  PantunDraftStore({SharedPreferences? prefs}) : _prefsOverride = prefs;

  static const keyPrefix = 'tmp_pantun:v1:';
  static const maxEntries = 20;
  static const ttl = Duration(days: 7);

  final SharedPreferences? _prefsOverride;

  Future<SharedPreferences> _prefs() async =>
      _prefsOverride ?? SharedPreferences.getInstance();

  /// Key penyimpanan dari konteks compose.
  static String draftKey({String? parentId, String? quoteId}) {
    if (parentId == null || parentId.isEmpty) return '${keyPrefix}new';
    final quote =
        (quoteId == null ||
            quoteId.isEmpty ||
            quoteId == PantunComposeArgs.quoteRoot)
        ? PantunComposeArgs.quoteRoot
        : quoteId;
    return '${keyPrefix}reply:$parentId:quote:$quote';
  }

  static String draftKeyFromArgs(PantunComposeArgs args) => draftKey(
    parentId: args.parentId,
    quoteId: args.isReply ? args.normalizedQuoteId : null,
  );

  /// Baca draf; null jika kosong, kedaluwarsa, atau rusak. Side-effect: hapus
  /// entri TTL mati dan LRU kelebihan.
  Future<PantunDraft?> load({String? parentId, String? quoteId}) async {
    final prefs = await _prefs();
    await _prune(prefs);
    final key = draftKey(parentId: parentId, quoteId: quoteId);
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    final draft = PantunDraft.tryParse(raw);
    if (draft == null) {
      await prefs.remove(key);
      return null;
    }
    if (draft.isExpired(DateTime.now().toUtc(), ttl)) {
      await prefs.remove(key);
      return null;
    }
    return draft;
  }

  /// Simpan 4 baris. Skip jika semua kosong (whitespace). Setelah write, LRU.
  Future<void> save({
    required List<String> lines,
    String? parentId,
    String? quoteId,
    DateTime? now,
  }) async {
    final normalized = _normalizeLines(lines);
    final key = draftKey(parentId: parentId, quoteId: quoteId);
    final prefs = await _prefs();
    if (normalized.every((l) => l.isEmpty)) {
      await prefs.remove(key);
      await _prune(prefs);
      return;
    }
    final draft = PantunDraft(
      lines: normalized,
      updatedAt: (now ?? DateTime.now().toUtc()),
    );
    await prefs.setString(key, draft.encode());
    await _prune(prefs);
  }

  Future<void> clear({String? parentId, String? quoteId}) async {
    final prefs = await _prefs();
    await prefs.remove(draftKey(parentId: parentId, quoteId: quoteId));
  }

  /// Hapus draf `quote:{replyId}` yang balasannya sudah tidak ada di thread.
  /// Key `quote:root` dan `new` tidak disentuh.
  Future<void> clearMissingReplyQuotes({
    required String parentId,
    required Set<String> liveReplyIds,
  }) async {
    if (parentId.isEmpty) return;
    final prefs = await _prefs();
    final prefix = '${keyPrefix}reply:$parentId:quote:';
    for (final key in prefs.getKeys().toList(growable: false)) {
      if (!key.startsWith(prefix)) continue;
      final quotePart = key.substring(prefix.length);
      if (quotePart.isEmpty || quotePart == PantunComposeArgs.quoteRoot) {
        continue;
      }
      if (!liveReplyIds.contains(quotePart)) {
        await prefs.remove(key);
      }
    }
  }

  /// Hapus TTL + jaga max [maxEntries] (LRU by updatedAt).
  Future<void> _prune(SharedPreferences prefs) async {
    final now = DateTime.now().toUtc();
    final entries = <_DraftEntry>[];
    for (final key in prefs.getKeys()) {
      if (!key.startsWith(keyPrefix)) continue;
      final raw = prefs.getString(key);
      if (raw == null) continue;
      final draft = PantunDraft.tryParse(raw);
      if (draft == null || draft.isExpired(now, ttl)) {
        await prefs.remove(key);
        continue;
      }
      entries.add(_DraftEntry(key: key, updatedAt: draft.updatedAt));
    }
    if (entries.length <= maxEntries) return;
    entries.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    final overflow = entries.length - maxEntries;
    for (var i = 0; i < overflow; i++) {
      await prefs.remove(entries[i].key);
    }
  }

  static List<String> _normalizeLines(List<String> lines) {
    final out = List<String>.filled(4, '');
    for (var i = 0; i < 4 && i < lines.length; i++) {
      out[i] = lines[i].trimRight();
    }
    return out;
  }
}

class PantunDraft {
  const PantunDraft({required this.lines, required this.updatedAt});

  final List<String> lines;
  final DateTime updatedAt;

  bool isExpired(DateTime now, Duration ttl) =>
      now.difference(updatedAt) > ttl;

  bool get hasContent => lines.any((l) => l.trim().isNotEmpty);

  String encode() => jsonEncode({
    'lines': lines,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  });

  static PantunDraft? tryParse(String raw) {
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return null;
      final linesRaw = map['lines'];
      final atRaw = map['updatedAt'];
      if (linesRaw is! List || atRaw is! String) return null;
      final lines = List<String>.filled(4, '');
      for (var i = 0; i < 4 && i < linesRaw.length; i++) {
        final v = linesRaw[i];
        lines[i] = v is String ? v : '$v';
      }
      final updatedAt = DateTime.parse(atRaw).toUtc();
      return PantunDraft(lines: lines, updatedAt: updatedAt);
    } catch (_) {
      return null;
    }
  }
}

class _DraftEntry {
  const _DraftEntry({required this.key, required this.updatedAt});
  final String key;
  final DateTime updatedAt;
}
