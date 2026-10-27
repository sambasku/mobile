import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/l10n.dart';
import '../../../core/network/network_providers.dart';
import '../domain/pantun_models.dart';

class PantunApi {
  PantunApi(this._dio);
  final Dio _dio;
  static const _base = '/api/v1/pantuns';

  Future<PantunPage> listPublished({
    int limit = 20,
    String? cursor,
    String? categoryId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      _base,
      queryParameters: {
        'limit': limit,
        'cursor': ?cursor,
        'category_id': ?categoryId,
      },
    );
    return _pageFromJson(res.data);
  }

  Future<PantunDetail> getDetail(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('$_base/$id');
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw const PantunFailure('Data pantun tidak lengkap');
    }
    final replies = (data['replies'] as List? ?? [])
        .map((e) => Pantun.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    data.remove('replies');
    return PantunDetail(Pantun.fromJson(data), replies);
  }

  /// Cari isi pantun + balasan. Hasil balasan bawa `parentId` terisi.
  Future<List<Pantun>> search(String q, {int limit = 20}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '$_base/search',
      queryParameters: {'q': q, 'limit': limit},
    );
    final data = res.data?['data'];
    if (data is! List) {
      throw const PantunFailure('Data hasil pencarian tidak lengkap');
    }
    return data
        .map((e) => Pantun.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Pantun> create({
    required List<String> lines,

    /// Null = server deteksi sendiri (ABAB lalu AAAA).
    String? rhymeScheme,
    String? categoryId,
    String? language,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      _base,
      data: {
        'lines': lines,
        'rhyme_scheme': ?rhymeScheme,
        'category_id': ?categoryId,
        'language': ?language,
      },
    );
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw const PantunFailure('Data pantun tidak lengkap');
    }
    return Pantun.fromJson(data);
  }

  Future<Pantun> createReply({
    required String parentId,
    required List<String> lines,

    /// Null = server deteksi sendiri (ABAB lalu AAAA).
    String? rhymeScheme,
    String? categoryId,
    String? language,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '$_base/$parentId/replies',
      data: {
        'lines': lines,
        'rhyme_scheme': ?rhymeScheme,
        'category_id': ?categoryId,
        'language': ?language,
      },
    );
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw const PantunFailure('Data balasan tidak lengkap');
    }
    return Pantun.fromJson(data);
  }

  Future<void> deleteReply(String replyId) async {
    try {
      await _dio.delete('$_base/replies/$replyId');
    } on DioException catch (e) {
      throw PantunFailure(_messageFrom(e));
    }
  }

  /// Hapus pantun milik sendiri (soft delete di server).
  Future<void> deletePantun(String id) async {
    try {
      await _dio.delete('$_base/$id');
    } on DioException catch (e) {
      throw PantunFailure(_messageFrom(e));
    }
  }

  /// Laporkan pantun/balasan untuk ditinjau admin. Konten tetap tayang.
  /// [targetType] `pantun` | `pantun_reply`.
  Future<void> report({
    required String targetType,
    required String targetId,
    required String reasonCode,
    String? note,
  }) async {
    try {
      await _dio.post(
        '$_base/reports',
        data: {
          'target_type': targetType,
          'target_id': targetId,
          'reason_code': reasonCode,
          'note': ?note,
        },
      );
    } on DioException catch (e) {
      throw PantunFailure(_messageFrom(e));
    }
  }
}

PantunPage _pageFromJson(Map<String, dynamic>? envelope) {
  final data = envelope?['data'];
  final meta = envelope?['meta'];
  if (data is! List) {
    throw const PantunFailure('Data feed pantun tidak lengkap');
  }
  return PantunPage(
    data
        .map((e) => Pantun.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    meta is Map ? meta['next_cursor'] as String? : null,
    meta is Map ? (meta['has_more'] as bool? ?? false) : false,
  );
}

/// Pesan error dari envelope API (`message`) atau fallback status.
String _messageFrom(DioException e) {
  final data = e.response?.data;
  if (data is Map<String, dynamic>) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
  }
  final status = e.response?.statusCode;
  if (status == 401) return 'Sesi berakhir, silakan masuk kembali';
  if (status == 429) return 'Terlalu banyak permintaan. Coba lagi sebentar.';
  if (status != null && status >= 500) {
    return 'Server sedang gangguan. Coba lagi sebentar ya.';
  }
  return l10n.pantunRequestFailed;
}

final pantunApiProvider = Provider<PantunApi>(
  (ref) => PantunApi(ref.watch(dioProvider)),
);
