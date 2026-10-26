import 'package:flutter/foundation.dart';

/// Error fitur usaha - pesan siap tampil ke user.
class UsahaException implements Exception {
  const UsahaException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Status publikasi (dimensi moderasi).
enum UsahaPublishStatus { draft, published, archived, restricted }

/// Status operasional (dimensi info buka/tutup) - TERPISAH dari publikasi.
enum UsahaOperationalStatus {
  unknown,
  open,
  temporarilyClosed,
  permanentlyClosed,
}

enum UsahaKind { product, service, both }

class UsahaCategoryRef {
  const UsahaCategoryRef({required this.id, required this.name});

  final String id;
  final String name;
}

class UsahaVillageRef {
  const UsahaVillageRef({required this.id, required this.name, this.slug});

  final String id;
  final String name;
  final String? slug;
}

/// Satu item katalog (produk/jasa yang dijual).
@immutable
class UsahaItem {
  const UsahaItem({
    required this.id,
    required this.name,
    this.description,
    this.priceText,
    this.imageUrl,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String? description;

  /// Teks bebas - kosong berarti belum dicantumkan, BUKAN gratis.
  final String? priceText;
  final String? imageUrl;
  final int sortOrder;
}

/// Usaha/jasa lokal di katalog SambasKu.
@immutable
class Usaha {
  const Usaha({
    required this.id,
    required this.slug,
    required this.name,
    required this.kind,
    required this.publishStatus,
    required this.operationalStatus,
    this.description,
    this.categoryId,
    this.category,
    this.regionId,
    this.villageId,
    this.village,
    this.addressText,
    this.lat,
    this.lng,
    this.mapsUrl,
    this.phone,
    this.whatsapp,
    this.website,
    this.socialUrl,
    this.coverUrl,
    this.restrictedReason,
    this.managerId,
    this.pendingChanges = 0,
    this.items = const [],
  });

  final String id;
  final String slug;
  final String name;
  final String? description;
  final String? categoryId;
  final UsahaCategoryRef? category;
  final UsahaKind kind;
  final String? regionId;
  final String? villageId;
  final UsahaVillageRef? village;
  final String? addressText;
  final double? lat;
  final double? lng;
  final String? mapsUrl;
  final String? phone;
  final String? whatsapp;
  final String? website;
  final String? socialUrl;
  final String? coverUrl;
  final UsahaPublishStatus publishStatus;
  final UsahaOperationalStatus operationalStatus;
  final String? restrictedReason;
  final String? managerId;

  /// Hanya terisi di `GET /usaha/mine` - pengajuan perubahan pending.
  final int pendingChanges;

  final List<UsahaItem> items;

  bool get hasCoordinates => lat != null && lng != null;

  bool get hasContact =>
      _filled(phone) || _filled(whatsapp) || _filled(website) || _filled(socialUrl);

  bool get isManaged => managerId != null && managerId!.isNotEmpty;
}

bool _filled(String? value) => value != null && value.trim().isNotEmpty;

/// Satu halaman daftar usaha.
class UsahaPage {
  const UsahaPage({required this.items, required this.nextCursor});

  final List<Usaha> items;
  final String? nextCursor;
}

/// Ringkasan Usaha Saya + jumlah klaim pending.
class UsahaMine {
  const UsahaMine({required this.items, required this.pendingClaimCount});

  final List<Usaha> items;
  final int pendingClaimCount;
}

enum UsahaContributionStatus { pending, needsRevision, approved, rejected }

enum UsahaContributionKind {
  baru,
  profile,
  itemAdd,
  itemEdit,
  itemDelete,
  operational,
  archive,
  restore,
}

/// Usulan/pengajuan usaha milik user.
@immutable
class UsahaContribution {
  const UsahaContribution({
    required this.id,
    required this.kind,
    required this.status,
    required this.createdAt,
    this.usahaId,
    this.usahaSlug,
    this.usahaName,
    this.name,
    this.revisionNote,
    this.rejectReason,
    this.wantsClaim = false,
  });

  final String id;
  final UsahaContributionKind kind;
  final UsahaContributionStatus status;

  /// Nama usaha yang diajukan (kind=new) atau yang diubah.
  final String? name;
  final String? usahaId;
  final String? usahaSlug;
  final String? usahaName;
  final String? revisionNote;
  final String? rejectReason;
  final bool wantsClaim;
  final DateTime createdAt;

  bool get isPending => status == UsahaContributionStatus.pending;

  bool get needsRevision =>
      status == UsahaContributionStatus.needsRevision;

  bool get canCancel => isPending || needsRevision;
}

enum UsahaClaimStatus { pending, approved, rejected, cancelled }

/// Klaim pengelolaan milik user (wire publik - tanpa bukti kontak).
@immutable
class UsahaClaim {
  const UsahaClaim({
    required this.id,
    required this.usahaId,
    required this.status,
    required this.createdAt,
    this.usahaSlug,
    this.usahaName,
    this.rejectReason,
  });

  final String id;
  final String usahaId;
  final String? usahaSlug;
  final String? usahaName;
  final UsahaClaimStatus status;
  final String? rejectReason;
  final DateTime createdAt;
}

/// Draft usulan usaha baru. Minimum: nama + kecamatan.
class UsahaContributionDraft {
  const UsahaContributionDraft({
    required this.name,
    required this.regionId,
    this.description,
    this.categoryId,
    this.kind,
    this.villageId,
    this.addressText,
    this.lat,
    this.lng,
    this.phone,
    this.whatsapp,
    this.website,
    this.socialUrl,
    this.coverUrl,
    this.wantsClaim = false,
  });

  final String name;
  final String regionId;
  final String? description;
  final String? categoryId;
  final UsahaKind? kind;
  final String? villageId;
  final String? addressText;
  final double? lat;
  final double? lng;
  final String? phone;
  final String? whatsapp;
  final String? website;
  final String? socialUrl;
  final String? coverUrl;
  final bool wantsClaim;

  Map<String, dynamic> toBody() => {
    'name': name,
    'region_id': regionId,
    if (_filled(description)) 'description': description,
    if (_filled(categoryId)) 'category_id': categoryId,
    if (kind != null) 'kind': kind!.name,
    if (_filled(villageId)) 'village_id': villageId,
    if (_filled(addressText)) 'address_text': addressText,
    if (lat != null && lng != null) ...{'lat': lat, 'lng': lng},
    if (_filled(phone)) 'phone': phone,
    if (_filled(whatsapp)) 'whatsapp': whatsapp,
    if (_filled(website)) 'website': website,
    if (_filled(socialUrl)) 'social_url': socialUrl,
    if (_filled(coverUrl)) 'cover_url': coverUrl,
    'wants_claim': wantsClaim,
  };
}

/// Label status publikasi.
String usahaPublishLabel(UsahaPublishStatus status) => switch (status) {
  UsahaPublishStatus.draft => 'Draft',
  UsahaPublishStatus.published => 'Tayang',
  UsahaPublishStatus.archived => 'Diarsipkan',
  UsahaPublishStatus.restricted => 'Dibatasi',
};

/// Label status operasional.
String usahaOperationalLabel(UsahaOperationalStatus status) =>
    switch (status) {
      UsahaOperationalStatus.unknown => 'Belum ada info buka',
      UsahaOperationalStatus.open => 'Buka',
      UsahaOperationalStatus.temporarilyClosed => 'Tutup sementara',
      UsahaOperationalStatus.permanentlyClosed => 'Tutup permanen',
    };

/// Label jenis usaha.
String usahaKindLabel(UsahaKind kind) => switch (kind) {
  UsahaKind.product => 'Produk',
  UsahaKind.service => 'Jasa',
  UsahaKind.both => 'Produk dan jasa',
};

/// Label status pengajuan usaha.
String usahaContributionStatusLabel(UsahaContributionStatus status) =>
    switch (status) {
      UsahaContributionStatus.approved => 'Disetujui',
      UsahaContributionStatus.rejected => 'Ditolak',
      UsahaContributionStatus.needsRevision => 'Perlu revisi',
      UsahaContributionStatus.pending => 'Menunggu',
    };

/// Label jenis pengajuan usaha.
String usahaContributionKindLabel(UsahaContributionKind kind) => switch (kind) {
  UsahaContributionKind.baru => 'Usulan baru',
  UsahaContributionKind.profile => 'Perubahan profil',
  UsahaContributionKind.itemAdd => 'Tambah item',
  UsahaContributionKind.itemEdit => 'Ubah item',
  UsahaContributionKind.itemDelete => 'Hapus item',
  UsahaContributionKind.operational => 'Status buka',
  UsahaContributionKind.archive => 'Minta arsip',
  UsahaContributionKind.restore => 'Minta tayang',
};

/// Alasan laporan masyarakat (kode wire + label tampil).
const Map<String, String> usahaReportReasonLabel = {
  'closed': 'Usaha sudah tutup',
  'wrong_location': 'Lokasi salah',
  'invalid_contact': 'Kontak tidak valid',
  'misleading': 'Info menyesatkan',
  'duplicate': 'Duplikat',
  'abuse': 'Penyalahgunaan',
};
