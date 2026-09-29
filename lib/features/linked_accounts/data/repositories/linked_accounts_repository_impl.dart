import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/failures/linked_accounts_failure.dart';
import '../../domain/repositories/linked_accounts_repository.dart';
import '../datasources/linked_accounts_remote_datasource.dart';
import '../models/auth_providers_dto.dart';
import '../models/github_link_request_dto.dart';

class LinkedAccountsRepositoryImpl implements LinkedAccountsRepository {
  LinkedAccountsRepositoryImpl(this._remote);

  final LinkedAccountsRemoteDatasource _remote;

  @override
  Future<Either<LinkedAccountsFailure, LinkedAccountsStatus>>
  getLinkStatus() async {
    try {
      final response = await _remote.listProviders();
      if (response.success == false || response.data == null) {
        return Either.left(
          LinkedAccountsFailure(
            response.message ?? 'Gagal memuat status akun',
            errorCode: response.errorCode,
          ),
        );
      }
      final providers = response.data!.providers;
      return Either.right(
        LinkedAccountsStatus(
          googleLinked: providers.any((p) => p.provider == 'google'),
          githubLinked: providers.any((p) => p.provider == 'github'),
        ),
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(LinkedAccountsFailure(error.toString()));
    }
  }

  @override
  Future<Either<LinkedAccountsFailure, void>> linkGoogle(String idToken) async {
    try {
      final response = await _remote.linkGoogle(
        GoogleLinkRequestDto(idToken: idToken),
      );
      if (response.success == false) {
        return Either.left(
          LinkedAccountsFailure(
            response.message ?? 'Gagal menambahkan ke akun terhubung',
            errorCode: response.errorCode,
          ),
        );
      }
      return Either.right(null);
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(LinkedAccountsFailure(error.toString()));
    }
  }

  @override
  Future<Either<LinkedAccountsFailure, String>> unlinkGoogle() async {
    try {
      final response = await _remote.unlinkGoogle();
      if (response.success == false) {
        return Either.left(
          LinkedAccountsFailure(
            response.message ?? 'Gagal melepas dari akun terhubung',
            errorCode: response.errorCode,
          ),
        );
      }
      return Either.right(
        response.data?.message ?? 'Berhasil dilepas dari akun terhubung.',
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(LinkedAccountsFailure(error.toString()));
    }
  }

  @override
  Future<Either<LinkedAccountsFailure, void>> linkGithub({
    required String code,
    required String redirectUri,
    String? codeVerifier,
  }) async {
    try {
      final response = await _remote.linkGithub(
        GithubLinkRequestDto(
          code: code,
          redirectUri: redirectUri,
          codeVerifier: codeVerifier,
        ),
      );
      if (response.success == false) {
        return Either.left(
          LinkedAccountsFailure(
            response.message ?? 'Gagal menambahkan ke akun terhubung',
            errorCode: response.errorCode,
          ),
        );
      }
      return Either.right(null);
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(LinkedAccountsFailure(error.toString()));
    }
  }

  @override
  Future<Either<LinkedAccountsFailure, String>> unlinkGithub() async {
    try {
      final response = await _remote.unlinkGithub();
      if (response.success == false) {
        return Either.left(
          LinkedAccountsFailure(
            response.message ?? 'Gagal melepas dari akun terhubung',
            errorCode: response.errorCode,
          ),
        );
      }
      return Either.right(
        response.data?.message ?? 'Berhasil dilepas dari akun terhubung.',
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(LinkedAccountsFailure(error.toString()));
    }
  }

  LinkedAccountsFailure _mapDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      final code = data['error_code'];
      if (message is String && message.isNotEmpty) {
        return LinkedAccountsFailure(
          message,
          errorCode: code is String ? code : null,
        );
      }
    }
    return LinkedAccountsFailure(switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Koneksi lambat, coba lagi',
      DioExceptionType.connectionError => 'Tidak ada koneksi internet',
      _ => 'Terjadi kesalahan, coba lagi',
    });
  }
}
