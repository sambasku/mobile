// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiResponse<T> {

 bool? get success; String? get message;@JsonKey(name: 'error_code') String? get errorCode; List<ApiErrorDetail>? get details; T? get data; Map<String, dynamic>? get meta;
/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiResponseCopyWith<T, ApiResponse<T>> get copyWith => _$ApiResponseCopyWithImpl<T, ApiResponse<T>>(this as ApiResponse<T>, _$identity);

  /// Serializes this ApiResponse to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  final _this = this as ApiResponse<T>;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiResponse<T>&&(identical(other.success, _this.success) || other.success == _this.success)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.errorCode, _this.errorCode) || other.errorCode == _this.errorCode)&&const DeepCollectionEquality().equals(other.details, _this.details)&&const DeepCollectionEquality().equals(other.data, _this.data)&&const DeepCollectionEquality().equals(other.meta, _this.meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ApiResponse<T>;
  return Object.hash(runtimeType,_this.success,_this.message,_this.errorCode,const DeepCollectionEquality().hash(_this.details),const DeepCollectionEquality().hash(_this.data),const DeepCollectionEquality().hash(_this.meta));
}

@override
String toString() {
  final _this = this as ApiResponse<T>;
  return 'ApiResponse<$T>(success: ${_this.success}, message: ${_this.message}, errorCode: ${_this.errorCode}, details: ${_this.details}, data: ${_this.data}, meta: ${_this.meta})';
}


}

/// @nodoc
abstract mixin class $ApiResponseCopyWith<T,$Res>  {
  factory $ApiResponseCopyWith(ApiResponse<T> value, $Res Function(ApiResponse<T>) _then) = _$ApiResponseCopyWithImpl;
@useResult
$Res call({
 bool? success, String? message,@JsonKey(name: 'error_code') String? errorCode, List<ApiErrorDetail>? details, T? data, Map<String, dynamic>? meta
});




}
/// @nodoc
class _$ApiResponseCopyWithImpl<T,$Res>
    implements $ApiResponseCopyWith<T, $Res> {
  _$ApiResponseCopyWithImpl(this._self, this._then);

  final ApiResponse<T> _self;
  final $Res Function(ApiResponse<T>) _then;

/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = freezed,Object? message = freezed,Object? errorCode = freezed,Object? details = freezed,Object? data = freezed,Object? meta = freezed,}) {
  return _then(ApiResponse(
success: freezed == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as List<ApiErrorDetail>?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiResponse].
extension ApiResponsePatterns<T> on ApiResponse<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiResponse<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiResponse<T> value)  $default,){
final _that = this;
switch (_that) {
case _ApiResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiResponse<T> value)?  $default,){
final _that = this;
switch (_that) {
case _ApiResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? success,  String? message, @JsonKey(name: 'error_code')  String? errorCode,  List<ApiErrorDetail>? details,  T? data,  Map<String, dynamic>? meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiResponse() when $default != null:
return $default(_that.success,_that.message,_that.errorCode,_that.details,_that.data,_that.meta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? success,  String? message, @JsonKey(name: 'error_code')  String? errorCode,  List<ApiErrorDetail>? details,  T? data,  Map<String, dynamic>? meta)  $default,) {final _that = this;
switch (_that) {
case _ApiResponse():
return $default(_that.success,_that.message,_that.errorCode,_that.details,_that.data,_that.meta);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? success,  String? message, @JsonKey(name: 'error_code')  String? errorCode,  List<ApiErrorDetail>? details,  T? data,  Map<String, dynamic>? meta)?  $default,) {final _that = this;
switch (_that) {
case _ApiResponse() when $default != null:
return $default(_that.success,_that.message,_that.errorCode,_that.details,_that.data,_that.meta);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _ApiResponse<T> implements ApiResponse<T> {
  const _ApiResponse({this.success, this.message, @JsonKey(name: 'error_code') this.errorCode,  List<ApiErrorDetail>? details, this.data,  Map<String, dynamic>? meta}): _details = details,_meta = meta;
  factory _ApiResponse.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$ApiResponseFromJson(json,fromJsonT);

@override final  bool? success;
@override final  String? message;
@override@JsonKey(name: 'error_code') final  String? errorCode;
 final  List<ApiErrorDetail>? _details;
@override List<ApiErrorDetail>? get details {
  final value = _details;
  if (value == null) return null;
  if (_details is EqualUnmodifiableListView) return _details;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  T? data;
 final  Map<String, dynamic>? _meta;
@override Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiResponseCopyWith<T, _ApiResponse<T>> get copyWith => __$ApiResponseCopyWithImpl<T, _ApiResponse<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$ApiResponseToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiResponse<T>&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&const DeepCollectionEquality().equals(other.details, _details)&&const DeepCollectionEquality().equals(other.data, data)&&const DeepCollectionEquality().equals(other.meta, _meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,success,message,errorCode,const DeepCollectionEquality().hash(_details),const DeepCollectionEquality().hash(data),const DeepCollectionEquality().hash(_meta));
}

@override
String toString() {
    return 'ApiResponse<$T>(success: $success, message: $message, errorCode: $errorCode, details: $details, data: $data, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$ApiResponseCopyWith<T,$Res> implements $ApiResponseCopyWith<T, $Res> {
  factory _$ApiResponseCopyWith(_ApiResponse<T> value, $Res Function(_ApiResponse<T>) _then) = __$ApiResponseCopyWithImpl;
@override @useResult
$Res call({
 bool? success, String? message,@JsonKey(name: 'error_code') String? errorCode, List<ApiErrorDetail>? details, T? data, Map<String, dynamic>? meta
});




}
/// @nodoc
class __$ApiResponseCopyWithImpl<T,$Res>
    implements _$ApiResponseCopyWith<T, $Res> {
  __$ApiResponseCopyWithImpl(this._self, this._then);

  final _ApiResponse<T> _self;
  final $Res Function(_ApiResponse<T>) _then;

/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = freezed,Object? message = freezed,Object? errorCode = freezed,Object? details = freezed,Object? data = freezed,Object? meta = freezed,}) {
  return _then(_ApiResponse<T>(
success: freezed == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,details: freezed == details ? _self._details : details // ignore: cast_nullable_to_non_nullable
as List<ApiErrorDetail>?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$ApiErrorDetail {

 String get field; String get message;
/// Create a copy of ApiErrorDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiErrorDetailCopyWith<ApiErrorDetail> get copyWith => _$ApiErrorDetailCopyWithImpl<ApiErrorDetail>(this as ApiErrorDetail, _$identity);

  /// Serializes this ApiErrorDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ApiErrorDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiErrorDetail&&(identical(other.field, _this.field) || other.field == _this.field)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ApiErrorDetail;
  return Object.hash(runtimeType,_this.field,_this.message);
}

@override
String toString() {
  final _this = this as ApiErrorDetail;
  return 'ApiErrorDetail(field: ${_this.field}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $ApiErrorDetailCopyWith<$Res>  {
  factory $ApiErrorDetailCopyWith(ApiErrorDetail value, $Res Function(ApiErrorDetail) _then) = _$ApiErrorDetailCopyWithImpl;
@useResult
$Res call({
 String field, String message
});




}
/// @nodoc
class _$ApiErrorDetailCopyWithImpl<$Res>
    implements $ApiErrorDetailCopyWith<$Res> {
  _$ApiErrorDetailCopyWithImpl(this._self, this._then);

  final ApiErrorDetail _self;
  final $Res Function(ApiErrorDetail) _then;

/// Create a copy of ApiErrorDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? field = null,Object? message = null,}) {
  return _then(ApiErrorDetail(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiErrorDetail].
extension ApiErrorDetailPatterns on ApiErrorDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiErrorDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiErrorDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiErrorDetail value)  $default,){
final _that = this;
switch (_that) {
case _ApiErrorDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiErrorDetail value)?  $default,){
final _that = this;
switch (_that) {
case _ApiErrorDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String field,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiErrorDetail() when $default != null:
return $default(_that.field,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String field,  String message)  $default,) {final _that = this;
switch (_that) {
case _ApiErrorDetail():
return $default(_that.field,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String field,  String message)?  $default,) {final _that = this;
switch (_that) {
case _ApiErrorDetail() when $default != null:
return $default(_that.field,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApiErrorDetail implements ApiErrorDetail {
  const _ApiErrorDetail({required this.field, required this.message});
  factory _ApiErrorDetail.fromJson(Map<String, dynamic> json) => _$ApiErrorDetailFromJson(json);

@override final  String field;
@override final  String message;

/// Create a copy of ApiErrorDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiErrorDetailCopyWith<_ApiErrorDetail> get copyWith => __$ApiErrorDetailCopyWithImpl<_ApiErrorDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApiErrorDetailToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiErrorDetail&&(identical(other.field, field) || other.field == field)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,field,message);
}

@override
String toString() {
    return 'ApiErrorDetail(field: $field, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ApiErrorDetailCopyWith<$Res> implements $ApiErrorDetailCopyWith<$Res> {
  factory _$ApiErrorDetailCopyWith(_ApiErrorDetail value, $Res Function(_ApiErrorDetail) _then) = __$ApiErrorDetailCopyWithImpl;
@override @useResult
$Res call({
 String field, String message
});




}
/// @nodoc
class __$ApiErrorDetailCopyWithImpl<$Res>
    implements _$ApiErrorDetailCopyWith<$Res> {
  __$ApiErrorDetailCopyWithImpl(this._self, this._then);

  final _ApiErrorDetail _self;
  final $Res Function(_ApiErrorDetail) _then;

/// Create a copy of ApiErrorDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field = null,Object? message = null,}) {
  return _then(_ApiErrorDetail(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
