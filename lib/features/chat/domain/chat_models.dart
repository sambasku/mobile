/// Model domain + wire mapping untuk chat publik (channel tunggal).
library;

/// Body system untuk jejak ping (wire). UI: ikon radio + nama : PING!!!
const kChatPingBody = 'PING!!!';

/// Body system voice join/leave (mirror API VOICE_PRESENCE_BODY).
const kChatVoiceJoinBody = 'bergabung ke voice room';
const kChatVoiceLeaveBody = 'keluar dari voice room';

enum ChatMessageKind {
  text,
  sticker,
  voiceNote,
  system;

  static ChatMessageKind fromWire(String? raw) {
    switch (raw) {
      case 'sticker':
        return ChatMessageKind.sticker;
      case 'voice_note':
        return ChatMessageKind.voiceNote;
      case 'system':
        return ChatMessageKind.system;
      default:
        return ChatMessageKind.text;
    }
  }

  String get wire => switch (this) {
    ChatMessageKind.text => 'text',
    ChatMessageKind.sticker => 'sticker',
    ChatMessageKind.voiceNote => 'voice_note',
    ChatMessageKind.system => 'system',
  };
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.channel,
    required this.userId,
    required this.kind,
    required this.createdAt,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.body,
    this.stickerId,
    this.audioUrl,
    this.durationMs,
    this.replyToId,
    this.replySnippet,
    this.replyUsername,
    this.editedAt,
    this.deletedAt,
    this.pending = false,
  });

  final String id;
  final String channel;
  final String userId;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final ChatMessageKind kind;
  final String? body;
  final String? stickerId;
  final String? audioUrl;
  final int? durationMs;
  final String? replyToId;
  final String? replySnippet;
  final String? replyUsername;
  final String? editedAt;
  final String? deletedAt;
  final String createdAt;

  /// Bubble lokal sebelum response API (optimistic).
  final bool pending;

  bool get isDeleted => (deletedAt ?? '').isNotEmpty;
  bool get isEdited => (editedAt ?? '').isNotEmpty;

  ChatMessage copyWith({
    String? id,
    String? channel,
    String? userId,
    String? username,
    String? displayName,
    String? avatarUrl,
    ChatMessageKind? kind,
    String? body,
    String? stickerId,
    String? audioUrl,
    int? durationMs,
    String? replyToId,
    String? replySnippet,
    String? replyUsername,
    String? editedAt,
    String? deletedAt,
    String? createdAt,
    bool? pending,
    bool clearDeletedAt = false,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      channel: channel ?? this.channel,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      kind: kind ?? this.kind,
      body: body ?? this.body,
      stickerId: stickerId ?? this.stickerId,
      audioUrl: audioUrl ?? this.audioUrl,
      durationMs: durationMs ?? this.durationMs,
      replyToId: replyToId ?? this.replyToId,
      replySnippet: replySnippet ?? this.replySnippet,
      replyUsername: replyUsername ?? this.replyUsername,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      createdAt: createdAt ?? this.createdAt,
      pending: pending ?? this.pending,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      channel: json['channel']?.toString() ?? 'public',
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString(),
      displayName: json['display_name']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      kind: ChatMessageKind.fromWire(json['kind']?.toString()),
      body: json['body']?.toString(),
      stickerId: json['sticker_id']?.toString(),
      audioUrl: json['audio_url']?.toString(),
      durationMs: _asInt(json['duration_ms']),
      replyToId: json['reply_to_id']?.toString(),
      replySnippet: json['reply_snippet']?.toString(),
      replyUsername: json['reply_username']?.toString(),
      editedAt: json['edited_at']?.toString(),
      deletedAt: json['deleted_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  static int? _asInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }
}

class ChatMessagePage {
  const ChatMessagePage({required this.items, required this.hasMore});

  final List<ChatMessage> items;
  final bool hasMore;
}

class ChatCapabilities {
  const ChatCapabilities({required this.voiceRoomEnabled});

  final bool voiceRoomEnabled;

  factory ChatCapabilities.fromJson(Map<String, dynamic> json) {
    return ChatCapabilities(
      voiceRoomEnabled: json['voice_room_enabled'] == true,
    );
  }
}

class ChatFailure implements Exception {
  const ChatFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  @override
  String toString() => message;
}

bool isChatPingMessage(ChatMessage message) =>
    message.kind == ChatMessageKind.system &&
    (message.body ?? '').trim() == kChatPingBody;

class ChatPingStatus {
  const ChatPingStatus({
    required this.cooldownSeconds,
    this.availableAt,
    this.lastPingAt,
  });

  final String? availableAt;
  final int cooldownSeconds;
  final String? lastPingAt;

  factory ChatPingStatus.fromJson(Map<String, dynamic> json) {
    return ChatPingStatus(
      availableAt: json['available_at']?.toString(),
      cooldownSeconds: (json['cooldown_seconds'] as num?)?.toInt() ?? 300,
      lastPingAt: json['last_ping_at']?.toString(),
    );
  }

  DateTime? get availableAtDate =>
      availableAt == null ? null : DateTime.tryParse(availableAt!);

  bool get isReady {
    final at = availableAtDate;
    if (at == null) return true;
    return !at.toUtc().isAfter(DateTime.now().toUtc());
  }

  Duration get remaining {
    final at = availableAtDate;
    if (at == null) return Duration.zero;
    final diff = at.toUtc().difference(DateTime.now().toUtc());
    return diff.isNegative ? Duration.zero : diff;
  }
}
