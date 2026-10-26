import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/failures/delete_account_failure.dart';
import '../../domain/repositories/delete_account_repository.dart';
import '../datasources/delete_account_remote_datasource.dart';
import '../models/delete_account_request_dto.dart';

class DeleteAccountRepositoryImpl implements DeleteAccountRepository {
  DeleteAccountRepositoryImpl(this._remoteDatasource);

  final DeleteAccountRemoteDatasource _remoteDatasource;

  @override
  Future<Either<DeleteAccountFailure, String>> deleteAccount({
    String? password,
    required String confirmation,
  }) async {
    try {
      final trimmed = password?.trim();
      final response = await _remoteDatasource.deleteAccount(
        DeleteAccountRequestDto(
          password: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
          confirmation: confirmation,
        ),
      );
      return Either.right(
        response.data?.message ?? 'Akun dan data pribadi berhasil dihapus.',
      );
    } on DioException catch (error) {
      return Either.left(
        DeleteAccountFailure(
          _mapDioError(error),
          errorCode: _mapErrorCode(error),
        ),
      );
    } catch (error) {
      return Either.left(DeleteAccountFailure(error.toString()));
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

  String? _mapErrorCode(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final code = data['error_code'];
      if (code is String && code.isNotEmpty) return code;
    }
    return null;
  }
}
