// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reset_password_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ForgotPasswordRequestDto {

 String get email;
/// Create a copy of ForgotPasswordRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForgotPasswordRequestDtoCopyWith<ForgotPasswordRequestDto> get copyWith => _$ForgotPasswordRequestDtoCopyWithImpl<ForgotPasswordRequestDto>(this as ForgotPasswordRequestDto, _$identity);

  /// Serializes this ForgotPasswordRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ForgotPasswordRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForgotPasswordRequestDto&&(identical(other.email, _this.email) || other.email == _this.email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ForgotPasswordRequestDto;
  return Object.hash(runtimeType,_this.email);
}

@override
String toString() {
  final _this = this as ForgotPasswordRequestDto;
  return 'ForgotPasswordRequestDto(email: ${_this.email})';
}


}

/// @nodoc
abstract mixin class $ForgotPasswordRequestDtoCopyWith<$Res>  {
  factory $ForgotPasswordRequestDtoCopyWith(ForgotPasswordRequestDto value, $Res Function(ForgotPasswordRequestDto) _then) = _$ForgotPasswordRequestDtoCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$ForgotPasswordRequestDtoCopyWithImpl<$Res>
    implements $ForgotPasswordRequestDtoCopyWith<$Res> {
  _$ForgotPasswordRequestDtoCopyWithImpl(this._self, this._then);

  final ForgotPasswordRequestDto _self;
  final $Res Function(ForgotPasswordRequestDto) _then;

/// Create a copy of ForgotPasswordRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,}) {
  return _then(ForgotPasswordRequestDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ForgotPasswordRequestDto].
extension ForgotPasswordRequestDtoPatterns on ForgotPasswordRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForgotPasswordRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForgotPasswordRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForgotPasswordRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _ForgotPasswordRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForgotPasswordRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _ForgotPasswordRequestDto() when $default != null:
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
case _ForgotPasswordRequestDto() when $default != null:
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
case _ForgotPasswordRequestDto():
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
case _ForgotPasswordRequestDto() when $default != null:
return $default(_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ForgotPasswordRequestDto implements ForgotPasswordRequestDto {
  const _ForgotPasswordRequestDto({required this.email});
  factory _ForgotPasswordRequestDto.fromJson(Map<String, dynamic> json) => _$ForgotPasswordRequestDtoFromJson(json);

@override final  String email;

/// Create a copy of ForgotPasswordRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForgotPasswordRequestDtoCopyWith<_ForgotPasswordRequestDto> get copyWith => __$ForgotPasswordRequestDtoCopyWithImpl<_ForgotPasswordRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ForgotPasswordRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForgotPasswordRequestDto&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email);
}

@override
String toString() {
    return 'ForgotPasswordRequestDto(email: $email)';
}


}

/// @nodoc
abstract mixin class _$ForgotPasswordRequestDtoCopyWith<$Res> implements $ForgotPasswordRequestDtoCopyWith<$Res> {
  factory _$ForgotPasswordRequestDtoCopyWith(_ForgotPasswordRequestDto value, $Res Function(_ForgotPasswordRequestDto) _then) = __$ForgotPasswordRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String email
});




}
/// @nodoc
class __$ForgotPasswordRequestDtoCopyWithImpl<$Res>
    implements _$ForgotPasswordRequestDtoCopyWith<$Res> {
  __$ForgotPasswordRequestDtoCopyWithImpl(this._self, this._then);

  final _ForgotPasswordRequestDto _self;
  final $Res Function(_ForgotPasswordRequestDto) _then;

/// Create a copy of ForgotPasswordRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(_ForgotPasswordRequestDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ResetPasswordRequestDto {

@JsonKey(includeIfNull: false) String? get token;@JsonKey(includeIfNull: false) String? get email;@JsonKey(includeIfNull: false) String? get code;@JsonKey(name: 'new_password') String get newPassword;
/// Create a copy of ResetPasswordRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResetPasswordRequestDtoCopyWith<ResetPasswordRequestDto> get copyWith => _$ResetPasswordRequestDtoCopyWithImpl<ResetPasswordRequestDto>(this as ResetPasswordRequestDto, _$identity);

  /// Serializes this ResetPasswordRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ResetPasswordRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResetPasswordRequestDto&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.newPassword, _this.newPassword) || other.newPassword == _this.newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ResetPasswordRequestDto;
  return Object.hash(runtimeType,_this.token,_this.email,_this.code,_this.newPassword);
}

@override
String toString() {
  final _this = this as ResetPasswordRequestDto;
  return 'ResetPasswordRequestDto(token: ${_this.token}, email: ${_this.email}, code: ${_this.code}, newPassword: ${_this.newPassword})';
}


}

/// @nodoc
abstract mixin class $ResetPasswordRequestDtoCopyWith<$Res>  {
  factory $ResetPasswordRequestDtoCopyWith(ResetPasswordRequestDto value, $Res Function(ResetPasswordRequestDto) _then) = _$ResetPasswordRequestDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? token,@JsonKey(includeIfNull: false) String? email,@JsonKey(includeIfNull: false) String? code,@JsonKey(name: 'new_password') String newPassword
});




}
/// @nodoc
class _$ResetPasswordRequestDtoCopyWithImpl<$Res>
    implements $ResetPasswordRequestDtoCopyWith<$Res> {
  _$ResetPasswordRequestDtoCopyWithImpl(this._self, this._then);

  final ResetPasswordRequestDto _self;
  final $Res Function(ResetPasswordRequestDto) _then;

/// Create a copy of ResetPasswordRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = freezed,Object? email = freezed,Object? code = freezed,Object? newPassword = null,}) {
  return _then(ResetPasswordRequestDto(
token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ResetPasswordRequestDto].
extension ResetPasswordRequestDtoPatterns on ResetPasswordRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResetPasswordRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResetPasswordRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResetPasswordRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _ResetPasswordRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResetPasswordRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _ResetPasswordRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? token, @JsonKey(includeIfNull: false)  String? email, @JsonKey(includeIfNull: false)  String? code, @JsonKey(name: 'new_password')  String newPassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResetPasswordRequestDto() when $default != null:
return $default(_that.token,_that.email,_that.code,_that.newPassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? token, @JsonKey(includeIfNull: false)  String? email, @JsonKey(includeIfNull: false)  String? code, @JsonKey(name: 'new_password')  String newPassword)  $default,) {final _that = this;
switch (_that) {
case _ResetPasswordRequestDto():
return $default(_that.token,_that.email,_that.code,_that.newPassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? token, @JsonKey(includeIfNull: false)  String? email, @JsonKey(includeIfNull: false)  String? code, @JsonKey(name: 'new_password')  String newPassword)?  $default,) {final _that = this;
switch (_that) {
case _ResetPasswordRequestDto() when $default != null:
return $default(_that.token,_that.email,_that.code,_that.newPassword);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResetPasswordRequestDto implements ResetPasswordRequestDto {
  const _ResetPasswordRequestDto({@JsonKey(includeIfNull: false) this.token, @JsonKey(includeIfNull: false) this.email, @JsonKey(includeIfNull: false) this.code, @JsonKey(name: 'new_password') required this.newPassword});
  factory _ResetPasswordRequestDto.fromJson(Map<String, dynamic> json) => _$ResetPasswordRequestDtoFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? token;
@override@JsonKey(includeIfNull: false) final  String? email;
@override@JsonKey(includeIfNull: false) final  String? code;
@override@JsonKey(name: 'new_password') final  String newPassword;

/// Create a copy of ResetPasswordRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResetPasswordRequestDtoCopyWith<_ResetPasswordRequestDto> get copyWith => __$ResetPasswordRequestDtoCopyWithImpl<_ResetPasswordRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResetPasswordRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResetPasswordRequestDto&&(identical(other.token, token) || other.token == token)&&(identical(other.email, email) || other.email == email)&&(identical(other.code, code) || other.code == code)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,token,email,code,newPassword);
}

@override
String toString() {
    return 'ResetPasswordRequestDto(token: $token, email: $email, code: $code, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class _$ResetPasswordRequestDtoCopyWith<$Res> implements $ResetPasswordRequestDtoCopyWith<$Res> {
  factory _$ResetPasswordRequestDtoCopyWith(_ResetPasswordRequestDto value, $Res Function(_ResetPasswordRequestDto) _then) = __$ResetPasswordRequestDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? token,@JsonKey(includeIfNull: false) String? email,@JsonKey(includeIfNull: false) String? code,@JsonKey(name: 'new_password') String newPassword
});




}
/// @nodoc
class __$ResetPasswordRequestDtoCopyWithImpl<$Res>
    implements _$ResetPasswordRequestDtoCopyWith<$Res> {
  __$ResetPasswordRequestDtoCopyWithImpl(this._self, this._then);

  final _ResetPasswordRequestDto _self;
  final $Res Function(_ResetPasswordRequestDto) _then;

/// Create a copy of ResetPasswordRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = freezed,Object? email = freezed,Object? code = freezed,Object? newPassword = null,}) {
  return _then(_ResetPasswordRequestDto(
token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AuthMessageResponseDto {

 String get message;
/// Create a copy of AuthMessageResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthMessageResponseDtoCopyWith<AuthMessageResponseDto> get copyWith => _$AuthMessageResponseDtoCopyWithImpl<AuthMessageResponseDto>(this as AuthMessageResponseDto, _$identity);

  /// Serializes this AuthMessageResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuthMessageResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthMessageResponseDto&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuthMessageResponseDto;
  return Object.hash(runtimeType,_this.message);
}

@override
String toString() {
  final _this = this as AuthMessageResponseDto;
  return 'AuthMessageResponseDto(message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $AuthMessageResponseDtoCopyWith<$Res>  {
  factory $AuthMessageResponseDtoCopyWith(AuthMessageResponseDto value, $Res Function(AuthMessageResponseDto) _then) = _$AuthMessageResponseDtoCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$AuthMessageResponseDtoCopyWithImpl<$Res>
    implements $AuthMessageResponseDtoCopyWith<$Res> {
  _$AuthMessageResponseDtoCopyWithImpl(this._self, this._then);

  final AuthMessageResponseDto _self;
  final $Res Function(AuthMessageResponseDto) _then;

/// Create a copy of AuthMessageResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(AuthMessageResponseDto(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthMessageResponseDto].
extension AuthMessageResponseDtoPatterns on AuthMessageResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthMessageResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthMessageResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthMessageResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _AuthMessageResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthMessageResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _AuthMessageResponseDto() when $default != null:
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
case _AuthMessageResponseDto() when $default != null:
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
case _AuthMessageResponseDto():
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
case _AuthMessageResponseDto() when $default != null:
return $default(_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthMessageResponseDto implements AuthMessageResponseDto {
  const _AuthMessageResponseDto({required this.message});
  factory _AuthMessageResponseDto.fromJson(Map<String, dynamic> json) => _$AuthMessageResponseDtoFromJson(json);

@override final  String message;

/// Create a copy of AuthMessageResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthMessageResponseDtoCopyWith<_AuthMessageResponseDto> get copyWith => __$AuthMessageResponseDtoCopyWithImpl<_AuthMessageResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthMessageResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthMessageResponseDto&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'AuthMessageResponseDto(message: $message)';
}


}

/// @nodoc
abstract mixin class _$AuthMessageResponseDtoCopyWith<$Res> implements $AuthMessageResponseDtoCopyWith<$Res> {
  factory _$AuthMessageResponseDtoCopyWith(_AuthMessageResponseDto value, $Res Function(_AuthMessageResponseDto) _then) = __$AuthMessageResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$AuthMessageResponseDtoCopyWithImpl<$Res>
    implements _$AuthMessageResponseDtoCopyWith<$Res> {
  __$AuthMessageResponseDtoCopyWithImpl(this._self, this._then);

  final _AuthMessageResponseDto _self;
  final $Res Function(_AuthMessageResponseDto) _then;

/// Create a copy of AuthMessageResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_AuthMessageResponseDto(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
