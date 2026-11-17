import 'package:dio/dio.dart';

import '../domain/karya.dart';

class KaryaException implements Exception {
  KaryaException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class KaryaApi {
  KaryaApi(this._dio);

  final Dio _dio;

  Future<List<KaryaEntry>> list({
    String? kind,
    int? year,
    String? q,
  }) async {
    final params = <String, dynamic>{};
    if (kind != null && kind.isNotEmpty) params['kind'] = kind;
    if (year != null) params['year'] = year;
    if (q != null && q.trim().isNotEmpty) params['q'] = q.trim();
    final res = await _dio.get<dynamic>(
      '/api/v1/karya',
      queryParameters: params.isEmpty ? null : params,
    );
    final items = _map(res.data)['items'];
    if (items is! List) return const [];
    return items.whereType<Map>().map((raw) => _entry(raw)).toList();
  }

  Future<KaryaEntry?> bySlug(String slug) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/karya/${Uri.encodeComponent(slug)}',
      );
      return _entry(_map(res.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> submit(Map<String, dynamic> body) async {
    await _dio.post<dynamic>('/api/v1/karya-contributions', data: body);
  }

  Future<List<KaryaProposal>> mine() async {
    final res = await _dio.get<dynamic>('/api/v1/karya-contributions/mine');
    final items = _map(res.data)['items'];
    if (items is! List) return const [];
    return items.whereType<Map>().map((raw) {
      final payload = raw['payload'];
      final map = payload is Map ? payload : const {};
      final title = map['title'] is String
          ? map['title'] as String
          : (map['text'] is String ? map['text'] as String : '');
      return KaryaProposal(
        id: '${raw['id']}',
        kind: '${raw['kind']}',
        status: '${raw['status']}',
        title: title,
        revisionNote: raw['revision_note'] as String?,
      );
    }).toList();
  }

  Map<String, dynamic> _map(Object? body) {
    if (body is Map && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    if (body is Map) return Map<String, dynamic>.from(body);
    return const {};
  }

  KaryaEntry _entry(Map raw) {
    final updated = DateTime.tryParse('${raw['updated_at']}') ?? DateTime.now();
    return KaryaEntry(
      id: '${raw['id']}',
      slug: '${raw['slug']}',
      title: '${raw['title']}',
      kind: '${raw['kind']}',
      year: (raw['year'] as num?)?.toInt() ?? 0,
      language: raw['language'] as String?,
      description: raw['description'] as String?,
      coverUrl: raw['cover_url'] as String?,
      sambasConnections: _sambas(raw['sambas_connections']),
      accessLinks: _access(raw['access_links']),
      credits: _credits(raw['credits']),
      excerpts: _excerpts(raw['excerpts']),
      musicReleaseType: raw['music_release_type'] as String?,
      musicDurationMs: (raw['music_duration_ms'] as num?)?.toInt(),
      musicIsCover: raw['music_is_cover'] == true,
      filmType: raw['film_type'] as String?,
      filmRuntimeMin: (raw['film_runtime_min'] as num?)?.toInt(),
      updatedAt: updated.toLocal(),
    );
  }

  List<KaryaSambasConnection> _sambas(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((row) => KaryaSambasConnection(
              type: '${row['type'] ?? ''}',
              note: '${row['note'] ?? ''}',
            ))
        .where((c) => c.type.isNotEmpty && c.note.isNotEmpty)
        .toList();
  }

  List<KaryaAccessLink> _access(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((row) => KaryaAccessLink(
              kind: '${row['kind'] ?? ''}',
              label: '${row['label'] ?? ''}',
              url: '${row['url'] ?? ''}',
              isPrimary: row['is_primary'] == true,
            ))
        .where((l) => l.url.isNotEmpty && l.label.isNotEmpty)
        .toList();
  }

  List<KaryaCredit> _credits(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((row) => KaryaCredit(
              id: row['id'] as String?,
              role: '${row['role'] ?? ''}',
              nameText: '${row['name_text'] ?? ''}',
              kreatorId: row['kreator_id'] as String?,
              kreatorSlug: row['kreator_slug'] as String?,
              sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
            ))
        .where((c) => c.role.isNotEmpty && c.nameText.isNotEmpty)
        .toList();
  }

  Future<KreatorProfile?> kreatorBySlug(String slug) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/kreators/${Uri.encodeComponent(slug)}',
      );
      final data = _map(res.data);
      final kreator = data['kreator'];
      if (kreator is! Map) return null;
      final karyasRaw = data['karyas'];
      final karyas = karyasRaw is List
          ? karyasRaw
              .whereType<Map>()
              .map(
                (row) => KreatorKaryaSummary(
                  id: '${row['id']}',
                  slug: '${row['slug']}',
                  title: '${row['title']}',
                  kind: '${row['kind']}',
                  year: (row['year'] as num?)?.toInt() ?? 0,
                  role: '${row['role'] ?? ''}',
                ),
              )
              .where((k) => k.slug.isNotEmpty && k.title.isNotEmpty)
              .toList()
          : const <KreatorKaryaSummary>[];
      final linksRaw = kreator['links'];
      final links = linksRaw is List
          ? linksRaw
              .whereType<Map>()
              .map(
                (row) => KreatorLink(
                  label: '${row['label'] ?? ''}',
                  url: '${row['url'] ?? ''}',
                ),
              )
              .where((l) => l.url.isNotEmpty)
              .toList()
          : const <KreatorLink>[];
      return KreatorProfile(
        id: '${kreator['id']}',
        slug: '${kreator['slug']}',
        displayName: '${kreator['display_name']}',
        kind: '${kreator['kind'] ?? 'person'}',
        bio: kreator['bio'] as String?,
        originRegion: kreator['origin_region'] as String?,
        links: links,
        karyas: karyas,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> claimKreator(String slug, {required String proofNote}) async {
    await _dio.post<dynamic>(
      '/api/v1/kreators/${Uri.encodeComponent(slug)}/claim',
      data: {'proof_note': proofNote},
    );
  }

  List<KaryaExcerpt> _excerpts(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((row) => KaryaExcerpt(
              id: '${row['id']}',
              kind: '${row['kind'] ?? ''}',
              text: '${row['text'] ?? ''}',
              language: row['language'] as String?,
              startLabel: row['start_label'] as String?,
              endLabel: row['end_label'] as String?,
              rightsStatus: '${row['rights_status'] ?? ''}',
              sourceUrl: row['source_url'] as String?,
            ))
        .where((e) => e.text.isNotEmpty)
        .toList();
  }
}

String karyaErrorMessage(Object error) {
  if (error is KaryaException) return error.message;
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        final parts = <String>[];
        for (final row in errors) {
          if (row is! Map) continue;
          final message = row['message'];
          if (message is String && message.trim().isNotEmpty) {
            parts.add(message.trim());
          }
        }
        if (parts.isNotEmpty) return parts.join('\n');
      }
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
  }
  return '';
}

/// Payload wire untuk usulan baru / edit.
Map<String, dynamic> karyaPayloadWire({
  required String title,
  required int year,
  required String kind,
  required List<Map<String, String>> sambasConnections,
  required List<Map<String, String>> credits,
  List<Map<String, dynamic>> accessLinks = const [],
  String? description,
}) {
  return {
    'title': title,
    'year': year,
    'kind': kind,
    'sambas_connections': sambasConnections,
    'credits': credits
        .map(
          (c) => {
            'role': c['role'],
            'name_text': c['name_text'],
          },
        )
        .toList(),
    if (description != null && description.isNotEmpty) 'description': description,
    if (accessLinks.isNotEmpty) 'access_links': accessLinks,
  };
}