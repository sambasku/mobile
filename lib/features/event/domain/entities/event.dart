import 'package:flutter/foundation.dart';

/// Status penyimpanan acara (cuma untuk admin, publik cuma published).
enum EventStatus { draft, published, archived }

/// Status pelaksanaan - DITURUNKAN read-time oleh API dari jadwal +
/// pembatalan. Tidak disimpan di DB.
enum EventOccurrenceStatus { upcoming, ongoing, completed, cancelled }

/// Platform sumber konten. Dipakai untuk badge di UI + triase admin.
enum EventSourceType {
  facebook,
  instagram,
  website,
  tiktok,
  youtube,
  whatsapp,
  other,
}

/// Kategori acara (id = slug `event_categories`).
class EventCategoryRef {
  const EventCategoryRef({required this.id, required this.name});

  final String id;
  final String name;
}

/// Desa terkait (single FK ke `regions`).
class EventVillageRef {
  const EventVillageRef({required this.id, required this.name, this.slug});

  final String id;
  final String name;
  final String? slug;
}

/// Tempat wisata terkait (junction `event_places`).
class EventPlaceRef {
  const EventPlaceRef({
    required this.id,
    required this.slug,
    required this.name,
    this.category,
  });

  final String id;
  final String slug;
  final String name;
  final String? category;
}

/// Satu acara di katalog SambasKu.
@immutable
class Event {
  const Event({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.startsAt,
    required this.endsAt,
    required this.occurrenceStatus,
    required this.locationText,
    required this.status,
    this.category,
    this.lat,
    this.lng,
    this.mapsUrl,
    this.posterUrls = const [],
    this.organizer,
    this.sourceUrl,
    this.sourceType,
    this.sourceAttribution,
    this.regionId,
    this.villageId,
    this.village,
    this.places = const [],
    this.cancelledAt,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String slug;
  final String name;
  final String description;
  final String categoryId;
  final EventCategoryRef? category;

  final DateTime startsAt;
  final DateTime endsAt;
  final EventOccurrenceStatus occurrenceStatus;

  /// Lokasi aktual acara. Wajib - independen dari relasi desa/wisata.
  final String locationText;

  final double? lat;
  final double? lng;
  final String? mapsUrl;

  /// Poster acara (bisa banyak). [0] = sampul.
  final List<String> posterUrls;

  /// Penyelenggara opsional - kalau null, UI skip labelnya (PRD 6.2).
  final String? organizer;

  /// Link original konten. Disimpan BERSIH tanpa UTM (helper UTM saat tap).
  final String? sourceUrl;
  final EventSourceType? sourceType;

  /// Kredit/nama akun penerbit, mis. "Panitia Pawai Blocks Keywords 2026".
  final String? sourceAttribution;

  final String? regionId;
  final String? villageId;
  final EventVillageRef? village;
  final List<EventPlaceRef> places;

  final EventStatus status;
  final DateTime? cancelledAt;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasCoordinates => lat != null && lng != null;

  /// Ada link sumber yang bisa dibuka.
  bool get hasSource => sourceUrl != null && sourceUrl!.isNotEmpty;

  /// Status pelaksanaan - API sudah menurunkan, tapi tetap dijaga di sisi
  /// client biar UI tidak stale kalau data lama di-cache.
  EventOccurrenceStatus get effectiveOccurrenceStatus {
    if (cancelledAt != null) return EventOccurrenceStatus.cancelled;
    final now = DateTime.now();
    if (now.isBefore(startsAt)) return EventOccurrenceStatus.upcoming;
    if (now.isAfter(endsAt)) return EventOccurrenceStatus.completed;
    return EventOccurrenceStatus.ongoing;
  }
}

/// Label status pelaksanaan untuk UI.
String eventOccurrenceLabel(EventOccurrenceStatus status) => switch (status) {
  EventOccurrenceStatus.upcoming => 'Akan datang',
  EventOccurrenceStatus.ongoing => 'Sedang berlangsung',
  EventOccurrenceStatus.completed => 'Sudah selesai',
  EventOccurrenceStatus.cancelled => 'Dibatalkan',
};

/// Label platform sumber. Null kalau `sourceType` kosong - UI skip badge.
String? eventSourceTypeLabel(EventSourceType? type) => switch (type) {
  EventSourceType.facebook => 'Facebook',
  EventSourceType.instagram => 'Instagram',
  EventSourceType.website => 'Website',
  EventSourceType.tiktok => 'TikTok',
  EventSourceType.youtube => 'YouTube',
  EventSourceType.whatsapp => 'WhatsApp',
  EventSourceType.other => 'Lainnya',
  null => null,
};
