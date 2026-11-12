import 'package:dio/dio.dart';

class WordReportFailure implements Exception {
  const WordReportFailure(this.message);

  final String message;
}

class WordReportRepository {
  WordReportRepository(this._dio);

  final Dio _dio;

  Future<void> submit({
    required String wordId,
    required String reasonCode,
    String? note,
    /// Saat diisi, laporan dikaitkan ke gambar tertentu (reason: violent_image).
    String? imageId,
    /// Saat diisi, laporan dikaitkan ke satu makna (#253).
    String? meaningId,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/v1/words/$wordId/reports',
        data: {
          'reason_code': reasonCode,
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
          if (imageId != null && imageId.trim().isNotEmpty)
            'image_id': imageId.trim(),
          if (meaningId != null && meaningId.trim().isNotEmpty)
            'meaning_id': meaningId.trim(),
        },
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String && (data['message'] as String).isNotEmpty) {
        throw WordReportFailure(data['message'] as String);
      }
      throw const WordReportFailure('Gagal mengirim laporan. Coba lagi.');
    }
  }
}
