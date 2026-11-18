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
class ChatRealtime {
  ChatRealtime._(this._client);

  final SupabaseClient _client;
  RealtimeChannel? _channel;
  RealtimeChannel? _presenceChannel;

  static ChatRealtime? tryCreate() {
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

  /// Mulai listen channel public. Panggil [stop] saat dispose.
  void start(void Function(ChatRealtimeEvent event) onEvent) {
    void emit(ChatRealtimeEventType type, Map<String, dynamic> row) {
      try {
        final message = ChatMessage.fromJson(row);
        if (message.id.isEmpty) return;
        if (message.channel != 'public') return;
        onEvent(ChatRealtimeEvent(type: type, message: message));
      } catch (e, st) {
        debugPrint('ChatRealtime map failed: $e\n$st');
      }
    }

    stop();
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

  Future<void> stop() async {
    await stopPresence();
    final ch = _channel;
    _channel = null;
    if (ch != null) await _client.removeChannel(ch);
  }

  Future<void> dispose() async {
    await stop();
    await _client.dispose();
  }
}
