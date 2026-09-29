// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_request_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NetworkRequestRecord _$NetworkRequestRecordFromJson(
  Map<String, dynamic> json,
) => _NetworkRequestRecord(
  id: json['id'] as String,
  startedAt: DateTime.parse(json['startedAt'] as String),
  method: json['method'] as String,
  url: json['url'] as String,
  path: json['path'] as String,
  finishedAt: json['finishedAt'] == null
      ? null
      : DateTime.parse(json['finishedAt'] as String),
  statusCode: (json['statusCode'] as num?)?.toInt(),
  durationMs: (json['durationMs'] as num?)?.toInt(),
  queryParameters:
      (json['queryParameters'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  requestHeaders:
      (json['requestHeaders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  requestBody: json['requestBody'] as String?,
  responseHeaders:
      (json['responseHeaders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  responseBody: json['responseBody'] as String?,
  errorMessage: json['errorMessage'] as String?,
  isError: json['isError'] as bool? ?? false,
  cacheSource: json['cacheSource'] as String?,
);

Map<String, dynamic> _$NetworkRequestRecordToJson(
  _NetworkRequestRecord instance,
) => <String, dynamic>{
  'id': instance.id,
  'startedAt': instance.startedAt.toIso8601String(),
  'method': instance.method,
  'url': instance.url,
  'path': instance.path,
  'finishedAt': instance.finishedAt?.toIso8601String(),
  'statusCode': instance.statusCode,
  'durationMs': instance.durationMs,
  'queryParameters': instance.queryParameters,
  'requestHeaders': instance.requestHeaders,
  'requestBody': instance.requestBody,
  'responseHeaders': instance.responseHeaders,
  'responseBody': instance.responseBody,
  'errorMessage': instance.errorMessage,
  'isError': instance.isError,
  'cacheSource': instance.cacheSource,
};
