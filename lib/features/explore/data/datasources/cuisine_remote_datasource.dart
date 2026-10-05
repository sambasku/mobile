import 'package:dio/dio.dart';

import '../../../../core/constants/places_config_url.dart';
import '../models/cuisine_dto.dart';

/// Remote datasource cuisines.json dari CDN.
///
/// Pola sama dengan [PlacesRemoteDatasource]; file `cuisines.json`
/// di repo `data` via jsDelivr.
class CuisineRemoteDatasource {
  CuisineRemoteDatasource(this._dio, {String? configUrl})
    : _configUrl = configUrl ?? kDefaultCuisinesUrl;

  final Dio _dio;

  final String _configUrl;

  String get configUrl => _configUrl;

  /// Response mentah (untuk cache envelope repository).
  Future<Response<dynamic>> fetchRaw() => _dio.get<dynamic>(
    _configUrl,
    options: Options(receiveTimeout: const Duration(seconds: 5)),
  );

  /// Fetch + parse `cuisines.json`. Throw = network/parse gagal.
  Future<CuisineDto> fetchCuisines() async {
    final body = (await fetchRaw()).data;
    if (body is! Map) {
      throw StateError('Body cuisines.json bukan object');
    }
    return CuisineDto.fromJson(Map<String, dynamic>.from(body));
  }
}
