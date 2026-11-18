/// Model domain + wire mapping untuk chat publik (channel tunggal).
library;

enum ChatMessageKind {
  text,
  sticker,
  voiceNote;

  static ChatMessageKind fromWire(String? raw) {
    switch (raw) {
      case 'sticker':
        return ChatMessageKind.sticker;
      case 'voice_note':
        return ChatMessageKind.voiceNote;
      default:
        return ChatMessageKind.text;
    }
  }

  String get wire => switch (this) {
    ChatMessageKind.text => 'text',
    ChatMessageKind.sticker => 'sticker',
    ChatMessageKind.voiceNote => 'voice_note',
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

/// Pack stiker v1: gambar statis + GIF play-sekali (hemat CPU).
class ChatSticker {
  const ChatSticker({
    required this.id,
    required this.asset,
    this.playOnce = false,
  });

  final String id;
  final String asset;

  /// true = GIF diputar sekali lalu diam (bukan loop).
  final bool playOnce;
}

const kChatStickers = <ChatSticker>[
  ChatSticker(id: 'cheer', asset: 'assets/stickers/cheer.png'),
  ChatSticker(id: 'fire', asset: 'assets/stickers/fire.png'),
  ChatSticker(id: 'heart', asset: 'assets/stickers/heart.png'),
  ChatSticker(id: 'ok', asset: 'assets/stickers/ok.png'),
  ChatSticker(id: 'party', asset: 'assets/stickers/party.png'),
  ChatSticker(id: 'pray', asset: 'assets/stickers/pray.png'),
  ChatSticker(
    id: 'wave',
    asset: 'assets/stickers/wave.gif',
    playOnce: true,
  ),
];

const kChatStickerIds = <String>[
  'cheer',
  'fire',
  'heart',
  'ok',
  'party',
  'pray',
  'wave',
];

ChatSticker? chatStickerById(String? id) {
  if (id == null || id.isEmpty) return null;
  for (final s in kChatStickers) {
    if (s.id == id) return s;
  }
  return null;
}

class ChatFailure implements Exception {
  const ChatFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  @override
  String toString() => message;
}
