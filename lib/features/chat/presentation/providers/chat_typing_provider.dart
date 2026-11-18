import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/chat_providers.dart';

class ChatTyper {
  const ChatTyper({required this.userId, required this.name});

  final String userId;
  final String name;
}

/// Orang lain yang sedang mengetik (Broadcast ephemeral).
final chatTypingProvider =
    NotifierProvider<ChatTypingController, List<ChatTyper>>(
      ChatTypingController.new,
    );

class ChatTypingController extends Notifier<List<ChatTyper>> {
  static const _idleTimeout = Duration(seconds: 3);
  static const _broadcastThrottle = Duration(milliseconds: 1500);

  final _expiry = <String, Timer>{};
  var _listening = false;
  DateTime? _lastBroadcastAt;
  var _lastBroadcastTyping = false;
  String? _selfUserId;

  @override
  List<ChatTyper> build() {
    ref.onDispose(() {
      _cancelAllExpiry();
      unawaited(ref.read(chatRealtimeProvider)?.stopTyping() ?? Future.value());
    });
    return const [];
  }

  void startListening({required String? selfUserId}) {
    final rt = ref.read(chatRealtimeProvider);
    if (rt == null) return;
    _selfUserId = selfUserId;
    if (_listening) return;
    _listening = true;
    rt.startTyping(({
      required String userId,
      required String name,
      required bool typing,
    }) {
      if (!ref.mounted) return;
      if (_selfUserId != null && userId == _selfUserId) return;
      if (!typing) {
        _remove(userId);
        return;
      }
      _upsert(userId, name);
    });
  }

  Future<void> stopListening() async {
    _listening = false;
    _cancelAllExpiry();
    state = const [];
    await ref.read(chatRealtimeProvider)?.stopTyping();
  }

  /// Throttle broadcast saat user mengetik di composer.
  void onLocalTextChanged({
    required String userId,
    required String name,
    required String text,
  }) {
    _selfUserId = userId;
    final typing = text.trim().isNotEmpty;
    if (!typing) {
      unawaited(stopLocalTyping(userId: userId, name: name));
      return;
    }
    final now = DateTime.timestamp();
    final last = _lastBroadcastAt;
    if (_lastBroadcastTyping &&
        last != null &&
        now.difference(last) < _broadcastThrottle) {
      return;
    }
    _lastBroadcastAt = now;
    _lastBroadcastTyping = true;
    unawaited(
      ref.read(chatRealtimeProvider)?.sendTyping(
            userId: userId,
            name: name,
            typing: true,
          ) ??
          Future.value(),
    );
  }

  Future<void> stopLocalTyping({
    required String userId,
    required String name,
  }) async {
    if (!_lastBroadcastTyping && _lastBroadcastAt == null) return;
    _lastBroadcastTyping = false;
    _lastBroadcastAt = DateTime.timestamp();
    await ref.read(chatRealtimeProvider)?.sendTyping(
          userId: userId,
          name: name,
          typing: false,
        );
  }

  void _upsert(String userId, String name) {
    final next = [
      for (final t in state)
        if (t.userId != userId) t,
      ChatTyper(userId: userId, name: name),
    ];
    state = next;
    _expiry[userId]?.cancel();
    _expiry[userId] = Timer(_idleTimeout, () {
      if (!ref.mounted) return;
      _remove(userId);
    });
  }

  void _remove(String userId) {
    _expiry.remove(userId)?.cancel();
    if (!state.any((t) => t.userId == userId)) return;
    state = [for (final t in state) if (t.userId != userId) t];
  }

  void _cancelAllExpiry() {
    for (final t in _expiry.values) {
      t.cancel();
    }
    _expiry.clear();
  }
}
