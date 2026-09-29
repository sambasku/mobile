// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_device_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegisterDeviceRequestDto {

 String get udid;@JsonKey(name: 'fcm_token') String get fcmToken;
/// Create a copy of RegisterDeviceRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterDeviceRequestDtoCopyWith<RegisterDeviceRequestDto> get copyWith => _$RegisterDeviceRequestDtoCopyWithImpl<RegisterDeviceRequestDto>(this as RegisterDeviceRequestDto, _$identity);

  /// Serializes this RegisterDeviceRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterDeviceRequestDto&&(identical(other.udid, udid) || other.udid == udid)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,udid,fcmToken);

@override
String toString() {
  return 'RegisterDeviceRequestDto(udid: $udid, fcmToken: $fcmToken)';
}


}

/// @nodoc
abstract mixin class $RegisterDeviceRequestDtoCopyWith<$Res>  {
  factory $RegisterDeviceRequestDtoCopyWith(RegisterDeviceRequestDto value, $Res Function(RegisterDeviceRequestDto) _then) = _$RegisterDeviceRequestDtoCopyWithImpl;
@useResult
$Res call({
 String udid,@JsonKey(name: 'fcm_token') String fcmToken
});




}
/// @nodoc
class _$RegisterDeviceRequestDtoCopyWithImpl<$Res>
    implements $RegisterDeviceRequestDtoCopyWith<$Res> {
  _$RegisterDeviceRequestDtoCopyWithImpl(this._self, this._then);

  final RegisterDeviceRequestDto _self;
  final $Res Function(RegisterDeviceRequestDto) _then;

/// Create a copy of RegisterDeviceRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? udid = null,Object? fcmToken = null,}) {
  return _then(_self.copyWith(
udid: null == udid ? _self.udid : udid // ignore: cast_nullable_to_non_nullable
as String,fcmToken: null == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterDeviceRequestDto].
extension RegisterDeviceRequestDtoPatterns on RegisterDeviceRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterDeviceRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterDeviceRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterDeviceRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _RegisterDeviceRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterDeviceRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterDeviceRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String udid, @JsonKey(name: 'fcm_token')  String fcmToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterDeviceRequestDto() when $default != null:
return $default(_that.udid,_that.fcmToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String udid, @JsonKey(name: 'fcm_token')  String fcmToken)  $default,) {final _that = this;
switch (_that) {
case _RegisterDeviceRequestDto():
return $default(_that.udid,_that.fcmToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String udid, @JsonKey(name: 'fcm_token')  String fcmToken)?  $default,) {final _that = this;
switch (_that) {
case _RegisterDeviceRequestDto() when $default != null:
return $default(_that.udid,_that.fcmToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterDeviceRequestDto implements RegisterDeviceRequestDto {
  const _RegisterDeviceRequestDto({required this.udid, @JsonKey(name: 'fcm_token') required this.fcmToken});
  factory _RegisterDeviceRequestDto.fromJson(Map<String, dynamic> json) => _$RegisterDeviceRequestDtoFromJson(json);

@override final  String udid;
@override@JsonKey(name: 'fcm_token') final  String fcmToken;

/// Create a copy of RegisterDeviceRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterDeviceRequestDtoCopyWith<_RegisterDeviceRequestDto> get copyWith => __$RegisterDeviceRequestDtoCopyWithImpl<_RegisterDeviceRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterDeviceRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterDeviceRequestDto&&(identical(other.udid, udid) || other.udid == udid)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,udid,fcmToken);

@override
String toString() {
  return 'RegisterDeviceRequestDto(udid: $udid, fcmToken: $fcmToken)';
}


}

/// @nodoc
abstract mixin class _$RegisterDeviceRequestDtoCopyWith<$Res> implements $RegisterDeviceRequestDtoCopyWith<$Res> {
  factory _$RegisterDeviceRequestDtoCopyWith(_RegisterDeviceRequestDto value, $Res Function(_RegisterDeviceRequestDto) _then) = __$RegisterDeviceRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String udid,@JsonKey(name: 'fcm_token') String fcmToken
});




}
/// @nodoc
class __$RegisterDeviceRequestDtoCopyWithImpl<$Res>
    implements _$RegisterDeviceRequestDtoCopyWith<$Res> {
  __$RegisterDeviceRequestDtoCopyWithImpl(this._self, this._then);

  final _RegisterDeviceRequestDto _self;
  final $Res Function(_RegisterDeviceRequestDto) _then;

/// Create a copy of RegisterDeviceRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? udid = null,Object? fcmToken = null,}) {
  return _then(_RegisterDeviceRequestDto(
udid: null == udid ? _self.udid : udid // ignore: cast_nullable_to_non_nullable
as String,fcmToken: null == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
