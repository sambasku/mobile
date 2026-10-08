import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../shared/dev_tool/network_monitor/data/models/network_request_record.dart';
import '../../../shared/dev_tool/network_monitor/domain/repositories/network_monitor_repository.dart';

class NetworkMonitorInterceptor extends Interceptor {
  NetworkMonitorInterceptor({required NetworkMonitorRepository repository})
    : _repository = repository;

  final NetworkMonitorRepository _repository;

  static const _recordKey = 'network_monitor_record';
  static int _counter = 0;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final record = err.requestOptions.extra[_recordKey];

    if (record is NetworkRequestRecord) {
      _repository.upsertRecord(
        record.copyWith(
          finishedAt: DateTime.now(),
          durationMs: DateTime.now()
              .difference(record.startedAt)
              .inMilliseconds,
          statusCode: err.response?.statusCode,
          responseHeaders: _normalizeHeaders(err.response?.headers.map),
          responseBody: _stringify(err.response?.data),
          errorMessage: err.message ?? err.error?.toString(),
          isError: true,
        ),
      );
    }

    super.onError(err, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final startedAt = DateTime.now();
    final record = NetworkRequestRecord(
      id: '${startedAt.microsecondsSinceEpoch}_${_counter++}',
      startedAt: startedAt,
      method: options.method.toUpperCase(),
      url: options.uri.toString(),
      path: options.path,
      queryParameters: _normalizeMap(options.queryParameters),
      requestHeaders: _normalizeHeaders(options.headers),
      requestBody: _stringify(options.data),
    );

    options.extra[_recordKey] = record;
    _repository.upsertRecord(record);

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final record = response.requestOptions.extra[_recordKey];

    if (record is NetworkRequestRecord) {
      _repository.upsertRecord(
        record.copyWith(
          finishedAt: DateTime.now(),
          durationMs: DateTime.now()
              .difference(record.startedAt)
              .inMilliseconds,
          statusCode: response.statusCode,
          responseHeaders: _normalizeHeaders(response.headers.map),
          responseBody: _stringify(response.data),
        ),
      );
    }

    super.onResponse(response, handler);
  }

  /// Header yang tak boleh ikut terekam (#73) - case-insensitive.
  static const _sensitiveHeaderKeys = {
    'authorization',
    'cookie',
    'set-cookie',
    'proxy-authorization',
  };

  /// Field body yang tak boleh ikut terekam (#73) - exact key, lowercase.
  static const _sensitiveBodyKeys = {
    'password',
    'new_password',
    'confirm_password',
    'refresh_token',
    'access_token',
    'token',
    'otp',
    'code',
  };

  Map<String, String> _normalizeHeaders(Map<String, dynamic>? headers) =>
      headers == null ? const <String, String>{} : _normalizeMap(headers);

  Map<String, String> _normalizeMap(Map<String, dynamic>? values) {
    if (values == null || values.isEmpty) {
      return const <String, String>{};
    }

    return Map<String, String>.fromEntries(
      values.entries.map(
        (entry) => MapEntry(
          entry.key,
          _sensitiveHeaderKeys.contains(entry.key.toLowerCase())
              ? '***'
              : _stringifyValue(entry.value),
        ),
      ),
    );
  }

  String? _stringify(dynamic data) {
    try {
      return _tryStringify(data);
    } catch (_) {
      return data?.toString();
    }
  }

  String? _tryStringify(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is FormData) {
      final fields = Map<String, String>.fromEntries(data.fields);
      final files = data.files.map((f) => f.key).toList();
      final result = StringBuffer('[FormData]\n');
      if (fields.isNotEmpty) {
        result.writeln('Fields:');
        for (final e in fields.entries) {
          final value = _sensitiveBodyKeys.contains(e.key.toLowerCase())
              ? '***'
              : e.value;
          result.writeln('  ${e.key}: $value');
        }
      }
      if (files.isNotEmpty) {
        result.writeln('Files:');
        for (final f in files) {
          result.writeln('  - $f');
        }
      }
      return result.toString().trimRight();
    }

    if (data is String) {
      return data;
    }

    if (data is Map || data is List || data is num || data is bool) {
      return const JsonEncoder.withIndent('  ').convert(_redactJson(data));
    }

    // Object DTO yang punya toJson() - serialize ke JSON
    try {
      final json = (data as dynamic).toJson();
      return const JsonEncoder.withIndent('  ').convert(_redactJson(json));
    } catch (_) {
      // Object tidak punya toJson() - fallback ke toString()
    }

    return data.toString();
  }

  /// Redaksi rekursif utk Map/List dari JSON body (#73).
  dynamic _redactJson(dynamic value) {
    if (value is Map) {
      return value.map(
        (k, v) => MapEntry(
          k,
          k is String && _sensitiveBodyKeys.contains(k.toLowerCase())
              ? '***'
              : _redactJson(v),
        ),
      );
    }
    if (value is List) {
      return value.map(_redactJson).toList();
    }
    return value;
  }

  String _stringifyValue(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is Iterable) {
      return value.join(', ');
    }

    return value.toString();
  }
}
