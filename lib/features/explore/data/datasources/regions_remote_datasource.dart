import 'package:dio/dio.dart';

import '../models/regions_dto.dart';

/// Remote datasource katalog wilayah dari API publik.
///
/// `GET /api/v1/regions/catalog` satu response (bukan CDN jsDelivr).
/// `id` dan `parent_id` di wire adalah slug, sama dengan geojson.
class RegionsRemoteDatasource {
  RegionsRemoteDatasource(this._dio, {String? catalogPath})
    : _catalogPath = catalogPath ?? kRegionsCatalogPath;

  final Dio _dio;

  static const kRegionsCatalogPath = '/api/v1/regions/catalog';

  final String _catalogPath;

  String get catalogPath => _catalogPath;

  /// Response mentah API `{ success, data: { regions } }`.
  Future<Response<dynamic>> fetchRaw() => _dio.get<dynamic>(
    _catalogPath,
    options: Options(receiveTimeout: const Duration(seconds: 8)),
  );

  /// Envelope `{ version, regions }` dengan `parentId` camelCase untuk [RegionsDto].
  Future<Map<String, dynamic>> fetchCatalogEnvelope() async =>
      regionsApiBodyToEnvelope((await fetchRaw()).data);

  /// Fetch + parse. Throw = network/parse gagal (caller yang putuskan soft-fail).
  Future<RegionsDto> fetchRegions() async {
    final dto = RegionsDto.fromJson(await fetchCatalogEnvelope());
    if (dto == null) {
      throw StateError('Struktur katalog wilayah tidak valid');
    }
    return dto;
  }
}

/// API: `{ success, data: { regions: [...snake_case] } }`
/// → envelope `{ version, regions: [...parentId] }` untuk [RegionsDto].
Map<String, dynamic> regionsApiBodyToEnvelope(Object? body) {
  if (body is! Map) {
    throw StateError('Body regions API bukan object');
  }
  final data = body['data'];
  if (data is! Map) {
    throw StateError('Field data regions API tidak valid');
  }
  final items = data['regions'];
  if (items is! List) {
    throw StateError('Field regions API tidak valid');
  }
  return {
    'version': 1,
    'regions': [
      for (final raw in items.whereType<Map>())
        _wireRegionToCamel(Map<String, dynamic>.from(raw)),
    ],
  };
}

Map<String, dynamic> _wireRegionToCamel(Map<String, dynamic> w) {
  return {
    'id': w['id'],
    'name': w['name'],
    'type': w['type'],
    'parentId': w['parent_id'],
    'lat': w['lat'],
    'lng': w['lng'],
    'code': w['code'],
  };
}
