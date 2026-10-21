import 'package:fpdart/fpdart.dart';

import '../failures/set_password_failure.dart';

abstract interface class SetPasswordRepository {
  Future<Either<SetPasswordFailure, SetPasswordSuccess>> setPassword({
    required String provider,
    required String newPassword,
    required String confirmPassword,
    String? idToken,
    String? accessToken,
    String? code,
    String? redirectUri,
    String? codeVerifier,
  });
}
