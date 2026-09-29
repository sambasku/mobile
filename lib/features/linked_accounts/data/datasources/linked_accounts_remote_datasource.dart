import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/auth_providers_dto.dart';
import '../models/github_link_request_dto.dart';

part 'linked_accounts_remote_datasource.g.dart';

@RestApi()
abstract interface class LinkedAccountsRemoteDatasource {
  factory LinkedAccountsRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _LinkedAccountsRemoteDatasource;

  @GET('/api/v1/auth/providers')
  Future<ApiResponse<AuthProvidersDto>> listProviders();

  @POST('/api/v1/auth/google/link')
  Future<ApiResponse<GoogleLinkResponseDto>> linkGoogle(
    @Body() GoogleLinkRequestDto body,
  );

  @DELETE('/api/v1/auth/google/link')
  Future<ApiResponse<UnlinkMessageDto>> unlinkGoogle();

  @POST('/api/v1/auth/github/link')
  Future<ApiResponse<GithubLinkResponseDto>> linkGithub(
    @Body() GithubLinkRequestDto body,
  );

  @DELETE('/api/v1/auth/github/link')
  Future<ApiResponse<UnlinkMessageDto>> unlinkGithub();
}
