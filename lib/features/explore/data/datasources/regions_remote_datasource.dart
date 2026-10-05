import 'package:dio/dio.dart';

import '../models/regions_dto.dart';

/// Remote datasource regions.json dari CDN (pola places_remote_datasource).
class RegionsRemoteDatasource {
  RegionsRemoteDatasource(this._dio, {String? configUrl})
    : _configUrl = configUrl ?? kDefaultRegionsUrl;

  final Dio _dio;

  static const kDefaultRegionsUrl =
      'https://cdn.jsdelivr.net/gh/sambasku/data@main/regions.json';

  final String _configUrl;

  String get configUrl => _configUrl;

  /// Response mentah (untuk cache envelope repository).
  Future<Response<dynamic>> fetchRaw() => _dio.get<dynamic>(
    _configUrl,
    options: Options(receiveTimeout: const Duration(seconds: 5)),
  );

  /// Fetch + parse `regions.json`. Throw = network/parse gagal (caller
  /// yang putuskan soft-fail).
  Future<RegionsDto> fetchRegions() async {
    final body = (await fetchRaw()).data;
    if (body is! Map) {
      throw StateError('Body regions.json bukan object');
    }
    final dto = RegionsDto.fromJson(Map<String, dynamic>.from(body));
    if (dto == null) {
      throw StateError('Struktur regions.json tidak valid');
    }
    return dto;
  }
}
