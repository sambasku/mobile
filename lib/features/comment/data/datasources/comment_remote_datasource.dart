import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/comment_dto.dart';
import '../models/create_comment_request_dto.dart';
import '../models/update_comment_request_dto.dart';

part 'comment_remote_datasource.g.dart';

/// Endpoint komentar (09-api-comment.md).
@RestApi()
abstract interface class CommentRemoteDatasource {
  factory CommentRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _CommentRemoteDatasource;

  /// List komentar published pada kata (publik) - GET
  /// /api/v1/words/:wordId/comments?limit=&cursor=.
  @GET('/api/v1/words/{wordId}/comments')
  Future<ApiResponse<List<CommentDto>>> listByWord(
    @Path('wordId') String wordId,
    @Queries() Map<String, dynamic> query,
  );

  /// Tulis komentar (login, pre-moderation) - POST
  /// /api/v1/words/:wordId/comments.
  @POST('/api/v1/words/{wordId}/comments')
  Future<ApiResponse<CommentDto>> create(
    @Path('wordId') String wordId,
    @Body() CreateCommentRequestDto body,
  );

  /// Soft-delete komentar (penulis/verifikator) - DELETE
  /// /api/v1/comments/:id. Response `{ success: true, data: null }`.
  @DELETE('/api/v1/comments/{id}')
  Future<ApiResponse<dynamic>> delete(@Path('id') String id);

  /// Sunting komentar (penulis) - PATCH /api/v1/comments/:id.
  @PATCH('/api/v1/comments/{id}')
  Future<ApiResponse<CommentDto>> update(
    @Path('id') String id,
    @Body() UpdateCommentRequestDto body,
  );

  /// Riwayat sunting - GET /api/v1/comments/:id/edit-history.
  @GET('/api/v1/comments/{id}/edit-history')
  Future<ApiResponse<dynamic>> editHistory(@Path('id') String id);
}