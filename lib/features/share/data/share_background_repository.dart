import 'package:dio/dio.dart';

import '../domain/share_models.dart';

class ShareBackgroundRepository {
  ShareBackgroundRepository(this._dio);

  final Dio _dio;

  /// Catat share sukses untuk feed. Fire-and-forget: gagal tidak mengganggu user.
  void recordCardShare(String wordId) {
    _dio
        .post<void>('/api/v1/words/${Uri.encodeComponent(wordId)}/card-shares')
        .catchError((_) => Response<void>(requestOptions: RequestOptions()));
  }

  /// Unsplash API Guidelines: catat download saat user memilih foto.
  /// Fire-and-forget: gagal tidak mengganggu user.
  void trackUnsplashDownload(String id) {
    _dio
        .post<void>(
          '/api/v1/share/backgrounds/unsplash/download',
          data: {'id': id},
        )
        .catchError((_) => Response<void>(requestOptions: RequestOptions()));
  }

  /// [sort] `relevant` butuh [query]; `popular` boleh query kosong (Image Explorer).
  Future<ShareBackgroundsResult> listBackgrounds(
    String query, {
    int page = 1,
    String sort = 'relevant',
    String provider = 'pixabay',
    int limit = 3,
    String media = 'photo',
    String? orientation,
  }) async {
    final q = query.trim();
    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit.clamp(1, 30);
    if (sort == 'relevant' && q.isEmpty) {
      return ShareBackgroundsResult(
        items: const [],
        page: safePage,
        degraded: true,
        provider: provider,
      );
    }
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/share/backgrounds',
        queryParameters: {
          if (q.isNotEmpty) 'q': q,
          'page': safePage,
          'sort': sort,
          'provider': provider,
          'limit': safeLimit,
          'media': media,
          'orientation': ?orientation,
        },
      );
      final data = res.data?['data'];
      if (data is! Map) {
        return ShareBackgroundsResult(
          items: const [],
          page: safePage,
          degraded: true,
          provider: provider,
        );
      }
      final itemsRaw = data['items'];
      final items = <ShareBackground>[];
      if (itemsRaw is List) {
        for (final raw in itemsRaw.whereType<Map>()) {
          final m = Map<String, dynamic>.from(raw);
          final url = m['url']?.toString() ?? '';
          if (url.isEmpty) continue;
          final attribution = m['attribution_url']?.toString() ??
              m['unsplash_url']?.toString() ??
              '';
          items.add(
            ShareBackground(
              id: m['id']?.toString() ?? url,
              url: url,
              photographer: m['photographer']?.toString() ?? '',
              username: m['username']?.toString() ?? '',
              attributionUrl: attribution,
              provider: m['provider']?.toString() ?? provider,
              kind: m['kind']?.toString() == 'video'
                  ? ShareMediaKind.video
                  : ShareMediaKind.photo,
              previewUrl: m['preview_url']?.toString(),
              width: (m['width'] as num?)?.toInt() ?? 0,
              height: (m['height'] as num?)?.toInt() ?? 0,
              durationSeconds: (m['duration_seconds'] as num?)?.toInt() ?? 0,
              license: m['license']?.toString(),
              licenseUrl: m['license_url']?.toString(),
              source: m['source']?.toString(),
            ),
          );
        }
      }
      return ShareBackgroundsResult(
        items: items,
        page: (data['page'] as num?)?.toInt() ?? safePage,
        degraded: data['degraded'] == true,
        provider: data['provider']?.toString() ?? provider,
      );
    } catch (_) {
      return ShareBackgroundsResult(
        items: const [],
        page: safePage,
        degraded: true,
        provider: provider,
      );
    }
  }
}
