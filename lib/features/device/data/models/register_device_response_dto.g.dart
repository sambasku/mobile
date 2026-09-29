// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_device_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterDeviceResponseDto _$RegisterDeviceResponseDtoFromJson(
  Map<String, dynamic> json,
) => _RegisterDeviceResponseDto(
  udid: json['udid'] as String,
  fcmTokenRegistered: json['fcm_token_registered'] as bool,
);

Map<String, dynamic> _$RegisterDeviceResponseDtoToJson(
  _RegisterDeviceResponseDto instance,
) => <String, dynamic>{
  'udid': instance.udid,
  'fcm_token_registered': instance.fcmTokenRegistered,
};
