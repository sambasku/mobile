/// Respons `GET /api/v1/hot-topics` (G4/G6).
class HotTopicsBundle {
  const HotTopicsBundle({
    required this.searched,
    required this.proposed,
    required this.viewed,
  });

  final HotTopicTab searched;
  final HotTopicTab proposed;
  final HotTopicTab viewed;

  bool get isEmpty =>
      searched.items.isEmpty && proposed.items.isEmpty && viewed.items.isEmpty;
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
