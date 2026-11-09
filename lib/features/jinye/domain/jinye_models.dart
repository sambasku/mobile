/// Wire Jinye (docs/api/56-api-jinye.md).
class JinyeImageRef {
  const JinyeImageRef({
    required this.url,
    required this.providerFileId,
  });

  final String url;
  final String providerFileId;

  Map<String, dynamic> toJson() => {
        'url': url,
        'provider_file_id': providerFileId,
      };
}

class JinyeUploadCredentials {
  const JinyeUploadCredentials({
    required this.token,
    required this.signature,
    required this.expire,
    required this.publicKey,
    required this.uploadEndpoint,
  });

  final String token;
  final String signature;
  final int expire;
  final String publicKey;
  final String uploadEndpoint;

  factory JinyeUploadCredentials.fromJson(Map<String, dynamic> json) {
    return JinyeUploadCredentials(
      token: json['token'] as String,
      signature: json['signature'] as String,
      expire: json['expire'] as int,
      publicKey: json['public_key'] as String,
      uploadEndpoint: json['upload_endpoint'] as String,
    );
  }
}

class JinyeImageUploadUnavailable implements Exception {
  const JinyeImageUploadUnavailable();
}

class JinyeFailure implements Exception {
  const JinyeFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

class JinyeImage {
  const JinyeImage({
    this.url,
    this.providerFileId,
    this.publicUrl,
    this.status = 'pending_review',
    this.contentWarnings = const [],
  });

  final String? url;
  final String? providerFileId;
  final String? publicUrl;
  final String status;
  final List<String> contentWarnings;

  /// URL yang bisa ditampilkan (publik atau staging owner).
  String? get displaySource {
    final pub = publicUrl?.trim();
    if (pub != null && pub.isNotEmpty) return pub;
    final staging = url?.trim();
    if (staging != null && staging.isNotEmpty) return staging;
    return null;
  }

  bool get isPending => status == 'pending_review' || publicUrl == null;

  factory JinyeImage.fromJson(Map<String, dynamic> json) {
    final warnings = json['content_warnings'];
    return JinyeImage(
      url: json['url'] as String?,
      providerFileId: json['provider_file_id'] as String?,
      publicUrl: json['public_url'] as String?,
      status: json['status'] as String? ?? 'pending_review',
      contentWarnings: warnings is List
          ? warnings.whereType<String>().toList()
          : const [],
    );
  }
}

class JinyeAudio {
  const JinyeAudio({
    required this.url,
    this.mimeType,
    this.durationMs,
  });

  final String url;
  final String? mimeType;
  final int? durationMs;

  factory JinyeAudio.fromJson(Map<String, dynamic> json) {
    return JinyeAudio(
      url: json['audio_url'] as String,
      mimeType: json['audio_mime_type'] as String?,
      durationMs: (json['audio_duration_ms'] as num?)?.toInt(),
    );
  }
}

class JinyeLemmaLink {
  const JinyeLemmaLink({
    required this.id,
    required this.start,
    required this.end,
    required this.wordId,
    required this.status,
    this.jinyeId,
    this.commentId,
    this.lemma,
    this.source = 'author',
    this.proposedWordId,
    this.proposedLemma,
    this.proposedBy,
  });

  final String id;
  final String? jinyeId;
  final String? commentId;
  final int start;
  final int end;
  final String wordId;
  final String? lemma;
  final String status;
  final String source;
  final String? proposedWordId;
  final String? proposedLemma;
  final String? proposedBy;

  bool get isPendingCorrection => status == 'pending_correction';

  factory JinyeLemmaLink.fromJson(Map<String, dynamic> json) {
    return JinyeLemmaLink(
      id: json['id'] as String,
      jinyeId: json['jinye_id'] as String?,
      commentId: json['comment_id'] as String?,
      start: (json['start'] as num).toInt(),
      end: (json['end'] as num).toInt(),
      wordId: json['word_id'] as String,
      lemma: json['lemma'] as String?,
      status: json['status'] as String? ?? 'active',
      source: json['source'] as String? ?? 'author',
      proposedWordId: json['proposed_word_id'] as String?,
      proposedLemma: json['proposed_lemma'] as String?,
      proposedBy: json['proposed_by'] as String?,
    );
  }
}

class JinyeTranslation {
  const JinyeTranslation({
    required this.id,
    required this.jinyeId,
    required this.bodyId,
    required this.status,
    required this.translatorId,
    this.reviewedBy,
    this.reviewedAt,
    this.createdAt,
  });

  final String id;
  final String jinyeId;
  final String bodyId;
  final String status;
  final String translatorId;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime? createdAt;

  bool get isAccepted => status == 'accepted';
  bool get isPending => status == 'pending';

  factory JinyeTranslation.fromJson(Map<String, dynamic> json) {
    return JinyeTranslation(
      id: json['id'] as String,
      jinyeId: json['jinye_id'] as String,
      bodyId: json['body_id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      translatorId: json['translator_id'] as String? ?? '',
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}

class JinyePromoteResult {
  const JinyePromoteResult({
    required this.exampleId,
    required this.status,
    required this.isVerified,
    this.wordAudioId,
  });

  final String exampleId;
  final String? wordAudioId;
  final String status;
  final bool isVerified;

  factory JinyePromoteResult.fromJson(Map<String, dynamic> json) {
    return JinyePromoteResult(
      exampleId: json['example_id'] as String,
      wordAudioId: json['word_audio_id'] as String?,
      status: json['status'] as String? ?? 'pending_review',
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}

class JinyeItem {
  const JinyeItem({
    required this.id,
    required this.userId,
    required this.body,
    required this.status,
    required this.createdAt,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.isVerifier = false,
    this.commentCount = 0,
    this.images = const [],
    this.audio,
    this.isPinned = false,
    this.lemmaLinks = const [],
  });

  final String id;
  final String userId;
  final String body;
  final String status;
  final DateTime createdAt;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final bool isVerifier;
  final int commentCount;
  final List<JinyeImage> images;
  final JinyeAudio? audio;
  final bool isPinned;
  final List<JinyeLemmaLink> lemmaLinks;

  bool get hasAudio => audio != null && audio!.url.isNotEmpty;

  bool get hasPendingImages => images.any((i) => i.isPending);

  bool get hasDisplayableImages =>
      images.any((i) => i.displaySource != null);

  factory JinyeItem.fromJson(Map<String, dynamic> json) {
    final imagesRaw = json['images'];
    final images = imagesRaw is List
        ? imagesRaw
            .whereType<Map>()
            .map((e) => JinyeImage.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : const <JinyeImage>[];

    final audioRaw = json['audio'];
    JinyeAudio? audio;
    if (audioRaw is Map &&
        audioRaw['audio_url'] is String &&
        (audioRaw['audio_url'] as String).isNotEmpty) {
      audio = JinyeAudio.fromJson(Map<String, dynamic>.from(audioRaw));
    }

    return JinyeItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      body: (json['body'] as String?) ?? '',
      status: json['status'] as String? ?? 'published',
      createdAt: DateTime.parse(json['created_at'] as String),
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isVerifier: json['is_verifier'] as bool? ?? false,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      images: images,
      audio: audio,
      isPinned: json['is_pinned'] as bool? ?? false,
      lemmaLinks: () {
        final raw = json['lemma_links'];
        if (raw is! List) return const <JinyeLemmaLink>[];
        return raw
            .whereType<Map>()
            .map((e) => JinyeLemmaLink.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }(),
    );
  }
}

class JinyePage {
  const JinyePage({required this.items, this.nextCursor});

  final List<JinyeItem> items;
  final String? nextCursor;
}

class JinyeComment {
  const JinyeComment({
    required this.id,
    required this.jinyeId,
    required this.body,
    required this.createdAt,
    this.parentId,
    this.userId,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.images = const [],
    this.replies = const [],
    this.upvotes = 0,
    this.downvotes = 0,
  });

  final String id;
  final String jinyeId;
  final String? parentId;
  final String body;
  final DateTime createdAt;
  final String? userId;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final List<JinyeImage> images;
  final List<JinyeComment> replies;
  final int upvotes;
  final int downvotes;

  factory JinyeComment.fromJson(Map<String, dynamic> json) {
    final imagesRaw = json['images'];
    final repliesRaw = json['replies'];
    return JinyeComment(
      id: json['id'] as String,
      jinyeId: json['jinye_id'] as String,
      parentId: json['parent_id'] as String?,
      body: (json['body'] as String?) ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String?,
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      images: imagesRaw is List
          ? imagesRaw
              .whereType<Map>()
              .map((e) => JinyeImage.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      replies: repliesRaw is List
          ? repliesRaw
              .whereType<Map>()
              .map((e) => JinyeComment.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
      downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Preview profil: max 32 karakter + elipsis (D21).
String jinyeProfilePreviewText(String body) {
  final t = body.trim();
  if (t.isEmpty) return '';
  if (t.length <= 32) return t;
  return '${t.substring(0, 32).trimRight()}...';
}
