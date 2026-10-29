import '../../../vote/domain/entities/vote_target.dart';
import 'comment_image.dart';

/// Komentar pada lemma (09-api-comment.md). Post-moderation:
/// published | taken_down | deleted_by_author.
class WordComment {
  const WordComment({
    required this.id,
    required this.wordId,
    required this.userId,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.isVerifier = false,
    this.body,
    this.audioUrl,
    this.audioMimeType,
    this.audioDurationMs,
    this.image,
    this.createdAt,
    this.status,
    this.upvotes = 0,
    this.downvotes = 0,
    this.myVote,
    this.isEdited = false,
    this.updatedAt,
  });

  final String id;
  final String wordId;
  final String userId;

  /// Handle penulis (link profil); null kalau penulis dihapus.
  final String? username;

  /// Nama tampilan; fallback UI → [username].
  final String? displayName;

  /// Avatar publik; null → inisial di UI.
  final String? avatarUrl;

  /// true jika role verifikator (admin|editor|root|reviewer).
  final bool isVerifier;

  /// Null jika taken_down / deleted_by_author (redact server).
  final String? body;

  final String? audioUrl;
  final String? audioMimeType;
  final int? audioDurationMs;

  final CommentImage? image;

  final String? createdAt;

  /// published | taken_down | deleted_by_author
  final String? status;
  final int upvotes;
  final int downvotes;
  final int? myVote;
  final bool isEdited;
  final String? updatedAt;

  VoteTarget get voteTarget => VoteTarget(type: 'comment', id: id);

  bool isOwner(String? actorId) => actorId != null && actorId == userId;

  bool get isPublished =>
      status == 'published' || (status == null && body != null);

  bool get isTakenDown => status == 'taken_down';

  bool get isDeletedByAuthor => status == 'deleted_by_author';

  bool get hasAudio =>
      audioUrl != null && audioUrl!.trim().isNotEmpty;

  bool get hasImage => image != null;

  bool get hasPendingImage => image?.isPendingReview ?? false;

  String get displayBody {
    if (isTakenDown) {
      return 'Komentar ini dihapus karena tidak memenuhi standar komunitas.';
    }
    if (isDeletedByAuthor) {
      return 'Komentar ini dihapus oleh penulis.';
    }
    if (body == null || body!.trim().isEmpty) {
      if ((hasAudio || hasImage) && isPublished) return '';
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
    bool? isEdited,
    String? updatedAt,
    CommentImage? image,
  }) {
    return WordComment(
      id: id,
      wordId: wordId,
      userId: userId,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      isVerifier: isVerifier,
      body: identical(body, _unset) ? this.body : body as String?,
      audioUrl: audioUrl,
      audioMimeType: audioMimeType,
      audioDurationMs: audioDurationMs,
      image: image ?? this.image,
      createdAt: createdAt,
      status: status ?? this.status,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      myVote: identical(myVote, _unset) ? this.myVote : myVote as int?,
      isEdited: isEdited ?? this.isEdited,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static const Object _unset = Object();
}
