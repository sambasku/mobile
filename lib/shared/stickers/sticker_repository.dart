import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sticker_models.dart';

const _kStickerCacheKey = 'stickers_catalog_v2';
const _kStickerByIdPrefix = 'sticker_by_id_v1_';

class StickerRepository {
  StickerRepository(this._dio);

  final Dio _dio;
  final Map<String, CatalogSticker> _memory = {};

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
      final items = data
          .whereType<Map>()
          .map((e) => CatalogSticker.fromJson(Map<String, dynamic>.from(e)))
          .where((s) => s.id.isNotEmpty && s.imageUrl.isNotEmpty)
          .toList(growable: false);
      for (final s in items) {
        _memory[s.id] = s;
      }
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
      final itemsRaw = decoded['items'];
      final catsRaw = decoded['categories'];
      final items = itemsRaw is List
          ? itemsRaw
              .whereType<Map>()
              .map(
                (e) => CatalogSticker.fromJson(Map<String, dynamic>.from(e)),
              )
              .where((s) => s.id.isNotEmpty && s.imageUrl.isNotEmpty)
              .toList(growable: false)
          : const <CatalogSticker>[];
      for (final s in items) {
        _memory[s.id] = s;
      }
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
