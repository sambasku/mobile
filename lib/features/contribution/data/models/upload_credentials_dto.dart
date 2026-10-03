import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_credentials_dto.freezed.dart';
part 'upload_credentials_dto.g.dart';

/// Data GET /api/v1/admin/images/upload-token.
@freezed
abstract class UploadCredentialsDto with _$UploadCredentialsDto {
  const factory UploadCredentialsDto({
    required String token,
    required String signature,
    required int expire,
    @JsonKey(name: 'public_key') required String publicKey,
    @JsonKey(name: 'upload_endpoint') required String uploadEndpoint,
  }) = _UploadCredentialsDto;

  factory UploadCredentialsDto.fromJson(Map<String, dynamic> json) =>
      _$UploadCredentialsDtoFromJson(json);
}
