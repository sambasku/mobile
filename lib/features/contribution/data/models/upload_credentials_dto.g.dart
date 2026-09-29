// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_credentials_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UploadCredentialsDto _$UploadCredentialsDtoFromJson(
  Map<String, dynamic> json,
) => _UploadCredentialsDto(
  token: json['token'] as String,
  signature: json['signature'] as String,
  expire: (json['expire'] as num).toInt(),
  publicKey: json['public_key'] as String,
  uploadEndpoint: json['upload_endpoint'] as String,
);

Map<String, dynamic> _$UploadCredentialsDtoToJson(
  _UploadCredentialsDto instance,
) => <String, dynamic>{
  'token': instance.token,
  'signature': instance.signature,
  'expire': instance.expire,
  'public_key': instance.publicKey,
  'upload_endpoint': instance.uploadEndpoint,
};
