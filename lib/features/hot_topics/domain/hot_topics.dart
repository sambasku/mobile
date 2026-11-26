/// Respons `GET /api/v1/hot-topics` (G4/G6).
class HotTopicsBundle {
  const HotTopicsBundle({
    required this.verified,
    required this.commented,
    required this.searched,
    required this.proposed,
    required this.viewed,
    required this.check,
  });

  final HotTopicTab verified;
  final HotTopicTab commented;
  final HotTopicTab searched;
  final HotTopicTab proposed;
  final HotTopicTab viewed;
  final HotTopicTab check;

  bool get isEmpty =>
      verified.items.isEmpty &&
      commented.items.isEmpty &&
      searched.items.isEmpty &&
      proposed.items.isEmpty &&
      viewed.items.isEmpty &&
      check.items.isEmpty;
}

class HotTopicTabMeta {
  const HotTopicTabMeta({
    required this.inWindow,
    required this.backfilled,
    required this.backfillUsed,
  });

  final int inWindow;
  final int backfilled;
  final bool backfillUsed;
}

class HotTopicTab {
  const HotTopicTab({required this.items, required this.meta});

  final List<HotTopicItem> items;
  final HotTopicTabMeta meta;
}

sealed class HotTopicItem {
  const HotTopicItem({required this.inWindow});

  final bool inWindow;
}

class HotSearchedItem extends HotTopicItem {
  const HotSearchedItem({
    required this.id,
    required this.term,
    required this.direction,
    required this.hitCount,
    required super.inWindow,
  });

  final String id;
  final String term;
  final String direction;
  final int hitCount;
}

class HotProposedItem extends HotTopicItem {
  const HotProposedItem({
    required this.id,
    required this.wordId,
    required this.lemma,
    required super.inWindow,
  });

  final String id;
  final String wordId;
  final String lemma;
}

class HotViewedItem extends HotTopicItem {
  const HotViewedItem({
    required this.wordId,
    required this.lemma,
    required this.viewCount,
    required this.lastViewedDay,
    required super.inWindow,
  });

  final String wordId;
  final String lemma;
  final int viewCount;
  final String lastViewedDay;
}

class HotCheckItem extends HotTopicItem {
  const HotCheckItem({
    required this.meaningId,
    required this.wordId,
    required this.lemma,
    required this.downvotes,
    this.definitionPreview,
    required super.inWindow,
  });

  final String meaningId;
  final String wordId;
  final String lemma;
  final int downvotes;
  final String? definitionPreview;
}

class HotVerifiedItem extends HotTopicItem {
  const HotVerifiedItem({
    required this.wordId,
    required this.lemma,
    required this.verifiedAt,
    required super.inWindow,
  });

  final String wordId;
  final String lemma;
  final DateTime verifiedAt;
}

class HotCommentedItem extends HotTopicItem {
  const HotCommentedItem({
    required this.wordId,
    required this.lemma,
    required this.commentCount,
    required this.lastCommentedAt,
    required super.inWindow,
  });

  final String wordId;
  final String lemma;
  final int commentCount;
  final DateTime lastCommentedAt;
}
