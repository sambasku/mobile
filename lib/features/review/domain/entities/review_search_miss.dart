/// Baris admin search-miss (#88): SEMUA miss termasuk yang belum
/// ditayangkan, dengan status tayang/terjawab. Endpoint:
/// `GET /api/v1/admin/search-misses` (sort terbaru).
class ReviewSearchMiss {
  const ReviewSearchMiss({
    required this.id,
    required this.term,
    required this.searchIn,
    required this.hitCount,
    required this.isVisible,
    required this.isFulfilled,
  });

  final String id;
  final String term;

  /// 'lemma' | 'translation' — mirror wire `direction`.
  final String searchIn;
  final int hitCount;
  final bool isVisible;
  final bool isFulfilled;

  ReviewSearchMiss copyWith({bool? isVisible}) => ReviewSearchMiss(
        id: id,
        term: term,
        searchIn: searchIn,
        hitCount: hitCount,
        isVisible: isVisible ?? this.isVisible,
        isFulfilled: isFulfilled,
      );
}

/// Satu halaman hasil list admin.
class ReviewSearchMissPageData {
  const ReviewSearchMissPageData({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<ReviewSearchMiss> items;
  final String? nextCursor;
  final bool hasMore;
}
