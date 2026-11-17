class KaryaCredit {
  const KaryaCredit({
    required this.role,
    required this.nameText,
    this.id,
    this.kreatorId,
    this.kreatorSlug,
    this.sortOrder = 0,
  });

  final String? id;
  final String role;
  final String nameText;
  final String? kreatorId;
  final String? kreatorSlug;
  final int sortOrder;
}

class KreatorLink {
  const KreatorLink({required this.label, required this.url});

  final String label;
  final String url;
}

class KreatorProfile {
  const KreatorProfile({
    required this.id,
    required this.slug,
    required this.displayName,
    required this.kind,
    required this.karyas,
    this.bio,
    this.originRegion,
    this.links = const [],
  });

  final String id;
  final String slug;
  final String displayName;
  final String kind;
  final String? bio;
  final String? originRegion;
  final List<KreatorLink> links;
  final List<KreatorKaryaSummary> karyas;
}

class KreatorKaryaSummary {
  const KreatorKaryaSummary({
    required this.id,
    required this.slug,
    required this.title,
    required this.kind,
    required this.year,
    required this.role,
  });

  final String id;
  final String slug;
  final String title;
  final String kind;
  final int year;
  final String role;
}

class KaryaAccessLink {
  const KaryaAccessLink({
    required this.kind,
    required this.label,
    required this.url,
    this.isPrimary = false,
  });

  final String kind;
  final String label;
  final String url;
  final bool isPrimary;
}

class KaryaSambasConnection {
  const KaryaSambasConnection({
    required this.type,
    required this.note,
  });

  final String type;
  final String note;
}

class KaryaLemmaLink {
  const KaryaLemmaLink({
    required this.id,
    required this.excerptId,
    required this.start,
    required this.end,
    required this.wordId,
    required this.status,
    this.lemma,
    this.source = 'author',
    this.proposedWordId,
    this.proposedLemma,
    this.proposedBy,
  });

  final String id;
  final String excerptId;
  final int start;
  final int end;
  final String wordId;
  final String? lemma;
  final String status;
  final String source;
  final String? proposedWordId;
  final String? proposedLemma;
  final String? proposedBy;

  bool get isActive => status == 'active';
}

class KaryaExcerpt {
  const KaryaExcerpt({
    required this.id,
    required this.kind,
    required this.text,
    this.language,
    this.startLabel,
    this.endLabel,
    required this.rightsStatus,
    this.sourceUrl,
    this.lemmaLinks = const [],
  });

  final String id;
  final String kind;
  final String text;
  final String? language;
  final String? startLabel;
  final String? endLabel;
  final String rightsStatus;
  final String? sourceUrl;
  final List<KaryaLemmaLink> lemmaLinks;

  List<KaryaLemmaLink> get activeLemmaLinks =>
      lemmaLinks.where((l) => l.isActive).toList();
}

class KaryaEntry {
  const KaryaEntry({
    required this.id,
    required this.slug,
    required this.title,
    required this.kind,
    required this.year,
    required this.sambasConnections,
    required this.accessLinks,
    required this.credits,
    required this.excerpts,
    required this.updatedAt,
    this.language,
    this.description,
    this.coverUrl,
    this.musicReleaseType,
    this.musicDurationMs,
    this.musicIsCover = false,
    this.filmType,
    this.filmRuntimeMin,
  });

  final String id;
  final String slug;
  final String title;
  final String kind;
  final int year;
  final String? language;
  final String? description;
  final String? coverUrl;
  final List<KaryaSambasConnection> sambasConnections;
  final List<KaryaAccessLink> accessLinks;
  final List<KaryaCredit> credits;
  final List<KaryaExcerpt> excerpts;
  final String? musicReleaseType;
  final int? musicDurationMs;
  final bool musicIsCover;
  final String? filmType;
  final int? filmRuntimeMin;
  final DateTime updatedAt;

  bool get isMusic => kind == 'music';

  KaryaAccessLink? get primaryAccess {
    for (final link in accessLinks) {
      if (link.isPrimary) return link;
    }
    return accessLinks.isEmpty ? null : accessLinks.first;
  }

  List<KaryaAccessLink> get secondaryAccess {
    final primary = primaryAccess;
    if (primary == null) return const [];
    return accessLinks.where((l) => !l.isPrimary && l.url != primary.url).toList();
  }
}

class KaryaProposal {
  const KaryaProposal({
    required this.id,
    required this.kind,
    required this.status,
    required this.title,
    this.revisionNote,
  });

  final String id;
  final String kind;
  final String status;
  final String title;
  final String? revisionNote;
}