import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/i18n/l10n.dart';
import '../domain/community_org.dart';

class CommunityException implements Exception {
  const CommunityException(this.message, {this.code});

  final String message;
  final String? code;
}

class CommunityApi {
  CommunityApi(this._dio);

  final Dio _dio;

  Future<CommunityOrgPage> list({
    String? category,
    String? q,
    String? cursor,
    int limit = 60,
  }) async {
    final res = await _send(
      () => _dio.get<dynamic>(
        '/api/v1/community/orgs',
        queryParameters: {
          'limit': limit,
          if (category != null && category.isNotEmpty) 'category': category,
          if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
        options: Options(receiveTimeout: const Duration(seconds: 8)),
      ),
    );
    final data = _dataMap(res.data);
    return CommunityOrgPage(
      items: CommunityOrgDto.listFromJson(data['items']),
      nextCursor: _stringOrNull(data['next_cursor']),
    );
  }

  Future<CommunityOrg?> detail(String slug) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/community/orgs/${Uri.encodeComponent(slug)}',
        options: Options(receiveTimeout: const Duration(seconds: 8)),
      );
      return CommunityOrgDto.fromJson(_dataMap(res.data)).toDomain();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      final data = e.response?.data;
      if (data is Map) {
        final message = data['message'];
        throw CommunityException(
          message is String && message.isNotEmpty
              ? message
              : l10n.communitySaveFailed,
          code: data['error_code'] as String?,
        );
      }
      throw CommunityException(l10n.communitySaveFailed);
    }
  }

  Future<List<CommunityOrg>> featured() async {
    final res = await _send(
      () => _dio.get<dynamic>(
        '/api/v1/community/featured',
        options: Options(receiveTimeout: const Duration(seconds: 8)),
      ),
    );
    return CommunityOrgDto.listFromJson(_dataMap(res.data)['items']);
  }

  Future<CommunityProposal> submit({
    required String name,
    required String description,
    String? logoUrl,
  }) async {
    final res = await _send(
      () => _dio.post<dynamic>(
        '/api/v1/community/proposals',
        data: {
          'name': name,
          'description': description,
          if (logoUrl != null && logoUrl.isNotEmpty) 'logo_url': logoUrl,
        },
      ),
    );
    return CommunityProposalDto.fromJson(_dataMap(res.data)).toDomain();
  }

  Future<List<CommunityProposal>> mine() async {
    final res = await _send(
      () => _dio.get<dynamic>('/api/v1/community/proposals/mine'),
    );
    return CommunityProposalDto.listFromJson(_dataMap(res.data)['items']);
  }

  Future<void> cancel(String id) async {
    await _send(
      () => _dio.post<dynamic>(
        '/api/v1/community/proposals/${Uri.encodeComponent(id)}/cancel',
      ),
    );
  }

  Future<String> uploadLogo(File file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      ),
    });
    final res = await _send(
      () => _dio.post<dynamic>(
        '/api/v1/images',
        queryParameters: const {'purpose': 'community'},
        data: form,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {Headers.contentTypeHeader: null},
        ),
      ),
    );
    final url = _dataMap(res.data)['url'];
    if (url is! String || url.isEmpty) {
      throw CommunityException(l10n.communityUploadLogoFailed);
    }
    return url;
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
        throw CommunityException(
          message is String && message.isNotEmpty
              ? message
              : l10n.communitySaveFailed,
          code: data['error_code'] as String?,
        );
      }
      throw CommunityException(l10n.communitySaveFailed);
    }
  }
}

class CommunityOrgDto {
  const CommunityOrgDto({
    required this.id,
    required this.slug,
    required this.name,
    required this.category,
    required this.description,
    this.logoUrl,
    this.coverUrl,
    this.featuredKind,
  });

  final String id;
  final String slug;
  final String name;
  final String category;
  final String description;
  final String? logoUrl;
  final String? coverUrl;
  final String? featuredKind;

  factory CommunityOrgDto.fromJson(Map<String, dynamic> json) {
    return CommunityOrgDto(
      id: '${json['id'] ?? ''}',
      slug: '${json['slug'] ?? json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      category: '${json['category'] ?? 'lain'}',
      description: '${json['description'] ?? ''}',
      logoUrl: _stringOrNull(json['logo_url']),
      coverUrl: _stringOrNull(json['cover_url']),
      featuredKind: _stringOrNull(json['is_featured_kind']),
    );
  }

  static List<CommunityOrg> listFromJson(Object? raw) {
    if (raw is! List) return const [];
    return [
      for (final item in raw.whereType<Map>())
        CommunityOrgDto.fromJson(Map<String, dynamic>.from(item)).toDomain(),
    ];
  }

  CommunityOrg toDomain() => CommunityOrg(
    id: id,
    slug: slug,
    name: name,
    category: category,
    description: description,
    logoUrl: logoUrl,
    coverUrl: coverUrl,
    featuredKind: featuredKind,
    isVerified: featuredKind != null,
  );
}

class CommunityProposalDto {
  const CommunityProposalDto({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    this.logoUrl,
    this.reviewNote,
    this.communityOrgId,
  });

  final String id;
  final String name;
  final String description;
  final String status;
  final String createdAt;
  final String? logoUrl;
  final String? reviewNote;
  final String? communityOrgId;

  factory CommunityProposalDto.fromJson(Map<String, dynamic> json) {
    return CommunityProposalDto(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      description: '${json['description'] ?? ''}',
      status: '${json['status'] ?? 'pending'}',
      createdAt: '${json['created_at'] ?? ''}',
      logoUrl: _stringOrNull(json['logo_url']),
      reviewNote: _stringOrNull(json['review_note']),
      communityOrgId: _stringOrNull(json['community_org_id']),
    );
  }

  static List<CommunityProposal> listFromJson(Object? raw) {
    if (raw is! List) return const [];
    return [
      for (final item in raw.whereType<Map>())
        CommunityProposalDto.fromJson(Map<String, dynamic>.from(item))
            .toDomain(),
    ];
  }

  CommunityProposal toDomain() => CommunityProposal(
    id: id,
    name: name,
    description: description,
    status: status,
    createdAt: createdAt,
    logoUrl: logoUrl,
    reviewNote: reviewNote,
    communityOrgId: communityOrgId,
  );
}

Map<String, dynamic> _dataMap(Object? body) {
  if (body is Map && body['data'] is Map) {
    return Map<String, dynamic>.from(body['data'] as Map);
  }
  return const {};
}

String? _stringOrNull(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return value;
}
