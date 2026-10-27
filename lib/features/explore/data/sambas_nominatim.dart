import 'package:dio/dio.dart';
import '../../../core/i18n/l10n.dart';

/// Batas produk Kabupaten Sambas. Hasil di luar ini tidak dipakai.
bool inSambasBounds(double lat, double lng) {
  return lat >= 1.0 && lat <= 1.8 && lng >= 108.5 && lng <= 110.0;
}

class NominatimHit {
  const NominatimHit({
    required this.lat,
    required this.lng,
    required this.label,
  });

  final double lat;
  final double lng;
  final String label;
}

/// Pencarian Nominatim untuk peta wisata.
///
/// Satu klien per layar. [search] membatalkan permintaan sebelumnya.
/// Pemanggil wajib debounce dan tidak memanggil untuk query kosong.
class SambasNominatim {
  SambasNominatim()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: const {
            'Accept': 'application/json',
            'Accept-Language': 'id',
            // Kebijakan Nominatim: identitas aplikasi, bukan UA bawaan.
            'User-Agent': 'SambasKu/1.0 (wisata map; https://sambasku.com)',
          },
        ),
      );

  final Dio _dio;
  CancelToken? _cancel;
  int _seq = 0;
  DateTime? _lastRequest;

  /// `null` = dibatalkan, query tidak layak, atau tidak ada hasil valid.
  /// Lempar [NominatimException] hanya untuk kegagalan jaringan.
  Future<List<NominatimHit>> searchMany(String raw, {int limit = 5}) async {
    final query = cleanNominatimQuery(raw);
    if (query == null) return const [];
    _cancel?.cancel();
    final token = CancelToken();
    _cancel = token;
    final seq = ++_seq;

    final last = _lastRequest;
    if (last != null) {
      final wait = const Duration(seconds: 1) - DateTime.now().difference(last);
      if (wait > Duration.zero) {
        await Future<void>.delayed(wait);
        if (seq != _seq || token.isCancelled) return const [];
      }
    }
    _lastRequest = DateTime.now();

    try {
      final response = await _dio.get<Object?>(
        'https://nominatim.openstreetmap.org/search',
        cancelToken: token,
        queryParameters: {
          'format': 'jsonv2',
          'limit': limit,
          'q': query,
          'countrycodes': 'id',
          'viewbox': '108.5,2.0,110.1,0.8',
          'bounded': 1,
        },
      );
      if (seq != _seq) return const [];
      return _allHits(response.data);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) || seq != _seq) return const [];
      throw NominatimException(l10n.nominatimSearchFailed);
    }
  }

  /// Compat: tetap kembalikan satu hit pertama.
  Future<NominatimHit?> search(String raw) async {
    final hits = await searchMany(raw, limit: 1);
    return hits.isEmpty ? null : hits.first;
  }

  void cancel() {
    _seq++;
    _cancel?.cancel();
  }

  void dispose() {
    cancel();
    _dio.close(force: true);
  }
}

class NominatimException implements Exception {
  const NominatimException(this.message);

  final String message;
}

/// Kosong, terlalu pendek, terlalu panjang, atau tanpa huruf/angka = abaikan.
String? cleanNominatimQuery(String raw) {
  final query = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (query.length < 3 || query.length > 80) return null;
  if (!RegExp('[A-Za-z0-9]').hasMatch(query)) return null;
  return query;
}

List<NominatimHit> _allHits(Object? data) {
  if (data is! List) return const [];
  final out = <NominatimHit>[];
  for (final row in data) {
    if (row is! Map) continue;
    final lat = double.tryParse('${row['lat']}');
    final lng = double.tryParse('${row['lon']}');
    if (lat == null || lng == null) continue;
    if (!lat.isFinite || !lng.isFinite) continue;
    if (!inSambasBounds(lat, lng)) continue;
    final name = row['display_name'];
    final label = name is String && name.trim().isNotEmpty
        ? name.trim()
        : 'Titik di Sambas';
    out.add(NominatimHit(lat: lat, lng: lng, label: label));
  }
  return out;
}
