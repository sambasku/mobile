import 'package:fpdart/fpdart.dart';

import '../entities/my_profile.dart';
import '../failures/edit_profile_failure.dart';
import '../repositories/edit_profile_repository.dart';

class GetMyProfileUseCase {
  GetMyProfileUseCase(this._repository);

  final EditProfileRepository _repository;

  Future<Either<EditProfileFailure, MyProfile>> call() =>
      _repository.getMyProfile();
}

class UpdateMyProfileUseCase {
  UpdateMyProfileUseCase(this._repository);

  final EditProfileRepository _repository;

  Future<Either<EditProfileFailure, MyProfile>> call({
    String? username,
    String? displayName,
    String? bio,
    String? regionId,
    String? villageId,
    bool? hasReadContributionGuide,
  }) =>
      _repository.updateMyProfile(
        username: username,
        displayName: displayName,
        bio: bio,
        regionId: regionId,
        villageId: villageId,
        hasReadContributionGuide: hasReadContributionGuide,
      );
}
