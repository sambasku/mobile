import '../../domain/entities/word_summary.dart';

/// State halaman Daftar Kata. q kosong + Sambas = browsing A-Z.
/// q terisi, atau mode Indonesia, memakai pencarian (`viaSearch`) supaya
/// hasil kosong tercatat sebagai search-miss.
class WordListState {
  const WordListState({
    this.q = '',
    this.category,
    this.searchIn = 'lemma',
    this.viaSearch = false,
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final String q;

  /// Filter kategori/glosarium (#50). Null = semua.
  final String? category;

  /// `lemma` = Sambas, `translation` = Indonesia.
  final String searchIn;

  /// Halaman ini datang dari `/words/search` (cursor id), bukan list A-Z.
  final bool viaSearch;

  final List<WordSummary> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  WordListState copyWith({
    String? q,
    String? category,
    String? searchIn,
    bool? viaSearch,
    List<WordSummary>? items,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return WordListState(
      q: q ?? this.q,
      category: category ?? this.category,
      searchIn: searchIn ?? this.searchIn,
      viaSearch: viaSearch ?? this.viaSearch,
      items: items ?? this.items,
      nextCursor: clearNextCursor ? null : nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
