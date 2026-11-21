import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/vote_data_providers.dart';
import '../usecases/get_my_votes_use_case.dart';
import '../usecases/get_vote_counts_use_case.dart';
import '../usecases/get_vote_deck_use_case.dart';
import '../usecases/get_vote_check_deck_use_case.dart';
import '../usecases/toggle_vote_use_case.dart';

part 'vote_domain_providers.g.dart';

@riverpod
ToggleVoteUseCase toggleVoteUseCase(Ref ref) =>
    ToggleVoteUseCase(ref.watch(voteRepositoryProvider));

@riverpod
GetVoteCountsUseCase getVoteCountsUseCase(Ref ref) =>
    GetVoteCountsUseCase(ref.watch(voteRepositoryProvider));

@riverpod
GetMyVotesUseCase getMyVotesUseCase(Ref ref) =>
    GetMyVotesUseCase(ref.watch(voteRepositoryProvider));

@riverpod
GetVoteDeckUseCase getVoteDeckUseCase(Ref ref) =>
    GetVoteDeckUseCase(ref.watch(voteRepositoryProvider));

@riverpod
GetVoteCheckDeckUseCase getVoteCheckDeckUseCase(Ref ref) =>
    GetVoteCheckDeckUseCase(ref.watch(voteRepositoryProvider));
