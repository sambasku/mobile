import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_deck_item.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_target.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_view.dart';
import 'package:sambasku_mobile/features/vote/domain/failures/vote_failure.dart';
import 'package:sambasku_mobile/features/vote/domain/repositories/vote_repository.dart';
import 'package:sambasku_mobile/features/vote/domain/usecases/get_vote_counts_use_case.dart';
import 'package:sambasku_mobile/features/vote/domain/usecases/toggle_vote_use_case.dart';

/// GetVoteCountsUseCase: dedupe target + zero-fill target tanpa vote.
/// ToggleVoteUseCase: passthrough target/value ke repository.
class _FakeVoteRepository implements VoteRepository {
  _FakeVoteRepository._();

  /// Kembalikan counts tertentu saja (simulasi backend hanya mengirim
  /// target yang punya vote).
  static _FakeVoteRepository withCounts(Map<String, VoteCounts> counts) =>
      _FakeVoteRepository._()..countsResult = Either.right(counts);

  static _FakeVoteRepository withFailure(VoteFailure failure) =>
      _FakeVoteRepository._()..countsResult = Either.left(failure);

  Either<VoteFailure, Map<String, VoteCounts>> countsResult =
      Either.right({});
  Either<VoteFailure, VoteView> toggleResult =
      Either.right(VoteView(target: VoteTarget(type: 'word', id: 'x')));

  final List<VoteTarget> receivedTargets = [];
  VoteTarget? receivedToggleTarget;
  int? receivedToggleValue;

  @override
  Future<Either<VoteFailure, Map<String, VoteCounts>>> countMany(
    List<VoteTarget> targets,
  ) async {
    receivedTargets.addAll(targets);
    return countsResult;
  }

  @override
  Future<Either<VoteFailure, Map<String, int>>> myVotes(
    List<VoteTarget> targets,
  ) async {
    receivedTargets.addAll(targets);
    return Either.right({});
  }

  @override
  Future<Either<VoteFailure, VoteView>> toggle(
    VoteTarget target,
    int value,
  ) async {
    receivedToggleTarget = target;
    receivedToggleValue = value;
    return toggleResult;
  }

  @override
  Future<Either<VoteFailure, VoteDeckPage>> getDeck({
    int limit = 10,
    String? cursor,
  }) async {
    return Either.right(const VoteDeckPage(items: []));
  }

  @override
  Future<Either<VoteFailure, Unit>> skipWord(String wordId) async =>
      Either.right(unit);

  @override
  Future<Either<VoteFailure, Unit>> unskipWord(String wordId) async =>
      Either.right(unit);
}

void main() {
  const word = VoteTarget(type: 'word', id: 'w1');
  const meaning = VoteTarget(type: 'meaning', id: 'm1');
  const pron = VoteTarget(type: 'pronunciation', id: 'p1');

  test('target tanpa vote dilengkapi 0/0, target ber-vote tetap', () async {
    final repo = _FakeVoteRepository.withCounts({
      word.key: const VoteCounts(upvotes: 4, downvotes: 1),
    });
    final usecase = GetVoteCountsUseCase(repo);

    final result = await usecase([word, meaning, pron]);
    final map = result.getRight().toNullable();

    expect(map, isNotNull);
    expect(map![word.key], const VoteCounts(upvotes: 4, downvotes: 1));
    expect(map[meaning.key], const VoteCounts());
    expect(map[pron.key], const VoteCounts());
  });

  test('target duplikat di-dedupe sebelum dikirim ke repository', () async {
    final repo = _FakeVoteRepository.withCounts({
      word.key: const VoteCounts(upvotes: 4, downvotes: 1),
    });
    final usecase = GetVoteCountsUseCase(repo);

    await usecase([word, const VoteTarget(type: 'word', id: 'w1'), meaning]);

    // duplikat word:w1 hanya terkirim sekali.
    expect(
      repo.receivedTargets
          .where((t) => t.type == 'word')
          .length,
      1,
    );
  });

  test('failure diteruskan apa adanya', () async {
    final failure = const VoteFailure('Target tidak ditemukan',
        errorCode: 'VOTE_TARGET_NOT_FOUND');
    final repo = _FakeVoteRepository.withFailure(failure);
    final usecase = GetVoteCountsUseCase(repo);

    final result = await usecase([word]);
    expect(result.getLeft().toNullable()?.errorCode, 'VOTE_TARGET_NOT_FOUND');
  });

  test('ToggleVoteUseCase meneruskan target dan value', () async {
    final repo = _FakeVoteRepository.withCounts({});
    final usecase = ToggleVoteUseCase(repo);

    await usecase(target: word, value: -1);

    expect(repo.receivedToggleTarget, const VoteTarget(type: 'word', id: 'w1'));
    expect(repo.receivedToggleValue, -1);
  });
}