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
  Future<ApiResponse<MyContributionItem>> resubmitContribution(
    String id,
    Map<String, dynamic> body,
  );
  Future<ApiResponse<MyContributionPage>> getMyContributions(
    Map<String, dynamic> query,
  );
}

class EncyclopediaRepositoryImpl implements EncyclopediaRepository {
  EncyclopediaRepositoryImpl(this._remote);
  final EncyclopediaRemoteDatasource _remote;

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
  Future<ApiResponse<MyContributionItem>> resubmitContribution(
    String id,
    Map<String, dynamic> body,
  ) => _remote.resubmitContribution(id, body);

  @override
  Future<ApiResponse<MyContributionPage>> getMyContributions(
    Map<String, dynamic> query,
  ) => _remote.getMyContributions(query);
}
