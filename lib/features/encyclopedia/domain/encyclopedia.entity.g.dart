// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encyclopedia.entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EncyclopediaCategory _$EncyclopediaCategoryFromJson(
  Map<String, dynamic> json,
) => EncyclopediaCategory(
  id: json['id'] as String,
  name: json['name'] as String,
  status: json['status'] as String?,
  sortOrder: (json['sort_order'] as num?)?.toInt(),
);

Map<String, dynamic> _$EncyclopediaCategoryToJson(
  EncyclopediaCategory instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'status': instance.status,
  'sort_order': instance.sortOrder,
};

EncyclopediaTag _$EncyclopediaTagFromJson(Map<String, dynamic> json) =>
    EncyclopediaTag(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$EncyclopediaTagToJson(EncyclopediaTag instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
    };

EncyclopediaAuthor _$EncyclopediaAuthorFromJson(Map<String, dynamic> json) =>
    EncyclopediaAuthor(
      userId: json['user_id'] as String,
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isVerifier: json['is_verifier'] as bool? ?? false,
    );

Map<String, dynamic> _$EncyclopediaAuthorToJson(EncyclopediaAuthor instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'is_verifier': instance.isVerifier,
    };

EncyclopediaArticleListItem _$EncyclopediaArticleListItemFromJson(
  Map<String, dynamic> json,
) => EncyclopediaArticleListItem(
  id: json['id'] as String,
  slug: json['slug'] as String,
  title: json['title'] as String,
  excerpt: json['excerpt'] as String,
  category: EncyclopediaCategory.fromJson(
    json['category'] as Map<String, dynamic>,
  ),
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  coverUrl: json['cover_url'] as String?,
  publishedAt: json['published_at'] as String?,
);

Map<String, dynamic> _$EncyclopediaArticleListItemToJson(
  EncyclopediaArticleListItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'title': instance.title,
  'excerpt': instance.excerpt,
  'category': instance.category,
  'tags': instance.tags,
  'cover_url': instance.coverUrl,
  'published_at': instance.publishedAt,
};

EncyclopediaArticle _$EncyclopediaArticleFromJson(Map<String, dynamic> json) =>
    EncyclopediaArticle(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      excerpt: json['excerpt'] as String,
      bodyMd: json['body_md'] as String,
      category: EncyclopediaCategory.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      author: EncyclopediaAuthor.fromJson(
        json['author'] as Map<String, dynamic>,
      ),
      status: json['status'] as String,
      coverUrl: json['cover_url'] as String?,
      sourceUrl: json['source_url'] as String?,
      referencesMd: json['references_md'] as String?,
      publishedAt: json['published_at'] as String?,
      bookmarked: json['bookmarked'] as bool?,
    );

Map<String, dynamic> _$EncyclopediaArticleToJson(
  EncyclopediaArticle instance,
) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'title': instance.title,
  'excerpt': instance.excerpt,
  'body_md': instance.bodyMd,
  'category': instance.category,
  'tags': instance.tags,
  'author': instance.author,
  'status': instance.status,
  'cover_url': instance.coverUrl,
  'source_url': instance.sourceUrl,
  'references_md': instance.referencesMd,
  'published_at': instance.publishedAt,
  'bookmarked': instance.bookmarked,
};

EncyclopediaBookmarkResult _$EncyclopediaBookmarkResultFromJson(
  Map<String, dynamic> json,
) => EncyclopediaBookmarkResult(bookmarked: json['bookmarked'] as bool);

Map<String, dynamic> _$EncyclopediaBookmarkResultToJson(
  EncyclopediaBookmarkResult instance,
) => <String, dynamic>{'bookmarked': instance.bookmarked};

EncyclopediaArticlePage _$EncyclopediaArticlePageFromJson(
  Map<String, dynamic> json,
) => EncyclopediaArticlePage(
  items: (json['items'] as List<dynamic>)
      .map(
        (e) => EncyclopediaArticleListItem.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  nextCursor: json['next_cursor'] as String?,
  hasMore: json['has_more'] as bool? ?? false,
);

Map<String, dynamic> _$EncyclopediaArticlePageToJson(
  EncyclopediaArticlePage instance,
) => <String, dynamic>{
  'items': instance.items,
  'next_cursor': instance.nextCursor,
  'has_more': instance.hasMore,
};

ArticleCommentPage _$ArticleCommentPageFromJson(Map<String, dynamic> json) =>
    ArticleCommentPage(
      items: (json['items'] as List<dynamic>)
          .map((e) => ArticleComment.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
      hasMore: json['has_more'] as bool? ?? false,
    );

Map<String, dynamic> _$ArticleCommentPageToJson(ArticleCommentPage instance) =>
    <String, dynamic>{
      'items': instance.items,
      'next_cursor': instance.nextCursor,
      'has_more': instance.hasMore,
    };

MyContributionPage _$MyContributionPageFromJson(Map<String, dynamic> json) =>
    MyContributionPage(
      items: (json['items'] as List<dynamic>)
          .map((e) => MyContributionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
      hasMore: json['has_more'] as bool? ?? false,
    );

Map<String, dynamic> _$MyContributionPageToJson(MyContributionPage instance) =>
    <String, dynamic>{
      'items': instance.items,
      'next_cursor': instance.nextCursor,
      'has_more': instance.hasMore,
    };

EncyclopediaCategoryList _$EncyclopediaCategoryListFromJson(
  Map<String, dynamic> json,
) => EncyclopediaCategoryList(
  items: (json['items'] as List<dynamic>)
      .map((e) => EncyclopediaCategory.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$EncyclopediaCategoryListToJson(
  EncyclopediaCategoryList instance,
) => <String, dynamic>{'items': instance.items};

EncyclopediaTagList _$EncyclopediaTagListFromJson(Map<String, dynamic> json) =>
    EncyclopediaTagList(
      items: (json['items'] as List<dynamic>)
          .map((e) => EncyclopediaTag.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EncyclopediaTagListToJson(
  EncyclopediaTagList instance,
) => <String, dynamic>{'items': instance.items};

ArticleComment _$ArticleCommentFromJson(Map<String, dynamic> json) =>
    ArticleComment(
      id: json['id'] as String,
      articleId: json['article_id'] as String,
      user: EncyclopediaAuthor.fromJson(json['user'] as Map<String, dynamic>),
      body: json['body'] as String,
      status: json['status'] as String,
      imageUrl: json['image_url'] as String?,
      isEdited: json['is_edited'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$ArticleCommentToJson(ArticleComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'article_id': instance.articleId,
      'user': instance.user,
      'body': instance.body,
      'status': instance.status,
      'image_url': instance.imageUrl,
      'is_edited': instance.isEdited,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

SubmitEncyclopediaContributionPayload
_$SubmitEncyclopediaContributionPayloadFromJson(Map<String, dynamic> json) =>
    SubmitEncyclopediaContributionPayload(
      kind: json['kind'] as String,
      title: json['title'] as String,
      excerpt: json['excerpt'] as String,
      bodyMd: json['body_md'] as String,
      categoryId: json['category_id'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      articleId: json['article_id'] as String?,
      coverUrl: json['cover_url'] as String?,
      sourceUrl: json['source_url'] as String?,
      referencesMd: json['references_md'] as String?,
    );

Map<String, dynamic> _$SubmitEncyclopediaContributionPayloadToJson(
  SubmitEncyclopediaContributionPayload instance,
) => <String, dynamic>{
  'kind': instance.kind,
  'title': instance.title,
  'excerpt': instance.excerpt,
  'body_md': instance.bodyMd,
  'category_id': instance.categoryId,
  'tags': instance.tags,
  'article_id': instance.articleId,
  'cover_url': instance.coverUrl,
  'source_url': instance.sourceUrl,
  'references_md': instance.referencesMd,
};

MyContributionItem _$MyContributionItemFromJson(Map<String, dynamic> json) =>
    MyContributionItem(
      id: json['id'] as String,
      kind: json['kind'] as String,
      status: json['status'] as String,
      articleId: json['article_id'] as String?,
      article: json['article'] as Map<String, dynamic>?,
      rejectReasonCode: json['reject_reason_code'] as String?,
      rejectReasonText: json['reject_reason_text'] as String?,
      resultArticleId: json['result_article_id'] as String?,
      createdAt: json['created_at'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
    );

Map<String, dynamic> _$MyContributionItemToJson(MyContributionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'status': instance.status,
      'article_id': instance.articleId,
      'article': instance.article,
      'reject_reason_code': instance.rejectReasonCode,
      'reject_reason_text': instance.rejectReasonText,
      'result_article_id': instance.resultArticleId,
      'created_at': instance.createdAt,
      'reviewed_at': instance.reviewedAt,
    };
