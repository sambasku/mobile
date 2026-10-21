import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/api_response.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/failures/achievement_failure.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../datasources/achievement_remote_datasource.dart';
import '../models/achievement_dto.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  AchievementRepositoryImpl(this._remote);

  final AchievementRemoteDatasource _remote;

  @override
  Future<Either<AchievementFailure, List<Achievement>>> listCatalog({
    String? rewardType,
    String? category,
  }) =>
      _guard(
        () => _remote.listCatalog(
          rewardType: rewardType,
          category: category,
          limit: 50,
        ),
      );

  @override
  Future<Either<AchievementFailure, List<Achievement>>> listByUsername(
    String username,
  ) => _guard(() => _remote.listByUsername(username));

  @override
  Future<Either<AchievementFailure, List<Achievement>>> listMine({
    String? rewardType,
    String? category,
  }) =>
      _guard(
        () => _remote.listMine(
          rewardType: rewardType,
          category: category,
          limit: 50,
        ),
      );

  @override
  Future<Either<AchievementFailure, String?>> setBorder(String? awardId) async {
    try {
      final response = await _remote.setBorder(
        SetBorderRequestDto(borderId: awardId),
      );
      if (response.success == false || response.data == null) {
        return Either.left(
          AchievementFailure(
            response.message ?? 'Gagal menyimpan bingkai profil',
            errorCode: response.errorCode,
          ),
        );
      }
      return Either.right(response.data!.activeBorderId);
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(AchievementFailure(error.toString()));
    }
  }

  Future<Either<AchievementFailure, List<Achievement>>> _guard(
    Future<ApiResponse<AchievementListDto>> Function() call,
  ) async {
    try {
      final response = await call();
      if (response.success == false || response.data == null) {
        return Either.left(
          AchievementFailure(
            response.message ?? 'Gagal memuat pencapaian',
            errorCode: response.errorCode,
          ),
        );
      }
      return Either.right(
        response.data!.items.map(_mapAchievement).toList(growable: false),
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(AchievementFailure(error.toString()));
    }
  }

  Achievement _mapAchievement(AchievementDto dto) => Achievement(
        id: dto.id,
        code: dto.code,
        title: dto.title,
        description: dto.description,
        category: dto.category,
        rewardType: dto.rewardType,
        badgeUrl: dto.badgeUrl,
        family: dto.family,
        level: dto.level,
        isActive: dto.isActive,
        userAchievementId: dto.userAchievementId,
        awardedAt: dto.awardedAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(dto.awardedAt! * 1000),
        isActiveBorder: dto.isActiveBorder,
      );

  AchievementFailure _mapDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      final code = data['error_code'];
      if (message is String && message.isNotEmpty) {
        return AchievementFailure(message, errorCode: code is String ? code : null);
      }
    }
    return AchievementFailure(switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Koneksi lambat, coba lagi',
      DioExceptionType.connectionError => 'Tidak ada koneksi internet',
      _ => 'Terjadi kesalahan, coba lagi',
    });
  }
}
