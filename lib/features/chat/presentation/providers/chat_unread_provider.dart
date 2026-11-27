import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/chat_providers.dart';
import '../../data/chat_read_cursor_store.dart';
import '../../data/chat_realtime.dart';
import '../../domain/chat_models.dart';
import '../../domain/chat_unread.dart';

/// Prefs ter-inject (test override dengan `setMockInitialValues`).
final chatUnreadPrefsProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

/// Badge chat belum dibaca (#360): titik untuk pesan umum, angka untuk
/// reply/mention ke akun sendiri. State per akun lewat cursor lokal
/// (`chat_last_seen_v1:<userId|guest>`).
final chatUnreadProvider =
    NotifierProvider<ChatUnreadController, ChatUnreadState>(
      ChatUnreadController.new,
    );

class ChatUnreadController extends Notifier<ChatUnreadState> {
  /// Batas id yang dilacak (memori). Tampilan sudah dipotong `99+`.
  static const maxTracked = 200;
  static const fetchLimit = 100;
  static const refreshDebounce = Duration(seconds: 30);

  /// Run pertama (belum ada cursor): hitung pesan sejauh jendela ini.
  static const firstRunWindow = Duration(hours: 24);

  String? _userId;
  String? _username;
  ChatReadCursor? _cursor;
  ChatReadCursor? _latest;
  var _cursorLoaded = false;
  var _viewers = 0;
  var _generation = 0;
  DateTime? _lastRefreshAt;

  /// id pesan belum dibaca -> apakah personal (reply/mention).
  final LinkedHashMap<String, bool> _tracked = LinkedHashMap();

  @override
  ChatUnreadState build() {
    final identity = ref.watch(
      authStatusProvider.select((s) {
        final a = s.value;
        if (a == null || !a.isAuth) return (null as String?, null as String?);
        return (a.userId, a.username);
      }),
    );
    _userId = identity.$1;
    _username = identity.$2;

    // Ganti akun / logout: buang hasil async lama, mulai dari nol.
    _generation++;
    _cursor = null;
    _latest = null;
    _cursorLoaded = false;
    _lastRefreshAt = null;
    _tracked.clear();

    final realtime = ref.watch(chatRealtimeProvider);
    if (realtime != null) {
      realtime.addMessageListener(_onRealtime);
      ref.onDispose(() => realtime.removeMessageListener(_onRealtime));
    }

    scheduleMicrotask(() {
      if (ref.mounted) unawaited(refresh(force: true));
    });
    return const ChatUnreadState();
  }

  bool _alive(int generation) => ref.mounted && generation == _generation;

  /// Sinkron dari REST (cold start, app resume, ganti akun). Gagal = state
  /// terakhir dipertahankan. Debounce 30 detik kecuali [force].
  Future<void> refresh({bool force = false}) async {
    final now = DateTime.now();
    final last = _lastRefreshAt;
    if (!force && last != null && now.difference(last) < refreshDebounce) {
      return;
    }
    _lastRefreshAt = now;

    final generation = _generation;
    try {
      final cursor = await _loadCursor();
      if (!_alive(generation)) return;

      final repo = ref.read(chatRepositoryProvider);
      final result = cursor == null
          ? await repo.listMessages(limit: fetchLimit)
          : await repo.listMessages(
              limit: fetchLimit,
              afterCreatedAt: cursor.createdAtRaw,
              afterId: cursor.id,
            );
      if (!_alive(generation)) return;

      result.match(
        (_) => _lastRefreshAt = null, // coba lagi di refresh berikutnya
        (page) => _applyFetched(page.items),
      );
    } catch (e, st) {
      _lastRefreshAt = null;
      debugPrint('ChatUnread refresh failed: $e\n$st');
    }
  }

  Future<ChatReadCursor?> _loadCursor() async {
    if (_cursorLoaded) return _cursor;
    final generation = _generation;
    final userId = _userId;
    ChatReadCursor? loaded;
    try {
      final prefs = await ref.read(chatUnreadPrefsProvider.future);
      loaded = ChatReadCursorStore(prefs).read(userId);
    } catch (e) {
      debugPrint('ChatUnread cursor read failed: $e');
    }
    if (!_alive(generation)) return null;
    _cursor = loaded;
    _cursorLoaded = true;
    return loaded;
  }

  DateTime get _cutoff => DateTime.now().toUtc().subtract(firstRunWindow);

  void _applyFetched(List<ChatMessage> items) {
    _tracked.clear();
    for (final m in items) {
      _noteLatest(m);
    }
    if (_viewers > 0) {
      // Chat sedang dibuka: semua yang baru terambil sudah terlihat.
      _publish();
      unawaited(_persistLatest());
      return;
    }
    final cutoff = _cutoff;
    for (final m in items) {
      if (!isChatMessageNewer(m, cursor: _cursor, fallbackCutoff: cutoff)) {
        continue;
      }
      if (!isChatUnreadEligible(m, myUserId: _userId)) continue;
      _track(m);
    }
    _publish();
  }

  void _onRealtime(ChatRealtimeEvent event) {
    if (!ref.mounted) return;
    final m = event.message;

    if (event.type == ChatRealtimeEventType.delete || m.isDeleted) {
      if (_tracked.remove(m.id) != null) _publish();
      return;
    }

    _noteLatest(m);
    if (_viewers > 0) {
      unawaited(_persistLatest());
      return;
    }
    if (!isChatMessageNewer(m, cursor: _cursor, fallbackCutoff: _cutoff)) {
      return;
    }
    if (!isChatUnreadEligible(m, myUserId: _userId)) {
      if (_tracked.remove(m.id) != null) _publish();
      return;
    }
    _track(m); // upsert: edit pesan sama tidak menggandakan hitungan
    _publish();
  }

  void _track(ChatMessage m) {
    _tracked.remove(m.id);
    _tracked[m.id] = isPersonalChatMessage(m, _username);
    while (_tracked.length > maxTracked) {
      _tracked.remove(_tracked.keys.first);
    }
  }

  void _noteLatest(ChatMessage m) {
    final candidate = ChatReadCursor.fromMessage(m);
    if (candidate == null) return;
    final current = _latest;
    if (current == null || current.isOlderThan(candidate)) _latest = candidate;
  }

  void _publish() {
    var personal = 0;
    for (final isPersonal in _tracked.values) {
      if (isPersonal) personal++;
    }
    final next = ChatUnreadState(total: _tracked.length, personal: personal);
    if (next != state) state = next;
  }

  Future<void> _persistLatest() async {
    final latest = _latest;
    if (latest == null) return;
    _cursor = latest;
    _cursorLoaded = true;
    final generation = _generation;
    final userId = _userId;
    try {
      final prefs = await ref.read(chatUnreadPrefsProvider.future);
      if (!_alive(generation)) return;
      await ChatReadCursorStore(prefs).write(userId, latest);
    } catch (e) {
      debugPrint('ChatUnread cursor write failed: $e');
    }
  }

  /// Tap chip Diskusi: badge hilang, cursor maju ke pesan terbaru yang
  /// diketahui. Pesan berikutnya memunculkan badge lagi.
  Future<void> markAsRead() {
    _tracked.clear();
    _publish();
    return _persistLatest();
  }

  /// Dipanggil ChatPage tiap daftar pesan berubah (selama terbuka).
  void noteSeen(ChatMessage latest) {
    _noteLatest(latest);
    if (_viewers <= 0) return;
    _tracked.clear();
    _publish();
    unawaited(_persistLatest());
  }

  void chatViewOpened() {
    _viewers++;
    unawaited(markAsRead());
  }

  void chatViewClosed() {
    if (_viewers > 0) _viewers--;
  }
}
