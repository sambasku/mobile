import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../l10n/app_localizations.dart';

/// Unggah gambar isi artikel: `POST /api/v1/images?purpose=encyclopedia`.
class EncyclopediaMarkdownUpload {
  EncyclopediaMarkdownUpload(this._dio, this._l10n);

  final Dio _dio;
  final AppLocalizations _l10n;

  Future<String> upload(File file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      ),
    });
    try {
      final res = await _dio.post<dynamic>(
        '/api/v1/images',
        queryParameters: const {'purpose': 'encyclopedia'},
        data: form,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {Headers.contentTypeHeader: null},
        ),
      );
      final root = res.data;
      final data = root is Map && root['data'] is Map
          ? root['data'] as Map
          : root is Map
              ? root
              : null;
      final url = data?['url'];
      if (url is! String || url.isEmpty) {
        throw EncyclopediaMarkdownUploadException(_l10n.mdEditorUploadFailed);
      }
      return url;
    } on DioException catch (e) {
      final payload = e.response?.data;
      if (payload is Map) {
        final message = payload['message'];
        throw EncyclopediaMarkdownUploadException(
          message is String && message.isNotEmpty
              ? message
              : _l10n.mdEditorUploadFailed,
          code: payload['error_code'] as String?,
        );
      }
      throw EncyclopediaMarkdownUploadException(_l10n.mdEditorUploadFailed);
    }
  }
}

class EncyclopediaMarkdownUploadException implements Exception {
  EncyclopediaMarkdownUploadException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => message;
}

final encyclopediaMarkdownUploadProvider =
    Provider.family<EncyclopediaMarkdownUpload, AppLocalizations>(
  (ref, l10n) => EncyclopediaMarkdownUpload(ref.watch(dioProvider), l10n),
);
