import 'package:fpdart/fpdart.dart';

import '../entities/public_profile.dart';
import '../failures/user_profile_failure.dart';
import '../repositories/user_profile_repository.dart';

class GetPublicActivityUseCase {
  const GetPublicActivityUseCase(this._repository);

  final UserProfileRepository _repository;

  Future<Either<UserProfileFailure, ({List<PublicActivityItem> items, String? nextCursor})>> call(
    String username, {
    String? kind,
    int? limit,
    String? cursor,
  }) =>
      _repository.getActivity(
        username,
        kind: kind,
        limit: limit,
        cursor: cursor,
      );
}
