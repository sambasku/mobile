import 'package:fpdart/fpdart.dart';

import '../entities/my_profile.dart';
import '../failures/edit_profile_failure.dart';

abstract interface class EditProfileRepository {
  Future<Either<EditProfileFailure, MyProfile>> getMyProfile();

  Future<Either<EditProfileFailure, MyProfile>> updateMyProfile({
    String? displayName,
    String? bio,
    bool? hasReadContributionGuide,
  });
}
