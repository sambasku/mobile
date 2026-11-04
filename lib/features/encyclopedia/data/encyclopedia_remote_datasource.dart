import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../domain/encyclopedia.entity.dart';

part 'encyclopedia_remote_datasource.g.dart';

@RestApi()
abstract interface class EncyclopediaRemoteDatasource {
  factory EncyclopediaRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _EncyclopediaRemoteDatasource;

  /// List artikel (publik) - GET /api/v1/encyclopedia/articles.
  @GET('/api/v1/encyclopedia/articles')
  Future<ApiResponse<EncyclopediaArticlePage>> listArticles(
    @Queries() Map<String, dynamic> query,
  );

  /// Cari artikel (publik) - GET /api/v1/encyclopedia/articles/search.
  @GET('/api/v1/encyclopedia/articles/search')
  Future<ApiResponse<EncyclopediaArticlePage>> searchArticles(
    @Queries() Map<String, dynamic> query,
  );

  /// Detail artikel (publik, optional auth) - GET /api/v1/encyclopedia/articles/:slug.
  @GET('/api/v1/encyclopedia/articles/{slug}')
  Future<ApiResponse<EncyclopediaArticle>> getArticle(
    @Path('slug') String slug,
  );

  /// Katalog kategori (publik) - GET /api/v1/encyclopedia/categories.
  @GET('/api/v1/encyclopedia/categories')
  Future<ApiResponse<EncyclopediaCategoryList>> getCategories();

  /// Autocomplete tag (publik) - GET /api/v1/encyclopedia/tags.
  @GET('/api/v1/encyclopedia/tags')
  Future<ApiResponse<EncyclopediaTagList>> getTags(
    @Queries() Map<String, dynamic> query,
  );

  /// Komentar satu artikel (publik) - GET /api/v1/encyclopedia/articles/:id/comments.
  @GET('/api/v1/encyclopedia/articles/{id}/comments')
  Future<ApiResponse<ArticleCommentPage>> getComments(
    @Path('id') String id,
    @Queries() Map<String, dynamic> query,
  );

  /// Kirim komentar (login) - POST /api/v1/encyclopedia/articles/:id/comments.
  @POST('/api/v1/encyclopedia/articles/{id}/comments')
  Future<ApiResponse<ArticleComment>> postComment(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Toggle bookmark (login) - POST /api/v1/encyclopedia/articles/:id/bookmark.
  @POST('/api/v1/encyclopedia/articles/{id}/bookmark')
  Future<ApiResponse<EncyclopediaBookmarkResult>> toggleBookmark(
    @Path('id') String id,
  );

  /// Kirim usulan (login) - POST /api/v1/encyclopedia/contributions.
  @POST('/api/v1/encyclopedia/contributions')
  Future<ApiResponse<MyContributionItem>> submitContribution(
    @Body() SubmitEncyclopediaContributionPayload body,
  );

  /// Kirim ulang usulan needs_revision - PATCH /api/v1/encyclopedia/contributions/:id.
  @PATCH('/api/v1/encyclopedia/contributions/{id}')
  Future<ApiResponse<MyContributionItem>> resubmitContribution(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Riwayat usulan user (login) - GET /api/v1/encyclopedia/me/contributions.
  @GET('/api/v1/encyclopedia/me/contributions')
  Future<ApiResponse<MyContributionPage>> getMyContributions(
    @Queries() Map<String, dynamic> query,
  );
}
