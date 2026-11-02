// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'set_password_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SetPasswordRequestDto {

 String get provider;@JsonKey(name: 'id_token') String? get idToken;@JsonKey(name: 'access_token') String? get accessToken; String? get code;@JsonKey(name: 'redirect_uri') String? get redirectUri;@JsonKey(name: 'code_verifier') String? get codeVerifier;@JsonKey(name: 'new_password') String get newPassword;@JsonKey(name: 'confirm_password') String get confirmPassword;
/// Create a copy of SetPasswordRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetPasswordRequestDtoCopyWith<SetPasswordRequestDto> get copyWith => _$SetPasswordRequestDtoCopyWithImpl<SetPasswordRequestDto>(this as SetPasswordRequestDto, _$identity);

  /// Serializes this SetPasswordRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SetPasswordRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetPasswordRequestDto&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.idToken, _this.idToken) || other.idToken == _this.idToken)&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.redirectUri, _this.redirectUri) || other.redirectUri == _this.redirectUri)&&(identical(other.codeVerifier, _this.codeVerifier) || other.codeVerifier == _this.codeVerifier)&&(identical(other.newPassword, _this.newPassword) || other.newPassword == _this.newPassword)&&(identical(other.confirmPassword, _this.confirmPassword) || other.confirmPassword == _this.confirmPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SetPasswordRequestDto;
  return Object.hash(runtimeType,_this.provider,_this.idToken,_this.accessToken,_this.code,_this.redirectUri,_this.codeVerifier,_this.newPassword,_this.confirmPassword);
}

@override
String toString() {
  final _this = this as SetPasswordRequestDto;
  return 'SetPasswordRequestDto(provider: ${_this.provider}, idToken: ${_this.idToken}, accessToken: ${_this.accessToken}, code: ${_this.code}, redirectUri: ${_this.redirectUri}, codeVerifier: ${_this.codeVerifier}, newPassword: ${_this.newPassword}, confirmPassword: ${_this.confirmPassword})';
}


}

/// @nodoc
abstract mixin class $SetPasswordRequestDtoCopyWith<$Res>  {
  factory $SetPasswordRequestDtoCopyWith(SetPasswordRequestDto value, $Res Function(SetPasswordRequestDto) _then) = _$SetPasswordRequestDtoCopyWithImpl;
@useResult
$Res call({
 String provider,@JsonKey(name: 'id_token') String? idToken,@JsonKey(name: 'access_token') String? accessToken, String? code,@JsonKey(name: 'redirect_uri') String? redirectUri,@JsonKey(name: 'code_verifier') String? codeVerifier,@JsonKey(name: 'new_password') String newPassword,@JsonKey(name: 'confirm_password') String confirmPassword
});




}
/// @nodoc
class _$SetPasswordRequestDtoCopyWithImpl<$Res>
    implements $SetPasswordRequestDtoCopyWith<$Res> {
  _$SetPasswordRequestDtoCopyWithImpl(this._self, this._then);

  final SetPasswordRequestDto _self;
  final $Res Function(SetPasswordRequestDto) _then;

/// Create a copy of SetPasswordRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? idToken = freezed,Object? accessToken = freezed,Object? code = freezed,Object? redirectUri = freezed,Object? codeVerifier = freezed,Object? newPassword = null,Object? confirmPassword = null,}) {
  return _then(SetPasswordRequestDto(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,idToken: freezed == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String?,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,redirectUri: freezed == redirectUri ? _self.redirectUri : redirectUri // ignore: cast_nullable_to_non_nullable
as String?,codeVerifier: freezed == codeVerifier ? _self.codeVerifier : codeVerifier // ignore: cast_nullable_to_non_nullable
as String?,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SetPasswordRequestDto].
extension SetPasswordRequestDtoPatterns on SetPasswordRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetPasswordRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetPasswordRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetPasswordRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _SetPasswordRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetPasswordRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _SetPasswordRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String provider, @JsonKey(name: 'id_token')  String? idToken, @JsonKey(name: 'access_token')  String? accessToken,  String? code, @JsonKey(name: 'redirect_uri')  String? redirectUri, @JsonKey(name: 'code_verifier')  String? codeVerifier, @JsonKey(name: 'new_password')  String newPassword, @JsonKey(name: 'confirm_password')  String confirmPassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetPasswordRequestDto() when $default != null:
return $default(_that.provider,_that.idToken,_that.accessToken,_that.code,_that.redirectUri,_that.codeVerifier,_that.newPassword,_that.confirmPassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String provider, @JsonKey(name: 'id_token')  String? idToken, @JsonKey(name: 'access_token')  String? accessToken,  String? code, @JsonKey(name: 'redirect_uri')  String? redirectUri, @JsonKey(name: 'code_verifier')  String? codeVerifier, @JsonKey(name: 'new_password')  String newPassword, @JsonKey(name: 'confirm_password')  String confirmPassword)  $default,) {final _that = this;
switch (_that) {
case _SetPasswordRequestDto():
return $default(_that.provider,_that.idToken,_that.accessToken,_that.code,_that.redirectUri,_that.codeVerifier,_that.newPassword,_that.confirmPassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String provider, @JsonKey(name: 'id_token')  String? idToken, @JsonKey(name: 'access_token')  String? accessToken,  String? code, @JsonKey(name: 'redirect_uri')  String? redirectUri, @JsonKey(name: 'code_verifier')  String? codeVerifier, @JsonKey(name: 'new_password')  String newPassword, @JsonKey(name: 'confirm_password')  String confirmPassword)?  $default,) {final _that = this;
switch (_that) {
case _SetPasswordRequestDto() when $default != null:
return $default(_that.provider,_that.idToken,_that.accessToken,_that.code,_that.redirectUri,_that.codeVerifier,_that.newPassword,_that.confirmPassword);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetPasswordRequestDto implements SetPasswordRequestDto {
  const _SetPasswordRequestDto({required this.provider, @JsonKey(name: 'id_token') this.idToken, @JsonKey(name: 'access_token') this.accessToken, this.code, @JsonKey(name: 'redirect_uri') this.redirectUri, @JsonKey(name: 'code_verifier') this.codeVerifier, @JsonKey(name: 'new_password') required this.newPassword, @JsonKey(name: 'confirm_password') required this.confirmPassword});
  factory _SetPasswordRequestDto.fromJson(Map<String, dynamic> json) => _$SetPasswordRequestDtoFromJson(json);

@override final  String provider;
@override@JsonKey(name: 'id_token') final  String? idToken;
@override@JsonKey(name: 'access_token') final  String? accessToken;
@override final  String? code;
@override@JsonKey(name: 'redirect_uri') final  String? redirectUri;
@override@JsonKey(name: 'code_verifier') final  String? codeVerifier;
@override@JsonKey(name: 'new_password') final  String newPassword;
@override@JsonKey(name: 'confirm_password') final  String confirmPassword;

/// Create a copy of SetPasswordRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetPasswordRequestDtoCopyWith<_SetPasswordRequestDto> get copyWith => __$SetPasswordRequestDtoCopyWithImpl<_SetPasswordRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetPasswordRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetPasswordRequestDto&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.idToken, idToken) || other.idToken == idToken)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.code, code) || other.code == code)&&(identical(other.redirectUri, redirectUri) || other.redirectUri == redirectUri)&&(identical(other.codeVerifier, codeVerifier) || other.codeVerifier == codeVerifier)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,provider,idToken,accessToken,code,redirectUri,codeVerifier,newPassword,confirmPassword);
}

@override
String toString() {
    return 'SetPasswordRequestDto(provider: $provider, idToken: $idToken, accessToken: $accessToken, code: $code, redirectUri: $redirectUri, codeVerifier: $codeVerifier, newPassword: $newPassword, confirmPassword: $confirmPassword)';
}


}

/// @nodoc
abstract mixin class _$SetPasswordRequestDtoCopyWith<$Res> implements $SetPasswordRequestDtoCopyWith<$Res> {
  factory _$SetPasswordRequestDtoCopyWith(_SetPasswordRequestDto value, $Res Function(_SetPasswordRequestDto) _then) = __$SetPasswordRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String provider,@JsonKey(name: 'id_token') String? idToken,@JsonKey(name: 'access_token') String? accessToken, String? code,@JsonKey(name: 'redirect_uri') String? redirectUri,@JsonKey(name: 'code_verifier') String? codeVerifier,@JsonKey(name: 'new_password') String newPassword,@JsonKey(name: 'confirm_password') String confirmPassword
});




}
/// @nodoc
class __$SetPasswordRequestDtoCopyWithImpl<$Res>
    implements _$SetPasswordRequestDtoCopyWith<$Res> {
  __$SetPasswordRequestDtoCopyWithImpl(this._self, this._then);

  final _SetPasswordRequestDto _self;
  final $Res Function(_SetPasswordRequestDto) _then;

/// Create a copy of SetPasswordRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? idToken = freezed,Object? accessToken = freezed,Object? code = freezed,Object? redirectUri = freezed,Object? codeVerifier = freezed,Object? newPassword = null,Object? confirmPassword = null,}) {
  return _then(_SetPasswordRequestDto(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,idToken: freezed == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String?,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,redirectUri: freezed == redirectUri ? _self.redirectUri : redirectUri // ignore: cast_nullable_to_non_nullable
as String?,codeVerifier: freezed == codeVerifier ? _self.codeVerifier : codeVerifier // ignore: cast_nullable_to_non_nullable
as String?,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SetPasswordResponseDto {

 String get message;@JsonKey(name: 'login_with') String get loginWith;
/// Create a copy of SetPasswordResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetPasswordResponseDtoCopyWith<SetPasswordResponseDto> get copyWith => _$SetPasswordResponseDtoCopyWithImpl<SetPasswordResponseDto>(this as SetPasswordResponseDto, _$identity);

  /// Serializes this SetPasswordResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SetPasswordResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetPasswordResponseDto&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.loginWith, _this.loginWith) || other.loginWith == _this.loginWith));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SetPasswordResponseDto;
  return Object.hash(runtimeType,_this.message,_this.loginWith);
}

@override
String toString() {
  final _this = this as SetPasswordResponseDto;
  return 'SetPasswordResponseDto(message: ${_this.message}, loginWith: ${_this.loginWith})';
}


}

/// @nodoc
abstract mixin class $SetPasswordResponseDtoCopyWith<$Res>  {
  factory $SetPasswordResponseDtoCopyWith(SetPasswordResponseDto value, $Res Function(SetPasswordResponseDto) _then) = _$SetPasswordResponseDtoCopyWithImpl;
@useResult
$Res call({
 String message,@JsonKey(name: 'login_with') String loginWith
});




}
/// @nodoc
class _$SetPasswordResponseDtoCopyWithImpl<$Res>
    implements $SetPasswordResponseDtoCopyWith<$Res> {
  _$SetPasswordResponseDtoCopyWithImpl(this._self, this._then);

  final SetPasswordResponseDto _self;
  final $Res Function(SetPasswordResponseDto) _then;

/// Create a copy of SetPasswordResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? loginWith = null,}) {
  return _then(SetPasswordResponseDto(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,loginWith: null == loginWith ? _self.loginWith : loginWith // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SetPasswordResponseDto].
extension SetPasswordResponseDtoPatterns on SetPasswordResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetPasswordResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetPasswordResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetPasswordResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _SetPasswordResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetPasswordResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _SetPasswordResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message, @JsonKey(name: 'login_with')  String loginWith)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetPasswordResponseDto() when $default != null:
return $default(_that.message,_that.loginWith);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message, @JsonKey(name: 'login_with')  String loginWith)  $default,) {final _that = this;
switch (_that) {
case _SetPasswordResponseDto():
return $default(_that.message,_that.loginWith);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message, @JsonKey(name: 'login_with')  String loginWith)?  $default,) {final _that = this;
switch (_that) {
case _SetPasswordResponseDto() when $default != null:
return $default(_that.message,_that.loginWith);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetPasswordResponseDto implements SetPasswordResponseDto {
  const _SetPasswordResponseDto({required this.message, @JsonKey(name: 'login_with') required this.loginWith});
  factory _SetPasswordResponseDto.fromJson(Map<String, dynamic> json) => _$SetPasswordResponseDtoFromJson(json);

@override final  String message;
@override@JsonKey(name: 'login_with') final  String loginWith;

/// Create a copy of SetPasswordResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetPasswordResponseDtoCopyWith<_SetPasswordResponseDto> get copyWith => __$SetPasswordResponseDtoCopyWithImpl<_SetPasswordResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetPasswordResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetPasswordResponseDto&&(identical(other.message, message) || other.message == message)&&(identical(other.loginWith, loginWith) || other.loginWith == loginWith));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,message,loginWith);
}

@override
String toString() {
    return 'SetPasswordResponseDto(message: $message, loginWith: $loginWith)';
}


}

/// @nodoc
abstract mixin class _$SetPasswordResponseDtoCopyWith<$Res> implements $SetPasswordResponseDtoCopyWith<$Res> {
  factory _$SetPasswordResponseDtoCopyWith(_SetPasswordResponseDto value, $Res Function(_SetPasswordResponseDto) _then) = __$SetPasswordResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String message,@JsonKey(name: 'login_with') String loginWith
});




}
/// @nodoc
class __$SetPasswordResponseDtoCopyWithImpl<$Res>
    implements _$SetPasswordResponseDtoCopyWith<$Res> {
  __$SetPasswordResponseDtoCopyWithImpl(this._self, this._then);

  final _SetPasswordResponseDto _self;
  final $Res Function(_SetPasswordResponseDto) _then;

/// Create a copy of SetPasswordResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? loginWith = null,}) {
  return _then(_SetPasswordResponseDto(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,loginWith: null == loginWith ? _self.loginWith : loginWith // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
