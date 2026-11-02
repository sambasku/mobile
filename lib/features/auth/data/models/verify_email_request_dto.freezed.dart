// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verify_email_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerifyEmailRequestDto {

 String get email; String get code;@JsonKey(name: 'client_type') String get clientType;
/// Create a copy of VerifyEmailRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifyEmailRequestDtoCopyWith<VerifyEmailRequestDto> get copyWith => _$VerifyEmailRequestDtoCopyWithImpl<VerifyEmailRequestDto>(this as VerifyEmailRequestDto, _$identity);

  /// Serializes this VerifyEmailRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VerifyEmailRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyEmailRequestDto&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.clientType, _this.clientType) || other.clientType == _this.clientType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VerifyEmailRequestDto;
  return Object.hash(runtimeType,_this.email,_this.code,_this.clientType);
}

@override
String toString() {
  final _this = this as VerifyEmailRequestDto;
  return 'VerifyEmailRequestDto(email: ${_this.email}, code: ${_this.code}, clientType: ${_this.clientType})';
}


}

/// @nodoc
abstract mixin class $VerifyEmailRequestDtoCopyWith<$Res>  {
  factory $VerifyEmailRequestDtoCopyWith(VerifyEmailRequestDto value, $Res Function(VerifyEmailRequestDto) _then) = _$VerifyEmailRequestDtoCopyWithImpl;
@useResult
$Res call({
 String email, String code,@JsonKey(name: 'client_type') String clientType
});




}
/// @nodoc
class _$VerifyEmailRequestDtoCopyWithImpl<$Res>
    implements $VerifyEmailRequestDtoCopyWith<$Res> {
  _$VerifyEmailRequestDtoCopyWithImpl(this._self, this._then);

  final VerifyEmailRequestDto _self;
  final $Res Function(VerifyEmailRequestDto) _then;

/// Create a copy of VerifyEmailRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? code = null,Object? clientType = null,}) {
  return _then(VerifyEmailRequestDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,clientType: null == clientType ? _self.clientType : clientType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VerifyEmailRequestDto].
extension VerifyEmailRequestDtoPatterns on VerifyEmailRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifyEmailRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifyEmailRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifyEmailRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _VerifyEmailRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifyEmailRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _VerifyEmailRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String code, @JsonKey(name: 'client_type')  String clientType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifyEmailRequestDto() when $default != null:
return $default(_that.email,_that.code,_that.clientType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String code, @JsonKey(name: 'client_type')  String clientType)  $default,) {final _that = this;
switch (_that) {
case _VerifyEmailRequestDto():
return $default(_that.email,_that.code,_that.clientType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String code, @JsonKey(name: 'client_type')  String clientType)?  $default,) {final _that = this;
switch (_that) {
case _VerifyEmailRequestDto() when $default != null:
return $default(_that.email,_that.code,_that.clientType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerifyEmailRequestDto implements VerifyEmailRequestDto {
  const _VerifyEmailRequestDto({required this.email, required this.code, @JsonKey(name: 'client_type') this.clientType = 'mobile'});
  factory _VerifyEmailRequestDto.fromJson(Map<String, dynamic> json) => _$VerifyEmailRequestDtoFromJson(json);

@override final  String email;
@override final  String code;
@override@JsonKey(name: 'client_type') final  String clientType;

/// Create a copy of VerifyEmailRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifyEmailRequestDtoCopyWith<_VerifyEmailRequestDto> get copyWith => __$VerifyEmailRequestDtoCopyWithImpl<_VerifyEmailRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerifyEmailRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyEmailRequestDto&&(identical(other.email, email) || other.email == email)&&(identical(other.code, code) || other.code == code)&&(identical(other.clientType, clientType) || other.clientType == clientType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email,code,clientType);
}

@override
String toString() {
    return 'VerifyEmailRequestDto(email: $email, code: $code, clientType: $clientType)';
}


}

/// @nodoc
abstract mixin class _$VerifyEmailRequestDtoCopyWith<$Res> implements $VerifyEmailRequestDtoCopyWith<$Res> {
  factory _$VerifyEmailRequestDtoCopyWith(_VerifyEmailRequestDto value, $Res Function(_VerifyEmailRequestDto) _then) = __$VerifyEmailRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String email, String code,@JsonKey(name: 'client_type') String clientType
});




}
/// @nodoc
class __$VerifyEmailRequestDtoCopyWithImpl<$Res>
    implements _$VerifyEmailRequestDtoCopyWith<$Res> {
  __$VerifyEmailRequestDtoCopyWithImpl(this._self, this._then);

  final _VerifyEmailRequestDto _self;
  final $Res Function(_VerifyEmailRequestDto) _then;

/// Create a copy of VerifyEmailRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? code = null,Object? clientType = null,}) {
  return _then(_VerifyEmailRequestDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,clientType: null == clientType ? _self.clientType : clientType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
