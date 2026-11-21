/// Domain antrean usulan eksplorasi di area verifikator.
enum ExplorationReviewDomain {
  usaha,
  place,
  event,
  culinary,
  layanan,
}

extension ExplorationReviewDomainX on ExplorationReviewDomain {
  String get apiPathSegment => switch (this) {
    .usaha => 'usaha-contributions',
    .place => 'place-contributions',
    .event => 'event-contributions',
    .culinary => 'culinary-contributions',
    .layanan => 'layanan-contributions',
  };

  /// Place tidak punya endpoint request-revision.
  bool get supportsRevision => this != ExplorationReviewDomain.place;

  /// Usaha/kuliner/layanan/acara list pakai query status (atau decided/q untuk acara).
  bool get listUsesStatusQuery =>
      this == ExplorationReviewDomain.usaha ||
      this == ExplorationReviewDomain.culinary ||
      this == ExplorationReviewDomain.layanan ||
      this == ExplorationReviewDomain.event;

  /// Hanya acara: API dukung `decided` + `q` untuk periksa/riwayat.
  bool get supportsListSearch => this == ExplorationReviewDomain.event;
}

/// Satu baris usulan eksplorasi dari list admin (payload embedded, tanpa GET-by-id).
class ExplorationProposal {
  const ExplorationProposal({
    required this.id,
    required this.domain,
    required this.status,
    required this.title,
    required this.createdAtLabel,
    required this.payload,
    this.kind,
    this.subtitle,
    this.fields = const [],
    this.revisionNote,
    this.wantsClaim = false,
  });

  final String id;
  final ExplorationReviewDomain domain;
  final String status;
  final String? kind;
  final String title;
  final String? subtitle;
  final String createdAtLabel;
  final Map<String, dynamic> payload;
  final List<String> fields;
  final String? revisionNote;
  final bool wantsClaim;

  bool get isPending => status == 'pending';
}
