import 'package:fpdart/fpdart.dart';

import '../entities/public_profile.dart';
import '../failures/user_profile_failure.dart';

abstract interface class UserProfileRepository {
  Future<Either<UserProfileFailure, PublicProfile>> getByUsername(
    String username,
  );

  Future<Either<UserProfileFailure, ({List<PublicActivityItem> items, String? nextCursor})>> getActivity(
    String username, {
    String? kind,
    int? limit,
    String? cursor,
  });

  Future<Either<UserProfileFailure, List<MentionSuggestion>>> suggestMentions(
    String query,
  );
}
