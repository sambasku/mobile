class ReviewItem {
  const ReviewItem({
    required this.id,
    required this.contributorUsername,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.status,
    required this.createdAt,
    this.contributorDisplayName,
    this.wordLemma,
    this.reopenedBy,
    this.reviewStatus,
    this.reviewComment,
    this.reviewedAt,
  });

  final String id;
  final String? contributorUsername;
  final String? contributorDisplayName;
  final String entityType;
  final String entityId;
  final String action;
  final String status;
  final String createdAt;
  final String? wordLemma;
  final String? reopenedBy;
  final String? reviewStatus;
  final String? reviewComment;
  final String? reviewedAt;

  bool get isPending => status == 'pending';

  /// Nama tampilan kontributor (null = anonim; label locale di presentation).
  String? get contributorLabel {
    final display = contributorDisplayName?.trim();
    if (display != null && display.isNotEmpty) return display;
    final handle = contributorUsername?.trim();
    if (handle != null && handle.isNotEmpty) return handle;
    return null;
  }

  /// Judul baris: lemma, atau kode entity (label locale di presentation).
  String get title => titleOrEntityType;

  /// Kode entity saat lemma kosong - siap dipetakan ke label locale.
  String get titleOrEntityType {
    final lemma = wordLemma?.trim();
    if (lemma != null && lemma.isNotEmpty) return lemma;
    return entityType;
  }
}

class ReviewListPage {
  const ReviewListPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<ReviewItem> items;
  final String? nextCursor;
  final bool hasMore;
}

class ReviewPriorDecision {
  const ReviewPriorDecision({
    required this.status,
    required this.createdAt,
    this.reviewerId,
    this.comment,
  });

  final String? reviewerId;
  final String status;
  final String? comment;
  final String createdAt;
}

class ReviewDetail {
  const ReviewDetail({
    required this.contribution,
    required this.entity,
    this.reviewComment,
    this.priorReviews = const [],
  });

  final ReviewItem contribution;
  final Map<String, dynamic> entity;
  final String? reviewComment;
  final List<ReviewPriorDecision> priorReviews;

  bool get wordAlreadyVerified {
    if (contribution.entityType != 'word') return false;
    return entity['isVerified'] == true || entity['is_verified'] == true;
  }

  /// Id kata induk dari kontribusi ini.
  ///
  /// Kontribusi `word` memakai kata itu sendiri sebagai entity. Untuk anak
  /// (makna, contoh, gambar, audio, pelafalan) payload detail sudah membawa
  /// `wordId` induk, jadi aksi yang butuh "kata yang sedang ditinjau" -
  /// misalnya menambah makna - tidak perlu lookup kedua.
  String? get wordId {
    if (contribution.entityType == 'word') return contribution.entityId;
    final raw = entity['wordId'];
    if (raw == null) return null;
    final id = raw.toString().trim();
    return id.isEmpty ? null : id;
  }

  String? get wordIdForUnverify {
    if (contribution.entityType == 'word') {
      return contribution.entityId;
    }
    return null;
  }

  String? get verifierUsername {
    final verifier = entity['verifier'];
    if (verifier is Map && verifier['username'] != null) {
      return verifier['username'].toString();
    }
    return null;
  }
}

class ReviewDecisionResult {
  const ReviewDecisionResult({
    required this.status,
    this.mergedIntoWordId,
    this.reopenedBy,
  });

  final String status;
  final String? mergedIntoWordId;
  final String? reopenedBy;
}
