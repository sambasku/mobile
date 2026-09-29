// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_account_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeleteAccountRequestDto _$DeleteAccountRequestDtoFromJson(
  Map<String, dynamic> json,
) => _DeleteAccountRequestDto(
  password: json['password'] as String?,
  confirmation: json['confirmation'] as String,
);

Map<String, dynamic> _$DeleteAccountRequestDtoToJson(
  _DeleteAccountRequestDto instance,
) => <String, dynamic>{
  'password': ?instance.password,
  'confirmation': instance.confirmation,
};
