import '../../../../core/models/image_attribution.dart';
import '../../domain/entities/event_image.dart';

/// Wire DTO untuk `GET /events/:slug/images` dan `POST /events/:slug/images`.
class EventImageDto {
  const EventImageDto({required this.id, required this.url, this.attribution});

  final String id;
  final String url;
  final ImageAttribution? attribution;

  factory EventImageDto.fromJson(Map<String, dynamic> json) {
    final url = json['url'];
    if (url is! String || !url.startsWith('https://')) {
      throw FormatException('Invalid image url');
    }
    return EventImageDto(
      id: (json['id'] as String?) ?? '',
      url: url,
      attribution: ImageAttribution.fromJson(json['attribution']),
    );
  }

  EventImage toEntity() => EventImage(
        id: id,
        url: url,
        attribution: attribution,
      );
}

/// Halaman galeri (`items`, `total`, `next_offset`).
class EventImagePageDto {
  const EventImagePageDto({
    required this.items,
    required this.total,
    this.nextOffset,
  });

  final List<EventImageDto> items;
  final int total;
  final int? nextOffset;

  factory EventImagePageDto.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];
    final items = [for (final raw in rawItems) EventImageDto.fromJson(raw)];
    final total = (json['total'] as num?)?.toInt() ?? 0;
    final nextOffset = (json['next_offset'] as num?)?.toInt();

    return EventImagePageDto(
      items: items,
      total: total,
      nextOffset: nextOffset,
    );
  }

  EventImagePage toEntity() {
    final entities = [for (final dto in items) dto.toEntity()];
    final int? next = nextOffset;
    return (items: entities, total: total, nextOffset: next);
  }
}