/// Satu tempat/penjual kuliner dari `/api/v1/culinary/places`.
///
/// Field sengaja tipis: mobile hanya butuh identitas + status buka untuk
/// daftar, detail mendalam tetap di web.
class CulinaryPlace {
  const CulinaryPlace({
    required this.id,
    required this.slug,
    required this.name,
    this.type,
    this.description,
    this.locationHint,
    this.addressText,
    this.coverUrl,
    this.operationalStatus = 'unknown',
  });

  final String id;
  final String slug;
  final String name;

  /// `restaurant` | `warung` | ... | `other`, null bila tak diisi.
  final String? type;
  final String? description;
  final String? locationHint;
  final String? addressText;
  final String? coverUrl;

  /// `unknown` | `operating` | `temporarily_closed` | `permanently_closed`.
  final String operationalStatus;

  /// Null bila field wajib absen → item di-skip.
  static CulinaryPlace? fromJson(Map<String, dynamic> json) {
    String? str(Object? key) {
      final v = json[key];
      return v is String && v.trim().isNotEmpty ? v.trim() : null;
    }

    final id = str('id');
    final slug = str('slug');
    final name = str('name');
    if (id == null || slug == null || name == null) return null;
    final cover = str('cover_url');
    return CulinaryPlace(
      id: id,
      slug: slug,
      name: name,
      type: str('type'),
      description: str('description'),
      locationHint: str('location_hint'),
      addressText: str('address_text'),
      // Hanya https yang dipakai - cegah render URL aneh dari data.
      coverUrl: cover != null && cover.startsWith('https://') ? cover : null,
      operationalStatus: str('operational_status') ?? 'unknown',
    );
  }
}

/// Label status operasional untuk UI.
String culinaryOperationalLabel(String status) => switch (status) {
  'operating' => 'Buka',
  'temporarily_closed' => 'Tutup sementara',
  'permanently_closed' => 'Tutup permanen',
  _ => 'Belum diketahui',
};
