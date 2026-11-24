/// Entitas organisasi komunitas di Kabupaten Sambas.
class CommunityOrg {
  const CommunityOrg({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.slug = '',
    this.logoUrl,
    this.coverUrl,
    this.location,
    this.contactUrl,
    this.isVerified = false,
    this.featuredKind,
  });

  final String id;
  final String slug;
  final String name;

  /// Nilai: 'seni' | 'bahasa' | 'pendidikan' | 'ukm' | 'lain'
  final String category;

  final String description;

  /// null = tampilkan avatar inisial.
  final String? logoUrl;
  final String? coverUrl;
  final String? location;

  /// Link eksternal (WA / IG / FB / web). null = tombol disembunyikan.
  final String? contactUrl;

  final bool isVerified;
  final String? featuredKind;

  /// Warna avatar inisial berdasarkan hash nama.
  int get avatarColorIndex => name.hashCode.abs();
}

class CommunityOrgPage {
  const CommunityOrgPage({required this.items, this.nextCursor});

  final List<CommunityOrg> items;
  final String? nextCursor;
}

class CommunityProposal {
  const CommunityProposal({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    this.logoUrl,
    this.reviewNote,
    this.communityOrgId,
  });

  final String id;
  final String name;
  final String description;
  final String status;
  final String createdAt;
  final String? logoUrl;
  final String? reviewNote;
  final String? communityOrgId;

  bool get canCancel => status == 'pending';
}

/// Kategori filter untuk halaman komunitas.
enum CommunityCategory {
  semua,
  seni,
  bahasa,
  pendidikan,
  ukm,
  lain;

  String get id => switch (this) {
    semua => 'semua',
    seni => 'seni',
    bahasa => 'bahasa',
    pendidikan => 'pendidikan',
    ukm => 'ukm',
    lain => 'lain',
  };

  static CommunityCategory fromId(String id) => switch (id) {
    'seni' => seni,
    'bahasa' => bahasa,
    'pendidikan' => pendidikan,
    'ukm' => ukm,
    'lain' => lain,
    _ => semua,
  };
}
