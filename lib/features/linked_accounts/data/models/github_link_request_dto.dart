import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_link_request_dto.freezed.dart';
part 'github_link_request_dto.g.dart';

@freezed
abstract class GithubLinkRequestDto with _$GithubLinkRequestDto {
  const factory GithubLinkRequestDto({
    required String code,
    @JsonKey(name: 'redirect_uri') required String redirectUri,
    @JsonKey(name: 'code_verifier') String? codeVerifier,
  }) = _GithubLinkRequestDto;

  factory GithubLinkRequestDto.fromJson(Map<String, dynamic> json) =>
      _$GithubLinkRequestDtoFromJson(json);
}

@freezed
abstract class GithubLinkResponseDto with _$GithubLinkResponseDto {
  const factory GithubLinkResponseDto({
    required String provider,
    @JsonKey(name: 'linked_at') required String linkedAt,
  }) = _GithubLinkResponseDto;

  factory GithubLinkResponseDto.fromJson(Map<String, dynamic> json) =>
      _$GithubLinkResponseDtoFromJson(json);
}
