/// Satu kartu antrean GET /api/v1/votes/deck (34-api-vote-deck.md).
class VoteDeckItem {
  const VoteDeckItem({
    required this.id,
    required this.lemma,
    required this.languageId,
    required this.languageCode,
    required this.wordType,
    required this.status,
    required this.isVerified,
    required this.approvedAt,
    this.sense,
    this.upvotes = 0,
    this.downvotes = 0,
  });

  final String id;
  final String lemma;
  final String languageId;
  final String languageCode;
  final String wordType;
  final String status;
  final bool isVerified;
  final String approvedAt;
  final String? sense;
  final int upvotes;
  final int downvotes;

  /// Label jenis entri untuk UI (seragam dengan wordSummary/wordDetail).
  String get wordTypeLabel => switch (wordType) {
        'idiom' => 'Idiom',
        'peribahasa' => 'Peribahasa',
        'ungkapan' => 'Ungkapan',
        _ => 'Kata',
      };
}

class VoteDeckPage {
  const VoteDeckPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<VoteDeckItem> items;
  final String? nextCursor;
  final bool hasMore;
}
