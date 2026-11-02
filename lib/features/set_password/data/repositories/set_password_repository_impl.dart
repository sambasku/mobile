import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/failures/set_password_failure.dart';
import '../../domain/repositories/set_password_repository.dart';
import '../datasources/set_password_remote_datasource.dart';
import '../models/set_password_request_dto.dart';

class SetPasswordRepositoryImpl implements SetPasswordRepository {
  SetPasswordRepositoryImpl(this._remote);

  final SetPasswordRemoteDatasource _remote;

  @override
  Future<Either<SetPasswordFailure, SetPasswordSuccess>> setPassword({
    required String provider,
    required String newPassword,
    required String confirmPassword,
    String? idToken,
    String? accessToken,
    String? code,
    String? redirectUri,
    String? codeVerifier,
  }) async {
    try {
      final response = await _remote.setPassword(
        SetPasswordRequestDto(
          provider: provider,
          idToken: idToken,
          accessToken: accessToken,
          code: code,
          redirectUri: redirectUri,
          codeVerifier: codeVerifier,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        ),
      );
      final data = response.data;
      if (data == null) {
        return Either.left(const SetPasswordFailure('Gagal membuat password'));
      }
      return Either.right(
        SetPasswordSuccess(message: data.message, loginWith: data.loginWith),
      );
    } on DioException catch (error) {
      return Either.left(SetPasswordFailure(_mapDioError(error)));
    } catch (error) {
      return Either.left(SetPasswordFailure(error.toString()));
    }
  }

  String _mapDioError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Server lama merespons. Coba lagi dalam beberapa saat.',
      DioExceptionType.connectionError =>
        'Gagal terhubung ke server. Coba lagi dalam beberapa saat.',
      _ => 'Terjadi kesalahan, coba lagi',
    };
  }
}
