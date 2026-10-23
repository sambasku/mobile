import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_view.dart';
import 'package:sambasku_mobile/features/vote/presentation/providers/meaning_vote_providers.dart';

/// State vote makna: baca per id, skor bersih, dan badge "Paling didukung".
void main() {
  MeaningVotesState stateWith(Map<String, VoteCounts> counts) =>
      MeaningVotesState(counts: counts);

  test('upvotes/downvotes per makna dibaca dari key meaning:<id>', () {
    final state = stateWith({
      'meaning:m1': const VoteCounts(upvotes: 5, downvotes: 1),
      'meaning:m2': const VoteCounts(upvotes: 2, downvotes: 0),
    });

    expect(state.upvotesOf('m1'), 5);
    expect(state.downvotesOf('m1'), 1);
    expect(state.upvotesOf('m2'), 2);
  });

  test('makna tanpa vote = 0/0 dan myVote null', () {
    const state = MeaningVotesState();

    expect(state.upvotesOf('m9'), 0);
    expect(state.downvotesOf('m9'), 0);
    expect(state.myVoteOf('m9'), isNull);
    expect(state.scoreOf('m9'), 0);
  });

  test('skor = upvote - downvote (bukan jumlah vote)', () {
    final state = stateWith({
      'meaning:m1': const VoteCounts(upvotes: 5, downvotes: 4),
    });

    expect(state.scoreOf('m1'), 1);
  });

  test('topMeaningId = makna dengan skor tertinggi', () {
    final state = stateWith({
      'meaning:m1': const VoteCounts(upvotes: 1, downvotes: 0),
      'meaning:m2': const VoteCounts(upvotes: 9, downvotes: 2),
      'meaning:m3': const VoteCounts(upvotes: 3, downvotes: 3),
    });

    expect(state.topMeaningId(['m1', 'm2', 'm3']), 'm2');
  });

  test('tanpa vote positif = null (badge tidak muncul)', () {
    final state = stateWith({
      'meaning:m1': const VoteCounts(upvotes: 0, downvotes: 3),
      'meaning:m2': const VoteCounts(upvotes: 2, downvotes: 2),
    });

    expect(state.topMeaningId(['m1', 'm2']), isNull);
  });

  test('daftar makna kosong = null', () {
    const state = MeaningVotesState();

    expect(state.topMeaningId(const []), isNull);
  });
}
