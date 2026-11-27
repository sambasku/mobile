import 'package:dio/dio.dart';

class LemmaMergeRemote {
  LemmaMergeRemote(this._dio);

  final Dio _dio;

  Future<LemmaMergeResult> create({
    required String keepWordId,
    required List<String> mergeWordIds,
    String? reasonText,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/words/lemma-merges',
      data: {
        'keep_word_id': keepWordId,
        'merge_word_ids': mergeWordIds,
        if (reasonText != null && reasonText.trim().isNotEmpty)
          'reason_text': reasonText.trim(),
      },
    );
    final data = res.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'Response tidak valid',
      );
    }
    return LemmaMergeResult(
      message: data['message'] as String? ?? '',
      applied: (data['status'] as String?) == 'approved',
    );
  }
}

class LemmaMergeResult {
  const LemmaMergeResult({required this.message, required this.applied});

  final String message;
  final bool applied;
}