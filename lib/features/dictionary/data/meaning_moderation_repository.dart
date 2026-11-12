import 'package:dio/dio.dart';

class MeaningModerationFailure implements Exception {
  const MeaningModerationFailure(this.message);

  final String message;
}

/// Soft-delete makna (#253) - verifikator saja di API.
class MeaningModerationRepository {
  MeaningModerationRepository(this._dio);

  final Dio _dio;

  Future<void> softDelete({
    required String wordId,
    required String meaningId,
  }) async {
    try {
      await _dio.delete<void>('/api/v1/words/$wordId/meanings/$meaningId');
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map &&
          data['message'] is String &&
          (data['message'] as String).isNotEmpty) {
        throw MeaningModerationFailure(data['message'] as String);
      }
      throw const MeaningModerationFailure(
        'Gagal menghapus makna. Coba lagi.',
      );
    }
  }
}
