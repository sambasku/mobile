/// Profil publik by username (19-api-profil-publik.md).
class PublicProfile {
  const PublicProfile({
    required this.username,
    required this.displayName,
    required this.role,
    required this.isVerifier,
    required this.joinedAt,
    required this.contributionsApproved,
    required this.verificationsDone,
    required this.commentsPublished,
    this.bio,
    this.avatarUrl,
  });
  final String username;
  final String displayName;
  final String? bio;
  final String role;
  final bool isVerifier;
  final String joinedAt;
  final int contributionsApproved;
  final int verificationsDone;
  final int commentsPublished;
  final String? avatarUrl;
}

class PublicActivityItem {
  const PublicActivityItem({
    required this.id,
    required this.kind,
    required this.occurredAt,
    required this.summary,
    this.wordId,
    this.lemma,
  });
  final String id;
  final String kind;
  final String occurredAt;
  final String summary;
  final String? wordId;
  final String? lemma;
}

/// Kandidat mention untuk autocomplete @username (38-api-mention.md).
class MentionSuggestion {
  const MentionSuggestion({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
  });
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
}