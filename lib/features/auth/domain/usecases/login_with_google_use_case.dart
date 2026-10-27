import 'dart:async';

import 'dart:developer' as developer;
import 'package:fpdart/fpdart.dart';
import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';
import '../ports/google_sign_in_port.dart';
import '../repositories/auth_repository.dart';

/// Google Sign-In. Batal sheet → `AuthFailure` dengan
/// [AuthFailure.googleSignInCanceled] (toast, bukan alert form).
class LoginWithGoogleUseCase {
  final AuthRepository _repository;
  final GoogleSignInPort _signIn;

  /// Activity picker bisa hilang saat app di-background (activity result
  /// tak pernah kembali) → future authenticate() menggantung selamanya.
  /// Deadline memaksa jalan batal agar UI tidak terkunci diam.
  final Duration authTimeout;

  const LoginWithGoogleUseCase(
    this._repository,
    this._signIn, {
    this.authTimeout = const Duration(seconds: 90),
  });

  /// [consents] diisi hanya dari halaman Daftar (checkbox legal wajib).
  Future<Either<AuthFailure, AuthSession>> call({
    List<({String documentType, String documentVersion})>? consents,
  }) async {
    try {
      // ponytail: deadline menutup hang activity-result; kalau kasus
      // bertambah (mis. process death), upgrade ke resume-time recovery.
      final idToken = await _signIn.authenticate().timeout(
        authTimeout,
        onTimeout: () => null,
      );
      if (idToken == null) {
        return Either.left(
          const AuthFailure(
            'Masuk dibatalkan.',
            errorCode: AuthFailure.googleSignInCanceled,
          ),
        );
      }
      if (idToken.trim().isEmpty) {
        return Either.left(
          const AuthFailure(
            'Tidak bisa masuk dengan Google.',
            errorCode: 'INVALID_GOOGLE_TOKEN',
          ),
        );
      }
      return await _repository.loginWithGoogle(
        idToken: idToken,
        consents: consents,
      );
    } catch (error, stack) {
      developer.log(
        'loginWithGoogle gagal',
        name: 'auth.google',
        error: error,
        stackTrace: stack,
      );
      final message = error is StateError
          ? error.message
          : 'Tidak bisa masuk dengan Google. Coba lagi.';
      final safe = message.contains('SHA') || message.length > 120
          ? 'Tidak bisa masuk dengan Google. Coba lagi.'
          : message;
      return Either.left(AuthFailure(safe));
    }
  }
}
