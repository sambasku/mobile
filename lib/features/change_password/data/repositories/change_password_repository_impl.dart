import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/failures/change_password_failure.dart';
import '../../domain/repositories/change_password_repository.dart';
import '../datasources/change_password_remote_datasource.dart';
import '../models/change_password_request_dto.dart';

class ChangePasswordRepositoryImpl implements ChangePasswordRepository {
  ChangePasswordRepositoryImpl(this._remoteDatasource);

  final ChangePasswordRemoteDatasource _remoteDatasource;

  @override
  Future<Either<ChangePasswordFailure, String>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _remoteDatasource.changePassword(
        ChangePasswordRequestDto(
          oldPassword: oldPassword,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        ),
      );
      return Either.right(
        response.data?.message ??
            'Password berhasil diubah. Silakan login kembali.',
      );
    } on DioException catch (error) {
      return Either.left(
        ChangePasswordFailure(
          _mapDioError(error),
          errorCode: _mapErrorCode(error),
        ),
      );
    } catch (error) {
      return Either.left(ChangePasswordFailure(error.toString()));
    }
  }

  /// Baca envelope error dari body 4xx (error_code + message sudah
  /// ramah user dari backend - jangan ditimpa)
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

  String? _mapErrorCode(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final code = data['error_code'];
      if (code is String && code.isNotEmpty) return code;
    }
    return null;
  }
}
