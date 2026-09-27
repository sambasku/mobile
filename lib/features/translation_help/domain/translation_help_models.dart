// Model domain + wire mapping untuk Bantuan Terjemahan.

import '../../vote/domain/entities/vote_target.dart';

class TranslationHelpImageRef {
  const TranslationHelpImageRef({
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

class TranslationHelpUploadCredentials {
  const TranslationHelpUploadCredentials({
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

  factory TranslationHelpUploadCredentials.fromJson(Map<String, dynamic> json) {
    return TranslationHelpUploadCredentials(
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

class TranslationHelpSubmitResult {
  const TranslationHelpSubmitResult({
    required this.id,
    required this.status,
    required this.submittedAt,
  });

  final String id;
  final String status;
  final String submittedAt;

  factory TranslationHelpSubmitResult.fromJson(Map<String, dynamic> json) {
    return TranslationHelpSubmitResult(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'pending_review',
      submittedAt: json['submitted_at'] as String? ?? '',
    );
  }
}

class TranslationHelpImage {
  const TranslationHelpImage({
    this.url,
    this.providerFileId,
    this.publicUrl,
  });

  final String? url;
  final String? providerFileId;
  final String? publicUrl;

  /// URL terbaik untuk tampilan publik (GitHub/jsDelivr → displayImageUrl).
  String? get displaySource {
    final pub = publicUrl?.trim();
    if (pub != null && pub.isNotEmpty) return pub;
    final raw = url?.trim();
    if (raw != null && raw.isNotEmpty) return raw;
    return null;
  }

  factory TranslationHelpImage.fromJson(Map<String, dynamic> json) {
    return TranslationHelpImage(
      url: json['url']?.toString(),
      providerFileId: json['provider_file_id']?.toString(),
      publicUrl: json['public_url']?.toString(),
    );
  }
}

class TranslationHelpReply {
  const TranslationHelpReply({
    required this.id,
    required this.userId,
    required this.username,
    this.displayName,
    required this.body,
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
  final String? body;
  final String status;
  final bool isVerifier;
  final bool isPinned;
  final String createdAt;
  final int upvotes;
  final int downvotes;
  final int? myVote;

  VoteTarget get voteTarget =>
      VoteTarget(type: 'translation_help_reply', id: id);

  int get netScore => upvotes - downvotes;

  bool get isPublished => status == 'published';

  bool isOwner(String? userId) =>
      userId != null && userId.isNotEmpty && userId == this.userId;

  factory TranslationHelpReply.fromJson(Map<String, dynamic> json) {
    return TranslationHelpReply(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString(),
      displayName: json['display_name']?.toString(),
      body: json['body']?.toString(),
      status: json['status']?.toString() ?? 'published',
      isVerifier: json['is_verifier'] == true,
      isPinned: json['is_pinned'] == true,
      createdAt: json['created_at']?.toString() ?? '',
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
      downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
    );
  }

  TranslationHelpReply copyWith({
    int? upvotes,
    int? downvotes,
    Object? myVote = _unset,
  }) {
    return TranslationHelpReply(
      id: id,
      userId: userId,
      username: username,
      displayName: displayName,
      body: body,
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

class TranslationHelpItem {
  const TranslationHelpItem({
    required this.id,
    required this.userId,
    required this.username,
    this.displayName,
    required this.body,
    required this.images,
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
  final List<TranslationHelpImage> images;
  final String status;
  final String? pinnedReplyId;
  final String createdAt;
  final String? rejectionNote;
  final String? reviewedAt;
  final String? updatedAt;
  final List<TranslationHelpReply> replies;
  final int upvotes;
  final int? myVote;

  VoteTarget get voteTarget => VoteTarget(type: 'translation_help', id: id);

  bool get isPublished => status == 'published';

  String get statusLabel => switch (status) {
    'pending_review' => 'Menunggu pengecekan',
    'published' => 'Tayang',
    'rejected' => 'Ditolak',
    'taken_down' => 'Diturunkan',
    _ => status,
  };

  /// Balasan: pinned → net score desc → created_at desc (sinkron API).
  List<TranslationHelpReply> get orderedReplies {
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

  factory TranslationHelpItem.fromJson(Map<String, dynamic> json) {
    final imagesRaw = json['images'];
    final repliesRaw = json['replies'];
    return TranslationHelpItem(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString(),
      displayName: json['display_name']?.toString(),
      body: json['body']?.toString(),
      images: imagesRaw is List
          ? [
              for (final raw in imagesRaw.whereType<Map>())
                TranslationHelpImage.fromJson(Map<String, dynamic>.from(raw)),
            ]
          : const [],
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
                TranslationHelpReply.fromJson(Map<String, dynamic>.from(raw)),
            ]
          : const [],
    );
  }

  TranslationHelpItem copyWith({
    List<TranslationHelpReply>? replies,
    String? pinnedReplyId,
    int? upvotes,
    Object? myVote = _unset,
  }) {
    return TranslationHelpItem(
      id: id,
      userId: userId,
      username: username,
      displayName: displayName,
      body: body,
      images: images,
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

class TranslationHelpPage {
  const TranslationHelpPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<TranslationHelpItem> items;
  final String? nextCursor;
  final bool hasMore;
}

class TranslationHelpFailure implements Exception {
  const TranslationHelpFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  @override
  String toString() => message;
}
