// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'revoke_device_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RevokeDeviceRequestDto {

 String get udid;
/// Create a copy of RevokeDeviceRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevokeDeviceRequestDtoCopyWith<RevokeDeviceRequestDto> get copyWith => _$RevokeDeviceRequestDtoCopyWithImpl<RevokeDeviceRequestDto>(this as RevokeDeviceRequestDto, _$identity);

  /// Serializes this RevokeDeviceRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevokeDeviceRequestDto&&(identical(other.udid, udid) || other.udid == udid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,udid);

@override
String toString() {
  return 'RevokeDeviceRequestDto(udid: $udid)';
}


}

/// @nodoc
abstract mixin class $RevokeDeviceRequestDtoCopyWith<$Res>  {
  factory $RevokeDeviceRequestDtoCopyWith(RevokeDeviceRequestDto value, $Res Function(RevokeDeviceRequestDto) _then) = _$RevokeDeviceRequestDtoCopyWithImpl;
@useResult
$Res call({
 String udid
});




}
/// @nodoc
class _$RevokeDeviceRequestDtoCopyWithImpl<$Res>
    implements $RevokeDeviceRequestDtoCopyWith<$Res> {
  _$RevokeDeviceRequestDtoCopyWithImpl(this._self, this._then);

  final RevokeDeviceRequestDto _self;
  final $Res Function(RevokeDeviceRequestDto) _then;

/// Create a copy of RevokeDeviceRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? udid = null,}) {
  return _then(_self.copyWith(
udid: null == udid ? _self.udid : udid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RevokeDeviceRequestDto].
extension RevokeDeviceRequestDtoPatterns on RevokeDeviceRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevokeDeviceRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevokeDeviceRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevokeDeviceRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _RevokeDeviceRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevokeDeviceRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _RevokeDeviceRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String udid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevokeDeviceRequestDto() when $default != null:
return $default(_that.udid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String udid)  $default,) {final _that = this;
switch (_that) {
case _RevokeDeviceRequestDto():
return $default(_that.udid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String udid)?  $default,) {final _that = this;
switch (_that) {
case _RevokeDeviceRequestDto() when $default != null:
return $default(_that.udid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevokeDeviceRequestDto implements RevokeDeviceRequestDto {
  const _RevokeDeviceRequestDto({required this.udid});
  factory _RevokeDeviceRequestDto.fromJson(Map<String, dynamic> json) => _$RevokeDeviceRequestDtoFromJson(json);

@override final  String udid;

/// Create a copy of RevokeDeviceRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevokeDeviceRequestDtoCopyWith<_RevokeDeviceRequestDto> get copyWith => __$RevokeDeviceRequestDtoCopyWithImpl<_RevokeDeviceRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevokeDeviceRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevokeDeviceRequestDto&&(identical(other.udid, udid) || other.udid == udid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,udid);

@override
String toString() {
  return 'RevokeDeviceRequestDto(udid: $udid)';
}


}

/// @nodoc
abstract mixin class _$RevokeDeviceRequestDtoCopyWith<$Res> implements $RevokeDeviceRequestDtoCopyWith<$Res> {
  factory _$RevokeDeviceRequestDtoCopyWith(_RevokeDeviceRequestDto value, $Res Function(_RevokeDeviceRequestDto) _then) = __$RevokeDeviceRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String udid
});




}
/// @nodoc
class __$RevokeDeviceRequestDtoCopyWithImpl<$Res>
    implements _$RevokeDeviceRequestDtoCopyWith<$Res> {
  __$RevokeDeviceRequestDtoCopyWithImpl(this._self, this._then);

  final _RevokeDeviceRequestDto _self;
  final $Res Function(_RevokeDeviceRequestDto) _then;

/// Create a copy of RevokeDeviceRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? udid = null,}) {
  return _then(_RevokeDeviceRequestDto(
udid: null == udid ? _self.udid : udid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
