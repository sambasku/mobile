import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/public_profile.dart';
import '../../domain/failures/user_profile_failure.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_remote_datasource.dart';
import '../models/public_profile_dto.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl(this._remoteDatasource);

  final UserProfileRemoteDatasource _remoteDatasource;

  @override
  Future<Either<UserProfileFailure, PublicProfile>> getByUsername(
    String username,
  ) async {
    try {
      final response = await _remoteDatasource.getByUsername(username);
      if (response.success == false || response.data == null) {
        return Either.left(
          UserProfileFailure(
            response.message ?? 'Gagal memuat profil',
            errorCode: response.errorCode,
          ),
        );
      }
      return Either.right(_mapProfile(response.data!));
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(UserProfileFailure(error.toString()));
    }
  }

  @override
  Future<Either<UserProfileFailure, ({List<PublicActivityItem> items, String? nextCursor})>> getActivity(
    String username, {
    String? kind,
    int? limit,
    String? cursor,
  }) async {
    try {
      final response = await _remoteDatasource.getActivity(
        username,
        kind: kind,
        limit: limit,
        cursor: cursor,
      );
      if (response.success == false || response.data == null) {
        return Either.left(
          UserProfileFailure(
            response.message ?? 'Gagal memuat aktivitas',
            errorCode: response.errorCode,
          ),
        );
      }
      final meta = response.data!.meta;
      return Either.right((
        items: response.data!.items.map(_mapActivity).toList(growable: false),
        nextCursor: meta?.nextCursor,
      ));
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(UserProfileFailure(error.toString()));
    }
  }

  PublicProfile _mapProfile(PublicProfileDto dto) => PublicProfile(
        username: dto.username,
        displayName: (dto.displayName == null || dto.displayName!.trim().isEmpty)
            ? dto.username
            : dto.displayName!,
        bio: dto.bio,
        role: dto.role,
        isVerifier: dto.isVerifier,
        joinedAt: dto.joinedAt,
        contributionsApproved: dto.stats.contributionsApproved,
        verificationsDone: dto.stats.verificationsDone,
        commentsPublished: dto.stats.commentsPublished,
        avatarUrl: dto.avatarUrl,
      );

  PublicActivityItem _mapActivity(PublicActivityItemDto dto) => PublicActivityItem(
        id: dto.id,
        kind: dto.kind,
        occurredAt: dto.occurredAt,
        summary: dto.summary,
        wordId: dto.wordId,
        lemma: dto.lemma,
      );

  @override
  Future<Either<UserProfileFailure, List<MentionSuggestion>>> suggestMentions(
    String query,
  ) async {
    try {
      final response = await _remoteDatasource.suggestMentions(query);
      if (response.success == false || response.data == null) {
        return Either.left(
          UserProfileFailure(
            response.message ?? 'Gagal memuat saran mention',
            errorCode: response.errorCode,
          ),
        );
      }
      return Either.right(
        response.data!.items
            .map(
              (dto) => MentionSuggestion(
                id: dto.id,
                username: dto.username,
                displayName: dto.displayName,
                avatarUrl: dto.avatarUrl,
              ),
            )
            .toList(growable: false),
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(UserProfileFailure(error.toString()));
    }
  }

  UserProfileFailure _mapDio(DioException error) {
    final response = error.response?.data;
    if (response != null && response['error_code'] == 'USER_NOT_FOUND') {
      return UserProfileFailure('Pengguna tidak ditemukan', errorCode: 'USER_NOT_FOUND');
    }
    final message = response?['message'];
    if (message != null && message.isNotEmpty) {
      return UserProfileFailure(message, errorCode: response?['error_code']);
    }
    return UserProfileFailure(
      _fallbackForStatus(error.response?.statusCode, error),
      errorCode: response?['error_code'],
    );
  }

  String _fallbackForStatus(int? statusCode, DioException error) {
    if (statusCode == 429 || error.response?.data?['error_code'] == 'RATE_LIMITED') {
      return 'Terlalu banyak permintaan. Coba lagi nanti.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server sedang gangguan. Coba lagi nanti.';
    }
    return 'Terjadi kesalahan saat memuat profil, coba lagi';
  }
}