/// Cover profil global dari API (`GET /about/profile-covers`).
class ProfileCovers {
  const ProfileCovers({
    this.tabUrl,
    this.publicUrl,
    this.wotdUrl,
    this.layananUrl,
  });

  final String? tabUrl;
  final String? publicUrl;
  final String? wotdUrl;
  final String? layananUrl;

  factory ProfileCovers.fromEnvelope(Map<String, dynamic> envelope) {
    final data = envelope['data'];
    if (data is! Map) return const ProfileCovers();
    final map = Map<String, dynamic>.from(data);
    String? read(String key) {
      final v = map[key];
      if (v is! String) return null;
      final t = v.trim();
      return t.isEmpty ? null : t;
    }

    return ProfileCovers(
      tabUrl: read('tab_url'),
      publicUrl: read('public_url'),
      wotdUrl: read('wotd_url'),
      layananUrl: read('layanan_url'),
    );
  }
}