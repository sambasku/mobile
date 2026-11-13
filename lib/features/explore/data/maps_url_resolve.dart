import 'package:dio/dio.dart';

import '../../../core/i18n/l10n.dart';
import 'sambas_nominatim.dart';

/// Hasil resolve tautan Google Maps.
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

class MapsCoords {
  const MapsCoords(this.lat, this.lng);

  final double lat;
  final double lng;
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

bool isShortMapsUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  final host = uri.host.toLowerCase();
  return host == 'maps.app.goo.gl' ||
      (host == 'goo.gl' && uri.path.startsWith('/maps'));
}

/// Prioritas: pin `!3d!4d` > kamera `/@lat,lng` > q/ll/query.
///
/// Pola acuan produk: baca URL hasil redirect, ambil `!3d` / `!4d`.
MapsCoords? extractCoordsFromMapsUrl(String urlStr) {
  var decoded = urlStr;
  try {
    decoded = Uri.decodeFull(urlStr);
  } catch (_) {
    // pakai mentah
  }

  final pinMatches = RegExp(
    r'!3d(-?\d+\.?\d*)!4d(-?\d+\.?\d*)',
  ).allMatches(decoded).toList();
  if (pinMatches.isNotEmpty) {
    final last = pinMatches.last;
    final pair = _finitePair(last.group(1), last.group(2));
    if (pair != null) return pair;
  }

  final at = RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*)').firstMatch(decoded);
  if (at != null) {
    final pair = _finitePair(at.group(1), at.group(2));
    if (pair != null) return pair;
  }

  final q = RegExp(
    r'[?&](?:q|query|ll)=(-?\d+\.?\d*),(-?\d+\.?\d*)',
  ).firstMatch(decoded);
  if (q != null) {
    final pair = _finitePair(q.group(1), q.group(2));
    if (pair != null) return pair;
  }

  return null;
}

MapsCoords? _finitePair(String? a, String? b) {
  if (a == null || b == null) return null;
  final lat = double.tryParse(a);
  final lng = double.tryParse(b);
  if (lat == null || lng == null) return null;
  if (!lat.isFinite || !lng.isFinite) return null;
  if (lat.abs() > 90 || lng.abs() > 180) return null;
  return MapsCoords(lat, lng);
}

/// Nama tempat dari path `/maps/place/Nama+Tempat/...`.
String? extractPlaceNameFromMapsUrl(String urlStr) {
  final uri = Uri.tryParse(urlStr);
  if (uri == null) return null;
  final match = RegExp(
    r'^/maps/place/([^/]+)',
    caseSensitive: false,
  ).firstMatch(uri.path);
  if (match == null) return null;
  final raw = match.group(1);
  if (raw == null) return null;
  var name = Uri.decodeComponent(raw.replaceAll('+', ' '));
  name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (name.length < 3 || name.length > 120) return null;
  if (RegExp(r'^-?\d+(?:\.\d+)?\s*,\s*-?\d+(?:\.\d+)?$').hasMatch(name)) {
    return null;
  }
  return name;
}

/// Kandidat query Nominatim (selaras API `buildPlaceGeocodeCandidates`).
List<String> buildPlaceGeocodeCandidates(String name) {
  final out = <String>[];
  void push(String raw) {
    final t = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (t.length < 3) return;
    final sliced = t.length > 80 ? t.substring(0, 80) : t;
    if (!out.contains(sliced)) out.add(sliced);
  }

  final parts = name
      .split(',')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isNotEmpty) push(parts.first);

  final cleaned = parts
      .map(
        (p) => p
            .replaceFirst(
              RegExp(
                r'^(kec\.?|kab(?:upaten)?\.?|kota|provinsi|prov\.?)\s+',
                caseSensitive: false,
              ),
              '',
            )
            .trim(),
      )
      .where((p) => p.length >= 2)
      .toList();
  if (cleaned.length >= 2) {
    push(cleaned.take(3).join(' '));
  }

  final hasAdmin = RegExp(
    r'\b(kec\.?|kab(?:upaten)?|kota|provinsi)\b',
    caseSensitive: false,
  ).hasMatch(name);
  if (!hasAdmin) push(name);

  return out;
}

String cleanCanonicalMapsUrl(String urlStr) {
  final uri = Uri.tryParse(urlStr);
  if (uri == null) return urlStr;
  final drop = {
    'utm_source',
    'utm_medium',
    'utm_campaign',
    'utm_term',
    'utm_content',
    'g_ep',
    'g_st',
    'entry',
  };
  final kept = Map<String, String>.fromEntries(
    uri.queryParameters.entries.where(
      (e) => !drop.contains(e.key) && !e.key.startsWith('utm_'),
    ),
  );
  // queryParameters: null = pertahankan lama; {} = buang semua.
  return uri.replace(queryParameters: kept).toString();
}

/// Expand short link di perangkat (Google sering blokir egress Workers).
Future<String?> expandShortMapsUrl(
  String url, {
  Dio? dio,
  CancelToken? cancelToken,
}) async {
  final owns = dio == null;
  final client =
      dio ??
      Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 12),
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (s) => s != null && s >= 200 && s < 400,
          headers: const {
            'Accept': 'text/html,application/xhtml+xml',
            // Browser UA: redirect Maps lebih stabil daripada bot UA.
            'User-Agent':
                'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 '
                '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          },
        ),
      );
  try {
    final res = await client.get<List<int>>(
      url,
      cancelToken: cancelToken,
      options: Options(responseType: ResponseType.bytes),
    );
    final real = res.realUri;
    if (!_isAllowedMapsHost(real)) return null;
    return real.toString();
  } on DioException {
    return null;
  } finally {
    if (owns) {
      client.close(force: true);
    }
  }
}

/// Klien resolve: expand lokal → parse koordinat → Nominatim → API.
class MapsUrlResolveApi {
  MapsUrlResolveApi(this._dio, {SambasNominatim? nominatim})
    : _nominatim = nominatim ?? SambasNominatim(),
      _ownsNominatim = nominatim == null;

  final Dio _dio;
  final SambasNominatim _nominatim;
  final bool _ownsNominatim;
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
      var working = url;

      // 1) Short link: expand di HP dulu (pola extractCoordinatesShortUrl).
      if (isShortMapsUrl(working)) {
        final expanded = await expandShortMapsUrl(
          working,
          cancelToken: token,
        );
        _ensureActive(seq);
        if (expanded != null) working = expanded;
      }

      // 2) Ambil !3d!4d / @ / q dari URL final.
      var coords = extractCoordsFromMapsUrl(working);
      if (coords != null) {
        return _hitOrBounds(coords, working);
      }

      // 3) Place-id-only (banyak share Maps): geocode nama di path.
      final local = await _geocodeFromPlaceUrl(working, seq);
      if (local != null) return local;

      // 4) Cadangan API (staging/prod yang bisa fetch Google + Nominatim).
      return await _resolveViaApi(working, token, seq);
    } on MapsUrlResolveException {
      rethrow;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) || seq != _seq) {
        throw const MapsUrlResolveException('', code: 'CANCELLED');
      }
      throw MapsUrlResolveException(
        l10n.placePinPickerMapsUrlFailed,
        code: 'MAPS_URL_RESOLVE_FAILED',
      );
    }
  }

  Future<MapsUrlResolveHit?> _geocodeFromPlaceUrl(
    String working,
    int seq,
  ) async {
    final placeName = extractPlaceNameFromMapsUrl(working);
    if (placeName == null) return null;
    for (final q in buildPlaceGeocodeCandidates(placeName)) {
      _ensureActive(seq);
      final hit = await _nominatim.search(q);
      _ensureActive(seq);
      if (hit == null) continue;
      return MapsUrlResolveHit(
        lat: hit.lat,
        lng: hit.lng,
        canonicalUrl: cleanCanonicalMapsUrl(working),
      );
    }
    return null;
  }

  Future<MapsUrlResolveHit> _resolveViaApi(
    String working,
    CancelToken token,
    int seq,
  ) async {
    try {
      final res = await _dio.post<dynamic>(
        '/api/v1/geo/resolve-maps-url',
        data: {'url': working},
        cancelToken: token,
        options: Options(
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 12),
        ),
      );
      _ensureActive(seq);
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
      return _hitOrBounds(MapsCoords(lat, lng), canonical);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) || seq != _seq) {
        throw const MapsUrlResolveException('', code: 'CANCELLED');
      }
      final data = e.response?.data;
      if (data is Map) {
        final code = data['error_code'] as String?;
        final message = data['message'];
        // API gagal expand/Nominatim → coba Nominatim lokal sekali lagi
        // dengan URL kerja (mungkin API host cadangan yang blokir Google).
        if (code == 'MAPS_URL_NO_COORDS' ||
            code == 'MAPS_URL_RESOLVE_FAILED') {
          final local = await _geocodeFromPlaceUrl(working, seq);
          if (local != null) return local;
        }
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

  MapsUrlResolveHit _hitOrBounds(MapsCoords coords, String canonical) {
    if (!inSambasBounds(coords.lat, coords.lng)) {
      throw MapsUrlResolveException(
        l10n.placePinPickerMapsUrlOutOfBounds,
        code: 'MAPS_URL_OUT_OF_BOUNDS',
      );
    }
    return MapsUrlResolveHit(
      lat: coords.lat,
      lng: coords.lng,
      canonicalUrl: cleanCanonicalMapsUrl(canonical),
    );
  }

  void _ensureActive(int seq) {
    if (seq != _seq) {
      throw const MapsUrlResolveException('', code: 'CANCELLED');
    }
  }

  void cancel() {
    _seq++;
    _cancel?.cancel();
    _nominatim.cancel();
  }

  void dispose() {
    cancel();
    if (_ownsNominatim) _nominatim.dispose();
  }

  String _fallbackMessage(String? code) => switch (code) {
    'MAPS_URL_INVALID' => l10n.placePinPickerMapsUrlInvalid,
    'MAPS_URL_NO_COORDS' => l10n.placePinPickerMapsUrlNoCoords,
    'MAPS_URL_OUT_OF_BOUNDS' => l10n.placePinPickerMapsUrlOutOfBounds,
    _ => l10n.placePinPickerMapsUrlFailed,
  };
}
