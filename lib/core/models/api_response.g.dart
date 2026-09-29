// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _ApiResponse<T>(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  errorCode: json['error_code'] as String?,
  details: (json['details'] as List<dynamic>?)
      ?.map((e) => ApiErrorDetail.fromJson(e as Map<String, dynamic>))
      .toList(),
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
  meta: json['meta'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ApiResponseToJson<T>(
  _ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_code': instance.errorCode,
  'details': instance.details,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
  'meta': instance.meta,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);

_ApiErrorDetail _$ApiErrorDetailFromJson(Map<String, dynamic> json) =>
    _ApiErrorDetail(
      field: json['field'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$ApiErrorDetailToJson(_ApiErrorDetail instance) =>
    <String, dynamic>{'field': instance.field, 'message': instance.message};
