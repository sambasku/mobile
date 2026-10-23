import 'package:dio/dio.dart';

/// Ukuran halaman. Di bawah batas API (500) supaya sisa katalog
/// diambil lewat `before` / `next_cursor`, bukan satu permintaan raksasa.
const placesPageSize = 50;

/// Halaman daftar wisata/kuliner. Kelipatan 3 supaya grid tidak patah.
const placesBrowsePageSize = 24;

/// Pagar kalau server mengulang cursor. 50 x 40 = 2000 tempat.
const placesMaxPages = 40;

/// Satu halaman `GET /api/v1/places`.
class PlacesPage {
  const PlacesPage({required this.places, required this.nextCursor});

  final List<Map<String, dynamic>> places;
  final String? nextCursor;
}

/// Remote datasource katalog Place dari API publik.
///
/// Peta dan detail masih menggabungkan semua halaman. Daftar wisata/kuliner
/// memakai [fetchPage] supaya scroll memuat `next_cursor`, bukan katalog utuh.
class PlacesRemoteDatasource {
  PlacesRemoteDatasource(this._dio, {String? listPath})
    : _listPath = listPath ?? '/api/v1/places';

  final Dio _dio;
  final String _listPath;

  /// Satu halaman. `before` = `next_cursor` halaman sebelumnya.
  Future<Response<dynamic>> fetchRaw({
    int limit = placesPageSize,
    String? before,
    String? category,
    String? type,
    String? q,
  }) => _dio.get<dynamic>(
    _listPath,
    queryParameters: {
      'limit': limit,
      if (before != null && before.isNotEmpty) 'before': before,
      if (category != null && category.isNotEmpty) 'category': category,
      if (type != null && type.isNotEmpty) 'type': type,
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
    },
    options: Options(receiveTimeout: const Duration(seconds: 8)),
  );

  /// Satu halaman untuk daftar. Tidak mengikuti cursor berikutnya.
  Future<PlacesPage> fetchPage({
    int limit = placesBrowsePageSize,
    String? before,
    String? category,
    String? type,
    String? q,
  }) async {
    final body = (await fetchRaw(
      limit: limit,
      before: before,
      category: category,
      type: type,
      q: q,
    )).data;
    final rawPlaces = placesApiBodyToEnvelope(body)['places'];
    return PlacesPage(
      places: [
        for (final item in rawPlaces is List ? rawPlaces : const [])
          if (item is Map) Map<String, dynamic>.from(item),
      ],
      nextCursor: readPlacesNextCursor(body),
    );
  }

  /// Semua halaman, digabung jadi envelope `{ version, places }`.
  Future<Map<String, dynamic>> fetchCatalogEnvelope() => walkPlaceCursors(
    fetchPage: (before) async => (await fetchRaw(before: before)).data,
  );

  /// Catat view detail place (metrik popularitas). Server dedupe per
  /// pembaca per hari (user login > X-Device-Id), jadi panggil ulang aman.
  /// Fire-and-forget: error jaringan dilempar ke caller yang ignore.
  /// #187: satu halaman galeri foto tempat (`next_offset` null = habis).
  /// Galeri bisa >12 foto, sedangkan detail hanya membawa halaman pertama.
  Future<({List<Map<String, dynamic>> items, int total, int? nextOffset})>
  fetchImagePage(String slug, {int offset = 0}) async {
    final res = await _dio.get<dynamic>(
      '/api/v1/places/${Uri.encodeComponent(slug)}/images',
      queryParameters: {'offset': offset},
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );
    final body = res.data;
    final data = body is Map ? body['data'] : null;
    final items = data is Map ? data['items'] : null;
    return (
      items: [
        for (final raw in (items is List ? items : const []).whereType<Map>())
          _wirePlaceImageToCamel(Map<String, dynamic>.from(raw)),
      ],
      total: data is Map ? (data['total'] as num?)?.toInt() ?? 0 : 0,
      nextOffset: data is Map ? (data['next_offset'] as num?)?.toInt() : null,
    );
  }

  Future<void> recordView(String slug) async {
    await _dio.post<dynamic>(
      '/api/v1/places/${Uri.encodeComponent(slug)}/view',
      options: Options(sendTimeout: const Duration(seconds: 5)),
    );
  }
}

/// `next_cursor` halaman ini. Null = halaman terakhir.
String? readPlacesNextCursor(Object? body) {
  if (body is! Map) return null;
  final data = body['data'];
  if (data is! Map) return null;
  final cursor = data['next_cursor'];
  if (cursor is! String || cursor.trim().isEmpty) return null;
  return cursor;
}

/// Ikuti `next_cursor` sampai habis. Cursor yang berulang dihentikan.
Future<Map<String, dynamic>> walkPlaceCursors({
  required Future<Object?> Function(String? before) fetchPage,
  int maxPages = placesMaxPages,
}) async {
  final places = <dynamic>[];
  final seenIds = <String>{};
  final seenCursors = <String>{};
  String? before;
  for (var page = 0; page < maxPages; page++) {
    final body = await fetchPage(before);
    final items = placesApiBodyToEnvelope(body)['places'];
    if (items is List) {
      for (final item in items) {
        final id = item is Map ? item['id'] : null;
        if (id is String && !seenIds.add(id)) continue;
        places.add(item);
      }
    }
    final next = readPlacesNextCursor(body);
    final count = items is List ? items.length : 0;
    if (next == null || count == 0 || !seenCursors.add(next)) break;
    before = next;
  }
  return {'version': 1, 'places': places};
}

/// API: `{ success, data: { items: [...snake_case], next_cursor } }`
/// → envelope lama `{ version, places: [...camelCase] }` untuk PlacesDto.
Map<String, dynamic> placesApiBodyToEnvelope(Object? body) {
  if (body is! Map) {
    throw StateError('Body places API bukan object');
  }
  final data = body['data'];
  if (data is! Map) {
    throw StateError('Field data places API tidak valid');
  }
  final items = data['items'];
  if (items is! List) {
    throw StateError('Field items places API tidak valid');
  }
  return {
    'version': 1,
    'places': [
      for (final raw in items.whereType<Map>())
        _wirePlaceToCamel(Map<String, dynamic>.from(raw)),
    ],
  };
}

Map<String, dynamic> _wirePlaceImageToCamel(Map<String, dynamic> img) {
  final attr = img['attribution'];
  Map<String, dynamic>? attribution;
  if (attr is Map) {
    attribution = {
      'name': attr['name'],
      'provider': attr['provider'],
      'url': attr['url'],
      'license': attr['license'],
      'license_url': attr['license_url'],
      'source': attr['source'],
      if (attr['authorId'] != null) 'authorId': attr['authorId'],
    };
  }
  return {
    'url': img['url'],
    'isMain': img['is_main'] == true,
    'attribution': ?attribution,
  };
}

Map<String, dynamic> _wirePlaceToCamel(Map<String, dynamic> w) {
  final images = <Map<String, dynamic>>[];
  final rawImages = w['images'];
  if (rawImages is List) {
    for (final img in rawImages.whereType<Map>()) {
      images.add(_wirePlaceImageToCamel(Map<String, dynamic>.from(img)));
    }
  }

  final sources = <Map<String, dynamic>>[];
  final rawSources = w['sources'];
  if (rawSources is List) {
    for (final s in rawSources.whereType<Map>()) {
      sources.add({
        'name': s['name'],
        'type': s['type'] ?? 'other',
        'address': s['address'],
        'license': s['license'],
        'licenseUrl': s['license_url'],
      });
    }
  }

  return {
    'id': w['id'],
    'slug': w['slug'],
    'name': w['name'],
    'category': w['category'],
    'type': w['type'],
    'lat': w['lat'],
    'lng': w['lng'],
    'mapsUrl': w['maps_url'],
    'shortDescription': w['short_description'],
    'regionId': w['region_id'],
    'hours': w['hours'],
    'contact': w['contact'],
    'authorId': w['author_id'],
    'images': images,
    'sources': sources,
    'related': <dynamic>[],
    'relatedWordIds': <dynamic>[],
  };
}
