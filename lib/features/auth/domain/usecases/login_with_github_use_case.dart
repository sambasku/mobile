import 'dart:developer' as developer;

import 'package:fpdart/fpdart.dart';

import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';
import '../ports/github_sign_in_port.dart';
import '../repositories/auth_repository.dart';

class LoginWithGithubUseCase {
  const LoginWithGithubUseCase(this._repository, this._signIn);

  final AuthRepository _repository;
  final GithubSignInPort _signIn;

  Future<Either<AuthFailure, AuthSession>> call() async {
    try {
      final auth = await _signIn.authenticate();
      if (auth == null) {
        return Either.left(
          const AuthFailure(
            'Masuk dibatalkan.',
            errorCode: AuthFailure.githubSignInCanceled,
          ),
        );
      }
      if (auth.code.trim().isEmpty) {
        return Either.left(
          const AuthFailure(
            'Tidak bisa masuk dengan GitHub.',
            errorCode: 'INVALID_GITHUB_TOKEN',
          ),
        );
      }
      return _repository.loginWithGithub(
        code: auth.code,
        redirectUri: auth.redirectUri,
        codeVerifier: auth.codeVerifier,
      );
    } catch (error, stack) {
      developer.log(
        'loginWithGithub gagal',
        name: 'auth.github',
        error: error,
        stackTrace: stack,
      );
      final message = error is StateError
          ? error.message
          : 'Tidak bisa masuk dengan GitHub. Coba lagi.';
      final safe = message.length > 120
          ? 'Tidak bisa masuk dengan GitHub. Coba lagi.'
          : message;
      return Either.left(AuthFailure(safe));
    }
  }
}
