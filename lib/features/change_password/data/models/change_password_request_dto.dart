import 'package:freezed_annotation/freezed_annotation.dart';

part 'change_password_request_dto.freezed.dart';
part 'change_password_request_dto.g.dart';

/// Body POST /api/v1/auth/change-password .
@freezed
abstract class ChangePasswordRequestDto with _$ChangePasswordRequestDto {
  const factory ChangePasswordRequestDto({
    @JsonKey(name: 'old_password') required String oldPassword,
    @JsonKey(name: 'new_password') required String newPassword,
    @JsonKey(name: 'confirm_password') required String confirmPassword,
  }) = _ChangePasswordRequestDto;

  factory ChangePasswordRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestDtoFromJson(json);
}
