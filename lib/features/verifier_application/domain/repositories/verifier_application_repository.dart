import 'package:fpdart/fpdart.dart';

import '../entities/verifier_application.dart';
import '../failures/verifier_application_failure.dart';

abstract interface class VerifierApplicationRepository {
  Future<Either<VerifierApplicationFailure, VerifierApplication?>> getMine();

  Future<Either<VerifierApplicationFailure, VerifierApplication>> submit({
    required String phone,
    required String address,
    required String fullName,
    required List<SocialLink> socialLinks,
    required String dialect,
    required String? dialectNote,
    required String reason,
    required SocialScreenshot? photo,
  });

  Future<Either<VerifierApplicationFailure, VerifierApplication>> resubmit({
    required String phone,
    required String address,
    required String fullName,
    required List<SocialLink> socialLinks,
    required String dialect,
    required String? dialectNote,
    required String reason,
    required SocialScreenshot? photo,
  });
}
