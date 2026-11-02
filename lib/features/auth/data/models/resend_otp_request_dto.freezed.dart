// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resend_otp_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ResendOtpRequestDto {

 String get email;
/// Create a copy of ResendOtpRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResendOtpRequestDtoCopyWith<ResendOtpRequestDto> get copyWith => _$ResendOtpRequestDtoCopyWithImpl<ResendOtpRequestDto>(this as ResendOtpRequestDto, _$identity);

  /// Serializes this ResendOtpRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ResendOtpRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResendOtpRequestDto&&(identical(other.email, _this.email) || other.email == _this.email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ResendOtpRequestDto;
  return Object.hash(runtimeType,_this.email);
}

@override
String toString() {
  final _this = this as ResendOtpRequestDto;
  return 'ResendOtpRequestDto(email: ${_this.email})';
}


}

/// @nodoc
abstract mixin class $ResendOtpRequestDtoCopyWith<$Res>  {
  factory $ResendOtpRequestDtoCopyWith(ResendOtpRequestDto value, $Res Function(ResendOtpRequestDto) _then) = _$ResendOtpRequestDtoCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$ResendOtpRequestDtoCopyWithImpl<$Res>
    implements $ResendOtpRequestDtoCopyWith<$Res> {
  _$ResendOtpRequestDtoCopyWithImpl(this._self, this._then);

  final ResendOtpRequestDto _self;
  final $Res Function(ResendOtpRequestDto) _then;

/// Create a copy of ResendOtpRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,}) {
  return _then(ResendOtpRequestDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ResendOtpRequestDto].
extension ResendOtpRequestDtoPatterns on ResendOtpRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResendOtpRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResendOtpRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResendOtpRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _ResendOtpRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResendOtpRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _ResendOtpRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResendOtpRequestDto() when $default != null:
return $default(_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email)  $default,) {final _that = this;
switch (_that) {
case _ResendOtpRequestDto():
return $default(_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email)?  $default,) {final _that = this;
switch (_that) {
case _ResendOtpRequestDto() when $default != null:
return $default(_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResendOtpRequestDto implements ResendOtpRequestDto {
  const _ResendOtpRequestDto({required this.email});
  factory _ResendOtpRequestDto.fromJson(Map<String, dynamic> json) => _$ResendOtpRequestDtoFromJson(json);

@override final  String email;

/// Create a copy of ResendOtpRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResendOtpRequestDtoCopyWith<_ResendOtpRequestDto> get copyWith => __$ResendOtpRequestDtoCopyWithImpl<_ResendOtpRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResendOtpRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResendOtpRequestDto&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email);
}

@override
String toString() {
    return 'ResendOtpRequestDto(email: $email)';
}


}

/// @nodoc
abstract mixin class _$ResendOtpRequestDtoCopyWith<$Res> implements $ResendOtpRequestDtoCopyWith<$Res> {
  factory _$ResendOtpRequestDtoCopyWith(_ResendOtpRequestDto value, $Res Function(_ResendOtpRequestDto) _then) = __$ResendOtpRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String email
});




}
/// @nodoc
class __$ResendOtpRequestDtoCopyWithImpl<$Res>
    implements _$ResendOtpRequestDtoCopyWith<$Res> {
  __$ResendOtpRequestDtoCopyWithImpl(this._self, this._then);

  final _ResendOtpRequestDto _self;
  final $Res Function(_ResendOtpRequestDto) _then;

/// Create a copy of ResendOtpRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(_ResendOtpRequestDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ResendOtpResponseDto {

 String get message;
/// Create a copy of ResendOtpResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResendOtpResponseDtoCopyWith<ResendOtpResponseDto> get copyWith => _$ResendOtpResponseDtoCopyWithImpl<ResendOtpResponseDto>(this as ResendOtpResponseDto, _$identity);

  /// Serializes this ResendOtpResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ResendOtpResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResendOtpResponseDto&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ResendOtpResponseDto;
  return Object.hash(runtimeType,_this.message);
}

@override
String toString() {
  final _this = this as ResendOtpResponseDto;
  return 'ResendOtpResponseDto(message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $ResendOtpResponseDtoCopyWith<$Res>  {
  factory $ResendOtpResponseDtoCopyWith(ResendOtpResponseDto value, $Res Function(ResendOtpResponseDto) _then) = _$ResendOtpResponseDtoCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ResendOtpResponseDtoCopyWithImpl<$Res>
    implements $ResendOtpResponseDtoCopyWith<$Res> {
  _$ResendOtpResponseDtoCopyWithImpl(this._self, this._then);

  final ResendOtpResponseDto _self;
  final $Res Function(ResendOtpResponseDto) _then;

/// Create a copy of ResendOtpResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(ResendOtpResponseDto(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ResendOtpResponseDto].
extension ResendOtpResponseDtoPatterns on ResendOtpResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResendOtpResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResendOtpResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResendOtpResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _ResendOtpResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResendOtpResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _ResendOtpResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResendOtpResponseDto() when $default != null:
return $default(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message)  $default,) {final _that = this;
switch (_that) {
case _ResendOtpResponseDto():
return $default(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message)?  $default,) {final _that = this;
switch (_that) {
case _ResendOtpResponseDto() when $default != null:
return $default(_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResendOtpResponseDto implements ResendOtpResponseDto {
  const _ResendOtpResponseDto({required this.message});
  factory _ResendOtpResponseDto.fromJson(Map<String, dynamic> json) => _$ResendOtpResponseDtoFromJson(json);

@override final  String message;

/// Create a copy of ResendOtpResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResendOtpResponseDtoCopyWith<_ResendOtpResponseDto> get copyWith => __$ResendOtpResponseDtoCopyWithImpl<_ResendOtpResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResendOtpResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResendOtpResponseDto&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'ResendOtpResponseDto(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ResendOtpResponseDtoCopyWith<$Res> implements $ResendOtpResponseDtoCopyWith<$Res> {
  factory _$ResendOtpResponseDtoCopyWith(_ResendOtpResponseDto value, $Res Function(_ResendOtpResponseDto) _then) = __$ResendOtpResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ResendOtpResponseDtoCopyWithImpl<$Res>
    implements _$ResendOtpResponseDtoCopyWith<$Res> {
  __$ResendOtpResponseDtoCopyWithImpl(this._self, this._then);

  final _ResendOtpResponseDto _self;
  final $Res Function(_ResendOtpResponseDto) _then;

/// Create a copy of ResendOtpResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_ResendOtpResponseDto(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
