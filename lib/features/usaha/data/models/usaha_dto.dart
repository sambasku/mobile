import '../../domain/entities/usaha.dart';

/// Parser wire API usaha (snake_case) -> domain.
///
/// Item rusak tidak mematikan koleksi: field wajib absen -> item di-skip.
class UsahaDto {
  const UsahaDto._();

  static Usaha? fromJson(Map<String, dynamic> json) {
    final id = _str(json['id']);
    final slug = _str(json['slug']);
    final name = _str(json['name']);
    if (id == null || slug == null || name == null) return null;
    return Usaha(
      id: id,
      slug: slug,
      name: name,
      description: _str(json['description']),
      categoryId: _str(json['category_id']),
      category: _categoryRef(json['category']),
      kind: _kind(json['kind']),
      regionId: _str(json['region_id']),
      villageId: _str(json['village_id']),
      village: _villageRef(json['village']),
      addressText: _str(json['address_text']),
      lat: _double(json['lat']),
      lng: _double(json['lng']),
      mapsUrl: _str(json['maps_url']),
      phone: _str(json['phone']),
      whatsapp: _str(json['whatsapp']),
      website: _str(json['website']),
      socialUrl: _str(json['social_url']),
      coverUrl: _str(json['cover_url']),
      publishStatus: _publishStatus(json['publish_status']),
      operationalStatus: _operational(json['operational_status']),
      restrictedReason: _str(json['restricted_reason']),
      managerId: _str(json['manager_id']),
      pendingChanges: _int(json['pending_changes']) ?? 0,
      items: _items(json['items']),
    );
  }

  static List<Usaha> listFromJson(List<dynamic> raw) => [
    for (final item in raw.whereType<Map>())
      ?fromJson(Map<String, dynamic>.from(item)),
  ];

  static List<UsahaItem> _items(Object? raw) {
    if (raw is! List) return const [];
    final out = <UsahaItem>[];
    for (final item in raw.whereType<Map>()) {
      final json = Map<String, dynamic>.from(item);
      final id = _str(json['id']);
      final name = _str(json['name']);
      if (id == null || name == null) continue;
      out.add(
        UsahaItem(
          id: id,
          name: name,
          description: _str(json['description']),
          priceText: _str(json['price_text']),
          imageUrl: _str(json['image_url']),
          sortOrder: _int(json['sort_order']) ?? 0,
        ),
      );
    }
    return out;
  }

  static UsahaCategoryRef? _categoryRef(Object? raw) {
    if (raw is! Map) return null;
    final id = _str(raw['id']);
    final name = _str(raw['name']);
    if (id == null || name == null) return null;
    return UsahaCategoryRef(id: id, name: name);
  }

  static UsahaVillageRef? _villageRef(Object? raw) {
    if (raw is! Map) return null;
    final id = _str(raw['id']);
    final name = _str(raw['name']);
    if (id == null || name == null) return null;
    return UsahaVillageRef(id: id, name: name, slug: _str(raw['slug']));
  }

  static UsahaKind _kind(Object? raw) => switch (raw) {
    'service' => UsahaKind.service,
    'both' => UsahaKind.both,
    _ => UsahaKind.product,
  };

  static UsahaPublishStatus _publishStatus(Object? raw) => switch (raw) {
    'draft' => UsahaPublishStatus.draft,
    'archived' => UsahaPublishStatus.archived,
    'restricted' => UsahaPublishStatus.restricted,
    _ => UsahaPublishStatus.published,
  };

  static UsahaOperationalStatus _operational(Object? raw) => switch (raw) {
    'open' => UsahaOperationalStatus.open,
    'temporarily_closed' => UsahaOperationalStatus.temporarilyClosed,
    'permanently_closed' => UsahaOperationalStatus.permanentlyClosed,
    _ => UsahaOperationalStatus.unknown,
  };
}

/// Parser pengajuan (usulan baru + pengajuan pengelola).
class UsahaContributionDto {
  const UsahaContributionDto._();

  static UsahaContribution? fromJson(Map<String, dynamic> json) {
    final id = _str(json['id']);
    final createdAt = DateTime.tryParse('${json['created_at'] ?? ''}');
    if (id == null || createdAt == null) return null;

    final payload = json['payload'];
    final payloadName = payload is Map ? _str(payload['name']) : null;
    final status = _status(json['status']);
    final rejectCode = _str(json['reject_reason_code']);
    final rejectText = _str(json['reject_reason_text']);

    return UsahaContribution(
      id: id,
      kind: _kind(json['kind']),
      status: status,
      createdAt: createdAt,
      usahaId: _str(json['usaha_id']),
      usahaSlug: _str(json['usaha_slug']),
      usahaName: _str(json['usaha_name']),
      name: payloadName ?? _str(json['usaha_name']),
      revisionNote: _str(json['revision_note']),
      rejectReasonCode: rejectCode,
      rejectReasonText: rejectText,
      wantsClaim: json['wants_claim'] == true,
    );
  }

  static UsahaContributionStatus _status(Object? raw) => switch (raw) {
    'needs_revision' => UsahaContributionStatus.needsRevision,
    'approved' => UsahaContributionStatus.approved,
    'rejected' => UsahaContributionStatus.rejected,
    _ => UsahaContributionStatus.pending,
  };

  /// `new` reserved word di Dart -> `baru`.
  static UsahaContributionKind _kind(Object? raw) => switch (raw) {
    'profile' => UsahaContributionKind.profile,
    'item_add' => UsahaContributionKind.itemAdd,
    'item_edit' => UsahaContributionKind.itemEdit,
    'item_delete' => UsahaContributionKind.itemDelete,
    'operational' => UsahaContributionKind.operational,
    'archive' => UsahaContributionKind.archive,
    'restore' => UsahaContributionKind.restore,
    _ => UsahaContributionKind.baru,
  };
}

/// Parser klaim pengelolaan milik user.
class UsahaClaimDto {
  const UsahaClaimDto._();

  static UsahaClaim? fromJson(Map<String, dynamic> json) {
    final id = _str(json['id']);
    final usahaId = _str(json['usaha_id']);
    final createdAt = DateTime.tryParse('${json['created_at'] ?? ''}');
    if (id == null || usahaId == null || createdAt == null) return null;
    final status = _claimStatus(json['status']);
    return UsahaClaim(
      id: id,
      usahaId: usahaId,
      usahaSlug: _str(json['usaha_slug']),
      usahaName: _str(json['usaha_name']),
      status: status,
      rejectReasonCode: _str(json['reject_reason_code']),
      rejectReasonText: _str(json['reject_reason_text']),
      createdAt: createdAt,
    );
  }

  static UsahaClaimStatus _claimStatus(Object? raw) => switch (raw) {
    'approved' => UsahaClaimStatus.approved,
    'rejected' => UsahaClaimStatus.rejected,
    'cancelled' => UsahaClaimStatus.cancelled,
    _ => UsahaClaimStatus.pending,
  };
}

String? _str(Object? value) {
  if (value == null) return null;
  final text = '$value'.trim();
  return text.isEmpty ? null : text;
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}');
}

double? _double(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? ''}');
}
