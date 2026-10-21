import 'package:fpdart/fpdart.dart';

import '../failures/set_password_failure.dart';
import '../repositories/set_password_repository.dart';

class SetPasswordUseCase {
  const SetPasswordUseCase(this._repository);

  final SetPasswordRepository _repository;

  Future<Either<SetPasswordFailure, SetPasswordSuccess>> call(
    SetPasswordParams params,
  ) {
    return _repository.setPassword(
      provider: params.provider,
      newPassword: params.newPassword,
      confirmPassword: params.confirmPassword,
      idToken: params.idToken,
      accessToken: params.accessToken,
      code: params.code,
      redirectUri: params.redirectUri,
      codeVerifier: params.codeVerifier,
    );
  }
}

class SetPasswordParams {
  const SetPasswordParams({
    required this.provider,
    required this.newPassword,
    required this.confirmPassword,
    this.idToken,
    this.accessToken,
    this.code,
    this.redirectUri,
    this.codeVerifier,
  });

  final String provider;
  final String newPassword;
  final String confirmPassword;
  final String? idToken;
  final String? accessToken;
  final String? code;
  final String? redirectUri;
  final String? codeVerifier;
}
