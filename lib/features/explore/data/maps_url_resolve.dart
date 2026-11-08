import 'package:dio/dio.dart';

import '../../../core/i18n/l10n.dart';
import 'sambas_nominatim.dart';

/// Hasil resolve tautan Google Maps dari API.
class MapsUrlResolveHit {
  const MapsUrlResolveHit({
    required this.lat,
    required this.lng,
    required this.canonicalUrl,
  });

  final double lat;
  final double lng;
  final String canonicalUrl;
}

class MapsUrlResolveException implements Exception {
  const MapsUrlResolveException(this.message, {this.code});

  final String message;
  final String? code;
}

/// Ambil URL https Maps pertama dari teks paste.
///
/// Dipakai UI + unit test (tanpa Dio).
String? extractMapsUrlCandidate(String raw) {
  final trimmed = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (trimmed.isEmpty || trimmed.length > 2048) return null;
  final match = RegExp(
    r'''https://[^\s<>"']+''',
    caseSensitive: false,
  ).firstMatch(trimmed);
  if (match == null) return null;
  var url = match.group(0)!.replaceAll(RegExp(r'[.,;)\]]+$'), '');
  if (url.length > 2048) return null;
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.isScheme('https')) return null;
  if (!_isAllowedMapsHost(uri)) return null;
  return uri.toString();
}

bool looksLikeMapsUrl(String raw) => extractMapsUrlCandidate(raw) != null;

bool _isAllowedMapsHost(Uri uri) {
  final host = uri.host.toLowerCase();
  final path = uri.path;
  if (host == 'maps.app.goo.gl') return true;
  if (host == 'goo.gl' && path.startsWith('/maps')) return true;
  if (host == 'maps.google.com') return true;
  if ((host == 'google.com' || host.endsWith('.google.com')) &&
      path.startsWith('/maps')) {
    return true;
  }
  return false;
}

/// Klien POST `/api/v1/geo/resolve-maps-url`.
class MapsUrlResolveApi {
  MapsUrlResolveApi(this._dio);

  final Dio _dio;
  CancelToken? _cancel;
  int _seq = 0;

  Future<MapsUrlResolveHit> resolve(String raw) async {
    final url = extractMapsUrlCandidate(raw);
    if (url == null) {
      throw MapsUrlResolveException(
        l10n.placePinPickerMapsUrlInvalid,
        code: 'MAPS_URL_INVALID',
      );
    }

    _cancel?.cancel();
    final token = CancelToken();
    _cancel = token;
    final seq = ++_seq;

    try {
      final res = await _dio.post<dynamic>(
        '/api/v1/geo/resolve-maps-url',
        data: {'url': url},
        cancelToken: token,
        options: Options(
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 12),
        ),
      );
      if (seq != _seq) {
        throw const MapsUrlResolveException('', code: 'CANCELLED');
      }
      final body = res.data;
      final data = body is Map ? body['data'] : null;
      if (data is! Map) {
        throw MapsUrlResolveException(
          l10n.placePinPickerMapsUrlFailed,
          code: 'MAPS_URL_RESOLVE_FAILED',
        );
      }
      final lat = (data['lat'] as num?)?.toDouble();
      final lng = (data['lng'] as num?)?.toDouble();
      final canonical = data['canonical_url'];
      if (lat == null ||
          lng == null ||
          !lat.isFinite ||
          !lng.isFinite ||
          canonical is! String ||
          canonical.isEmpty) {
        throw MapsUrlResolveException(
          l10n.placePinPickerMapsUrlFailed,
          code: 'MAPS_URL_RESOLVE_FAILED',
        );
      }
      if (!inSambasBounds(lat, lng)) {
        throw MapsUrlResolveException(
          l10n.placePinPickerMapsUrlOutOfBounds,
          code: 'MAPS_URL_OUT_OF_BOUNDS',
        );
      }
      return MapsUrlResolveHit(
        lat: lat,
        lng: lng,
        canonicalUrl: canonical,
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) || seq != _seq) {
        throw const MapsUrlResolveException('', code: 'CANCELLED');
      }
      final data = e.response?.data;
      if (data is Map) {
        final code = data['error_code'] as String?;
        final message = data['message'];
        throw MapsUrlResolveException(
          message is String && message.isNotEmpty
              ? message
              : _fallbackMessage(code),
          code: code,
        );
      }
      throw MapsUrlResolveException(
        l10n.placePinPickerMapsUrlFailed,
        code: 'MAPS_URL_RESOLVE_FAILED',
      );
    }
  }

  void cancel() {
    _seq++;
    _cancel?.cancel();
  }

  void dispose() {
    cancel();
  }

  String _fallbackMessage(String? code) => switch (code) {
    'MAPS_URL_INVALID' => l10n.placePinPickerMapsUrlInvalid,
    'MAPS_URL_NO_COORDS' => l10n.placePinPickerMapsUrlNoCoords,
    'MAPS_URL_OUT_OF_BOUNDS' => l10n.placePinPickerMapsUrlOutOfBounds,
    _ => l10n.placePinPickerMapsUrlFailed,
  };
}
