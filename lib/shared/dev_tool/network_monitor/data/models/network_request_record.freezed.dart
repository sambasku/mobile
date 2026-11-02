// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'network_request_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NetworkRequestRecord {

 String get id; DateTime get startedAt; String get method; String get url; String get path; DateTime? get finishedAt; int? get statusCode; int? get durationMs; Map<String, String> get queryParameters; Map<String, String> get requestHeaders; String? get requestBody; Map<String, String> get responseHeaders; String? get responseBody; String? get errorMessage; bool get isError;/// Sumber L1: `HIT` | `STALE` | `DEGRADED`. Null = request jaringan.
 String? get cacheSource;
/// Create a copy of NetworkRequestRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkRequestRecordCopyWith<NetworkRequestRecord> get copyWith => _$NetworkRequestRecordCopyWithImpl<NetworkRequestRecord>(this as NetworkRequestRecord, _$identity);

  /// Serializes this NetworkRequestRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NetworkRequestRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkRequestRecord&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.finishedAt, _this.finishedAt) || other.finishedAt == _this.finishedAt)&&(identical(other.statusCode, _this.statusCode) || other.statusCode == _this.statusCode)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs)&&const DeepCollectionEquality().equals(other.queryParameters, _this.queryParameters)&&const DeepCollectionEquality().equals(other.requestHeaders, _this.requestHeaders)&&(identical(other.requestBody, _this.requestBody) || other.requestBody == _this.requestBody)&&const DeepCollectionEquality().equals(other.responseHeaders, _this.responseHeaders)&&(identical(other.responseBody, _this.responseBody) || other.responseBody == _this.responseBody)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.isError, _this.isError) || other.isError == _this.isError)&&(identical(other.cacheSource, _this.cacheSource) || other.cacheSource == _this.cacheSource));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NetworkRequestRecord;
  return Object.hash(runtimeType,_this.id,_this.startedAt,_this.method,_this.url,_this.path,_this.finishedAt,_this.statusCode,_this.durationMs,const DeepCollectionEquality().hash(_this.queryParameters),const DeepCollectionEquality().hash(_this.requestHeaders),_this.requestBody,const DeepCollectionEquality().hash(_this.responseHeaders),_this.responseBody,_this.errorMessage,_this.isError,_this.cacheSource);
}

@override
String toString() {
  final _this = this as NetworkRequestRecord;
  return 'NetworkRequestRecord(id: ${_this.id}, startedAt: ${_this.startedAt}, method: ${_this.method}, url: ${_this.url}, path: ${_this.path}, finishedAt: ${_this.finishedAt}, statusCode: ${_this.statusCode}, durationMs: ${_this.durationMs}, queryParameters: ${_this.queryParameters}, requestHeaders: ${_this.requestHeaders}, requestBody: ${_this.requestBody}, responseHeaders: ${_this.responseHeaders}, responseBody: ${_this.responseBody}, errorMessage: ${_this.errorMessage}, isError: ${_this.isError}, cacheSource: ${_this.cacheSource})';
}


}

/// @nodoc
abstract mixin class $NetworkRequestRecordCopyWith<$Res>  {
  factory $NetworkRequestRecordCopyWith(NetworkRequestRecord value, $Res Function(NetworkRequestRecord) _then) = _$NetworkRequestRecordCopyWithImpl;
@useResult
$Res call({
 String id, DateTime startedAt, String method, String url, String path, DateTime? finishedAt, int? statusCode, int? durationMs, Map<String, String> queryParameters, Map<String, String> requestHeaders, String? requestBody, Map<String, String> responseHeaders, String? responseBody, String? errorMessage, bool isError, String? cacheSource
});




}
/// @nodoc
class _$NetworkRequestRecordCopyWithImpl<$Res>
    implements $NetworkRequestRecordCopyWith<$Res> {
  _$NetworkRequestRecordCopyWithImpl(this._self, this._then);

  final NetworkRequestRecord _self;
  final $Res Function(NetworkRequestRecord) _then;

/// Create a copy of NetworkRequestRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? startedAt = null,Object? method = null,Object? url = null,Object? path = null,Object? finishedAt = freezed,Object? statusCode = freezed,Object? durationMs = freezed,Object? queryParameters = null,Object? requestHeaders = null,Object? requestBody = freezed,Object? responseHeaders = null,Object? responseBody = freezed,Object? errorMessage = freezed,Object? isError = null,Object? cacheSource = freezed,}) {
  return _then(NetworkRequestRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,queryParameters: null == queryParameters ? _self.queryParameters : queryParameters // ignore: cast_nullable_to_non_nullable
as Map<String, String>,requestHeaders: null == requestHeaders ? _self.requestHeaders : requestHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>,requestBody: freezed == requestBody ? _self.requestBody : requestBody // ignore: cast_nullable_to_non_nullable
as String?,responseHeaders: null == responseHeaders ? _self.responseHeaders : responseHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>,responseBody: freezed == responseBody ? _self.responseBody : responseBody // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,cacheSource: freezed == cacheSource ? _self.cacheSource : cacheSource // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NetworkRequestRecord].
extension NetworkRequestRecordPatterns on NetworkRequestRecord {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NetworkRequestRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetworkRequestRecord() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NetworkRequestRecord value)  $default,){
final _that = this;
switch (_that) {
case _NetworkRequestRecord():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NetworkRequestRecord value)?  $default,){
final _that = this;
switch (_that) {
case _NetworkRequestRecord() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime startedAt,  String method,  String url,  String path,  DateTime? finishedAt,  int? statusCode,  int? durationMs,  Map<String, String> queryParameters,  Map<String, String> requestHeaders,  String? requestBody,  Map<String, String> responseHeaders,  String? responseBody,  String? errorMessage,  bool isError,  String? cacheSource)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetworkRequestRecord() when $default != null:
return $default(_that.id,_that.startedAt,_that.method,_that.url,_that.path,_that.finishedAt,_that.statusCode,_that.durationMs,_that.queryParameters,_that.requestHeaders,_that.requestBody,_that.responseHeaders,_that.responseBody,_that.errorMessage,_that.isError,_that.cacheSource);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime startedAt,  String method,  String url,  String path,  DateTime? finishedAt,  int? statusCode,  int? durationMs,  Map<String, String> queryParameters,  Map<String, String> requestHeaders,  String? requestBody,  Map<String, String> responseHeaders,  String? responseBody,  String? errorMessage,  bool isError,  String? cacheSource)  $default,) {final _that = this;
switch (_that) {
case _NetworkRequestRecord():
return $default(_that.id,_that.startedAt,_that.method,_that.url,_that.path,_that.finishedAt,_that.statusCode,_that.durationMs,_that.queryParameters,_that.requestHeaders,_that.requestBody,_that.responseHeaders,_that.responseBody,_that.errorMessage,_that.isError,_that.cacheSource);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime startedAt,  String method,  String url,  String path,  DateTime? finishedAt,  int? statusCode,  int? durationMs,  Map<String, String> queryParameters,  Map<String, String> requestHeaders,  String? requestBody,  Map<String, String> responseHeaders,  String? responseBody,  String? errorMessage,  bool isError,  String? cacheSource)?  $default,) {final _that = this;
switch (_that) {
case _NetworkRequestRecord() when $default != null:
return $default(_that.id,_that.startedAt,_that.method,_that.url,_that.path,_that.finishedAt,_that.statusCode,_that.durationMs,_that.queryParameters,_that.requestHeaders,_that.requestBody,_that.responseHeaders,_that.responseBody,_that.errorMessage,_that.isError,_that.cacheSource);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NetworkRequestRecord implements NetworkRequestRecord {
  const _NetworkRequestRecord({required this.id, required this.startedAt, required this.method, required this.url, required this.path, this.finishedAt, this.statusCode, this.durationMs,  Map<String, String> queryParameters = const <String, String>{},  Map<String, String> requestHeaders = const <String, String>{}, this.requestBody,  Map<String, String> responseHeaders = const <String, String>{}, this.responseBody, this.errorMessage, this.isError = false, this.cacheSource}): _queryParameters = queryParameters,_requestHeaders = requestHeaders,_responseHeaders = responseHeaders;
  factory _NetworkRequestRecord.fromJson(Map<String, dynamic> json) => _$NetworkRequestRecordFromJson(json);

@override final  String id;
@override final  DateTime startedAt;
@override final  String method;
@override final  String url;
@override final  String path;
@override final  DateTime? finishedAt;
@override final  int? statusCode;
@override final  int? durationMs;
 final  Map<String, String> _queryParameters;
@override@JsonKey() Map<String, String> get queryParameters {
  if (_queryParameters is EqualUnmodifiableMapView) return _queryParameters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_queryParameters);
}

 final  Map<String, String> _requestHeaders;
@override@JsonKey() Map<String, String> get requestHeaders {
  if (_requestHeaders is EqualUnmodifiableMapView) return _requestHeaders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_requestHeaders);
}

@override final  String? requestBody;
 final  Map<String, String> _responseHeaders;
@override@JsonKey() Map<String, String> get responseHeaders {
  if (_responseHeaders is EqualUnmodifiableMapView) return _responseHeaders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_responseHeaders);
}

@override final  String? responseBody;
@override final  String? errorMessage;
@override@JsonKey() final  bool isError;
/// Sumber L1: `HIT` | `STALE` | `DEGRADED`. Null = request jaringan.
@override final  String? cacheSource;

/// Create a copy of NetworkRequestRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetworkRequestRecordCopyWith<_NetworkRequestRecord> get copyWith => __$NetworkRequestRecordCopyWithImpl<_NetworkRequestRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NetworkRequestRecordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetworkRequestRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.method, method) || other.method == method)&&(identical(other.url, url) || other.url == url)&&(identical(other.path, path) || other.path == path)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&const DeepCollectionEquality().equals(other.queryParameters, _queryParameters)&&const DeepCollectionEquality().equals(other.requestHeaders, _requestHeaders)&&(identical(other.requestBody, requestBody) || other.requestBody == requestBody)&&const DeepCollectionEquality().equals(other.responseHeaders, _responseHeaders)&&(identical(other.responseBody, responseBody) || other.responseBody == responseBody)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isError, isError) || other.isError == isError)&&(identical(other.cacheSource, cacheSource) || other.cacheSource == cacheSource));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,startedAt,method,url,path,finishedAt,statusCode,durationMs,const DeepCollectionEquality().hash(_queryParameters),const DeepCollectionEquality().hash(_requestHeaders),requestBody,const DeepCollectionEquality().hash(_responseHeaders),responseBody,errorMessage,isError,cacheSource);
}

@override
String toString() {
    return 'NetworkRequestRecord(id: $id, startedAt: $startedAt, method: $method, url: $url, path: $path, finishedAt: $finishedAt, statusCode: $statusCode, durationMs: $durationMs, queryParameters: $queryParameters, requestHeaders: $requestHeaders, requestBody: $requestBody, responseHeaders: $responseHeaders, responseBody: $responseBody, errorMessage: $errorMessage, isError: $isError, cacheSource: $cacheSource)';
}


}

/// @nodoc
abstract mixin class _$NetworkRequestRecordCopyWith<$Res> implements $NetworkRequestRecordCopyWith<$Res> {
  factory _$NetworkRequestRecordCopyWith(_NetworkRequestRecord value, $Res Function(_NetworkRequestRecord) _then) = __$NetworkRequestRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime startedAt, String method, String url, String path, DateTime? finishedAt, int? statusCode, int? durationMs, Map<String, String> queryParameters, Map<String, String> requestHeaders, String? requestBody, Map<String, String> responseHeaders, String? responseBody, String? errorMessage, bool isError, String? cacheSource
});




}
/// @nodoc
class __$NetworkRequestRecordCopyWithImpl<$Res>
    implements _$NetworkRequestRecordCopyWith<$Res> {
  __$NetworkRequestRecordCopyWithImpl(this._self, this._then);

  final _NetworkRequestRecord _self;
  final $Res Function(_NetworkRequestRecord) _then;

/// Create a copy of NetworkRequestRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? startedAt = null,Object? method = null,Object? url = null,Object? path = null,Object? finishedAt = freezed,Object? statusCode = freezed,Object? durationMs = freezed,Object? queryParameters = null,Object? requestHeaders = null,Object? requestBody = freezed,Object? responseHeaders = null,Object? responseBody = freezed,Object? errorMessage = freezed,Object? isError = null,Object? cacheSource = freezed,}) {
  return _then(_NetworkRequestRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,queryParameters: null == queryParameters ? _self._queryParameters : queryParameters // ignore: cast_nullable_to_non_nullable
as Map<String, String>,requestHeaders: null == requestHeaders ? _self._requestHeaders : requestHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>,requestBody: freezed == requestBody ? _self.requestBody : requestBody // ignore: cast_nullable_to_non_nullable
as String?,responseHeaders: null == responseHeaders ? _self._responseHeaders : responseHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>,responseBody: freezed == responseBody ? _self.responseBody : responseBody // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,cacheSource: freezed == cacheSource ? _self.cacheSource : cacheSource // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
