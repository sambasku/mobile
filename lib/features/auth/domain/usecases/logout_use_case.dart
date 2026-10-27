import 'package:fpdart/fpdart.dart';

import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<AuthFailure, void>> call() => _repository.logout();
}
