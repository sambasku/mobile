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
  welcome,
  cardShare,
  suggestion,
  contribution,
  verification,
  voteUp,
  voteDown,
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
    case 'welcome':
      return FeedActivityKind.welcome;
    case 'card_share':
      return FeedActivityKind.cardShare;
    case 'suggestion':
      return FeedActivityKind.suggestion;
    case 'contribution':
      return FeedActivityKind.contribution;
    case 'verification':
      return FeedActivityKind.verification;
    case 'vote_up':
      return FeedActivityKind.voteUp;
    case 'vote_down':
      return FeedActivityKind.voteDown;
    default:
      return null;
  }
}

/// Potong body feed jadi `(teks, lemma?)`. API mengutip lemma di body
/// (`"kumis" sudah pas`) sebagai penanda parsing; kutipnya dibuang di sini
/// supaya tampilannya cukup bold tanpa tanda kutip (kosakata Sambas sering
/// memakai `'`). Kutip tak berpasangan bukan lemma.
List<(String, bool)> splitQuotedLemma(String body) {
  final out = <(String, bool)>[];
  var i = 0;
  for (final m in RegExp(r'"[^"]+"').allMatches(body)) {
    if (m.start > i) out.add((body.substring(i, m.start), false));
    out.add((m[0]!.substring(1, m[0]!.length - 1), true));
    i = m.end;
  }
  if (i < body.length) out.add((body.substring(i), false));
  return out;
}

class FeedActivityActor {
  const FeedActivityActor({this.username, this.displayName, this.avatarUrl});

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
