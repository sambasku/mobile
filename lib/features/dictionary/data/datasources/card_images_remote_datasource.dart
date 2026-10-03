import 'package:dio/dio.dart';

import '../../../../core/constants/card_config_url.dart';
import '../models/card_images_dto.dart';

/// Remote datasource config card dari CDN.
///
/// "Repository URL" CDN: base jsDelivr repo `data`, file JSON per platform.
/// Ganti CDN = ganti `kDefaultCardConfigUrl` / arahkan via [configUrl].
class CardImagesRemoteDatasource {
  CardImagesRemoteDatasource(this._dio, {String? configUrl})
      : _configUrl = configUrl ?? kDefaultCardConfigUrl;

  final Dio _dio;

  final String _configUrl;

  /// URL config aktif (override ctor atau fallback konstanta).
  String get configUrl => _configUrl;

  /// Fetch + parse `home.json`. Throw = network/parse gagal (caller
  /// yang putuskan soft-fail).
  Future<CardImagesDto> fetchConfig() async {
    final resp = await _dio.get<dynamic>(
      _configUrl,
      options: Options(receiveTimeout: const Duration(seconds: 5)),
    );
    final body = resp.data;
    if (body is! Map) {
      throw const CardImagesException('Body home.json bukan object');
    }
    return CardImagesDto.fromJson(Map<String, dynamic>.from(body));
  }
}
