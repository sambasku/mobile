import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/models/api_response.dart';
import '../models/public_profile_dto.dart';

part 'user_profile_remote_datasource.g.dart';

/// GET /api/v1/users/:username (+ activity). Publik, tanpa auth.
@RestApi()
abstract interface class UserProfileRemoteDatasource {
  factory UserProfileRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _UserProfileRemoteDatasource;

  @GET('/api/v1/users/{username}')
  Future<ApiResponse<PublicProfileDto>> getByUsername(
    @Path('username') String username,
  );

  @GET('/api/v1/users/{username}/activity')
  Future<ApiResponse<PublicActivityDto>> getActivity(
    @Path('username') String username, {
    @Query('kind') String? kind,
    @Query('limit') int? limit,
    @Query('cursor') String? cursor,
  });

  /// GET /api/v1/users/suggest?q= - autocomplete mention @username (publik).
  @GET('/api/v1/users/suggest')
  Future<ApiResponse<MentionSuggestDto>> suggestMentions(
    @Query('q') String query,
  );
}