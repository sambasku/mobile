import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/my_profile.dart';
import '../../domain/failures/edit_profile_failure.dart';
import '../../domain/repositories/edit_profile_repository.dart';
import '../datasources/edit_profile_remote_datasource.dart';
import '../models/my_profile_dto.dart';

class EditProfileRepositoryImpl implements EditProfileRepository {
  EditProfileRepositoryImpl(this._remote);

  final EditProfileRemoteDatasource _remote;

  @override
  Future<Either<EditProfileFailure, MyProfile>> getMyProfile() async {
    try {
      final response = await _remote.getMyProfile();
      if (response.success == false || response.data == null) {
        return Either.left(
          EditProfileFailure(
            response.message ?? 'Gagal memuat profil',
            errorCode: response.errorCode,
          ),
        );
      }
      return Either.right(_map(response.data!));
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(EditProfileFailure(error.toString()));
    }
  }

  @override
  Future<Either<EditProfileFailure, MyProfile>> updateMyProfile({
    String? displayName,
    String? bio,
    bool? hasReadContributionGuide,
  }) async {
    try {
      final response = await _remote.updateMyProfile(
        UpdateMyProfileRequestDto(
          displayName: displayName,
          bio: bio,
          hasReadContributionGuide: hasReadContributionGuide,
        ),
      );
      if (response.success == false || response.data == null) {
        return Either.left(
          EditProfileFailure(
            response.message ?? 'Gagal menyimpan profil',
            errorCode: response.errorCode,
          ),
        );
      }
      return Either.right(_map(response.data!));
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(EditProfileFailure(error.toString()));
    }
  }

  MyProfile _map(MyProfileDto dto) => MyProfile(
        username: dto.username,
        displayName: dto.displayName,
        bio: dto.bio,
        avatarUrl: dto.avatarUrl,
        hasReadContributionGuide: dto.hasReadContributionGuide,
      );

  EditProfileFailure _mapDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      final code = data['error_code'];
      if (message is String && message.isNotEmpty) {
        return EditProfileFailure(
          message,
          errorCode: code is String ? code : null,
        );
      }
    }
    return EditProfileFailure(switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Koneksi lambat, coba lagi',
      DioExceptionType.connectionError => 'Tidak ada koneksi internet',
      _ => 'Terjadi kesalahan, coba lagi',
    });
  }
}
