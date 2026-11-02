class MyProfile {
  const MyProfile({
    required this.username,
    required this.displayName,
    this.bio,
    this.regionId,
    this.villageId,
    this.avatarUrl,
    this.hasReadContributionGuide = false,
    this.requiresConsent = false,
    this.notifyStreakReminder = true,
    this.notifyLevelUp = true,
  });

  final String username;
  final String displayName;
  final String? bio;
  final String? regionId;
  final String? villageId;
  final String? avatarUrl;

  /// Guide swipe di tab Kontribusi sudah ditandai baca di server.
  final bool hasReadContributionGuide;

  /// Server hitung dari user_consents vs versi aktif - dipakai app untuk
  /// memunculkan sheet persetujuan setiap launch sampai user setuju.
  final bool requiresConsent;

  /// Opt-in pengingat streak (cron).
  final bool notifyStreakReminder;

  /// Opt-in notifikasi naik level.
  final bool notifyLevelUp;
}
