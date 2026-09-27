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

  bool get isPending => status == 'pending';

  /// Nama tampilan kontributor; fallback username lalu anonim.
  String get contributorLabel {
    final display = contributorDisplayName?.trim();
    if (display != null && display.isNotEmpty) return display;
    final handle = contributorUsername?.trim();
    if (handle != null && handle.isNotEmpty) return handle;
    return 'anonim';
  }

  String get title {
    final lemma = wordLemma?.trim();
    if (lemma != null && lemma.isNotEmpty) return lemma;
    return reviewFallbackTitle(entityType);
  }
}

String reviewFallbackTitle(String entityType) => switch (entityType) {
  'word' => 'Kata',
  'pronunciation' => 'Pelafalan',
  'word_image' => 'Gambar',
  'word_audio' => 'Audio',
  'example' => 'Contoh kalimat',
  'meaning' => 'Makna',
  _ => 'Usulan',
};

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

class ReviewDetail {
  const ReviewDetail({
    required this.contribution,
    required this.entity,
    this.reviewComment,
  });

  final ReviewItem contribution;
  final Map<String, dynamic> entity;
  final String? reviewComment;

  bool get wordAlreadyVerified =>
      contribution.entityType == 'word' && entity['isVerified'] == true;

  String? get verifierUsername {
    final verifier = entity['verifier'];
    if (verifier is Map && verifier['username'] != null) {
      return verifier['username'].toString();
    }
    return null;
  }
}

class ReviewDecisionResult {
  const ReviewDecisionResult({required this.status, this.mergedIntoWordId});

  final String status;
  final String? mergedIntoWordId;
}
