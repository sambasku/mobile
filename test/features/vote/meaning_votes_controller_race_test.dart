import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/features/vote/data/providers/vote_data_providers.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_deck_item.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_target.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_view.dart';
import 'package:sambasku_mobile/features/vote/domain/failures/vote_failure.dart';
import 'package:sambasku_mobile/features/vote/domain/providers/vote_domain_providers.dart';
import 'package:sambasku_mobile/features/vote/domain/repositories/vote_repository.dart';
import 'package:sambasku_mobile/features/vote/domain/usecases/get_my_votes_use_case.dart';
import 'package:sambasku_mobile/features/vote/domain/usecases/get_vote_counts_use_case.dart';
import 'package:sambasku_mobile/features/vote/presentation/providers/meaning_vote_providers.dart';

class _FakeAuthStatus extends AuthStatusNotifier {
  @override
  Future<AuthStatusState> build() async =>
      const AuthStatusState(isAuth: true, username: 'tester');
}

/// Repo yang menahan respons counts sampai dilepas manual - mensimulasikan
/// request kata A yang selesai SETELAH request kata B.
class _SlowRepo implements VoteRepository {
  final Map<String, VoteCounts> countsByTarget = {};
  final List<Completer<void>> gates = [];

  Completer<void> nextGate() {
    final gate = Completer<void>();
    gates.add(gate);
    return gate;
  }

  @override
  Future<Either<VoteFailure, Map<String, VoteCounts>>> countMany(
    List<VoteTarget> targets,
  ) async {
    final gate = gates.isEmpty ? null : gates.removeAt(0);
    if (gate != null) await gate.future;
    return Either.right({
      for (final t in targets)
        if (countsByTarget.containsKey(t.key)) t.key: countsByTarget[t.key]!,
    });
  }

  @override
  Future<Either<VoteFailure, Map<String, int>>> myVotes(
    List<VoteTarget> targets,
  ) async =>
      Either.right(const {});

  @override
  Future<Either<VoteFailure, VoteView>> toggle(VoteTarget target, int value) async =>
      Either.right(VoteView(target: target, myVote: value));

  @override
  Future<Either<VoteFailure, VoteDeckPage>> getDeck({
    int limit = 10,
    String? cursor,
  }) async =>
      Either.right(const VoteDeckPage(items: [], hasMore: false));

  @override
  Future<Either<VoteFailure, Unit>> skipMeaning(String meaningId) async =>
      Either.right(unit);

  @override
  Future<Either<VoteFailure, Unit>> unskipMeaning(String meaningId) async =>
      Either.right(unit);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _SlowRepo repo;
  late ProviderContainer container;

  setUp(() {
    repo = _SlowRepo();
    container = ProviderContainer(
      overrides: [
        authStatusProvider.overrideWith(_FakeAuthStatus.new),
        voteRepositoryProvider.overrideWithValue(repo),
        getVoteCountsUseCaseProvider.overrideWithValue(
          GetVoteCountsUseCase(repo),
        ),
        getMyVotesUseCaseProvider.overrideWithValue(
          GetMyVotesUseCase(repo),
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('load kata lama yang selesai belakangan tidak menimpa kata baru',
      () async {
    repo.countsByTarget['meaning:m1'] = const VoteCounts(upvotes: 9);
    repo.countsByTarget['meaning:m2'] = const VoteCounts(upvotes: 1);

    final gateA = repo.nextGate();
    final gateB = repo.nextGate();

    final controller = container.read(meaningVotesControllerProvider.notifier);
    final loadA = controller.load(['m1']);
    final loadB = controller.load(['m2']);

    // B selesai dulu, lalu A (urutan terbalik dari pemanggilan).
    gateB.complete();
    await loadB;
    expect(controller.state.upvotesOf('m2'), 1);

    gateA.complete();
    await loadA;

    // State tetap milik kata B - hasil A dibuang.
    expect(controller.state.upvotesOf('m2'), 1);
    expect(controller.state.upvotesOf('m1'), 0);
  });

  test('load terakhir tetap menang saat dipanggil berurutan', () async {
    repo.countsByTarget['meaning:m1'] = const VoteCounts(upvotes: 5);
    repo.countsByTarget['meaning:m2'] = const VoteCounts(upvotes: 3);

    final controller = container.read(meaningVotesControllerProvider.notifier);
    await controller.load(['m1']);
    await controller.load(['m2']);

    expect(controller.state.upvotesOf('m2'), 3);
    expect(controller.state.upvotesOf('m1'), 0);
  });
}
