import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/create_word_request_dto.dart';
import '../models/duplicate_confirm_response_dto.dart';
import '../models/submit_word_response_dto.dart';

part 'contribution_remote_datasource.g.dart';

/// Endpoint submit kata (publik, anonim).
///
/// Body valid = 201 Created { data: { word_id, status: 'pending_review' } }.
/// Body invalid / referensi tidak ada = 400 VALIDATION_ERROR details[].
@RestApi()
abstract interface class ContributionRemoteDatasource {
  factory ContributionRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _ContributionRemoteDatasource;

  @POST('/api/v1/contributions/words')
  Future<ApiResponse<SubmitWordResponseDto>> submitWord(
    @Body() CreateWordRequestDto body,
  );

  /// Konfirmasi makna duplikat (vote + riwayat) - POST duplicate-confirm.
  @POST('/api/v1/contributions/duplicate-confirm')
  Future<ApiResponse<DuplicateConfirmResponseDto>> confirmDuplicateMeaning(
    @Body() Map<String, dynamic> body,
  );
}
