// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_device_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegisterDeviceResponseDto {

 String get udid;@JsonKey(name: 'fcm_token_registered') bool get fcmTokenRegistered;
/// Create a copy of RegisterDeviceResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterDeviceResponseDtoCopyWith<RegisterDeviceResponseDto> get copyWith => _$RegisterDeviceResponseDtoCopyWithImpl<RegisterDeviceResponseDto>(this as RegisterDeviceResponseDto, _$identity);

  /// Serializes this RegisterDeviceResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterDeviceResponseDto&&(identical(other.udid, udid) || other.udid == udid)&&(identical(other.fcmTokenRegistered, fcmTokenRegistered) || other.fcmTokenRegistered == fcmTokenRegistered));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,udid,fcmTokenRegistered);

@override
String toString() {
  return 'RegisterDeviceResponseDto(udid: $udid, fcmTokenRegistered: $fcmTokenRegistered)';
}


}

/// @nodoc
abstract mixin class $RegisterDeviceResponseDtoCopyWith<$Res>  {
  factory $RegisterDeviceResponseDtoCopyWith(RegisterDeviceResponseDto value, $Res Function(RegisterDeviceResponseDto) _then) = _$RegisterDeviceResponseDtoCopyWithImpl;
@useResult
$Res call({
 String udid,@JsonKey(name: 'fcm_token_registered') bool fcmTokenRegistered
});




}
/// @nodoc
class _$RegisterDeviceResponseDtoCopyWithImpl<$Res>
    implements $RegisterDeviceResponseDtoCopyWith<$Res> {
  _$RegisterDeviceResponseDtoCopyWithImpl(this._self, this._then);

  final RegisterDeviceResponseDto _self;
  final $Res Function(RegisterDeviceResponseDto) _then;

/// Create a copy of RegisterDeviceResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? udid = null,Object? fcmTokenRegistered = null,}) {
  return _then(_self.copyWith(
udid: null == udid ? _self.udid : udid // ignore: cast_nullable_to_non_nullable
as String,fcmTokenRegistered: null == fcmTokenRegistered ? _self.fcmTokenRegistered : fcmTokenRegistered // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterDeviceResponseDto].
extension RegisterDeviceResponseDtoPatterns on RegisterDeviceResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterDeviceResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterDeviceResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterDeviceResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _RegisterDeviceResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterDeviceResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterDeviceResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String udid, @JsonKey(name: 'fcm_token_registered')  bool fcmTokenRegistered)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterDeviceResponseDto() when $default != null:
return $default(_that.udid,_that.fcmTokenRegistered);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String udid, @JsonKey(name: 'fcm_token_registered')  bool fcmTokenRegistered)  $default,) {final _that = this;
switch (_that) {
case _RegisterDeviceResponseDto():
return $default(_that.udid,_that.fcmTokenRegistered);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String udid, @JsonKey(name: 'fcm_token_registered')  bool fcmTokenRegistered)?  $default,) {final _that = this;
switch (_that) {
case _RegisterDeviceResponseDto() when $default != null:
return $default(_that.udid,_that.fcmTokenRegistered);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterDeviceResponseDto implements RegisterDeviceResponseDto {
  const _RegisterDeviceResponseDto({required this.udid, @JsonKey(name: 'fcm_token_registered') required this.fcmTokenRegistered});
  factory _RegisterDeviceResponseDto.fromJson(Map<String, dynamic> json) => _$RegisterDeviceResponseDtoFromJson(json);

@override final  String udid;
@override@JsonKey(name: 'fcm_token_registered') final  bool fcmTokenRegistered;

/// Create a copy of RegisterDeviceResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterDeviceResponseDtoCopyWith<_RegisterDeviceResponseDto> get copyWith => __$RegisterDeviceResponseDtoCopyWithImpl<_RegisterDeviceResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterDeviceResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterDeviceResponseDto&&(identical(other.udid, udid) || other.udid == udid)&&(identical(other.fcmTokenRegistered, fcmTokenRegistered) || other.fcmTokenRegistered == fcmTokenRegistered));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,udid,fcmTokenRegistered);

@override
String toString() {
  return 'RegisterDeviceResponseDto(udid: $udid, fcmTokenRegistered: $fcmTokenRegistered)';
}


}

/// @nodoc
abstract mixin class _$RegisterDeviceResponseDtoCopyWith<$Res> implements $RegisterDeviceResponseDtoCopyWith<$Res> {
  factory _$RegisterDeviceResponseDtoCopyWith(_RegisterDeviceResponseDto value, $Res Function(_RegisterDeviceResponseDto) _then) = __$RegisterDeviceResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String udid,@JsonKey(name: 'fcm_token_registered') bool fcmTokenRegistered
});




}
/// @nodoc
class __$RegisterDeviceResponseDtoCopyWithImpl<$Res>
    implements _$RegisterDeviceResponseDtoCopyWith<$Res> {
  __$RegisterDeviceResponseDtoCopyWithImpl(this._self, this._then);

  final _RegisterDeviceResponseDto _self;
  final $Res Function(_RegisterDeviceResponseDto) _then;

/// Create a copy of RegisterDeviceResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? udid = null,Object? fcmTokenRegistered = null,}) {
  return _then(_RegisterDeviceResponseDto(
udid: null == udid ? _self.udid : udid // ignore: cast_nullable_to_non_nullable
as String,fcmTokenRegistered: null == fcmTokenRegistered ? _self.fcmTokenRegistered : fcmTokenRegistered // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
