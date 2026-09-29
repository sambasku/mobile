/// Jenis entri di feed Aktivitas terbaru (Analitik).
enum AnalyticsActivityKind { comment, vote, discussion, searchMiss }

/// Satu baris feed aktivitas campuran.
class AnalyticsActivityItem {
  const AnalyticsActivityItem({
    required this.kind,
    required this.id,
    required this.createdAt,
    required this.actorLabel,
    required this.body,
    this.actorUsername,
    this.avatarUrl,
    this.subtitle,
    this.navigatePath,
  });

  final AnalyticsActivityKind kind;
  final String id;

  /// ISO timestamp dari sumber (untuk sort).
  final String createdAt;

  /// Nama tampilan: display_name, username, atau "Warga" untuk anonim.
  final String actorLabel;

  /// Username mentah (untuk tap profil); null bila anonim / tidak ada.
  final String? actorUsername;

  /// URL avatar; null → placeholder inisial di [UserAvatar].
  final String? avatarUrl;

  /// Teks utama (body komentar, ringkasan vote, dsb.).
  final String body;

  /// Meta sekunder (lemma, target type, dsb.).
  final String? subtitle;

  /// Path go_router bila baris bisa diketuk; null = non-interaktif.
  final String? navigatePath;
}

/// Copy search-miss yang sudah ditayangkan di feed.
String searchMissActivityBody(String term) {
  final t = term.trim();
  final shown = t.isEmpty ? '…' : t;
  return 'mencari $shown tapi tidak terdapat. Bantu isi.';
}
