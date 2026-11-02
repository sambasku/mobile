/// Ringkasan kata hasil pencarian publik (GET /api/v1/words/search).
class WordSummary {
  const WordSummary({
    required this.id,
    required this.lemma,
    required this.languageCode,
    required this.wordType,
    required this.status,
    required this.isVerified,
    this.matchedTranslation,
    this.matchedVariant,
    this.matchType,
    this.sense,
    this.approvedAt,
    this.usageLabels = const [],
  });

  final String id;
  final String lemma;
  final String languageCode;
  final String wordType;
  final String status;
  final bool isVerified;

  /// Relasi terjemahan yang cocok (hanya search_in=translation):
  /// tampilkan sebagai "makan → makatn".
  final String? matchedTranslation;

  /// Form variasi penulisan yang cocok (doc 11).
  final String? matchedVariant;

  /// PRD relasi-lemma: 'related_group' = hasil ini datang dari perluasan
  /// kelompok makna, bukan cocok langsung. Null = hasil langsung.
  final String? matchType;

  /// Hasil perluasan kelompok makna (bukan hasil pencarian langsung).
  bool get isRelatedGroupMatch => matchType == 'related_group';

  /// Satu baris arti.
  /// - GET /words/latest: definisi atau terjemahan pertama.
  /// - GET /words (A-Z) dan GET /words/search: gloss `[n] makan,[v] santap`.
  final String? sense;

  /// Waktu persetujuan / tayang. Hanya feed beranda.
  final DateTime? approvedAt;

  /// Register & peringatan (`usage_labels` API). Kosong jika endpoint belum mengirim.
  final List<String> usageLabels;

  /// Label jenis entri untuk UI.
  String get wordTypeLabel => switch (wordType) {
        'idiom' => 'Idiom',
        'peribahasa' => 'Peribahasa',
        'ungkapan' => 'Ungkapan',
        _ => 'Kata',
      };
}

/// Satu halaman hasil cursor-based (api-base-stack Section 13).
class WordSearchPage {
  const WordSearchPage({
    required this.items,
    this.nextCursor,
    required this.hasMore,
  });

  final List<WordSummary> items;
  final String? nextCursor;
  final bool hasMore;
}
