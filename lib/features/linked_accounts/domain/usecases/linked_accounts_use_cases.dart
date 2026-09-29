import 'package:fpdart/fpdart.dart';

import '../failures/linked_accounts_failure.dart';
import '../repositories/linked_accounts_repository.dart';

class GetLinkedAccountsStatusUseCase {
  GetLinkedAccountsStatusUseCase(this._repository);

  final LinkedAccountsRepository _repository;

  Future<Either<LinkedAccountsFailure, LinkedAccountsStatus>> call() =>
      _repository.getLinkStatus();
}

class LinkGoogleAccountUseCase {
  LinkGoogleAccountUseCase(this._repository);

  final LinkedAccountsRepository _repository;

  Future<Either<LinkedAccountsFailure, void>> call(String idToken) =>
      _repository.linkGoogle(idToken);
}

class UnlinkGoogleAccountUseCase {
  UnlinkGoogleAccountUseCase(this._repository);

  final LinkedAccountsRepository _repository;

  Future<Either<LinkedAccountsFailure, String>> call() =>
      _repository.unlinkGoogle();
}

class LinkGithubAccountUseCase {
  LinkGithubAccountUseCase(this._repository);

  final LinkedAccountsRepository _repository;

  Future<Either<LinkedAccountsFailure, void>> call({
    required String code,
    required String redirectUri,
    String? codeVerifier,
  }) => _repository.linkGithub(
    code: code,
    redirectUri: redirectUri,
    codeVerifier: codeVerifier,
  );
}

class UnlinkGithubAccountUseCase {
  UnlinkGithubAccountUseCase(this._repository);

  final LinkedAccountsRepository _repository;

  Future<Either<LinkedAccountsFailure, String>> call() =>
      _repository.unlinkGithub();
}
