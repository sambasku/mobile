import '../../domain/entities/event.dart';
import '../../domain/entities/event_contribution.dart';

/// Parser usulan acara dari wire API (snake_case).
class EventContributionDto {
  const EventContributionDto._();

  static EventContribution? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) return null;

    final payload = json['payload'];
    final map = payload is Map ? payload : const {};
    final status = eventContributionStatusFromWire(
      json['status'] is String ? json['status'] as String : null,
    );
    if (status == null) return null;

    return EventContribution(
      id: id,
      name: _str(map['name']) ?? 'Usulan acara',
      status: status,
      eventId: _str(json['event_id']),
      categoryId: _str(map['category_id']),
      startsAt: DateTime.tryParse('${map['starts_at'] ?? ''}'),
      endsAt: DateTime.tryParse('${map['ends_at'] ?? ''}'),
      locationText: _str(map['location_text']),
      revisionNote: _str(json['revision_note']),
      rejectReason: _str(json['reject_reason_display']),
      createdAt:
          DateTime.tryParse('${json['created_at'] ?? ''}') ?? DateTime.now(),
    );
  }

  /// Katalog kategori acara (id = slug).
  static List<EventCategoryRef> categoriesFromJson(List<dynamic> items) {
    final out = <EventCategoryRef>[];
    for (final raw in items.whereType<Map>()) {
      final id = _str(raw['id']);
      final name = _str(raw['name']);
      if (id == null || name == null) continue;
      out.add(EventCategoryRef(id: id, name: name));
    }
    return out;
  }

  static String? _str(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}
