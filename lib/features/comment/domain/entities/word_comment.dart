import '../../../vote/domain/entities/vote_target.dart';

/// Komentar pada lemma (09-api-comment.md). Post-moderation:
/// published | taken_down | deleted_by_author.
class WordComment {
  const WordComment({
    required this.id,
    required this.wordId,
    required this.userId,
    this.username,
    this.displayName,
    this.body,
    this.createdAt,
    this.status,
    this.upvotes = 0,
    this.downvotes = 0,
    this.myVote,
  });

  final String id;
  final String wordId;
  final String userId;

  /// Handle penulis (link profil); null kalau penulis dihapus.
  final String? username;

  /// Nama tampilan; fallback UI → [username].
  final String? displayName;

  /// Null jika taken_down / deleted_by_author (redact server).
  final String? body;

  final String? createdAt;

  /// published | taken_down | deleted_by_author
  final String? status;
  final int upvotes;
  final int downvotes;
  final int? myVote;

  VoteTarget get voteTarget => VoteTarget(type: 'comment', id: id);

  bool isOwner(String? actorId) => actorId != null && actorId == userId;

  bool get isPublished =>
      status == 'published' || (status == null && body != null);

  bool get isTakenDown => status == 'taken_down';

  bool get isDeletedByAuthor => status == 'deleted_by_author';

  String get displayBody {
    if (isTakenDown) {
      return 'Komentar ini dihapus karena tidak memenuhi standar komunitas.';
    }
    if (isDeletedByAuthor) {
      return 'Komentar ini dihapus oleh penulis.';
    }
    // body null tanpa status jelas → treat sebagai redacted aman
    if (body == null) {
      return 'Komentar ini tidak tersedia.';
    }
    return body!;
  }

  WordComment copyWith({
    Object? body = _unset,
    String? status,
    int? upvotes,
    int? downvotes,
    Object? myVote = _unset,
  }) {
    return WordComment(
      id: id,
      wordId: wordId,
      userId: userId,
      username: username,
      displayName: displayName,
      body: identical(body, _unset) ? this.body : body as String?,
      createdAt: createdAt,
      status: status ?? this.status,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      myVote: identical(myVote, _unset) ? this.myVote : myVote as int?,
    );
  }

  static const Object _unset = Object();
}
