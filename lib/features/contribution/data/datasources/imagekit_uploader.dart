import 'dart:io';

import 'package:dio/dio.dart';

import '../models/upload_credentials_dto.dart';
import '../../../../core/i18n/l10n.dart';

/// Hasil upload langsung ke CDN ImageKit (bukan envelope sambasku).
class UploadedImageResult {
  const UploadedImageResult({required this.url, required this.fileId});

  final String url;
  final String fileId;
}

/// POST multipart ke `upload_endpoint` - Dio polos, tanpa auth interceptor.
class ImageKitUploader {
  ImageKitUploader({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 60),
                sendTimeout: const Duration(seconds: 60),
              ),
            );

  final Dio _dio;

  Future<UploadedImageResult> upload({
    required File file,
    required UploadCredentialsDto creds,
    String folder = '/words',
  }) async {
    final fileName = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : 'image.jpg';
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
      'fileName': fileName,
      'folder': folder,
      'publicKey': creds.publicKey,
      'token': creds.token,
      'expire': '${creds.expire}',
      'signature': creds.signature,
    });

    final res = await _dio.post<Map<String, dynamic>>(
      creds.uploadEndpoint,
      data: form,
    );
    final data = res.data;
    if (data == null) {
      throw StateError(l10n.contributeImageKitEmpty);
    }
    final url = data['url'] as String?;
    final fileId = data['fileId'] as String?;
    if (url == null || url.isEmpty || fileId == null || fileId.isEmpty) {
      throw StateError(l10n.contributeImageKitIncomplete);
    }
    return UploadedImageResult(url: url, fileId: fileId);
  }
}
