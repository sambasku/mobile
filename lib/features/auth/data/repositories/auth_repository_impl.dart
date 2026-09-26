import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/cache/cache_entry.dart';
import '../../../../core/cache/response_cache_store.dart';
import '../../../../core/network/auth_token_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/facebook_login_request_dto.dart';
import '../models/google_login_request_dto.dart';
import '../models/login_request_dto.dart';
import '../models/login_response_dto.dart';
import '../models/logout_request_dto.dart';
import '../models/register_request_dto.dart';
import '../models/resend_otp_request_dto.dart';
import '../models/reset_password_dto.dart';
import '../models/verify_email_request_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._remoteDatasource,
    this._tokenStorage, {
    ResponseCacheStore? responseCache,
  }) : _responseCache = responseCache;

  final AuthRemoteDatasource _remoteDatasource;
  final AuthTokenStorage _tokenStorage;
  final ResponseCacheStore? _responseCache;

  @override
  Future<Either<AuthFailure, void>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String confirmPassword,
    required List<({String documentType, String documentVersion})> consents,
  }) async {
    try {
      final response = await _remoteDatasource.register(
        RegisterRequestDto(
          name: name,
          email: email,
          phone: phone,
          password: password,
          confirmPassword: confirmPassword,
          clientId: 'sambasku-mobile',
          consents: consents
              .map(
                (c) => LegalConsentDto(
                  documentType: c.documentType,
                  documentVersion: c.documentVersion,
                ),
              )
              .toList(),
        ),
      );

      if (response.success == true && response.data != null) {
        return Either.right(null);
      }
      return Either.left(
        AuthFailure(
          response.message ?? 'Registrasi gagal',
          errorCode: response.errorCode,
        ),
      );
    } on DioException catch (error) {
      return Either.left(
        AuthFailure(_mapDioError(error), errorCode: _mapErrorCode(error)),
      );
    } catch (error) {
      return Either.left(AuthFailure(error.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDatasource.login(
        LoginRequestDto(email: email, password: password),
      );

      final payload = response.data;
      if (payload == null) {
        return Either.left(
          AuthFailure(
            response.message ?? 'Login gagal',
            errorCode: response.errorCode,
          ),
        );
      }

      return _persistSession(payload);
    } on DioException catch (error) {
      return Either.left(
        AuthFailure(_mapDioError(error), errorCode: _mapErrorCode(error)),
      );
    } catch (error) {
      return Either.left(AuthFailure(error.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithGoogle({
    required String idToken,
  }) async {
    try {
      final response = await _remoteDatasource.loginWithGoogle(
        GoogleLoginRequestDto(idToken: idToken),
      );
      final payload = response.data;
      if (payload == null) {
        return Either.left(
          AuthFailure(
            response.message ?? 'Tidak bisa masuk dengan Google.',
            errorCode: response.errorCode,
          ),
        );
      }
      return _persistSession(payload);
    } on DioException catch (error) {
      return Either.left(
        AuthFailure(_mapDioError(error), errorCode: _mapErrorCode(error)),
      );
    } catch (error) {
      return Either.left(AuthFailure(error.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithFacebook({
    required String accessToken,
  }) async {
    try {
      final response = await _remoteDatasource.loginWithFacebook(
        FacebookLoginRequestDto(accessToken: accessToken),
      );
      final payload = response.data;
      if (payload == null) {
        return Either.left(
          AuthFailure(
            response.message ?? 'Tidak bisa masuk dengan Facebook.',
            errorCode: response.errorCode,
          ),
        );
      }
      return _persistSession(payload);
    } on DioException catch (error) {
      return Either.left(
        AuthFailure(_mapDioError(error), errorCode: _mapErrorCode(error)),
      );
    } catch (error) {
      return Either.left(AuthFailure(error.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, AuthSession>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _remoteDatasource.verifyEmail(
        VerifyEmailRequestDto(email: email, code: code),
      );
      final payload = response.data;
      if (payload == null) {
        return Either.left(
          AuthFailure(
            response.message ?? 'Verifikasi gagal',
            errorCode: response.errorCode,
          ),
        );
      }
      return _persistSession(payload);
    } on DioException catch (error) {
      return Either.left(
        AuthFailure(_mapDioError(error), errorCode: _mapErrorCode(error)),
      );
    } catch (error) {
      return Either.left(AuthFailure(error.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, void>> resendOtp({required String email}) async {
    try {
      await _remoteDatasource.resendOtp(ResendOtpRequestDto(email: email));
      return Either.right(null);
    } on DioException catch (error) {
      return Either.left(
        AuthFailure(_mapDioError(error), errorCode: _mapErrorCode(error)),
      );
    } catch (error) {
      return Either.left(AuthFailure(error.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, String>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _remoteDatasource.forgotPassword(
        ForgotPasswordRequestDto(email: email),
      );
      return Either.right(
        response.data?.message ??
            'Jika email terdaftar, kode reset telah dikirim',
      );
    } on DioException catch (error) {
      return Either.left(
        AuthFailure(_mapDioError(error), errorCode: _mapErrorCode(error)),
      );
    } catch (error) {
      return Either.left(AuthFailure(error.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, String>> resetPassword({
    String? token,
    String? email,
    String? code,
    required String newPassword,
  }) async {
    try {
      final response = await _remoteDatasource.resetPassword(
        ResetPasswordRequestDto(
          token: token,
          email: email,
          code: code,
          newPassword: newPassword,
        ),
      );
      return Either.right(
        response.data?.message ?? 'Password berhasil direset',
      );
    } on DioException catch (error) {
      return Either.left(
        AuthFailure(_mapDioError(error), errorCode: _mapErrorCode(error)),
      );
    } catch (error) {
      return Either.left(AuthFailure(error.toString()));
    }
  }

  Future<Either<AuthFailure, AuthSession>> _persistSession(
    LoginResponseDto payload,
  ) async {
    final refreshToken = payload.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      return Either.left(
        const AuthFailure(
          'Login mobile tanpa refresh_token; cek client_type',
          errorCode: 'INTERNAL_ERROR',
        ),
      );
    }

    await _tokenStorage.saveTokens(
      accessToken: payload.accessToken,
      refreshToken: refreshToken,
    );
    await _tokenStorage.saveSessionUser(
      username: payload.user.username,
      role: payload.user.role,
      userId: payload.user.id,
      avatarUrl: payload.user.avatarUrl,
    );
    await _tokenStorage.setIsAuth(true);

    return Either.right(
      AuthSession(
        userId: payload.user.id,
        username: payload.user.username,
        role: payload.user.role,
        avatarUrl: payload.user.avatarUrl,
      ),
    );
  }

  @override
  Future<Either<AuthFailure, void>> logout() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _remoteDatasource.logout(
          LogoutRequestDto(refreshToken: refreshToken),
        );
      }
    } on DioException catch (_) {
      // revoke refresh bersifat best-effort (00-api-auth.md): offline/gagal
      // tetap lanjut clear sesi lokal - refresh token tak lagi dimiliki client
    } finally {
      await _tokenStorage.clearTokens();
      // Publik (reference/WOTD/feed) boleh tetap; user-scoped dihapus.
      await _responseCache?.wipeScope(CacheScope.user);
    }
    return Either.right(null);
  }

  /// Baca envelope error dari body 4xx (error_code + message sudah
  /// ramah user dari backend - jangan ditimpa)
  String _mapDioError(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        if (error.response?.statusCode == 429) {
          final retry = error.response?.headers.value('retry-after');
          if (retry != null && retry.isNotEmpty) {
            return '$message Coba lagi dalam $retry detik.';
          }
        }
        return message;
      }
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => 'Koneksi lambat, coba lagi',
      DioExceptionType.connectionError => 'Tidak ada koneksi internet',
      _ => 'Terjadi kesalahan, coba lagi',
    };
  }

  String? _mapErrorCode(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final code = data['error_code'];
      if (code is String && code.isNotEmpty) return code;
    }
    return null;
  }
}
