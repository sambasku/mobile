import 'package:dio/dio.dart';

import '../domain/bug_report_models.dart';
import '../../../core/i18n/l10n.dart';

class BugReportRepository {
  BugReportRepository(this._dio);

  final Dio _dio;

  Future<UploadCredentials> getUploadToken() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/bug-reports/upload-token',
        queryParameters: {'folder': '/bug-reports'},
      );
      final data = res.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: res.requestOptions,
          message: l10n.reportBugUploadCredsIncomplete,
        );
      }
      return UploadCredentials.fromJson(data);
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

  Future<BugReportSubmitResult> submit({
    required String description,
    required List<BugReportImageRef> images,
    required String? appVersion,
    required String? platform,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/bug-reports',
      data: {
        'description': description,
        'images': images.map((e) => e.toJson()).toList(),
        'app_version': ?appVersion,
        'platform': ?platform,
      },
    );
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.reportBugResponseIncomplete,
      );
    }
    return BugReportSubmitResult.fromJson(data);
  }
}
