import 'package:fpdart/fpdart.dart';

import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';

abstract interface class AuthRepository {
  Future<Either<AuthFailure, void>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String confirmPassword,
    required List<({String documentType, String documentVersion})> consents,
  });

  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, AuthSession>> loginWithGoogle({
    required String idToken,
  });

  Future<Either<AuthFailure, AuthSession>> loginWithFacebook({
    required String accessToken,
  });

  Future<Either<AuthFailure, AuthSession>> loginWithGithub({
    required String code,
    required String redirectUri,
    String? codeVerifier,
  });

  Future<Either<AuthFailure, AuthSession>> verifyEmail({
    required String email,
    required String code,
  });

  Future<Either<AuthFailure, void>> resendOtp({required String email});

  /// POST /api/v1/auth/forgot-password. Response selalu sama
  /// (anti-enumeration). Return pesan sukses dari backend.
  Future<Either<AuthFailure, String>> forgotPassword({required String email});

  /// POST /api/v1/auth/reset-password. Kode 6 karakter 0-9A-Z atau token tautan,
  /// sekali pakai.
  Future<Either<AuthFailure, String>> resetPassword({
    String? token,
    String? email,
    String? code,
    required String newPassword,
  });

  /// Revoke refresh token di backend (POST /api/v1/auth/logout),
  /// lalu clear sesi lokal. Best-effort: gagal jaringan tetap clear.
  Future<Either<AuthFailure, void>> logout();
}
