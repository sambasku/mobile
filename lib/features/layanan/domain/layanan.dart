class LayananPhone {
  const LayananPhone({
    required this.phone,
    this.note,
    this.whatsapp,
  });

  final String phone;
  final String? note;
  final String? whatsapp;
}

class LayananEntry {
  const LayananEntry({
    required this.id,
    required this.slug,
    required this.category,
    required this.name,
    required this.phones,
    required this.regionId,
    required this.updatedAt,
    this.logoUrl,
    this.addressText,
    this.lat,
    this.lng,
    this.mapsUrl,
    this.regionName,
    this.regionSlug,
    this.villageName,
    this.note,
  });

  final String id;
  final String slug;
  final String category;
  final String name;
  final List<LayananPhone> phones;
  final String? logoUrl;
  final String? addressText;
  final double? lat;
  final double? lng;
  final String? mapsUrl;
  final String regionId;
  final String? regionName;
  final String? regionSlug;
  final String? villageName;
  final String? note;
  final DateTime updatedAt;

  bool get isAmbulance => category == 'ambulance';

  LayananPhone? get primaryPhone => phones.isEmpty ? null : phones.first;
}

class LayananProposal {
  const LayananProposal({
    required this.id,
    required this.kind,
    required this.status,
    required this.name,
    required this.phones,
    this.revisionNote,
  });

  final String id;
  final String kind;
  final String status;
  final String name;
  final List<LayananPhone> phones;
  final String? revisionNote;
}
