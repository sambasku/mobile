import 'package:fpdart/fpdart.dart';

import '../entities/verifier_application.dart';
import '../failures/verifier_application_failure.dart';
import '../repositories/verifier_application_repository.dart';

class SubmitVerifierApplicationParams {
  const SubmitVerifierApplicationParams({
    required this.phone,
    required this.address,
    required this.fullName,
    required this.socialLinks,
    required this.dialect,
    required this.dialectNote,
    required this.reason,
    required this.photo,
    required this.isResubmit,
  });

  final String phone;
  final String address;
  final String fullName;
  final List<SocialLink> socialLinks;
  final String dialect;
  final String? dialectNote;
  final String reason;
  final SocialScreenshot? photo;
  final bool isResubmit;
}

class SubmitVerifierApplicationUseCase {
  const SubmitVerifierApplicationUseCase(this._repository);

  final VerifierApplicationRepository _repository;

  Future<Either<VerifierApplicationFailure, VerifierApplication>> call(
    SubmitVerifierApplicationParams params,
  ) {
    if (params.isResubmit) {
      return _repository.resubmit(
        phone: params.phone,
        address: params.address,
        fullName: params.fullName,
        socialLinks: params.socialLinks,
        dialect: params.dialect,
        dialectNote: params.dialectNote,
        reason: params.reason,
        photo: params.photo,
      );
    }
    return _repository.submit(
      phone: params.phone,
      address: params.address,
      fullName: params.fullName,
      socialLinks: params.socialLinks,
      dialect: params.dialect,
      dialectNote: params.dialectNote,
      reason: params.reason,
      photo: params.photo,
    );
  }
}
