import 'rhyme_check.dart' show RhymeScheme;
import '../../vote/domain/entities/vote_target.dart';

class Pantun {
  const Pantun({
    required this.id,
    required this.userId,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.parentId,
    required this.language,
    required this.themeId,
    required this.rhymeScheme,
    required this.lines,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.isVerifier = false,
    this.upvotes = 0,
    this.downvotes = 0,
    this.myVote,
  });

  final String id;
  final String userId;
  final String? username;
  final String? displayName;
  final String? avatarUrl;

  /// Penulis punya role verifikator (admin/editor/reviewer/root) → centang.
  final bool isVerifier;

  /// Null = pantun pembuka; berisi id pantun = balasan.
  final String? parentId;
  final String language;
  final String? themeId;
  final RhymeScheme rhymeScheme;
  final List<String> lines;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Counts vote (wire `upvotes`/`downvotes`); 0 untuk API lama.
  final int upvotes;
  final int downvotes;

  /// 1 | -1 | null - di-seed dari GET /votes/my, bukan wire list.
  final int? myVote;

  factory Pantun.fromJson(Map<String, dynamic> json) => Pantun(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    username: json['username'] as String?,
    displayName: json['display_name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    isVerifier: json['is_verifier'] as bool? ?? false,
    parentId: json['parent_id'] as String?,
    language: json['language'] as String? ?? 'id',
    themeId: json['theme_id'] as String?,
    rhymeScheme: json['rhyme_scheme'] as String? ?? 'ABAB',
    lines: (json['lines'] as List)
        .map((e) => e as String)
        .toList(growable: false),
    status: json['status'] as String? ?? 'published',
    upvotes: json['upvotes'] as int? ?? 0,
    downvotes: json['downvotes'] as int? ?? 0,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: json['updated_at'] == null
        ? null
        : DateTime.parse(json['updated_at'] as String),
  );

  String get authorLabel => displayName ?? username ?? 'Seseorang';

  /// Target vote polymorphic: pantun pembuka vs balasan.
  VoteTarget get voteTarget =>
      VoteTarget(type: parentId == null ? 'pantun' : 'pantun_reply', id: id);

  Pantun copyWith({
    int? upvotes,
    int? downvotes,
    int? myVote,
    bool clearMyVote = false,
  }) {
    return Pantun(
      id: id,
      userId: userId,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      parentId: parentId,
      language: language,
      themeId: themeId,
      rhymeScheme: rhymeScheme,
      lines: lines,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isVerifier: isVerifier,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      myVote: clearMyVote ? null : (myVote ?? this.myVote),
    );
  }
}

class PantunPage {
  const PantunPage(this.items, this.nextCursor, this.hasMore);
  final List<Pantun> items;
  final String? nextCursor;
  final bool hasMore;
}

class PantunDetail {
  const PantunDetail(this.pantun, this.replies);
  final Pantun pantun;
  final List<Pantun> replies;
}

class PantunFailure implements Exception {
  const PantunFailure(this.message, {this.details = const {}});
  final String message;

  /// Pesan validasi per-field dari backend (mis. rima belum pas).
  final Map<String, String> details;
  @override
  String toString() => message;
}
