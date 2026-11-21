import 'package:dio/dio.dart';

import '../../../core/models/api_response.dart';
import '../data/encyclopedia_remote_datasource.dart';
import 'encyclopedia.entity.dart';

/// Kontrak akses API ensiklopedia.
abstract interface class EncyclopediaRepository {
  Future<ApiResponse<EncyclopediaArticlePage>> listArticles(
    Map<String, dynamic> query,
  );
  Future<ApiResponse<EncyclopediaArticlePage>> searchArticles(
    Map<String, dynamic> query,
  );
  Future<ApiResponse<EncyclopediaArticle>> getArticle(String slug);
  Future<ApiResponse<EncyclopediaCategoryList>> getCategories();
  Future<ApiResponse<EncyclopediaTagList>> getTags(Map<String, dynamic> query);
  Future<ApiResponse<ArticleCommentPage>> getComments(
    String id,
    Map<String, dynamic> query,
  );
  Future<ApiResponse<ArticleComment>> postComment(
    String id,
    Map<String, dynamic> body,
  );
  Future<ApiResponse<ArticleComment>> updateComment(
    String id,
    Map<String, dynamic> body,
  );
  Future<ApiResponse<void>> deleteComment(String id);
  Future<ApiResponse<EncyclopediaBookmarkResult>> toggleBookmark(String id);
  Future<ApiResponse<MyContributionItem>> submitContribution(
    SubmitEncyclopediaContributionPayload body,
  );
  Future<ApiResponse<MyContributionItem>> updateContribution(
    String id,
    Map<String, dynamic> body,
  );
  Future<ApiResponse<MyContributionPage>> getMyContributions(
    Map<String, dynamic> query,
  );
  Future<void> recordView(String slug);
}

class EncyclopediaRepositoryImpl implements EncyclopediaRepository {
  EncyclopediaRepositoryImpl(this._remote, this._dio);
  final EncyclopediaRemoteDatasource _remote;
  final Dio _dio;

  @override
  Future<ApiResponse<EncyclopediaArticlePage>> listArticles(
    Map<String, dynamic> query,
  ) => _remote.listArticles(query);

  @override
  Future<ApiResponse<EncyclopediaArticlePage>> searchArticles(
    Map<String, dynamic> query,
  ) => _remote.searchArticles(query);

  @override
  Future<ApiResponse<EncyclopediaArticle>> getArticle(String slug) =>
      _remote.getArticle(slug);

  @override
  Future<ApiResponse<EncyclopediaCategoryList>> getCategories() =>
      _remote.getCategories();

  @override
  Future<ApiResponse<EncyclopediaTagList>> getTags(Map<String, dynamic> query) =>
      _remote.getTags(query);

  @override
  Future<ApiResponse<ArticleCommentPage>> getComments(
    String id,
    Map<String, dynamic> query,
  ) => _remote.getComments(id, query);

  @override
  Future<ApiResponse<ArticleComment>> postComment(
    String id,
    Map<String, dynamic> body,
  ) => _remote.postComment(id, body);

  @override
  Future<ApiResponse<ArticleComment>> updateComment(
    String id,
    Map<String, dynamic> body,
  ) => _remote.updateComment(id, body);

  @override
  Future<ApiResponse<void>> deleteComment(String id) =>
      _remote.deleteComment(id);

  @override
  Future<ApiResponse<EncyclopediaBookmarkResult>> toggleBookmark(String id) =>
      _remote.toggleBookmark(id);

  @override
  Future<ApiResponse<MyContributionItem>> submitContribution(
    SubmitEncyclopediaContributionPayload body,
  ) => _remote.submitContribution(body);

  @override
  Future<ApiResponse<MyContributionItem>> updateContribution(
    String id,
    Map<String, dynamic> body,
  ) => _remote.updateContribution(id, body);

  @override
  Future<ApiResponse<MyContributionPage>> getMyContributions(
    Map<String, dynamic> query,
  ) => _remote.getMyContributions(query);

  @override
  Future<void> recordView(String slug) async {
    await _dio.post<void>(
      '/api/v1/encyclopedia/articles/${Uri.encodeComponent(slug)}/view',
      options: Options(sendTimeout: const Duration(seconds: 5)),
    );
  }
}
