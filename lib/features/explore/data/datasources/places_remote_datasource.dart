import 'package:dio/dio.dart';

import '../../../../core/constants/places_config_url.dart';
import '../models/places_dto.dart';

/// Remote datasource places.json dari CDN.
///
/// "Repository URL" CDN: base jsDelivr repo `data`, file JSON per platform.
/// Ganti CDN = ganti `kDefaultPlacesUrl` / arahkan via [configUrl].
class PlacesRemoteDatasource {
  PlacesRemoteDatasource(this._dio, {String? configUrl})
    : _configUrl = configUrl ?? kDefaultPlacesUrl;

  final Dio _dio;

  final String _configUrl;

  /// URL config aktif (override ctor atau fallback konstanta).
  String get configUrl => _configUrl;

  /// Response mentah (untuk cache envelope repository).
  Future<Response<dynamic>> fetchRaw() => _dio.get<dynamic>(
    _configUrl,
    options: Options(receiveTimeout: const Duration(seconds: 5)),
  );

  /// Fetch + parse `places.json`. Throw = network/parse gagal (caller
  /// yang putuskan soft-fail).
  Future<PlacesDto> fetchPlaces() async {
    final body = (await fetchRaw()).data;
    if (body is! Map) {
      throw StateError('Body places.json bukan object');
    }
    return PlacesDto.fromJson(Map<String, dynamic>.from(body));
  }
}
