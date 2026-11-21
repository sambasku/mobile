import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/env.dart';
import '../domain/chat_models.dart';

enum ChatRealtimeEventType { upsert, delete }

class ChatRealtimeEvent {
  const ChatRealtimeEvent({required this.type, required this.message});

  final ChatRealtimeEventType type;
  final ChatMessage message;
}

/// Subscribe Postgres changes `public.chat_messages` via Supabase Realtime.
///
/// Kosong URL/key → null (chat tetap REST). Gagal subscribe → diam; REST
/// tetap jalur utama histori + mutasi.
typedef ChatTypingBroadcastHandler =
    void Function({
      required String userId,
      required String name,
      required bool typing,
    });

class ChatRealtime {
  ChatRealtime._(this._client);

  static final bool _inTests = Platform.environment.containsKey('FLUTTER_TEST');

  final SupabaseClient _client;
  RealtimeChannel? _channel;
  RealtimeChannel? _presenceChannel;
  RealtimeChannel? _typingChannel;
  final _messageListeners = <void Function(ChatRealtimeEvent event)>{};

  static ChatRealtime? tryCreate() {
    // flutter_test gagal invariant "Timer still pending": SupabaseClient
    // .dispose() menjadwalkan Timer 6s (close timeout) di fake_async.
    if (_inTests) return null;
    final url = Env.supabaseUrl;
    final key = Env.supabaseAnonKey;
    if (url == null || key == null) return null;
    try {
      return ChatRealtime._(SupabaseClient(url, key));
    } catch (e, st) {
      debugPrint('ChatRealtime create failed: $e\n$st');
      return null;
    }
  }

  /// Presence "siapa sedang di layar Chat". [presenceKey] = userId / guest-*.
  void startPresence({
    required String presenceKey,
    required Map<String, dynamic> meta,
    required void Function(int count) onCount,
  }) {
    stopPresence();
    final ch = _client.channel(
      'chat-public-presence',
      opts: RealtimeChannelConfig(key: presenceKey),
    );
    _presenceChannel = ch;

    void emitCount() {
      try {
        onCount(ch.presenceState().length);
      } catch (e, st) {
        debugPrint('ChatRealtime presence count failed: $e\n$st');
      }
    }

    ch
        .onPresenceSync((_) => emitCount())
        .onPresenceJoin((_) => emitCount())
        .onPresenceLeave((_) => emitCount())
        .subscribe((status, [_]) async {
          if (status != RealtimeSubscribeStatus.subscribed) return;
          try {
            await ch.track(meta);
          } catch (e, st) {
            debugPrint('ChatRealtime presence track failed: $e\n$st');
          }
        });
  }

  Future<void> stopPresence() async {
    final ch = _presenceChannel;
    _presenceChannel = null;
    if (ch == null) return;
    try {
      await ch.untrack();
    } catch (_) {}
    try {
      await _client.removeChannel(ch);
    } catch (e, st) {
      debugPrint('ChatRealtime stopPresence failed: $e\n$st');
    }
  }

  /// Broadcast ephemeral "sedang mengetik" (tidak nulis DB).
  void startTyping(ChatTypingBroadcastHandler onEvent) {
    stopTyping();
    final ch = _client.channel(
      'chat-public-typing',
      // self: false = jangan echo ke pengirim.
      opts: const RealtimeChannelConfig(),
    );
    _typingChannel = ch;
    ch
        .onBroadcast(
          event: 'typing',
          callback: (payload) {
            try {
              final raw = payload['payload'] is Map
                  ? Map<String, dynamic>.from(payload['payload'] as Map)
                  : Map<String, dynamic>.from(payload);
              final userId = raw['user_id']?.toString() ?? '';
              if (userId.isEmpty) return;
              final name = (raw['name']?.toString() ?? '').trim();
              final typing = raw['typing'] == true || raw['typing'] == 'true';
              onEvent(
                userId: userId,
                name: name.isEmpty ? userId : name,
                typing: typing,
              );
            } catch (e, st) {
              debugPrint('ChatRealtime typing parse failed: $e\n$st');
            }
          },
        )
        .subscribe();
  }

  Future<void> sendTyping({
    required String userId,
    required String name,
    required bool typing,
  }) async {
    final ch = _typingChannel;
    if (ch == null) return;
    try {
      await ch.sendBroadcastMessage(
        event: 'typing',
        payload: {
          'user_id': userId,
          'name': name,
          'typing': typing,
        },
      );
    } catch (e, st) {
      debugPrint('ChatRealtime sendTyping failed: $e\n$st');
    }
  }

  Future<void> stopTyping() async {
    final ch = _typingChannel;
    _typingChannel = null;
    if (ch == null) return;
    try {
      await _client.removeChannel(ch);
    } catch (e, st) {
      debugPrint('ChatRealtime stopTyping failed: $e\n$st');
    }
  }

  /// Tambah listener channel public. Multi-listener aman (shell + chat page).
  void addMessageListener(void Function(ChatRealtimeEvent event) onEvent) {
    _messageListeners.add(onEvent);
    if (_channel == null) {
      _subscribeMessages();
    }
  }

  void removeMessageListener(void Function(ChatRealtimeEvent event) onEvent) {
    _messageListeners.remove(onEvent);
    if (_messageListeners.isEmpty) {
      // ignore: discarded_futures
      stop();
    }
  }

  /// Kompat: satu listener (ganti semua). Prefer [addMessageListener].
  void start(void Function(ChatRealtimeEvent event) onEvent) {
    _messageListeners
      ..clear()
      ..add(onEvent);
    if (_channel == null) {
      _subscribeMessages();
    } else {
      // Channel sudah hidup - biarkan listener set baru.
    }
  }

  void _subscribeMessages() {
    void emit(ChatRealtimeEventType type, Map<String, dynamic> row) {
      try {
        final message = ChatMessage.fromJson(row);
        if (message.id.isEmpty) return;
        if (message.channel != 'public') return;
        final event = ChatRealtimeEvent(type: type, message: message);
        for (final listener in List.of(_messageListeners)) {
          listener(event);
        }
      } catch (e, st) {
        debugPrint('ChatRealtime map failed: $e\n$st');
      }
    }
    _channel = _client
        .channel('chat-public')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'channel',
            value: 'public',
          ),
          callback: (payload) {
            emit(
              ChatRealtimeEventType.upsert,
              Map<String, dynamic>.from(payload.newRecord),
            );
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'channel',
            value: 'public',
          ),
          callback: (payload) {
            emit(
              ChatRealtimeEventType.upsert,
              Map<String, dynamic>.from(payload.newRecord),
            );
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'chat_messages',
          callback: (payload) {
            final row = Map<String, dynamic>.from(payload.oldRecord);
            if (row['id'] == null) return;
            emit(ChatRealtimeEventType.delete, {
              ...row,
              'channel': row['channel'] ?? 'public',
              'user_id': row['user_id'] ?? '',
              'kind': row['kind'] ?? 'text',
              'created_at':
                  row['created_at'] ?? DateTime.now().toUtc().toIso8601String(),
            });
          },
        )
        .subscribe();

  }

  /// Hanya channel postgres messages - presence/typing channel terpisah.
  Future<void> stop() async {
    final ch = _channel;
    _channel = null;
    if (ch != null) await _client.removeChannel(ch);
  }

  Future<void> dispose() async {
    await stopTyping();
    await stopPresence();
    await stop();
    await _client.dispose();
  }
}
