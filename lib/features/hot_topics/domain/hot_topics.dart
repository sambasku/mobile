/// Respons `GET /api/v1/hot-topics` (G4).
class HotTopicsBundle {
  const HotTopicsBundle({
    required this.searched,
    required this.proposed,
    required this.nearThreshold,
  });

  final HotTopicTab searched;
  final HotTopicTab proposed;
  final HotTopicTab nearThreshold;

  bool get isEmpty =>
      searched.items.isEmpty &&
      proposed.items.isEmpty &&
      nearThreshold.items.isEmpty;
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

class HotNearThresholdItem extends HotTopicItem {
  const HotNearThresholdItem({
    required this.meaningId,
    required this.wordId,
    required this.lemma,
    required this.definitionPreview,
    required this.net,
    required this.upvotes,
    required this.downvotes,
    required super.inWindow,
  });

  final String meaningId;
  final String wordId;
  final String lemma;
  final String? definitionPreview;
  final int net;
  final int upvotes;
  final int downvotes;
}
