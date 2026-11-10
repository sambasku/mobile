/// Kelas kata milik MAKNA kartu (bukan kata induk). Satu lemma bisa punya
/// makna dengan kelas berbeda, jadi kelas dibaca per kartu.
class VoteDeckWordClass {
  const VoteDeckWordClass({
    required this.id,
    required this.code,
    required this.name,
    this.alias,
  });

  final String id;
  final String code;
  final String name;
  final String? alias;
}

/// Satu kartu antrean GET /api/v1/votes/deck (34-api-vote-deck.md, 0101:
/// deck per makna - 1 kartu = 1 makna). [id] = ID makna (target vote),
/// [wordId] = kata induk.
class VoteDeckItem {
  const VoteDeckItem({
    required this.id,
    required this.wordId,
    required this.lemma,
    required this.languageId,
    required this.languageCode,
    required this.wordType,
    required this.status,
    required this.isVerified,
    required this.approvedAt,
    required this.orderIndex,
    this.meaningCount = 1,
    this.wordClass,
    this.sense,
    this.upvotes = 0,
    this.downvotes = 0,
  });

  /// ID makna - target vote + kunci dedupe antrean.
  final String id;

  /// ID kata induk (buka detail kata dari kartu).
  final String wordId;
  final String lemma;
  final String languageId;
  final String languageCode;
  final String wordType;
  final String status;
  final bool isVerified;
  final String approvedAt;

  /// Definisi makna ini; fallback terjemahan pertama bila kosong.
  final String? sense;

  /// Posisi 1-based antar makna published kata ini (konteks "Makna ke-N").
  final int orderIndex;

  /// Jumlah makna published kata ini (konteks "dari M").
  final int meaningCount;

  /// Kelas kata makna ini; null = belum diisi (atau API lama).
  final VoteDeckWordClass? wordClass;

  final int upvotes;
  final int downvotes;

  VoteDeckItem copyWith({
    String? id,
    String? wordId,
    String? lemma,
    String? languageId,
    String? languageCode,
    String? wordType,
    String? status,
    bool? isVerified,
    String? approvedAt,
    int? orderIndex,
    int? meaningCount,
    VoteDeckWordClass? wordClass,
    String? sense,
    int? upvotes,
    int? downvotes,
    bool clearWordClass = false,
  }) {
    return VoteDeckItem(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      lemma: lemma ?? this.lemma,
      languageId: languageId ?? this.languageId,
      languageCode: languageCode ?? this.languageCode,
      wordType: wordType ?? this.wordType,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      approvedAt: approvedAt ?? this.approvedAt,
      orderIndex: orderIndex ?? this.orderIndex,
      meaningCount: meaningCount ?? this.meaningCount,
      wordClass: clearWordClass ? null : (wordClass ?? this.wordClass),
      sense: sense ?? this.sense,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
    );
  }

  /// Label jenis entri untuk UI (seragam dengan wordSummary/wordDetail).
  String get wordTypeLabel => switch (wordType) {
        'idiom' => 'Idiom',
        'peribahasa' => 'Peribahasa',
        'ungkapan' => 'Ungkapan',
        _ => 'Kata',
      };

  /// Label chip kelas kata: pakai `alias` ("Kata Benda") untuk kelas
  /// spesifik. `umum` pakai `name` - alias seed-nya ("Belum Diketahui")
  /// berbunyi status, bukan nama kelas.
  String get wordClassLabel {
    final wc = wordClass;
    if (wc == null) return '';
    final alias = wc.alias?.trim();
    if (wc.code.toLowerCase() == 'umum') return wc.name;
    return (alias == null || alias.isEmpty) ? wc.name : alias;
  }
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
