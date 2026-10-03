import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/user_profile_data_providers.dart';
import '../usecases/get_public_activity_use_case.dart';
import '../usecases/get_public_profile_use_case.dart';
import '../usecases/suggest_mentions_use_case.dart';

part 'user_profile_domain_providers.g.dart';

@riverpod
GetPublicProfileUseCase getPublicProfileUseCase(Ref ref) =>
    GetPublicProfileUseCase(ref.watch(userProfileRepositoryProvider));

@riverpod
GetPublicActivityUseCase getPublicActivityUseCase(Ref ref) =>
    GetPublicActivityUseCase(ref.watch(userProfileRepositoryProvider));

@riverpod
SuggestMentionsUseCase suggestMentionsUseCase(Ref ref) =>
    SuggestMentionsUseCase(ref.watch(userProfileRepositoryProvider));
