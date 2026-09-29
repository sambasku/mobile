// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'revoke_device_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RevokeDeviceResponseDto {

 String get udid; bool get revoked;
/// Create a copy of RevokeDeviceResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevokeDeviceResponseDtoCopyWith<RevokeDeviceResponseDto> get copyWith => _$RevokeDeviceResponseDtoCopyWithImpl<RevokeDeviceResponseDto>(this as RevokeDeviceResponseDto, _$identity);

  /// Serializes this RevokeDeviceResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevokeDeviceResponseDto&&(identical(other.udid, udid) || other.udid == udid)&&(identical(other.revoked, revoked) || other.revoked == revoked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,udid,revoked);

@override
String toString() {
  return 'RevokeDeviceResponseDto(udid: $udid, revoked: $revoked)';
}


}

/// @nodoc
abstract mixin class $RevokeDeviceResponseDtoCopyWith<$Res>  {
  factory $RevokeDeviceResponseDtoCopyWith(RevokeDeviceResponseDto value, $Res Function(RevokeDeviceResponseDto) _then) = _$RevokeDeviceResponseDtoCopyWithImpl;
@useResult
$Res call({
 String udid, bool revoked
});




}
/// @nodoc
class _$RevokeDeviceResponseDtoCopyWithImpl<$Res>
    implements $RevokeDeviceResponseDtoCopyWith<$Res> {
  _$RevokeDeviceResponseDtoCopyWithImpl(this._self, this._then);

  final RevokeDeviceResponseDto _self;
  final $Res Function(RevokeDeviceResponseDto) _then;

/// Create a copy of RevokeDeviceResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? udid = null,Object? revoked = null,}) {
  return _then(_self.copyWith(
udid: null == udid ? _self.udid : udid // ignore: cast_nullable_to_non_nullable
as String,revoked: null == revoked ? _self.revoked : revoked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RevokeDeviceResponseDto].
extension RevokeDeviceResponseDtoPatterns on RevokeDeviceResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevokeDeviceResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevokeDeviceResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevokeDeviceResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _RevokeDeviceResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevokeDeviceResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _RevokeDeviceResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String udid,  bool revoked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevokeDeviceResponseDto() when $default != null:
return $default(_that.udid,_that.revoked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String udid,  bool revoked)  $default,) {final _that = this;
switch (_that) {
case _RevokeDeviceResponseDto():
return $default(_that.udid,_that.revoked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String udid,  bool revoked)?  $default,) {final _that = this;
switch (_that) {
case _RevokeDeviceResponseDto() when $default != null:
return $default(_that.udid,_that.revoked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevokeDeviceResponseDto implements RevokeDeviceResponseDto {
  const _RevokeDeviceResponseDto({required this.udid, required this.revoked});
  factory _RevokeDeviceResponseDto.fromJson(Map<String, dynamic> json) => _$RevokeDeviceResponseDtoFromJson(json);

@override final  String udid;
@override final  bool revoked;

/// Create a copy of RevokeDeviceResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevokeDeviceResponseDtoCopyWith<_RevokeDeviceResponseDto> get copyWith => __$RevokeDeviceResponseDtoCopyWithImpl<_RevokeDeviceResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevokeDeviceResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevokeDeviceResponseDto&&(identical(other.udid, udid) || other.udid == udid)&&(identical(other.revoked, revoked) || other.revoked == revoked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,udid,revoked);

@override
String toString() {
  return 'RevokeDeviceResponseDto(udid: $udid, revoked: $revoked)';
}


}

/// @nodoc
abstract mixin class _$RevokeDeviceResponseDtoCopyWith<$Res> implements $RevokeDeviceResponseDtoCopyWith<$Res> {
  factory _$RevokeDeviceResponseDtoCopyWith(_RevokeDeviceResponseDto value, $Res Function(_RevokeDeviceResponseDto) _then) = __$RevokeDeviceResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String udid, bool revoked
});




}
/// @nodoc
class __$RevokeDeviceResponseDtoCopyWithImpl<$Res>
    implements _$RevokeDeviceResponseDtoCopyWith<$Res> {
  __$RevokeDeviceResponseDtoCopyWithImpl(this._self, this._then);

  final _RevokeDeviceResponseDto _self;
  final $Res Function(_RevokeDeviceResponseDto) _then;

/// Create a copy of RevokeDeviceResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? udid = null,Object? revoked = null,}) {
  return _then(_RevokeDeviceResponseDto(
udid: null == udid ? _self.udid : udid // ignore: cast_nullable_to_non_nullable
as String,revoked: null == revoked ? _self.revoked : revoked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
