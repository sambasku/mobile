// Model domain + wire mapping untuk Ruang Diskusi.

import '../../vote/domain/entities/vote_target.dart';

class DiscussionImageRef {
  const DiscussionImageRef({
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

class DiscussionUploadCredentials {
  const DiscussionUploadCredentials({
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

  factory DiscussionUploadCredentials.fromJson(Map<String, dynamic> json) {
    return DiscussionUploadCredentials(
      token: json['token'] as String,
      signature: json['signature'] as String,
      expire: json['expire'] as int,
      publicKey: json['public_key'] as String,
      uploadEndpoint: json['upload_endpoint'] as String,
    );
  }
}

class ImageUploadUnavailable implements Exception {
  const ImageUploadUnavailable();
}

class DiscussionSubmitResult {
  const DiscussionSubmitResult({
    required this.id,
    required this.status,
    required this.submittedAt,
  });

  final String id;
  final String status;
  final String submittedAt;

  factory DiscussionSubmitResult.fromJson(Map<String, dynamic> json) {
    return DiscussionSubmitResult(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'pending_review',
      submittedAt: json['submitted_at'] as String? ?? '',
    );
  }
}

class DiscussionImage {
  const DiscussionImage({
    this.url,
    this.providerFileId,
    this.publicUrl,
    this.contentWarnings = const [],
  });

  final String? url;
  final String? providerFileId;
  final String? publicUrl;
  final List<String> contentWarnings;

  bool get hasViolenceWarning => contentWarnings.contains('kekerasan');

  /// URL terbaik untuk tampilan publik (GitHub/jsDelivr → displayImageUrl).
  String? get displaySource {
    final pub = publicUrl?.trim();
    if (pub != null && pub.isNotEmpty) return pub;
    final raw = url?.trim();
    if (raw != null && raw.isNotEmpty) return raw;
    return null;
  }

  factory DiscussionImage.fromJson(Map<String, dynamic> json) {
    final warningsRaw = json['content_warnings'];
    return DiscussionImage(
      url: json['url']?.toString(),
      providerFileId: json['provider_file_id']?.toString(),
      publicUrl: json['public_url']?.toString(),
      contentWarnings: warningsRaw is List
          ? [
              for (final w in warningsRaw)
                if (w != null) w.toString(),
            ]
          : const [],
    );
  }
}

class DiscussionReply {
  const DiscussionReply({
    required this.id,
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    required this.body,
    this.audioUrl,
    this.audioMimeType,
    this.audioDurationMs,
    required this.status,
    required this.isVerifier,
    required this.isPinned,
    required this.createdAt,
    this.upvotes = 0,
    this.downvotes = 0,
    this.myVote,
  });

  final String id;
  final String userId;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? body;
  final String? audioUrl;
  final String? audioMimeType;
  final int? audioDurationMs;
  final String status;
  final bool isVerifier;
  final bool isPinned;
  final String createdAt;
  final int upvotes;
  final int downvotes;
  final int? myVote;

  VoteTarget get voteTarget =>
      VoteTarget(type: 'discussion_reply', id: id);

  int get netScore => upvotes - downvotes;

  bool get isPublished => status == 'published';

  bool get hasAudio =>
      audioUrl != null && audioUrl!.trim().isNotEmpty;

  bool isOwner(String? userId) =>
      userId != null && userId.isNotEmpty && userId == this.userId;

  factory DiscussionReply.fromJson(Map<String, dynamic> json) {
    return DiscussionReply(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString(),
      displayName: json['display_name']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      body: json['body']?.toString(),
      audioUrl: json['audio_url']?.toString(),
      audioMimeType: json['audio_mime_type']?.toString(),
      audioDurationMs: (json['audio_duration_ms'] as num?)?.toInt(),
      status: json['status']?.toString() ?? 'published',
      isVerifier: json['is_verifier'] == true,
      isPinned: json['is_pinned'] == true,
      createdAt: json['created_at']?.toString() ?? '',
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
      downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
    );
  }

  DiscussionReply copyWith({
    int? upvotes,
    int? downvotes,
    Object? myVote = _unset,
  }) {
    return DiscussionReply(
      id: id,
      userId: userId,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      body: body,
      audioUrl: audioUrl,
      audioMimeType: audioMimeType,
      audioDurationMs: audioDurationMs,
      status: status,
      isVerifier: isVerifier,
      isPinned: isPinned,
      createdAt: createdAt,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      myVote: identical(myVote, _unset) ? this.myVote : myVote as int?,
    );
  }

  static const Object _unset = Object();
}

class DiscussionItem {
  const DiscussionItem({
    required this.id,
    required this.userId,
    required this.username,
    this.displayName,
    required this.body,
    this.linkUrl,
    required this.images,
    this.audioUrl,
    this.audioMimeType,
    this.audioDurationMs,
    required this.status,
    required this.pinnedReplyId,
    required this.createdAt,
    this.rejectionNote,
    this.reviewedAt,
    this.updatedAt,
    this.replies = const [],
    this.upvotes = 0,
    this.myVote,
  });

  final String id;
  final String userId;
  final String? username;
  final String? displayName;
  final String? body;
  final String? linkUrl;
  final List<DiscussionImage> images;
  final String? audioUrl;
  final String? audioMimeType;
  final int? audioDurationMs;
  final String status;
  final String? pinnedReplyId;
  final String createdAt;
  final String? rejectionNote;
  final String? reviewedAt;
  final String? updatedAt;
  final List<DiscussionReply> replies;
  final int upvotes;
  final int? myVote;

  VoteTarget get voteTarget => VoteTarget(type: 'discussion', id: id);

  bool get isPublished => status == 'published';

  bool get hasAudio =>
      audioUrl != null && audioUrl!.trim().isNotEmpty;

  String get statusLabel => switch (status) {
    'pending_review' => 'Menunggu pengecekan',
    'published' => 'Tayang',
    'rejected' => 'Ditolak',
    'taken_down' => 'Diturunkan',
    _ => status,
  };

  /// Balasan: pinned → net score desc → created_at desc (sinkron API).
  List<DiscussionReply> get orderedReplies {
    if (replies.isEmpty) return const [];
    final copy = [...replies];
    copy.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      final netCmp = b.netScore.compareTo(a.netScore);
      if (netCmp != 0) return netCmp;
      return b.createdAt.compareTo(a.createdAt);
    });
    return copy;
  }

  List<String> get imageDisplayUrls => [
    for (final img in images)
      if (img.displaySource != null) img.displaySource!,
  ];

  factory DiscussionItem.fromJson(Map<String, dynamic> json) {
    final imagesRaw = json['images'];
    final repliesRaw = json['replies'];
    return DiscussionItem(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString(),
      displayName: json['display_name']?.toString(),
      body: json['body']?.toString(),
      linkUrl: json['link_url']?.toString(),
      images: imagesRaw is List
          ? [
              for (final raw in imagesRaw.whereType<Map>())
                DiscussionImage.fromJson(Map<String, dynamic>.from(raw)),
            ]
          : const [],
      audioUrl: json['audio_url']?.toString(),
      audioMimeType: json['audio_mime_type']?.toString(),
      audioDurationMs: (json['audio_duration_ms'] as num?)?.toInt(),
      status: json['status']?.toString() ?? 'published',
      pinnedReplyId: json['pinned_reply_id']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      rejectionNote: json['rejection_note']?.toString(),
      reviewedAt: json['reviewed_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
      replies: repliesRaw is List
          ? [
              for (final raw in repliesRaw.whereType<Map>())
                DiscussionReply.fromJson(Map<String, dynamic>.from(raw)),
            ]
          : const [],
    );
  }

  DiscussionItem copyWith({
    List<DiscussionReply>? replies,
    String? pinnedReplyId,
    int? upvotes,
    Object? myVote = _unset,
  }) {
    return DiscussionItem(
      id: id,
      userId: userId,
      username: username,
      displayName: displayName,
      body: body,
      linkUrl: linkUrl,
      images: images,
      audioUrl: audioUrl,
      audioMimeType: audioMimeType,
      audioDurationMs: audioDurationMs,
      status: status,
      pinnedReplyId: pinnedReplyId ?? this.pinnedReplyId,
      createdAt: createdAt,
      rejectionNote: rejectionNote,
      reviewedAt: reviewedAt,
      updatedAt: updatedAt,
      replies: replies ?? this.replies,
      upvotes: upvotes ?? this.upvotes,
      myVote: identical(myVote, _unset) ? this.myVote : myVote as int?,
    );
  }

  static const Object _unset = Object();
}

class DiscussionPage {
  const DiscussionPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<DiscussionItem> items;
  final String? nextCursor;
  final bool hasMore;
}

class DiscussionFailure implements Exception {
  const DiscussionFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  @override
  String toString() => message;
}
