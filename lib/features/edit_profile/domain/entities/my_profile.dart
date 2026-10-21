class MyProfile {
  const MyProfile({
    required this.username,
    required this.displayName,
    this.bio,
    this.regionId,
    this.villageId,
    this.avatarUrl,
    this.hasReadContributionGuide = false,
  });

  final String username;
  final String displayName;
  final String? bio;
  final String? regionId;
  final String? villageId;
  final String? avatarUrl;

  /// Guide swipe di tab Kontribusi sudah ditandai baca di server.
  final bool hasReadContributionGuide;
}
