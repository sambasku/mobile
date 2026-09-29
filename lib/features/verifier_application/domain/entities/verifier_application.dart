class SocialScreenshot {
  const SocialScreenshot({required this.url, required this.providerFileId});

  final String url;
  final String providerFileId;
}

class SocialLink {
  const SocialLink({
    required this.platform,
    required this.username,
    required this.screenshot,
  });

  final String platform;
  final String username;
  final SocialScreenshot screenshot;
}

class VerifierApplication {
  const VerifierApplication({
    required this.id,
    required this.status,
    required this.phone,
    required this.address,
    required this.socialLinks,
    this.adminComment,
    this.reviewedAt,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String status;
  final String phone;
  final String address;
  final List<SocialLink> socialLinks;
  final String? adminComment;
  final String? reviewedAt;
  final String createdAt;
  final String? updatedAt;

  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get isApproved => status == 'approved';

  /// Rejected dengan catatan admin → copy "perlu perbaikan".
  bool get needsRevision =>
      isRejected && (adminComment?.trim().isNotEmpty ?? false);

  /// Rejected tanpa catatan → copy "ditolak, data kurang lengkap".
  bool get isHardRejected => isRejected && !needsRevision;
}
