import 'package:fpdart/fpdart.dart';

import '../entities/my_profile.dart';
import '../entities/username_availability.dart';
import '../entities/username_history_item.dart';
import '../failures/edit_profile_failure.dart';

abstract interface class EditProfileRepository {
  Future<Either<EditProfileFailure, MyProfile>> getMyProfile();

  Future<Either<EditProfileFailure, UsernameAvailability>>
      checkUsernameAvailability(String username);

  Future<Either<EditProfileFailure, List<UsernameHistoryItem>>>
      getUsernameHistory();

  Future<Either<EditProfileFailure, MyProfile>> updateMyProfile({
    String? username,
    String? displayName,
    String? bio,
    String? regionId,
    String? villageId,
    bool? hasReadContributionGuide,
    bool? notifyStreakReminder,
    bool? notifyLevelUp,
  });
}
