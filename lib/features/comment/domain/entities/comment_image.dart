/// Foto komentar di wire publik (staging tidak diekspos).
class CommentImage {
  const CommentImage({
    required this.status,
    this.publicUrl,
    this.contentWarnings = const [],
  });

  /// pending_review | published | rejected
  final String status;

  /// Null saat pending_review; null di wire jika rejected (image null).
  final String? publicUrl;

  /// V1: 'kekerasan'
  final List<String> contentWarnings;

  bool get isPendingReview => status == 'pending_review';

  bool get isPublished => status == 'published';

  bool get hasViolenceWarning => contentWarnings.contains('kekerasan');

  bool get hasDisplayableUrl =>
      publicUrl != null && publicUrl!.trim().isNotEmpty;
}

/// Referensi staging ImageKit setelah direct-upload (create body).
class CommentImageStaging {
  const CommentImageStaging({
    required this.url,
    required this.providerFileId,
  });

  final String url;
  final String providerFileId;
}

/// Kredensial GET /api/v1/comments/upload-token.
class CommentUploadCredentials {
  const CommentUploadCredentials({
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

  factory CommentUploadCredentials.fromJson(Map<String, dynamic> json) {
    return CommentUploadCredentials(
      token: json['token'] as String,
      signature: json['signature'] as String,
      expire: json['expire'] as int,
      publicKey: json['public_key'] as String,
      uploadEndpoint: json['upload_endpoint'] as String,
    );
  }
}

class CommentImageUploadUnavailable implements Exception {
  const CommentImageUploadUnavailable();
}
