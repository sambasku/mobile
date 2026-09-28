import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

/// Upload / hapus avatar milik user login.
class AvatarUploadService {
  AvatarUploadService(this._dio);

  final Dio _dio;

  Future<Either<String, String>> upload(File file) async {
    try {
      final fileName = file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : 'avatar.webp';
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/users/me/avatar',
        data: form,
      );
      final data = res.data?['data'];
      if (data is Map<String, dynamic>) {
        final url = data['avatar_url'] as String?;
        if (url != null && url.isNotEmpty) return Either.right(url);
      }
      return Either.left('Gagal mengunggah foto profil');
    } on DioException catch (e) {
      final msg = e.response?.data;
      if (msg is Map && msg['message'] is String) {
        return Either.left(msg['message'] as String);
      }
      return Either.left('Gagal mengunggah foto profil');
    } catch (_) {
      return Either.left('Gagal mengunggah foto profil');
    }
  }

  Future<Either<String, void>> delete() async {
    try {
      await _dio.delete<void>('/api/v1/users/me/avatar');
      return Either.right(null);
    } on DioException catch (e) {
      final msg = e.response?.data;
      if (msg is Map && msg['message'] is String) {
        return Either.left(msg['message'] as String);
      }
      return Either.left('Gagal menghapus foto profil');
    } catch (_) {
      return Either.left('Gagal menghapus foto profil');
    }
  }
}
