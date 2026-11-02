import 'package:fpdart/fpdart.dart';

import '../failures/linked_accounts_failure.dart';

class LinkedAccountsStatus {
  const LinkedAccountsStatus({
    required this.googleLinked,
    required this.githubLinked,
    required this.googleLinkedAt,
    required this.githubLinkedAt,
    required this.hasPassword,
  });

  final bool googleLinked;
  final bool githubLinked;

  /// ISO timestamp saat provider ditautkan (null bila belum terhubung).
  final String? googleLinkedAt;
  final String? githubLinkedAt;
  final bool hasPassword;
}

abstract interface class LinkedAccountsRepository {
  Future<Either<LinkedAccountsFailure, LinkedAccountsStatus>> getLinkStatus();
  Future<Either<LinkedAccountsFailure, void>> linkGoogle(String idToken);
  Future<Either<LinkedAccountsFailure, String>> unlinkGoogle();
  Future<Either<LinkedAccountsFailure, void>> linkGithub({
    required String code,
    required String redirectUri,
    String? codeVerifier,
  });
  Future<Either<LinkedAccountsFailure, String>> unlinkGithub();
}
