import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/models/api_response.dart';
import '../models/facebook_login_request_dto.dart';
import '../models/github_login_request_dto.dart';
import '../models/google_login_request_dto.dart';
import '../models/login_request_dto.dart';
import '../models/login_response_dto.dart';
import '../models/logout_request_dto.dart';
import '../models/register_request_dto.dart';
import '../models/resend_otp_request_dto.dart';
import '../models/reset_password_dto.dart';
import '../models/verify_email_request_dto.dart';

part 'auth_remote_datasource.g.dart';

@RestApi()
abstract interface class AuthRemoteDatasource {
  factory AuthRemoteDatasource(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _AuthRemoteDatasource;

  @POST('/api/v1/auth/register')
  Future<ApiResponse<RegisterResponseDto>> register(
    @Body() RegisterRequestDto body,
  );

  @POST('/api/v1/auth/login')
  Future<ApiResponse<LoginResponseDto>> login(@Body() LoginRequestDto body);

  @POST('/api/v1/auth/google')
  Future<ApiResponse<LoginResponseDto>> loginWithGoogle(
    @Body() GoogleLoginRequestDto body,
  );

  @POST('/api/v1/auth/facebook')
  Future<ApiResponse<LoginResponseDto>> loginWithFacebook(
    @Body() FacebookLoginRequestDto body,
  );

  @POST('/api/v1/auth/github')
  Future<ApiResponse<LoginResponseDto>> loginWithGithub(
    @Body() GithubLoginRequestDto body,
  );

  @POST('/api/v1/auth/verify-email')
  Future<ApiResponse<LoginResponseDto>> verifyEmail(
    @Body() VerifyEmailRequestDto body,
  );

  @POST('/api/v1/auth/resend-otp')
  Future<ApiResponse<ResendOtpResponseDto>> resendOtp(
    @Body() ResendOtpRequestDto body,
  );

  @POST('/api/v1/auth/forgot-password')
  Future<ApiResponse<AuthMessageResponseDto>> forgotPassword(
    @Body() ForgotPasswordRequestDto body,
  );

  @POST('/api/v1/auth/reset-password')
  Future<ApiResponse<AuthMessageResponseDto>> resetPassword(
    @Body() ResetPasswordRequestDto body,
  );

  @POST('/api/v1/auth/logout')
  Future<void> logout(@Body() LogoutRequestDto body);
}
