import '../../features/comment/domain/entities/comment_image.dart';
import '../../features/jinye/domain/jinye_models.dart';
import '../span_lemma/lemma_links_parse.dart';

/// Target komentar seragam (semua 8 permukaan UGC).
enum EntityCommentTarget {
  word,
  article,
  jinye,
  place,
  usaha,
  cuisine,
  event,
  karya;

  /// Nilai `target_type` untuk API vote polimorfik (`/api/v1/votes`).
  String get voteTargetType => switch (this) {
        EntityCommentTarget.word => 'comment',
        EntityCommentTarget.article => 'article_comment',
        EntityCommentTarget.jinye => 'jinye_comment',
        EntityCommentTarget.place => 'place_comment',
        EntityCommentTarget.usaha => 'usaha_comment',
        EntityCommentTarget.cuisine => 'cuisine_comment',
        EntityCommentTarget.event => 'event_comment',
        EntityCommentTarget.karya => 'karya_comment',
      };
}

/// Satu snapshot revisi komentar dari `GET .../edit-history`.
class EntityCommentRevision {
  const EntityCommentRevision({
    required this.body,
    required this.editorId,
    required this.createdAt,
  });

  final String body;
  final String editorId;
  final DateTime createdAt;

  factory EntityCommentRevision.fromJson(Map<String, dynamic> json) {
    return EntityCommentRevision(
      body: json['body'] as String? ?? '',
      editorId: json['editor_id'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Riwayat sunting komentar seragam.
class EntityCommentEditHistory {
  const EntityCommentEditHistory({
    required this.currentBody,
    required this.isEdited,
    required this.revisions,
    this.updatedAt,
  });

  final String? currentBody;
  final DateTime? updatedAt;
  final bool isEdited;
  final List<EntityCommentRevision> revisions;

  factory EntityCommentEditHistory.fromJson(Map<String, dynamic> json) {
    final current = json['current'] is Map
        ? Map<String, dynamic>.from(json['current'] as Map)
        : const <String, dynamic>{};
    final rawRevs = json['revisions'];
    final revisions = <EntityCommentRevision>[];
    if (rawRevs is List) {
      for (final raw in rawRevs.whereType<Map>()) {
        revisions.add(
          EntityCommentRevision.fromJson(Map<String, dynamic>.from(raw)),
        );
      }
    }
    return EntityCommentEditHistory(
      currentBody: current['body'] as String?,
      updatedAt: current['updated_at'] is String
          ? DateTime.tryParse(current['updated_at'] as String)
          : null,
      isEdited: current['is_edited'] == true,
      revisions: revisions,
    );
  }
}

/// Satu baris komentar dari wire API (2-level nested, media + vote + lemma).
class EntityComment {
  const EntityComment({
    required this.id,
    required this.entityId,
    required this.userId,
    required this.body,
    required this.status,
    required this.isEdited,
    required this.createdAt,
    this.parentId,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.isVerifier = false,
    this.updatedAt,
    this.stickerId,
    this.audioUrl,
    this.audioMimeType,
    this.audioDurationMs,
    this.image,
    this.images = const [],
    this.upvotes = 0,
    this.downvotes = 0,
    this.lemmaLinks = const [],
    this.replies = const [],
  });

  final String id;
  final String entityId;
  final String? parentId;
  final String userId;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final bool isVerifier;
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
  final List<CommentImage> images;
  final int upvotes;
  final int downvotes;
  final List<JinyeLemmaLink> lemmaLinks;
  final List<EntityComment> replies;

  bool get isTakenDown => status == 'taken_down';
  bool get isDeletedByAuthor => status == 'deleted_by_author';
  bool get isPublished =>
      status == 'published' ||
      (!isTakenDown && !isDeletedByAuthor && status.isNotEmpty);

  bool get hasAudio => audioUrl != null && audioUrl!.trim().isNotEmpty;
  bool get hasImage => image != null || images.isNotEmpty;
  bool get hasSticker => stickerId != null && stickerId!.trim().isNotEmpty;

  /// Total semua gambar (prioritaskan `images` multi-foto, fallback `image` tunggal).
  List<CommentImage> get allImages {
    if (images.isNotEmpty) return images;
    if (image != null) return [image!];
    return const [];
  }

  EntityComment copyWith({
    String? body,
    bool? isEdited,
    DateTime? updatedAt,
    List<EntityComment>? replies,
    List<JinyeLemmaLink>? lemmaLinks,
  }) {
    return EntityComment(
      id: id,
      entityId: entityId,
      parentId: parentId,
      userId: userId,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      isVerifier: isVerifier,
      body: body ?? this.body,
      status: status,
      isEdited: isEdited ?? this.isEdited,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stickerId: stickerId,
      audioUrl: audioUrl,
      audioMimeType: audioMimeType,
      audioDurationMs: audioDurationMs,
      image: image,
      images: images,
      upvotes: upvotes,
      downvotes: downvotes,
      lemmaLinks: lemmaLinks ?? this.lemmaLinks,
      replies: replies ?? this.replies,
    );
  }

  static CommentImage? _parseSingleImage(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) {
      return CommentImage(status: 'published', publicUrl: raw.trim());
    }
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final status = map['status'] as String?;
    if (status == null || status.isEmpty) return null;
    final warnings = map['content_warnings'];
    return CommentImage(
      status: status,
      publicUrl: map['public_url'] as String?,
      contentWarnings: warnings is List
          ? warnings.whereType<String>().toList(growable: false)
          : const [],
    );
  }

  factory EntityComment.fromJson(
    Map<String, dynamic> json, {
    required String entityIdKey,
  }) {
    // Support nested `user: {...}` (entity/article) dan flat `user_id` (word/jinye).
    final userRaw = json['user'];
    final userMap =
        userRaw is Map ? Map<String, dynamic>.from(userRaw) : const {};
    final userId =
        (userMap['user_id'] ?? json['user_id']) as String? ?? '';
    final username = (userMap['username'] ?? json['username']) as String?;
    final displayName =
        (userMap['display_name'] ?? json['display_name']) as String?;
    final avatarUrl =
        (userMap['avatar_url'] ?? json['avatar_url']) as String?;
    final isVerifier =
        userMap['is_verifier'] == true || json['is_verifier'] == true;

    CommentImage? image = _parseSingleImage(json['image']);
    final images = <CommentImage>[];
    final imagesRaw = json['images'];
    if (imagesRaw is List) {
      for (final raw in imagesRaw) {
        final parsed = _parseSingleImage(raw);
        if (parsed != null) images.add(parsed);
      }
    }
    if (image == null && images.isEmpty) {
      // Ensiklopedia-style flat image_url (fallback).
      final flat = json['image_url'] as String?;
      if (flat != null && flat.trim().isNotEmpty) {
        image = CommentImage(status: 'published', publicUrl: flat.trim());
      }
    } else if (image == null && images.isNotEmpty) {
      image = images.first;
    }

    final replies = <EntityComment>[];
    final rawReplies = json['replies'];
    if (rawReplies is List) {
      for (final raw in rawReplies.whereType<Map>()) {
        replies.add(
          EntityComment.fromJson(
            Map<String, dynamic>.from(raw),
            entityIdKey: entityIdKey,
          ),
        );
      }
    }

    final parentRaw = json['parent_id'] as String?;
    final parentId =
        parentRaw != null && parentRaw.trim().isNotEmpty ? parentRaw : null;

    return EntityComment(
      id: json['id'] as String,
      entityId: json[entityIdKey] as String? ?? '',
      parentId: parentId,
      userId: userId,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      isVerifier: isVerifier,
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
      audioDurationMs: (json['audio_duration_ms'] as num?)?.toInt(),
      image: image,
      images: images,
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
      downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
      lemmaLinks: parseLemmaLinksWire(json['lemma_links']),
      replies: replies,
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
