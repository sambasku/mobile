import 'package:json_annotation/json_annotation.dart';

import '../../../shared/models/content_related_link.dart';

part 'encyclopedia.entity.g.dart';

List<ContentRelatedLink> _relatedFromJson(Object? json) =>
    ContentRelatedLink.listFromJson(json);

List<Map<String, dynamic>>? _relatedToJson(List<ContentRelatedLink>? related) =>
    related?.map((e) => e.toRefJson()).toList();

/// Kategori = katalog `encyclopedia_categories` (slug, bukan ULID).
@JsonSerializable(fieldRename: FieldRename.snake)
class EncyclopediaCategory {
  const EncyclopediaCategory({
    required this.id,
    required this.name,
    this.status,
    this.sortOrder,
  });
  factory EncyclopediaCategory.fromJson(Map<String, dynamic> json) =>
      _$EncyclopediaCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$EncyclopediaCategoryToJson(this);

  final String id;
  final String name;
  final String? status;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
}

/// Tag wire `{id, slug, name}`.
@JsonSerializable(fieldRename: FieldRename.snake)
class EncyclopediaTag {
  const EncyclopediaTag({
    required this.id,
    required this.slug,
    required this.name,
  });
  factory EncyclopediaTag.fromJson(Map<String, dynamic> json) =>
      _$EncyclopediaTagFromJson(json);
  Map<String, dynamic> toJson() => _$EncyclopediaTagToJson(this);

  final String id;
  final String slug;
  final String name;
}

/// Penulis/komentator wire (semua null saat akun dihapus).
@JsonSerializable(fieldRename: FieldRename.snake)
class EncyclopediaAuthor {
  const EncyclopediaAuthor({
    @JsonKey(name: 'user_id') required this.userId,
    this.username,
    this.displayName,
    this.avatarUrl,
    @JsonKey(name: 'is_verifier') this.isVerifier = false,
  });
  factory EncyclopediaAuthor.fromJson(Map<String, dynamic> json) =>
      _$EncyclopediaAuthorFromJson(json);
  Map<String, dynamic> toJson() => _$EncyclopediaAuthorToJson(this);

  final String userId;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final bool isVerifier;
}

/// Item ringkas list (tanpa body - payload hemat).
@JsonSerializable(fieldRename: FieldRename.snake)
class EncyclopediaArticleListItem {
  const EncyclopediaArticleListItem({
    required this.id,
    required this.slug,
    required this.title,
    required this.excerpt,
    required this.category,
    required this.tags,
    this.coverUrl,
    this.publishedAt,
  });
  factory EncyclopediaArticleListItem.fromJson(Map<String, dynamic> json) =>
      _$EncyclopediaArticleListItemFromJson(json);
  Map<String, dynamic> toJson() => _$EncyclopediaArticleListItemToJson(this);

  final String id;
  final String slug;
  final String title;
  final String excerpt;
  final EncyclopediaCategory category;
  final List<String> tags;
  @JsonKey(name: 'cover_url')
  final String? coverUrl;
  @JsonKey(name: 'published_at')
  final String? publishedAt;
}

/// Detail artikel - `GET /articles/:slug`.
@JsonSerializable(fieldRename: FieldRename.snake)
class EncyclopediaArticle {
  const EncyclopediaArticle({
    required this.id,
    required this.slug,
    required this.title,
    required this.excerpt,
    required this.bodyMd,
    required this.category,
    required this.tags,
    required this.author,
    required this.status,
    this.coverUrl,
    this.sourceUrl,
    this.referencesMd,
    this.publishedAt,
    this.bookmarked,
    this.related = const [],
  });
  factory EncyclopediaArticle.fromJson(Map<String, dynamic> json) =>
      _$EncyclopediaArticleFromJson(json);
  Map<String, dynamic> toJson() => _$EncyclopediaArticleToJson(this);

  final String id;
  final String slug;
  final String title;
  final String excerpt;
  @JsonKey(name: 'body_md')
  final String bodyMd;
  final EncyclopediaCategory category;
  final List<String> tags;
  final EncyclopediaAuthor author;
  final String status;
  @JsonKey(name: 'cover_url')
  final String? coverUrl;
  @JsonKey(name: 'source_url')
  final String? sourceUrl;
  @JsonKey(name: 'references_md')
  final String? referencesMd;
  @JsonKey(name: 'published_at')
  final String? publishedAt;
  /// null = tamu / tidak dicek; true/false = status bookmark user login.
  final bool? bookmarked;
  @JsonKey(fromJson: _relatedFromJson, toJson: _relatedToJson)
  final List<ContentRelatedLink> related;
}

/// Response toggle bookmark - `POST /articles/:id/bookmark`.
@JsonSerializable(fieldRename: FieldRename.snake)
class EncyclopediaBookmarkResult {
  const EncyclopediaBookmarkResult({required this.bookmarked});
  factory EncyclopediaBookmarkResult.fromJson(Map<String, dynamic> json) =>
      _$EncyclopediaBookmarkResultFromJson(json);
  Map<String, dynamic> toJson() => _$EncyclopediaBookmarkResultToJson(this);

  final bool bookmarked;
}

/// Halaman ber-kursor: `data = {items, next_cursor, has_more}`.
@JsonSerializable(fieldRename: FieldRename.snake)
class EncyclopediaArticlePage {
  const EncyclopediaArticlePage({
    required this.items,
    @JsonKey(name: 'next_cursor') this.nextCursor,
    @JsonKey(name: 'has_more') this.hasMore = false,
  });
  factory EncyclopediaArticlePage.fromJson(Map<String, dynamic> json) =>
      _$EncyclopediaArticlePageFromJson(json);
  Map<String, dynamic> toJson() => _$EncyclopediaArticlePageToJson(this);

  final List<EncyclopediaArticleListItem> items;
  final String? nextCursor;
  final bool hasMore;
}

/// Halaman komentar: `data = {items, next_cursor, has_more}`.
@JsonSerializable(fieldRename: FieldRename.snake)
class ArticleCommentPage {
  const ArticleCommentPage({
    required this.items,
    @JsonKey(name: 'next_cursor') this.nextCursor,
    @JsonKey(name: 'has_more') this.hasMore = false,
  });
  factory ArticleCommentPage.fromJson(Map<String, dynamic> json) =>
      _$ArticleCommentPageFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleCommentPageToJson(this);

  final List<ArticleComment> items;
  final String? nextCursor;
  final bool hasMore;
}

/// Halaman riwayat usulan user: `data = {items, next_cursor, has_more}`.
@JsonSerializable(fieldRename: FieldRename.snake)
class MyContributionPage {
  const MyContributionPage({
    required this.items,
    @JsonKey(name: 'next_cursor') this.nextCursor,
    @JsonKey(name: 'has_more') this.hasMore = false,
  });
  factory MyContributionPage.fromJson(Map<String, dynamic> json) =>
      _$MyContributionPageFromJson(json);
  Map<String, dynamic> toJson() => _$MyContributionPageToJson(this);

  final List<MyContributionItem> items;
  final String? nextCursor;
  final bool hasMore;
}

/// Data kategori: `data = {items}` (tanpa pagination).
@JsonSerializable(fieldRename: FieldRename.snake)
class EncyclopediaCategoryList {
  const EncyclopediaCategoryList({required this.items});
  factory EncyclopediaCategoryList.fromJson(Map<String, dynamic> json) =>
      _$EncyclopediaCategoryListFromJson(json);
  Map<String, dynamic> toJson() => _$EncyclopediaCategoryListToJson(this);

  final List<EncyclopediaCategory> items;
}

/// Data tag: `data = {items}` (tanpa pagination).
@JsonSerializable(fieldRename: FieldRename.snake)
class EncyclopediaTagList {
  const EncyclopediaTagList({required this.items});
  factory EncyclopediaTagList.fromJson(Map<String, dynamic> json) =>
      _$EncyclopediaTagListFromJson(json);
  Map<String, dynamic> toJson() => _$EncyclopediaTagListToJson(this);

  final List<EncyclopediaTag> items;
}

/// Komentar artikel (list publik hanya `published`).
@JsonSerializable(fieldRename: FieldRename.snake)
class ArticleComment {
  const ArticleComment({
    required this.id,
    required this.articleId,
    required this.user,
    required this.body,
    required this.status,
    this.imageUrl,
    this.stickerId,
    this.audioUrl,
    this.audioMimeType,
    this.audioDurationMs,
    this.isEdited = false,
    this.createdAt,
    this.updatedAt,
  });
  factory ArticleComment.fromJson(Map<String, dynamic> json) =>
      _$ArticleCommentFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleCommentToJson(this);

  final String id;
  @JsonKey(name: 'article_id')
  final String articleId;
  final EncyclopediaAuthor user;
  final String body;
  final String status;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'sticker_id')
  final String? stickerId;
  @JsonKey(name: 'audio_url')
  final String? audioUrl;
  @JsonKey(name: 'audio_mime_type')
  final String? audioMimeType;
  @JsonKey(name: 'audio_duration_ms')
  final int? audioDurationMs;
  @JsonKey(name: 'is_edited')
  final bool isEdited;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  bool get isPublished => status == 'published';
  bool get isTakenDown => status == 'taken_down';
  bool get isDeletedByAuthor => status == 'deleted_by_author';
  bool get hasSticker =>
      stickerId != null && stickerId!.trim().isNotEmpty;
  bool get hasAudio => audioUrl != null && audioUrl!.trim().isNotEmpty;
  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;
  bool isOwner(String? actorId) =>
      actorId != null && actorId.isNotEmpty && actorId == user.userId;
}

/// Payload usulan kontribusi (new & edit bentuknya sama; `kind` penentu).
@JsonSerializable(fieldRename: FieldRename.snake)
class SubmitEncyclopediaContributionPayload {
  const SubmitEncyclopediaContributionPayload({
    required this.kind,
    required this.title,
    required this.excerpt,
    required this.bodyMd,
    required this.categoryId,
    this.tags = const [],
    this.articleId,
    this.coverUrl,
    this.sourceUrl,
    this.referencesMd,
    this.related,
  });
  factory SubmitEncyclopediaContributionPayload.fromJson(
    Map<String, dynamic> json,
  ) => _$SubmitEncyclopediaContributionPayloadFromJson(json);
  Map<String, dynamic> toJson() =>
      _$SubmitEncyclopediaContributionPayloadToJson(this);

  final String kind;
  final String title;
  final String excerpt;
  @JsonKey(name: 'body_md')
  final String bodyMd;
  @JsonKey(name: 'category_id')
  final String categoryId;
  final List<String> tags;
  @JsonKey(name: 'article_id')
  final String? articleId;
  @JsonKey(name: 'cover_url')
  final String? coverUrl;
  @JsonKey(name: 'source_url')
  final String? sourceUrl;
  @JsonKey(name: 'references_md')
  final String? referencesMd;
  @JsonKey(toJson: _relatedToJson, includeIfNull: false)
  final List<ContentRelatedLink>? related;
}

/// Payload tersimpan di usulan (wire `toContributionWire.payload`).
@JsonSerializable(fieldRename: FieldRename.snake)
class EncyclopediaContributionPayload {
  const EncyclopediaContributionPayload({
    required this.title,
    required this.excerpt,
    required this.bodyMd,
    required this.categoryId,
    this.tags = const [],
    this.coverUrl,
    this.sourceUrl,
    this.referencesMd,
    this.related = const [],
  });
  factory EncyclopediaContributionPayload.fromJson(Map<String, dynamic> json) =>
      _$EncyclopediaContributionPayloadFromJson(json);
  Map<String, dynamic> toJson() =>
      _$EncyclopediaContributionPayloadToJson(this);

  final String title;
  final String excerpt;
  @JsonKey(name: 'body_md')
  final String bodyMd;
  @JsonKey(name: 'category_id')
  final String categoryId;
  final List<String> tags;
  @JsonKey(name: 'cover_url')
  final String? coverUrl;
  @JsonKey(name: 'source_url')
  final String? sourceUrl;
  @JsonKey(name: 'references_md')
  final String? referencesMd;
  @JsonKey(fromJson: _relatedFromJson, toJson: _relatedToJson)
  final List<ContentRelatedLink> related;
}

/// Riwayat usulan milik user (wire `toContributionWire`).
@JsonSerializable(fieldRename: FieldRename.snake)
class MyContributionItem {
  const MyContributionItem({
    required this.id,
    required this.kind,
    required this.status,
    this.articleId,
    this.article,
    this.payload,
    this.revisionNote,
    this.rejectReasonCode,
    this.rejectReasonText,
    this.resultArticleId,
    this.createdAt,
    this.reviewedAt,
  });
  factory MyContributionItem.fromJson(Map<String, dynamic> json) =>
      _$MyContributionItemFromJson(json);
  Map<String, dynamic> toJson() => _$MyContributionItemToJson(this);

  final String id;
  final String kind;
  final String status;
  @JsonKey(name: 'article_id')
  final String? articleId;
  final Map<String, dynamic>? article;
  final EncyclopediaContributionPayload? payload;
  @JsonKey(name: 'revision_note')
  final String? revisionNote;
  @JsonKey(name: 'reject_reason_code')
  final String? rejectReasonCode;
  @JsonKey(name: 'reject_reason_text')
  final String? rejectReasonText;
  @JsonKey(name: 'result_article_id')
  final String? resultArticleId;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'reviewed_at')
  final String? reviewedAt;

  bool get canEdit => status == 'pending' || status == 'needs_revision';

  String get displayTitle {
    final fromPayload = payload?.title.trim();
    if (fromPayload != null && fromPayload.isNotEmpty) return fromPayload;
    final fromArticle = article?['title'];
    if (fromArticle is String && fromArticle.trim().isNotEmpty) {
      return fromArticle.trim();
    }
    return '';
  }
}