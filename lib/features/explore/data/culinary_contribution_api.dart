import 'dart:io';

import 'package:dio/dio.dart';

import '../domain/entities/culinary_proposal.dart';
import '../../../../core/i18n/l10n.dart';

/// Klien usulan/klaim/laporan kuliner (`/api/v1/culinary*`).
///
/// Usulan boleh anonim; klaim & laporan wajib token. Pesan error server
/// diteruskan apa adanya supaya bottom sheet bisa jelaskan sebab + aksi.
class CulinaryContributionApi {
  CulinaryContributionApi(this._dio);

  final Dio _dio;

  Future<void> submitNewCuisine({
    required String name,
    String? description,
    String? categoryId,
    String? originRegion,
    List<String> ingredients = const [],
    String? servingSuggestion,
    List<String> tags = const [],
    List<Map<String, dynamic>> images = const [],
  }) => _send(
    () => _dio.post<dynamic>(
      '/api/v1/culinary/contributions',
      data: {
        'kind': 'new_cuisine',
        'payload': {
          'name': name,
          if (description != null && description.trim().isNotEmpty)
            'description': description.trim(),
          if (categoryId != null && categoryId.isNotEmpty)
            'category_id': categoryId,
          if (originRegion != null && originRegion.trim().isNotEmpty)
            'origin_region': originRegion.trim(),
          if (ingredients.isNotEmpty) 'ingredients': ingredients,
          if (servingSuggestion != null && servingSuggestion.trim().isNotEmpty)
            'serving_suggestion': servingSuggestion.trim(),
          if (tags.isNotEmpty) 'tags': tags,
          if (images.isNotEmpty) 'images': images,
        },
      },
    ),
  );

  Future<void> submitNewPlace({
    required String name,
    String? type,
    String? description,
    String? locationHint,
    String? addressText,
    double? lat,
    double? lng,
    String? phone,
    String? whatsapp,
    String? website,
    String? socialUrl,
    String? coverUrl,
  }) => _send(
    () => _dio.post<dynamic>(
      '/api/v1/culinary/contributions',
      data: {
        'kind': 'new_place',
        'payload': {
          'name': name,
          'type': ?type,
          if (description != null && description.trim().isNotEmpty)
            'description': description.trim(),
          if (locationHint != null && locationHint.trim().isNotEmpty)
            'location_hint': locationHint.trim(),
          if (addressText != null && addressText.trim().isNotEmpty)
            'address_text': addressText.trim(),
          if (lat != null && lng != null) 'lat': lat,
          if (lat != null && lng != null) 'lng': lng,
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
          if (whatsapp != null && whatsapp.trim().isNotEmpty)
            'whatsapp': whatsapp.trim(),
          if (website != null && website.trim().isNotEmpty)
            'website': website.trim(),
          if (socialUrl != null && socialUrl.trim().isNotEmpty)
            'social_url': socialUrl.trim(),
          if (coverUrl != null && coverUrl.isNotEmpty) 'cover_url': coverUrl,
        },
      },
    ),
  );

  /// Pengajuan perbaikan/hubungan umum (payload per `kind`).
  ///
  /// `cuisine_edit`/`place_operational`/`archive`/`restore` butuh id entitas
  /// (bukan slug); `link` butuh slug pasangan di dalam payload.
  Future<void> submitChange({
    required String kind,
    String? cuisineId,
    String? placeId,
    String? linkId,
    Map<String, dynamic> payload = const {},
    List<String> fields = const [],
  }) => _send(
    () => _dio.post<dynamic>(
      '/api/v1/culinary/contributions/change',
      data: {
        'kind': kind,
        'cuisine_id': ?cuisineId,
        'place_id': ?placeId,
        'link_id': ?linkId,
        'payload': payload,
        if (fields.isNotEmpty) 'fields': fields,
      },
    ),
  );

  /// Usulkan hubungan kuliner-tempat (mis. warung X jual bubur pedas).
  Future<void> submitLink({
    required String cuisineSlug,
    required String placeSlug,
    String? availability,
    String? note,
  }) => _send(
    () => _dio.post<dynamic>(
      '/api/v1/culinary/contributions/change',
      data: {
        'kind': 'link',
        'payload': {
          'cuisineSlug': cuisineSlug,
          'placeSlug': placeSlug,
          'availability': ?availability,
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        },
      },
    ),
  );

  /// Klaim pengelolaan tempat. `contactEvidence` privat, tidak pernah
  /// dikembalikan ke publik.
  Future<void> claimPlace(
    String slug, {
    required String contactEvidence,
    String? note,
  }) => _send(
    () => _dio.post<dynamic>(
      '/api/v1/culinary/places/${Uri.encodeComponent(slug)}/claims',
      data: {
        'contact_evidence': contactEvidence,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    ),
  );

  /// Usulan milik user login (semua kind: baru, edit, link, status, arsip).
  Future<List<CulinaryProposal>> mine() async {
    final res = await _send(
      () => _dio.get<dynamic>('/api/v1/culinary/contributions/mine'),
    );
    final body = res.data;
    final items = body is Map && body['data'] is Map
        ? (body['data'] as Map)['items']
        : null;
    if (items is! List) return const [];
    return [
      for (final raw in items.whereType<Map>())
        CulinaryProposal(
          id: '${raw['id']}',
          kind: '${raw['kind'] ?? ''}',
          status: '${raw['status'] ?? 'pending'}',
          createdAt: DateTime.tryParse('${raw['created_at'] ?? ''}'),
          name: (raw['payload'] as Map?)?['name'] as String?,
          cuisineName: raw['cuisine_name'] as String?,
          placeName: raw['place_name'] as String?,
          revisionNote: raw['revision_note'] as String?,
          rejectReasonCode: raw['reject_reason_code'] as String?,
          rejectReasonText: raw['reject_reason_text'] as String?,
        ),
    ];
  }

  /// Batalkan usulan yang masih pending / perlu revisi.
  Future<void> cancelContribution(String id) => _send(
    () => _dio.delete<dynamic>(
      '/api/v1/culinary/contributions/${Uri.encodeComponent(id)}',
    ),
  );

  Future<void> reportPlace(
    String slug, {
    required String reasonCode,
    String? note,
  }) => _report(
    '/api/v1/culinary/places/${Uri.encodeComponent(slug)}/reports',
    reasonCode,
    note,
  );

  Future<void> reportCuisine(
    String slug, {
    required String reasonCode,
    String? note,
  }) => _report(
    '/api/v1/culinary/cuisines/${Uri.encodeComponent(slug)}/reports',
    reasonCode,
    note,
  );

  Future<void> _report(String path, String reasonCode, String? note) => _send(
    () => _dio.post<dynamic>(
      path,
      data: {
        'reason_code': reasonCode,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    ),
  );

  /// Unggah foto usulan kuliner (maks 5 MB, anonim boleh) - URL https.
  Future<String> uploadImage(File file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      ),
    });
    final res = await _send(
      () => _dio.post<dynamic>(
        '/api/v1/culinary/contributions/images',
        data: form,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {Headers.contentTypeHeader: null},
        ),
      ),
    );
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      final url = (data['data'] as Map)['url'];
      if (url is String && url.isNotEmpty) return url;
    }
    throw CulinaryException(l10n.exploreUploadImageFailed);
  }

  Future<Response<dynamic>> _send(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      return await call();
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        final message = data['message'];
        throw CulinaryException(
          message is String && message.isNotEmpty
              ? message
              : l10n.exploreSubmitFailed,
          code: data['error_code'] as String?,
        );
      }
      throw CulinaryException(l10n.exploreSubmitFailed);
    }
  }
}

/// Error usulan/klaim kuliner - `code` untuk bedakan rate limit / field lock.
class CulinaryException implements Exception {
  const CulinaryException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}
