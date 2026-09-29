// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revoke_device_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RevokeDeviceResponseDto _$RevokeDeviceResponseDtoFromJson(
  Map<String, dynamic> json,
) => _RevokeDeviceResponseDto(
  udid: json['udid'] as String,
  revoked: json['revoked'] as bool,
);

Map<String, dynamic> _$RevokeDeviceResponseDtoToJson(
  _RevokeDeviceResponseDto instance,
) => <String, dynamic>{'udid': instance.udid, 'revoked': instance.revoked};
