/// Ringkasan kata pada item bookmark - subset minimal untuk list UI
/// (16-api-bookmark.md).
class BookmarkWord {
  const BookmarkWord({
    required this.id,
    required this.lemma,
    required this.wordType,
    this.isVerified = false,
    this.available = true,
  });

  final String id;
  final String lemma;
  final String wordType;
  final bool isVerified;

  /// false bila entri ditarik atau tidak lagi tayang.
  final bool available;
}
