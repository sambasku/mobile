import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/achievement_dto.dart';

part 'achievement_remote_datasource.g.dart';

/// Endpoint achievement (43-api-achievements.md).
@RestApi()
abstract interface class AchievementRemoteDatasource {
  factory AchievementRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _AchievementRemoteDatasource;

  /// Katalog aktif (publik, tanpa auth).
  @GET('/api/v1/achievements')
  Future<ApiResponse<AchievementListDto>> listCatalog({
    @Query('reward_type') String? rewardType,
    @Query('category') String? category,
    @Query('limit') int? limit,
    @Query('before') String? before,
  });

  /// Reward milik user publik (badge profil).
  @GET('/api/v1/users/{username}/achievements')
  Future<ApiResponse<AchievementListDto>> listByUsername(
    @Path('username') String username,
  );

  /// Achievement milikku (owned + locked). Auth.
  @GET('/api/v1/me/achievements')
  Future<ApiResponse<AchievementListDto>> listMine({
    @Query('reward_type') String? rewardType,
    @Query('category') String? category,
    @Query('limit') int? limit,
    @Query('before') String? before,
  });

  /// Set / lepas bingkai profil aktif. Auth.
  @PATCH('/api/v1/me/profile/border')
  Future<ApiResponse<SetBorderResponseDto>> setBorder(
    @Body() SetBorderRequestDto body,
  );
}
