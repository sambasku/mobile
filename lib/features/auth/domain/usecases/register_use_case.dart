import 'package:fpdart/fpdart.dart';

import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<AuthFailure, void>> call(RegisterParams params) {
    return _repository.register(
      name: params.name.trim(),
      email: params.email.trim(),
      phone: params.phoneNationalDigits,
      password: params.password,
      confirmPassword: params.confirmPassword,
      consents: params.consents,
    );
  }
}

class RegisterParams {
  const RegisterParams({
    required this.name,
    required this.email,
    this.phoneNationalDigits,
    required this.password,
    required this.confirmPassword,
    required this.consents,
  });

  final String name;
  final String email;

  /// Digit nasional tanpa prefix negara (mis. 81234567890). Null/kosong = skip.
  final String? phoneNationalDigits;
  final String password;
  final String confirmPassword;
  final List<({String documentType, String documentVersion})> consents;
}
