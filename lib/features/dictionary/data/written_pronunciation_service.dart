import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/i18n/l10n.dart';
import '../presentation/utils/pronunciation_format.dart';

class WrittenPronunciationFailure {
  const WrittenPronunciationFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;
}

/// POST JSON `/api/v1/words/:wordId/pronunciations` - value raw tanpa slash.
class WrittenPronunciationService {
  WrittenPronunciationService(this._dio);

  final Dio _dio;

  Future<Either<WrittenPronunciationFailure, void>> create({
    required String wordId,
    required String value,
  }) async {
    final raw = pronunciationRaw(value);
    if (raw.isEmpty) {
      return Either.left(
        WrittenPronunciationFailure(l10n.dictAddPronunciationEmpty),
      );
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/words/$wordId/pronunciations',
        data: <String, dynamic>{
          'notation': 'ipa',
          'value': raw,
        },
      );
      final body = response.data;
      if (body != null && body['success'] == false) {
        return Either.left(
          WrittenPronunciationFailure(
            body['message']?.toString() ?? l10n.dictAddPronunciationFailed,
            errorCode: body['error_code']?.toString(),
          ),
        );
      }
      return Either.right(null);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return Either.left(
            WrittenPronunciationFailure(
              message,
              errorCode: data['error_code']?.toString(),
            ),
          );
        }
      }
      return Either.left(
        WrittenPronunciationFailure(l10n.dictAddPronunciationFailed),
      );
    } catch (_) {
      return Either.left(
        WrittenPronunciationFailure(l10n.dictAddPronunciationFailed),
      );
    }
  }
}
