import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/edit_profile_data_providers.dart';
import '../usecases/edit_profile_use_cases.dart';

part 'edit_profile_domain_providers.g.dart';

@riverpod
GetMyProfileUseCase getMyProfileUseCase(Ref ref) =>
    GetMyProfileUseCase(ref.watch(editProfileRepositoryProvider));

@riverpod
CheckUsernameAvailabilityUseCase checkUsernameAvailabilityUseCase(Ref ref) =>
    CheckUsernameAvailabilityUseCase(ref.watch(editProfileRepositoryProvider));

@riverpod
UpdateMyProfileUseCase updateMyProfileUseCase(Ref ref) =>
    UpdateMyProfileUseCase(ref.watch(editProfileRepositoryProvider));
