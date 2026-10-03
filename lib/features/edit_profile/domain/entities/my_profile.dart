class MyProfile {
  const MyProfile({
    required this.username,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.hasReadContributionGuide = false,
  });

  final String username;
  final String displayName;
  final String? bio;
  final String? avatarUrl;

  /// Guide swipe di tab Kontribusi sudah ditandai baca di server.
  final bool hasReadContributionGuide;
}
