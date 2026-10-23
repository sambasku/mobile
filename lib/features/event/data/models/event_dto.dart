import '../../domain/entities/event.dart';

/// Parser event dari wire API (snake_case) ke domain (camelCase).
///
/// Satu item rusak tidak mematikan seluruh koleksi: field wajib absen →
/// item di-skip (null).
class EventDto {
  const EventDto._();

  static Event? fromJson(Map<String, dynamic> json) {
    final id = _str(json['id']);
    final slug = _str(json['slug']);
    final name = _str(json['name']);
    final categoryId = _str(json['category_id']);
    final startsAt = DateTime.tryParse('${json['starts_at'] ?? ''}');
    final endsAt = DateTime.tryParse('${json['ends_at'] ?? ''}');
    if (id == null ||
        slug == null ||
        name == null ||
        categoryId == null ||
        startsAt == null ||
        endsAt == null) {
      return null;
    }

    return Event(
      id: id,
      slug: slug,
      name: name,
      description: _str(json['description']) ?? '',
      categoryId: categoryId,
      category: _categoryRef(json['category']),
      startsAt: startsAt,
      endsAt: endsAt,
      occurrenceStatus: _occurrence(json['occurrence_status']),
      locationText: _str(json['location_text']) ?? '',
      lat: _double(json['lat']),
      lng: _double(json['lng']),
      mapsUrl: _str(json['maps_url']),
      posterUrl: _str(json['poster_url']),
      organizer: _str(json['organizer']),
      sourceUrl: _str(json['source_url']),
      sourceType: _sourceType(json['source_type']),
      sourceAttribution: _str(json['source_attribution']),
      regionId: _str(json['region_id']),
      villageId: _str(json['village_id']),
      village: _villageRef(json['village']),
      places: _places(json['places']),
      status: _status(json['status']),
      cancelledAt: DateTime.tryParse('${json['cancelled_at'] ?? ''}'),
      publishedAt: DateTime.tryParse('${json['published_at'] ?? ''}'),
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
      updatedAt: DateTime.tryParse('${json['updated_at'] ?? ''}'),
    );
  }

  static String? _str(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  static double? _double(Object? value) =>
      value is num ? value.toDouble() : null;

  static EventCategoryRef? _categoryRef(Object? raw) {
    if (raw is! Map) return null;
    final id = _str(raw['id']);
    final name = _str(raw['name']);
    if (id == null || name == null) return null;
    return EventCategoryRef(id: id, name: name);
  }

  static EventVillageRef? _villageRef(Object? raw) {
    if (raw is! Map) return null;
    final id = _str(raw['id']);
    final name = _str(raw['name']);
    if (id == null || name == null) return null;
    return EventVillageRef(id: id, name: name, slug: _str(raw['slug']));
  }

  static List<EventPlaceRef> _places(Object? raw) {
    if (raw is! List) return const [];
    final out = <EventPlaceRef>[];
    for (final item in raw.whereType<Map>()) {
      final id = _str(item['id']);
      final slug = _str(item['slug']);
      final name = _str(item['name']);
      if (id == null || slug == null || name == null) continue;
      out.add(
        EventPlaceRef(
          id: id,
          slug: slug,
          name: name,
          category: _str(item['category']),
        ),
      );
    }
    return out;
  }

  static EventOccurrenceStatus _occurrence(Object? raw) => switch (raw) {
    'ongoing' => EventOccurrenceStatus.ongoing,
    'completed' => EventOccurrenceStatus.completed,
    'cancelled' => EventOccurrenceStatus.cancelled,
    _ => EventOccurrenceStatus.upcoming,
  };

  static EventStatus _status(Object? raw) => switch (raw) {
    'draft' => EventStatus.draft,
    'archived' => EventStatus.archived,
    _ => EventStatus.published,
  };

  static EventSourceType? _sourceType(Object? raw) {
    if (raw is! String) return null;
    for (final type in EventSourceType.values) {
      if (type.name == raw) return type;
    }
    return null;
  }
}
