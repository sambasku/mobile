import 'package:fpdart/fpdart.dart';

import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';
import '../ports/facebook_sign_in_port.dart';
import '../repositories/auth_repository.dart';

/// Facebook Sign-In. Batal sheet → [AuthFailure.facebookSignInCanceled].
class LoginWithFacebookUseCase {
  const LoginWithFacebookUseCase(this._repository, this._signIn);

  final AuthRepository _repository;
  final FacebookSignInPort _signIn;

  /// [consents] diisi hanya dari halaman Daftar (checkbox legal wajib).
  Future<Either<AuthFailure, AuthSession>> call({
    List<({String documentType, String documentVersion})>? consents,
  }) async {
    try {
      final accessToken = await _signIn.authenticate();
      if (accessToken == null) {
        return Either.left(
          const AuthFailure(
            'Masuk dibatalkan.',
            errorCode: AuthFailure.facebookSignInCanceled,
          ),
        );
      }
      if (accessToken.trim().isEmpty) {
        return Either.left(
          const AuthFailure(
            'Tidak bisa masuk dengan Facebook.',
            errorCode: 'INVALID_FACEBOOK_TOKEN',
          ),
        );
      }
      return await _repository.loginWithFacebook(
        accessToken: accessToken,
        consents: consents,
      );
    } catch (_) {
      return Either.left(
        const AuthFailure('Tidak bisa masuk dengan Facebook. Coba lagi.'),
      );
    }
  }
}
