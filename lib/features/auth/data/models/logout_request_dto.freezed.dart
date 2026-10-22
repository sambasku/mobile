// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'logout_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LogoutRequestDto {

@JsonKey(name: 'refresh_token') String get refreshToken;@JsonKey(name: 'client_type') String get clientType;
/// Create a copy of LogoutRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogoutRequestDtoCopyWith<LogoutRequestDto> get copyWith => _$LogoutRequestDtoCopyWithImpl<LogoutRequestDto>(this as LogoutRequestDto, _$identity);

  /// Serializes this LogoutRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LogoutRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogoutRequestDto&&(identical(other.refreshToken, _this.refreshToken) || other.refreshToken == _this.refreshToken)&&(identical(other.clientType, _this.clientType) || other.clientType == _this.clientType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LogoutRequestDto;
  return Object.hash(runtimeType,_this.refreshToken,_this.clientType);
}

@override
String toString() {
  final _this = this as LogoutRequestDto;
  return 'LogoutRequestDto(refreshToken: ${_this.refreshToken}, clientType: ${_this.clientType})';
}


}

/// @nodoc
abstract mixin class $LogoutRequestDtoCopyWith<$Res>  {
  factory $LogoutRequestDtoCopyWith(LogoutRequestDto value, $Res Function(LogoutRequestDto) _then) = _$LogoutRequestDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'refresh_token') String refreshToken,@JsonKey(name: 'client_type') String clientType
});




}
/// @nodoc
class _$LogoutRequestDtoCopyWithImpl<$Res>
    implements $LogoutRequestDtoCopyWith<$Res> {
  _$LogoutRequestDtoCopyWithImpl(this._self, this._then);

  final LogoutRequestDto _self;
  final $Res Function(LogoutRequestDto) _then;

/// Create a copy of LogoutRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? refreshToken = null,Object? clientType = null,}) {
  return _then(LogoutRequestDto(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,clientType: null == clientType ? _self.clientType : clientType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LogoutRequestDto].
extension LogoutRequestDtoPatterns on LogoutRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LogoutRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogoutRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LogoutRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _LogoutRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LogoutRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _LogoutRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'refresh_token')  String refreshToken, @JsonKey(name: 'client_type')  String clientType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LogoutRequestDto() when $default != null:
return $default(_that.refreshToken,_that.clientType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'refresh_token')  String refreshToken, @JsonKey(name: 'client_type')  String clientType)  $default,) {final _that = this;
switch (_that) {
case _LogoutRequestDto():
return $default(_that.refreshToken,_that.clientType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'refresh_token')  String refreshToken, @JsonKey(name: 'client_type')  String clientType)?  $default,) {final _that = this;
switch (_that) {
case _LogoutRequestDto() when $default != null:
return $default(_that.refreshToken,_that.clientType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LogoutRequestDto implements LogoutRequestDto {
  const _LogoutRequestDto({@JsonKey(name: 'refresh_token') required this.refreshToken, @JsonKey(name: 'client_type') this.clientType = 'mobile'});
  factory _LogoutRequestDto.fromJson(Map<String, dynamic> json) => _$LogoutRequestDtoFromJson(json);

@override@JsonKey(name: 'refresh_token') final  String refreshToken;
@override@JsonKey(name: 'client_type') final  String clientType;

/// Create a copy of LogoutRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogoutRequestDtoCopyWith<_LogoutRequestDto> get copyWith => __$LogoutRequestDtoCopyWithImpl<_LogoutRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LogoutRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogoutRequestDto&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.clientType, clientType) || other.clientType == clientType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,refreshToken,clientType);
}

@override
String toString() {
    return 'LogoutRequestDto(refreshToken: $refreshToken, clientType: $clientType)';
}


}

/// @nodoc
abstract mixin class _$LogoutRequestDtoCopyWith<$Res> implements $LogoutRequestDtoCopyWith<$Res> {
  factory _$LogoutRequestDtoCopyWith(_LogoutRequestDto value, $Res Function(_LogoutRequestDto) _then) = __$LogoutRequestDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'refresh_token') String refreshToken,@JsonKey(name: 'client_type') String clientType
});




}
/// @nodoc
class __$LogoutRequestDtoCopyWithImpl<$Res>
    implements _$LogoutRequestDtoCopyWith<$Res> {
  __$LogoutRequestDtoCopyWithImpl(this._self, this._then);

  final _LogoutRequestDto _self;
  final $Res Function(_LogoutRequestDto) _then;

/// Create a copy of LogoutRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? refreshToken = null,Object? clientType = null,}) {
  return _then(_LogoutRequestDto(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,clientType: null == clientType ? _self.clientType : clientType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
