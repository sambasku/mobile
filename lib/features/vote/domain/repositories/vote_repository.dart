import 'package:fpdart/fpdart.dart';

import '../entities/vote_deck_item.dart';
import '../entities/vote_target.dart';
import '../entities/vote_view.dart';
import '../failures/vote_failure.dart';

/// Interface repository vote (08-api-upvote-downvote.md + 34 deck).
/// Semua method mengembalikan `Either`, failure = [VoteFailure].
abstract interface class VoteRepository {
  /// Toggle vote (1 = upvote, -1 = downvote). Semantik servernya: vote
  /// searah kedua kali = batal (my_vote null); beda arah = ganti arah.
  /// Response selalu membawa count + my_vote terbaru.
  Future<Either<VoteFailure, VoteView>> toggle(VoteTarget target, int value);

  /// Batch jumlah vote per target. Kunci map = `target.key`
  /// ("type:id"). Target tanpa vote TIDAK muncul (lengkapi nol di
  /// use case / caller, bukan di SQL).
  Future<Either<VoteFailure, Map<String, VoteCounts>>> countMany(
    List<VoteTarget> targets,
  );

  /// Vote milik user login untuk batch target. Hanya target yang dipilih
  /// user yang dikembalikan (key `target.key` -> 1 | -1).
  Future<Either<VoteFailure, Map<String, int>>> myVotes(
    List<VoteTarget> targets,
  );

  /// Antrean kata published yang user belum vote (34-api-vote-deck.md).
  Future<Either<VoteFailure, VoteDeckPage>> getDeck({
    int limit = 10,
    String? cursor,
  });

  /// Lewati kartu deck tanpa menulis vote. Idempoten.
  Future<Either<VoteFailure, Unit>> skipWord(String wordId);

  /// Batalkan skip. Idempoten.
  Future<Either<VoteFailure, Unit>> unskipWord(String wordId);
}
