import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../domain/discussion_models.dart';

class DiscussionRepository {
  DiscussionRepository(this._dio);

  final Dio _dio;

  static const _base = '/api/v1/discussions';

  Future<DiscussionUploadCredentials> getUploadToken() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_base/upload-token',
        queryParameters: {'folder': '/discussions'},
      );
      final data = res.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: res.requestOptions,
          message: 'Kredensial upload tidak lengkap',
        );
      }
      return DiscussionUploadCredentials.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 503) {
        final code = (e.response?.data is Map)
            ? (e.response!.data as Map)['error_code']
            : null;
        if (code == 'IMAGE_UPLOAD_UNAVAILABLE') {
          throw const ImageUploadUnavailable();
        }
      }
      rethrow;
    }
  }

  Future<DiscussionSubmitResult> create({
    required String body,
    String? linkUrl,
    required List<DiscussionImageRef> images,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      _base,
      data: {
        'body': body.trim(),
        if (linkUrl != null && linkUrl.trim().isNotEmpty)
          'link_url': linkUrl.trim(),
        'images': images.map((e) => e.toJson()).toList(),
      },
    );
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'Response diskusi tidak lengkap',
      );
    }
    return DiscussionSubmitResult.fromJson(data);
  }

  Future<Either<DiscussionFailure, Unit>> attachTopicAudio({
    required String discussionId,
    required File audioFile,
    required int durationMs,
  }) async {
    try {
      final name = audioFile.path.split(Platform.pathSeparator).last;
      final lower = name.toLowerCase();
      final (mimeType, filename) = lower.endsWith('.wav')
          ? (
              DioMediaType('audio', 'wav'),
              name.endsWith('.wav') ? name : 'recording.wav',
            )
          : lower.endsWith('.webm')
          ? (DioMediaType('audio', 'webm'), 'recording.webm')
          : lower.endsWith('.ogg')
          ? (DioMediaType('audio', 'ogg'), 'recording.ogg')
          : lower.endsWith('.mp3')
          ? (DioMediaType('audio', 'mpeg'), 'recording.mp3')
          : (DioMediaType('audio', 'mp4'), 'recording.m4a');

      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFile.path,
          filename: filename,
          contentType: mimeType,
        ),
        'duration_ms': durationMs,
      });

      await _dio.post<Map<String, dynamic>>(
        '$_base/$discussionId/audio',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return Either.right(unit);
    } on DioException catch (e) {
      return Either.left(_mapDio(e, 'Gagal mengirim rekaman suara'));
    } catch (e) {
      return Either.left(DiscussionFailure(e.toString()));
    }
  }

  Future<Either<DiscussionFailure, DiscussionPage>> listPublished({
    int limit = 20,
    String? cursor,
    String sort = 'latest',
  }) async {
    try {
      final query = <String, dynamic>{
        'limit': limit,
        'sort': sort,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      };
      final res = await _dio.get<Map<String, dynamic>>(
        _base,
        queryParameters: query,
      );
      return Either.right(_parsePage(res.data));
    } on DioException catch (e) {
      return Either.left(_mapDio(e, 'Gagal memuat diskusi'));
    } catch (e) {
      return Either.left(DiscussionFailure(e.toString()));
    }
  }

  Future<Either<DiscussionFailure, DiscussionPage>> listMine({
    int limit = 20,
    String? cursor,
    String? status,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_base/my',
        queryParameters: {
          'limit': limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );
      return Either.right(_parsePage(res.data));
    } on DioException catch (e) {
      return Either.left(_mapDio(e, 'Gagal memuat riwayat diskusi'));
    } catch (e) {
      return Either.left(DiscussionFailure(e.toString()));
    }
  }

  Future<Either<DiscussionFailure, DiscussionItem>> getDetail(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('$_base/$id');
      final raw = res.data?['data'];
      final data = (raw is Map) ? Map<String, dynamic>.from(raw) : null;
      if (data == null) {
        return Either.left(
          const DiscussionFailure('Detail diskusi tidak lengkap'),
        );
      }
      return Either.right(DiscussionItem.fromJson(data));
    } on DioException catch (e) {
      return Either.left(_mapDio(e, 'Gagal memuat detail diskusi'));
    } catch (e) {
      return Either.left(DiscussionFailure(e.toString()));
    }
  }

  Future<Either<DiscussionFailure, DiscussionReply>> createReply({
    required String discussionId,
    required String body,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '$_base/$discussionId/replies',
        data: {'body': body.trim()},
      );
      final data = res.data?['data'];
      if (data is! Map) {
        return Either.left(
          const DiscussionFailure('Balasan tidak lengkap'),
        );
      }
      return Either.right(
        DiscussionReply.fromJson(Map<String, dynamic>.from(data)),
      );
    } on DioException catch (e) {
      return Either.left(_mapDio(e, 'Gagal mengirim balasan'));
    } catch (e) {
      return Either.left(DiscussionFailure(e.toString()));
    }
  }

  Future<Either<DiscussionFailure, DiscussionReply>> createReplyAudio({
    required String discussionId,
    required File audioFile,
    required int durationMs,
    String? body,
  }) async {
    try {
      final name = audioFile.path.split(Platform.pathSeparator).last;
      final lower = name.toLowerCase();
      final (mimeType, filename) = lower.endsWith('.wav')
          ? (
              DioMediaType('audio', 'wav'),
              name.endsWith('.wav') ? name : 'recording.wav',
            )
          : lower.endsWith('.webm')
          ? (DioMediaType('audio', 'webm'), 'recording.webm')
          : lower.endsWith('.ogg')
          ? (DioMediaType('audio', 'ogg'), 'recording.ogg')
          : lower.endsWith('.mp3')
          ? (DioMediaType('audio', 'mpeg'), 'recording.mp3')
          : (DioMediaType('audio', 'mp4'), 'recording.m4a');

      final caption = body?.trim();
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFile.path,
          filename: filename,
          contentType: mimeType,
        ),
        'duration_ms': durationMs,
        if (caption != null && caption.isNotEmpty) 'body': caption,
      });

      final res = await _dio.post<Map<String, dynamic>>(
        '$_base/$discussionId/replies/audio',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = res.data?['data'];
      if (data is! Map) {
        return Either.left(
          const DiscussionFailure('Balasan suara tidak lengkap'),
        );
      }
      return Either.right(
        DiscussionReply.fromJson(Map<String, dynamic>.from(data)),
      );
    } on DioException catch (e) {
      return Either.left(_mapDio(e, 'Gagal mengirim rekaman suara'));
    } catch (e) {
      return Either.left(DiscussionFailure(e.toString()));
    }
  }

  Future<Either<DiscussionFailure, Unit>> deleteReply(String replyId) async {
    try {
      await _dio.delete<Map<String, dynamic>>('$_base/replies/$replyId');
      return Either.right(unit);
    } on DioException catch (e) {
      return Either.left(_mapDio(e, 'Gagal menghapus balasan'));
    } catch (e) {
      return Either.left(DiscussionFailure(e.toString()));
    }
  }

  // --- Admin moderasi (GET/POST /api/v1/admin/discussions) ---

  static const _adminBase = '/api/v1/admin/discussions';

  Future<Either<DiscussionFailure, DiscussionPage>> listAdmin({
    String? status,
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        _adminBase,
        queryParameters: {
          'limit': limit,
          if (status != null && status.isNotEmpty) 'status': status,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      return Either.right(_parsePage(res.data));
    } on DioException catch (e) {
      return Either.left(_mapDio(e, 'Gagal memuat antrean diskusi'));
    } catch (e) {
      return Either.left(DiscussionFailure(e.toString()));
    }
  }

  Future<Either<DiscussionFailure, DiscussionItem>> getAdminDetail(
    String id,
  ) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('$_adminBase/$id');
      final raw = res.data?['data'];
      if (raw is! Map) {
        return Either.left(
          const DiscussionFailure('Detail diskusi tidak lengkap'),
        );
      }
      return Either.right(
        DiscussionItem.fromJson(Map<String, dynamic>.from(raw)),
      );
    } on DioException catch (e) {
      return Either.left(_mapDio(e, 'Gagal memuat detail diskusi'));
    } catch (e) {
      return Either.left(DiscussionFailure(e.toString()));
    }
  }

  Future<Either<DiscussionFailure, DiscussionItem>> approveAdmin(
    String id, {
    List<List<int>?>? censoredFiles,
    List<List<String>>? contentWarnings,
  }) async {
    try {
      final hasCensored =
          censoredFiles?.any((f) => f != null && f.isNotEmpty) ?? false;
      final hasWarnings =
          contentWarnings?.any((w) => w.isNotEmpty) ?? false;

      final Response<Map<String, dynamic>> res;
      if (!hasCensored && !hasWarnings) {
        res = await _dio.post<Map<String, dynamic>>(
          '$_adminBase/$id/approve',
          data: <String, dynamic>{},
        );
      } else if (!hasCensored && hasWarnings) {
        res = await _dio.post<Map<String, dynamic>>(
          '$_adminBase/$id/approve',
          data: {'content_warnings': contentWarnings},
        );
      } else {
        final form = FormData();
        final files = censoredFiles ?? const <List<int>?>[];
        for (var i = 0; i < files.length; i++) {
          final bytes = files[i];
          if (bytes != null && bytes.isNotEmpty) {
            form.files.add(
              MapEntry(
                'file_$i',
                MultipartFile.fromBytes(
                  bytes,
                  filename: 'censored_$i.png',
                  contentType: DioMediaType('image', 'png'),
                ),
              ),
            );
          } else {
            form.files.add(
              MapEntry(
                'file_$i',
                MultipartFile.fromBytes(
                  const <int>[],
                  filename: 'empty_$i.bin',
                  contentType: DioMediaType('application', 'octet-stream'),
                ),
              ),
            );
          }
        }
        if (contentWarnings != null) {
          form.fields.add(
            MapEntry('content_warnings', jsonEncode(contentWarnings)),
          );
        }
        res = await _dio.post<Map<String, dynamic>>(
          '$_adminBase/$id/approve',
          data: form,
        );
      }

      final raw = res.data?['data'];
      if (raw is! Map) {
        return Either.left(
          const DiscussionFailure('Respons approve tidak lengkap'),
        );
      }
      return Either.right(
        DiscussionItem.fromJson(Map<String, dynamic>.from(raw)),
      );
    } on DioException catch (e) {
      return Either.left(_mapDio(e, 'Gagal menyetujui diskusi'));
    } catch (e) {
      return Either.left(DiscussionFailure(e.toString()));
    }
  }

  Future<Either<DiscussionFailure, DiscussionItem>> rejectAdmin({
    required String id,
    required String note,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '$_adminBase/$id/reject',
        data: {'note': note.trim()},
      );
      final raw = res.data?['data'];
      if (raw is! Map) {
        return Either.left(
          const DiscussionFailure('Respons reject tidak lengkap'),
        );
      }
      return Either.right(
        DiscussionItem.fromJson(Map<String, dynamic>.from(raw)),
      );
    } on DioException catch (e) {
      return Either.left(_mapDio(e, 'Gagal menolak diskusi'));
    } catch (e) {
      return Either.left(DiscussionFailure(e.toString()));
    }
  }

  DiscussionPage _parsePage(Map<String, dynamic>? body) {
    final data = body?['data'];
    final meta = body?['meta'];
    final items = <DiscussionItem>[];
    if (data is List) {
      for (final raw in data.whereType<Map>()) {
        items.add(
          DiscussionItem.fromJson(Map<String, dynamic>.from(raw)),
        );
      }
    }
    return DiscussionPage(
      items: items,
      nextCursor: meta is Map ? meta['next_cursor']?.toString() : null,
      hasMore: meta is Map && meta['has_more'] == true,
    );
  }

  DiscussionFailure _mapDio(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map) {
      var message = data['message']?.toString() ?? fallback;
      if (error.response?.statusCode == 429) {
        final retry = error.response?.headers.value('retry-after');
        if (retry != null && retry.isNotEmpty) {
          message = '$message Coba lagi dalam $retry detik.';
        }
      }
      return DiscussionFailure(
        message,
        errorCode: data['error_code']?.toString(),
      );
    }
    return DiscussionFailure(switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Koneksi lambat, coba lagi',
      DioExceptionType.connectionError => 'Tidak ada koneksi internet',
      _ => fallback,
    });
  }
}
