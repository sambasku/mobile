import '../../features/comment/domain/entities/comment_image.dart';
import '../../features/jinye/domain/jinye_models.dart';
import '../span_lemma/lemma_links_parse.dart';

/// Target komentar (wisata / usaha / kuliner / acara).
enum EntityCommentTarget { place, usaha, cuisine, event }

/// Satu baris komentar dari wire API (media selaras lemma).
class EntityComment {
  const EntityComment({
    required this.id,
    required this.entityId,
    required this.userId,
    required this.body,
    required this.status,
    required this.isEdited,
    required this.createdAt,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.updatedAt,
    this.stickerId,
    this.audioUrl,
    this.audioMimeType,
    this.audioDurationMs,
    this.image,
    this.lemmaLinks = const [],
  });

  final String id;
  final String entityId;
  final String userId;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String body;
  final String status;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? stickerId;
  final String? audioUrl;
  final String? audioMimeType;
  final int? audioDurationMs;
  final CommentImage? image;
  final List<JinyeLemmaLink> lemmaLinks;

  bool get isTakenDown => status == 'taken_down';
  bool get isDeletedByAuthor => status == 'deleted_by_author';
  bool get isPublished =>
      status == 'published' ||
      (!isTakenDown && !isDeletedByAuthor && status.isNotEmpty);

  bool get hasAudio => audioUrl != null && audioUrl!.trim().isNotEmpty;
  bool get hasImage => image != null;
  bool get hasSticker => stickerId != null && stickerId!.trim().isNotEmpty;

  factory EntityComment.fromJson(
    Map<String, dynamic> json, {
    required String entityIdKey,
  }) {
    final user = json['user'];
    final userMap = user is Map ? Map<String, dynamic>.from(user) : const {};
    final imageRaw = json['image'];
    CommentImage? image;
    if (imageRaw is Map) {
      final map = Map<String, dynamic>.from(imageRaw);
      final status = map['status'] as String?;
      if (status != null && status.isNotEmpty) {
        final warnings = map['content_warnings'];
        image = CommentImage(
          status: status,
          publicUrl: map['public_url'] as String?,
          contentWarnings: warnings is List
              ? warnings.whereType<String>().toList(growable: false)
              : const [],
        );
      }
    } else {
      // Ensiklopedia-style flat image_url (fallback).
      final flat = json['image_url'] as String?;
      if (flat != null && flat.trim().isNotEmpty) {
        image = CommentImage(status: 'published', publicUrl: flat.trim());
      }
    }

    return EntityComment(
      id: json['id'] as String,
      entityId: json[entityIdKey] as String? ?? '',
      userId: userMap['user_id'] as String? ?? '',
      username: userMap['username'] as String?,
      displayName: userMap['display_name'] as String?,
      avatarUrl: userMap['avatar_url'] as String?,
      body: json['body'] as String? ?? '',
      status: json['status'] as String? ?? 'published',
      isEdited: json['is_edited'] == true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: json['updated_at'] is String
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      stickerId: json['sticker_id'] as String?,
      audioUrl: json['audio_url'] as String?,
      audioMimeType: json['audio_mime_type'] as String?,
      audioDurationMs: json['audio_duration_ms'] as int?,
      image: image,
      lemmaLinks: parseLemmaLinksWire(json['lemma_links']),
    );
  }
}

class EntityCommentPage {
  const EntityCommentPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<EntityComment> items;
  final String? nextCursor;
  final bool hasMore;
}
