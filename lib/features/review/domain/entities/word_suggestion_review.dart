/// Domain ringkas untuk antrean admin word-suggestions (mobile review).
class WordSuggestionSummary {
  const WordSuggestionSummary({
    required this.id,
    required this.wordId,
    required this.wordLemma,
    required this.contributorId,
    this.contributorUsername,
    this.contributorDisplayName,
    required this.reason,
    required this.reasonCode,
    required this.status,
    required this.createdAt,
    this.summaryLemma,
    this.summaryNotes,
    this.meaningsCount = 0,
    this.imagesCount = 0,
  });

  final String id;
  final String wordId;
  final String wordLemma;
  final String contributorId;
  final String? contributorUsername;
  final String? contributorDisplayName;
  final String reason;
  final String reasonCode;
  final String status;
  final String createdAt;
  final String? summaryLemma;
  final String? summaryNotes;
  final int meaningsCount;
  final int imagesCount;

  String get contributorLabel =>
      contributorDisplayName?.trim().isNotEmpty == true
          ? contributorDisplayName!.trim()
          : (contributorUsername?.trim().isNotEmpty == true
              ? contributorUsername!.trim()
              : 'Kontributor');

  String get changeHint {
    final parts = <String>[];
    if (summaryLemma != null && summaryLemma!.isNotEmpty) {
      parts.add('lemma');
    }
    if (summaryNotes != null && summaryNotes!.isNotEmpty) {
      parts.add('catatan');
    }
    if (meaningsCount > 0) parts.add('makna ($meaningsCount)');
    if (imagesCount > 0) parts.add('gambar ($imagesCount)');
    if (parts.isEmpty) return 'Perubahan usulan';
    return parts.join(', ');
  }
}

class WordSuggestionListPage {
  const WordSuggestionListPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<WordSuggestionSummary> items;
  final String? nextCursor;
  final bool hasMore;
}

class WordSuggestionFieldDiff {
  const WordSuggestionFieldDiff({
    this.current,
    this.proposed,
    required this.changed,
  });

  final String? current;
  final String? proposed;
  final bool changed;
}

class WordSuggestionDetail {
  const WordSuggestionDetail({
    required this.id,
    required this.wordId,
    required this.wordLemma,
    required this.contributorId,
    this.contributorUsername,
    this.contributorDisplayName,
    required this.reason,
    required this.reasonCode,
    required this.status,
    required this.createdAt,
    required this.lemmaDiff,
    required this.notesDiff,
    this.meaningsChanged = 0,
    this.categoriesAdded = 0,
    this.categoriesRemoved = 0,
    this.relationsAdded = 0,
    this.relationsRemoved = 0,
    this.variantsAdded = 0,
    this.variantsRemoved = 0,
    this.imagesAdded = 0,
    this.imagesRemoved = 0,
  });

  final String id;
  final String wordId;
  final String wordLemma;
  final String contributorId;
  final String? contributorUsername;
  final String? contributorDisplayName;
  final String reason;
  final String reasonCode;
  final String status;
  final String createdAt;
  final WordSuggestionFieldDiff lemmaDiff;
  final WordSuggestionFieldDiff notesDiff;
  final int meaningsChanged;
  final int categoriesAdded;
  final int categoriesRemoved;
  final int relationsAdded;
  final int relationsRemoved;
  final int variantsAdded;
  final int variantsRemoved;
  final int imagesAdded;
  final int imagesRemoved;

  String get contributorLabel =>
      contributorDisplayName?.trim().isNotEmpty == true
          ? contributorDisplayName!.trim()
          : (contributorUsername?.trim().isNotEmpty == true
              ? contributorUsername!.trim()
              : 'Kontributor');

  bool get isPending => status == 'pending';
}
