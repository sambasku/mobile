import 'package:flutter/foundation.dart';

import '../../../../core/models/image_attribution.dart';

/// Satu foto galeri acara (user-generated).
@immutable
class EventImage {
  const EventImage({required this.id, required this.url, this.attribution});

  final String id;
  final String url;

  /// Null = tanpa kredit.
  final ImageAttribution? attribution;
}

/// Response `GET /events/:slug/images` - halaman galeri (offset).
typedef EventImagePage = ({List<EventImage> items, int total, int? nextOffset});