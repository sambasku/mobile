import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class PronunciationUploadFailure {
  const PronunciationUploadFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  bool get isUploadUnavailable =>
      errorCode == 'PRONUNCIACION_UPLOAD_UNAVAILABLE';

  bool get isRateLimited => errorCode == 'RATE_LIMITED';
}

/// POST multipart `/api/v1/words/:wordId/pronunciations/audio`.
class PronunciationAudioUploadService {
  PronunciationAudioUploadService(this._dio);

  final Dio _dio;

  Future<Either<PronunciationUploadFailure, void>> upload({
    required String wordId,
    required File audioFile,
    String? speakerName,
    required int durationMs,
    String? dialectId,
    String? exampleId,
  }) async {
    try {
      final name = audioFile.path.split(Platform.pathSeparator).last;
      final lower = name.toLowerCase();
      final (mimeType, filename) = lower.endsWith('.wav')
          ? (DioMediaType('audio', 'wav'), name.endsWith('.wav') ? name : 'recording.wav')
          : lower.endsWith('.webm')
              ? (DioMediaType('audio', 'webm'), 'recording.webm')
              : lower.endsWith('.ogg')
                  ? (DioMediaType('audio', 'ogg'), 'recording.ogg')
                  : lower.endsWith('.mp3')
                      ? (DioMediaType('audio', 'mpeg'), 'recording.mp3')
                      : (DioMediaType('audio', 'mp4'), 'recording.m4a');

      final trimmedSpeaker = speakerName?.trim();
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFile.path,
          filename: filename,
          contentType: mimeType,
        ),
        if (trimmedSpeaker != null && trimmedSpeaker.isNotEmpty)
          'speaker_name': trimmedSpeaker,
        'duration_ms': durationMs,
        if (dialectId != null && dialectId.isNotEmpty) 'dialect_id': dialectId,
        if (exampleId != null && exampleId.isNotEmpty) 'example_id': exampleId,
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/words/$wordId/pronunciations/audio',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final body = response.data;
      if (body != null && body['success'] == false) {
        return Either.left(
          PronunciationUploadFailure(
            body['message']?.toString() ?? 'Gagal mengunggah audio',
            errorCode: body['error_code']?.toString(),
          ),
        );
      }

      return Either.right(null);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final code = data['error_code']?.toString();
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return Either.left(
            PronunciationUploadFailure(message, errorCode: code),
          );
        }
      }
      if (status == 503) {
        return Either.left(
          PronunciationUploadFailure(
            'Unggah audio pelafalan belum tersedia',
            errorCode: 'PRONUNCIACION_UPLOAD_UNAVAILABLE',
          ),
        );
      }
      return Either.left(
        PronunciationUploadFailure(
          e.message ?? 'Gagal mengunggah audio, periksa koneksi',
        ),
      );
    } catch (e) {
      return Either.left(PronunciationUploadFailure(e.toString()));
    }
  }
}
