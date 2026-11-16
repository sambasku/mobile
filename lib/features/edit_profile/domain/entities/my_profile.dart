import '../../../../core/models/speaker_status.dart';

class MyProfile {
  const MyProfile({
    required this.username,
    required this.displayName,
    this.bio,
    this.speakerStatus,
    this.regionId,
    this.villageId,
    this.avatarUrl,
    this.hasReadContributionGuide = false,
    this.requiresConsent = false,
    this.notifyStreakReminder = true,
    this.notifyLevelUp = true,
    this.usernameChangedAt,
    this.usernameChangeAllowedAt,
    this.usernameChangeCooldownDays = 7,
  });

  final String username;
  final String displayName;
  final String? bio;
  final SpeakerStatus? speakerStatus;
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

  /// Terakhir ganti ke username baru (bukan reclaim).
  final DateTime? usernameChangedAt;

  /// Null = boleh ganti username sekarang (#257).
  final DateTime? usernameChangeAllowedAt;

  final int usernameChangeCooldownDays;

  bool get isUsernameLocked {
    final at = usernameChangeAllowedAt;
    if (at == null) return false;
    return at.isAfter(DateTime.now());
  }
}
