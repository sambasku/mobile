import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../my_votes/presentation/providers/my_votes_providers.dart';
import '../../domain/entities/vote_target.dart';
import '../../domain/entities/vote_view.dart';
import '../../domain/failures/vote_failure.dart';
import '../../domain/providers/vote_domain_providers.dart';

part 'meaning_vote_providers.g.dart';

/// State vote makna untuk satu kata yang sedang dibuka.
///
/// BATCH: semua makna satu kata diambil dalam 2 request (counts + my-votes),
/// bukan 2×N. Batas 50 target per request (validator backend) - kata dengan
/// lebih dari 50 makna hanya 50 pertama yang di-vote.
class MeaningVotesState {
  const MeaningVotesState({
    this.counts = const {},
    this.myVotes = const {},
  });

  /// Key `meaning:<id>` -> jumlah upvote/downvote.
  final Map<String, VoteCounts> counts;

  /// Key `meaning:<id>` -> 1 | -1 (hanya target yang dipilih user).
  final Map<String, int> myVotes;

  int upvotesOf(String meaningId) => counts['meaning:$meaningId']?.upvotes ?? 0;

  int downvotesOf(String meaningId) => counts['meaning:$meaningId']?.downvotes ?? 0;

  int? myVoteOf(String meaningId) => myVotes['meaning:$meaningId'];

  /// Skor bersih (upvote - downvote) - dasar urutan "mana yang paling valid".
  int scoreOf(String meaningId) =>
      upvotesOf(meaningId) - downvotesOf(meaningId);

  /// Id makna dengan skor tertinggi (net). Null = belum ada vote sama sekali.
  ///
  /// Satu makna dengan net 0 TIDAK jadi "paling didukung" - butuh minimal
  /// 1 upvote lebih banyak dari downvote, supaya badge tidak muncul untuk
  /// kata yang belum ada penilaian.
  String? topMeaningId(Iterable<String> meaningIds) {
    String? best;
    var bestScore = 0;
    for (final id in meaningIds) {
      final score = scoreOf(id);
      if (score > bestScore) {
        bestScore = score;
        best = id;
      }
    }
    return best;
  }
}

/// Vote makna untuk kata yang sedang dibuka (satu slot, bukan per kata).
///
/// Id makna dikirim dari halaman detail (sudah ada di memory) - controller
/// tidak perlu fetch detail kata sendiri, jadi 1 kata = 2 request saja.
@Riverpod(keepAlive: true)
class MeaningVotesController extends _$MeaningVotesController {
  static const _maxTargets = 50;

  @override
  MeaningVotesState build() => const MeaningVotesState();

  /// Muat counts + vote milik user untuk daftar id makna (idempoten).
  Future<void> load(List<String> meaningIds) async {
    final ids = meaningIds.take(_maxTargets).toList(growable: false);
    if (ids.isEmpty) {
      state = const MeaningVotesState();
      return;
    }
    final targets = ids
        .map((id) => VoteTarget(type: 'meaning', id: id))
        .toList(growable: false);

    final counts = await ref.watch(getVoteCountsUseCaseProvider)(targets);
    final countMap = counts.match(
      (failure) => throw failure,
      (map) => map,
    );

    var myVotes = <String, int>{};
    final auth = await ref.watch(authStatusProvider.future);
    if (auth.isAuth) {
      final mine = await ref.watch(getMyVotesUseCaseProvider)(targets);
      myVotes = mine.match(
        (failure) {
          // 401 = flag isAuth stale (secure store ter-wipe) - degrade ke
          // tampilan anonim; counts publik tetap tampil.
          final staleSession =
              failure.errorCode == 'UNAUTHORIZED' ||
              failure.errorCode == 'TOKEN_EXPIRED';
          if (!staleSession) throw failure;
          return <String, int>{};
        },
        (map) => map,
      );
    }

    state = MeaningVotesState(counts: countMap, myVotes: myVotes);
  }

  /// Toggle vote makna. Return `VoteFailure?` (null = sukses).
  Future<VoteFailure?> toggle(String meaningId, int value) async {
    final target = VoteTarget(type: 'meaning', id: meaningId);
    final result =
        await ref.watch(toggleVoteUseCaseProvider)(target: target, value: value);
    return result.match(
      (failure) => failure,
      (view) {
        final current = state;
        final nextMyVotes = Map<String, int>.from(current.myVotes);
        if (view.myVote == null) {
          nextMyVotes.remove(target.key);
        } else {
          nextMyVotes[target.key] = view.myVote!;
        }
        state = MeaningVotesState(
          counts: {
            ...current.counts,
            target.key: VoteCounts(
              upvotes: view.upvotes,
              downvotes: view.downvotes,
            ),
          },
          myVotes: nextMyVotes,
        );
        ref.invalidate(myVotesListControllerProvider);
        AnalyticsService.instance.logVoteCast(
          targetType: 'meaning',
          direction: value,
        );
        return null;
      },
    );
  }
}
