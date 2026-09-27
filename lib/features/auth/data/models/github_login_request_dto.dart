import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_login_request_dto.freezed.dart';
part 'github_login_request_dto.g.dart';

@freezed
abstract class GithubLoginRequestDto with _$GithubLoginRequestDto {
  const factory GithubLoginRequestDto({
    required String code,
    @JsonKey(name: 'redirect_uri') required String redirectUri,
    @JsonKey(name: 'code_verifier') String? codeVerifier,
    @JsonKey(name: 'client_type') @Default('mobile') String clientType,
  }) = _GithubLoginRequestDto;

  factory GithubLoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$GithubLoginRequestDtoFromJson(json);
}
