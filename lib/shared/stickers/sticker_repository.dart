import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sticker_models.dart';

const _kStickerCacheKey = 'stickers_catalog_v2';
const _kStickerByIdPrefix = 'sticker_by_id_v1_';
const _kStickerFavPrefix = 'stickers_favorites_v1_';
const _kStickerMinePrefix = 'stickers_mine_v1_';

class StickerRepository {
  StickerRepository(this._dio);

  final Dio _dio;
  final Map<String, CatalogSticker> _memory = {};

  /// Instance Dio shared untuk download frame statis GIF tanpa bikin client baru.
  static final Dio mediaDio = Dio();

  StickerApiException _extractApiError(Object err) {
    if (err is DioException) {
      final data = err.response?.data;
      if (data is Map) {
        return StickerApiException(
          errorCode: data['error_code']?.toString(),
          message: data['message']?.toString(),
        );
      }
      if (err.response?.statusCode == 429) {
        return const StickerApiException(errorCode: 'RATE_LIMITED');
      }
    }
    return const StickerApiException();
  }

  List<CatalogSticker> _parseList(Object? raw) {
    if (raw is! List) return const <CatalogSticker>[];
    final items = raw
        .whereType<Map>()
        .map((e) => CatalogSticker.fromJson(Map<String, dynamic>.from(e)))
        .where((s) => s.id.isNotEmpty && s.imageUrl.isNotEmpty)
        .toList(growable: false);
    for (final s in items) {
      _memory[s.id] = s;
    }
    return items;
  }

  Future<StickerCatalogPage> fetchPage({
    String? q,
    String? categorySlug,
    String? cursor,
    int limit = 40,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/stickers',
        queryParameters: {
          if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
          if (categorySlug != null && categorySlug.isNotEmpty)
            'category_slug': categorySlug,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          'limit': limit,
        },
      );
      final data = res.data?['data'];
      final meta = res.data?['meta'];
      if (data is! List) {
        return await _offlinePage();
      }
      final items = _parseList(data);
      final categories = meta is Map && meta['categories'] is List
          ? (meta['categories'] as List)
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList(growable: false)
          : const <String>[];
      final next = meta is Map ? meta['next_cursor']?.toString() : null;
      if (cursor == null &&
          (q == null || q.isEmpty) &&
          (categorySlug == null || categorySlug.isEmpty)) {
        await _writeCache(items, categories);
      }
      return StickerCatalogPage(
        items: items,
        categories: categories,
        nextCursor: (next == null || next.isEmpty) ? null : next,
      );
    } catch (_) {
      if (cursor != null) {
        return const StickerCatalogPage(items: [], categories: []);
      }
      return _offlinePage();
    }
  }

  Future<CatalogSticker?> fetchById(String id) async {
    final key = id.trim();
    if (key.isEmpty) return null;
    final mem = _memory[key];
    if (mem != null) return mem;
    final cached = await _readByIdCache(key);
    if (cached != null) {
      _memory[key] = cached;
      return cached;
    }
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/stickers/${Uri.encodeComponent(key)}',
      );
      final data = res.data?['data'];
      if (data is! Map) return null;
      final sticker =
          CatalogSticker.fromJson(Map<String, dynamic>.from(data));
      if (sticker.id.isEmpty || sticker.imageUrl.isEmpty) return null;
      _memory[sticker.id] = sticker;
      await _writeByIdCache(sticker);
      return sticker;
    } catch (_) {
      return null;
    }
  }

  // --- Favorit per user ---

  Future<List<CatalogSticker>> fetchFavorites(String userId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/stickers/favorites',
      );
      final items = _parseList(res.data?['data']);
      await _writeScopedList('$_kStickerFavPrefix$userId', items);
      return items;
    } catch (_) {
      return _readScopedList('$_kStickerFavPrefix$userId');
    }
  }

  Future<CatalogSticker> addFavorite(String stickerId) async {
    try {
      final res = await _dio.put<Map<String, dynamic>>(
        '/api/v1/stickers/favorites/${Uri.encodeComponent(stickerId)}',
      );
      final data = res.data?['data'];
      if (data is Map) {
        final sticker =
            CatalogSticker.fromJson(Map<String, dynamic>.from(data));
        _memory[sticker.id] = sticker;
        return sticker;
      }
      throw const StickerApiException();
    } catch (e) {
      if (e is StickerApiException) rethrow;
      throw _extractApiError(e);
    }
  }

  Future<void> removeFavorite(String stickerId) async {
    try {
      await _dio.delete<Map<String, dynamic>>(
        '/api/v1/stickers/favorites/${Uri.encodeComponent(stickerId)}',
      );
    } catch (e) {
      throw _extractApiError(e);
    }
  }

  // --- Custom stiker milik user ---

  Future<List<CatalogSticker>> fetchMine(String userId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/stickers/mine',
      );
      final items = _parseList(res.data?['data']);
      await _writeScopedList('$_kStickerMinePrefix$userId', items);
      return items;
    } catch (_) {
      return _readScopedList('$_kStickerMinePrefix$userId');
    }
  }

  Future<StickerUploadCredentials> getUploadToken() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/stickers/upload-token',
      );
      final data = res.data?['data'];
      if (data is Map) {
        return StickerUploadCredentials.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
      throw const StickerApiException();
    } catch (e) {
      if (e is StickerApiException) rethrow;
      throw _extractApiError(e);
    }
  }

  Future<CatalogSticker> createMine({
    String? name,
    required String imageUrl,
    String? providerFileId,
    bool playOnce = false,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/stickers/mine',
        data: {
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
          'image_url': imageUrl,
          if (providerFileId != null && providerFileId.trim().isNotEmpty)
            'provider_file_id': providerFileId.trim(),
          'play_once': playOnce,
        },
      );
      final data = res.data?['data'];
      if (data is Map) {
        final sticker =
            CatalogSticker.fromJson(Map<String, dynamic>.from(data));
        _memory[sticker.id] = sticker;
        await _writeByIdCache(sticker);
        return sticker;
      }
      throw const StickerApiException();
    } catch (e) {
      if (e is StickerApiException) rethrow;
      throw _extractApiError(e);
    }
  }

  Future<void> deleteMine(String stickerId) async {
    try {
      await _dio.delete<Map<String, dynamic>>(
        '/api/v1/stickers/mine/${Uri.encodeComponent(stickerId)}',
      );
      _memory.remove(stickerId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_kStickerByIdPrefix$stickerId');
    } catch (e) {
      throw _extractApiError(e);
    }
  }

  Future<void> clearUserCache(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_kStickerFavPrefix$userId');
    await prefs.remove('$_kStickerMinePrefix$userId');
  }

  Future<List<CatalogSticker>> readCachedFavorites(String userId) {
    return _readScopedList('$_kStickerFavPrefix$userId');
  }

  Future<void> writeCachedFavorites(String userId, List<CatalogSticker> items) {
    return _writeScopedList('$_kStickerFavPrefix$userId', items);
  }

  Future<List<CatalogSticker>> readCachedMine(String userId) {
    return _readScopedList('$_kStickerMinePrefix$userId');
  }

  Future<void> writeCachedMine(String userId, List<CatalogSticker> items) {
    return _writeScopedList('$_kStickerMinePrefix$userId', items);
  }

  Future<StickerCatalogPage> _offlinePage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStickerCacheKey);
    if (raw == null || raw.isEmpty) {
      return const StickerCatalogPage(items: [], categories: []);
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const StickerCatalogPage(items: [], categories: []);
      }
      final items = _parseList(decoded['items']);
      final catsRaw = decoded['categories'];
      final categories = catsRaw is List
          ? catsRaw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : const <String>[];
      return StickerCatalogPage(items: items, categories: categories);
    } catch (_) {
      return const StickerCatalogPage(items: [], categories: []);
    }
  }

  Future<void> _writeCache(
    List<CatalogSticker> items,
    List<String> categories,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kStickerCacheKey,
      jsonEncode({
        'items': items.map((e) => e.toJson()).toList(),
        'categories': categories,
      }),
    );
  }

  Future<List<CatalogSticker>> _readScopedList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return const <CatalogSticker>[];
    try {
      return _parseList(jsonDecode(raw));
    } catch (_) {
      return const <CatalogSticker>[];
    }
  }

  Future<void> _writeScopedList(String key, List<CatalogSticker> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<CatalogSticker?> _readByIdCache(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_kStickerByIdPrefix$id');
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return CatalogSticker.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeByIdCache(CatalogSticker sticker) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_kStickerByIdPrefix${sticker.id}',
      jsonEncode(sticker.toJson()),
    );
  }
}
