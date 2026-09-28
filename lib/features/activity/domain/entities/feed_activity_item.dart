/// Jenis baris feed beranda (GET /api/v1/activity).
enum FeedActivityKind {
  word,
  comment,
  vote,
  discussion,
  wordImage,
  wordAudio,
  pronunciation,
  example,
  searchMiss,
}

FeedActivityKind? parseFeedActivityKind(String raw) {
  switch (raw) {
    case 'word':
      return FeedActivityKind.word;
    case 'comment':
      return FeedActivityKind.comment;
    case 'vote':
      return FeedActivityKind.vote;
    case 'discussion':
      return FeedActivityKind.discussion;
    case 'word_image':
      return FeedActivityKind.wordImage;
    case 'word_audio':
      return FeedActivityKind.wordAudio;
    case 'pronunciation':
      return FeedActivityKind.pronunciation;
    case 'example':
      return FeedActivityKind.example;
    case 'search_miss':
      return FeedActivityKind.searchMiss;
    default:
      return null;
  }
}

class FeedActivityActor {
  const FeedActivityActor({
    this.username,
    this.displayName,
    this.avatarUrl,
  });

  final String? username;
  final String? displayName;
  final String? avatarUrl;
}

class FeedActivityTarget {
  const FeedActivityTarget({required this.type, required this.id});

  final String type;
  final String id;
}

/// Satu baris Aktivitas terbaru di beranda.
class FeedActivityItem {
  const FeedActivityItem({
    required this.id,
    required this.kind,
    required this.createdAt,
    required this.body,
    this.actor,
    this.subtitle,
    this.target,
  });

  final String id;
  final FeedActivityKind kind;
  final String createdAt;
  final String body;
  final FeedActivityActor? actor;
  final String? subtitle;
  final FeedActivityTarget? target;
}
