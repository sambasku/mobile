/// Model + pembanding versi untuk cek update app (issue mobile#196).
///
/// Versi mengikuti semver ringkas `x.y.z` (build `+N` opsional, diabaikan
/// saat compare). Bandingkan per segmen numerik, bukan string biasa
/// (`0.10.0` harus lebih baru dari `0.9.1`).
library;

class LatestRelease {
  const LatestRelease({
    required this.platform,
    required this.version,
    required this.storeUrl,
    this.notes,
  });

  final String platform;
  final String version;
  final Uri? storeUrl;
  final String? notes;

  factory LatestRelease.fromJson(Map<String, dynamic> json) {
    final storeUrl = json['store_url'] as String?;
    return LatestRelease(
      platform: json['platform'] as String? ?? '',
      version: json['version'] as String? ?? '',
      storeUrl: storeUrl == null || storeUrl.isEmpty ? null : Uri.tryParse(storeUrl),
      notes: json['notes'] as String?,
    );
  }
}

/// True jika [latest] lebih tinggi dari [current].
///
/// Segmen di belakang `+` (build number) diabaikan. Segmen non-numerik
/// diperlakukan 0 supaya tidak crash pada versi aneh dari server.
bool isNewerRelease(String latest, String current) {
  List<int> parse(String v) {
    final core = v.split('+').first;
    return core
        .split('.')
        .map((s) => int.tryParse(s.trim()) ?? 0)
        .toList();
  }

  final l = parse(latest);
  final c = parse(current);
  for (var i = 0; i < l.length || i < c.length; i++) {
    final li = i < l.length ? l[i] : 0;
    final ci = i < c.length ? c[i] : 0;
    if (li != ci) return li > ci;
  }
  return false;
}
