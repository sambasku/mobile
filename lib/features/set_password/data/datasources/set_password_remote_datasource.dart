import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/set_password_request_dto.dart';

part 'set_password_remote_datasource.g.dart';

@RestApi()
abstract interface class SetPasswordRemoteDatasource {
  factory SetPasswordRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _SetPasswordRemoteDatasource;

  @POST('/api/v1/auth/set-password')
  Future<ApiResponse<SetPasswordResponseDto>> setPassword(
    @Body() SetPasswordRequestDto body,
  );
}
