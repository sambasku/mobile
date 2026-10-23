// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_credentials_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UploadCredentialsDto {

 String get token; String get signature; int get expire;@JsonKey(name: 'public_key') String get publicKey;@JsonKey(name: 'upload_endpoint') String get uploadEndpoint;
/// Create a copy of UploadCredentialsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadCredentialsDtoCopyWith<UploadCredentialsDto> get copyWith => _$UploadCredentialsDtoCopyWithImpl<UploadCredentialsDto>(this as UploadCredentialsDto, _$identity);

  /// Serializes this UploadCredentialsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UploadCredentialsDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadCredentialsDto&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.signature, _this.signature) || other.signature == _this.signature)&&(identical(other.expire, _this.expire) || other.expire == _this.expire)&&(identical(other.publicKey, _this.publicKey) || other.publicKey == _this.publicKey)&&(identical(other.uploadEndpoint, _this.uploadEndpoint) || other.uploadEndpoint == _this.uploadEndpoint));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UploadCredentialsDto;
  return Object.hash(runtimeType,_this.token,_this.signature,_this.expire,_this.publicKey,_this.uploadEndpoint);
}

@override
String toString() {
  final _this = this as UploadCredentialsDto;
  return 'UploadCredentialsDto(token: ${_this.token}, signature: ${_this.signature}, expire: ${_this.expire}, publicKey: ${_this.publicKey}, uploadEndpoint: ${_this.uploadEndpoint})';
}


}

/// @nodoc
abstract mixin class $UploadCredentialsDtoCopyWith<$Res>  {
  factory $UploadCredentialsDtoCopyWith(UploadCredentialsDto value, $Res Function(UploadCredentialsDto) _then) = _$UploadCredentialsDtoCopyWithImpl;
@useResult
$Res call({
 String token, String signature, int expire,@JsonKey(name: 'public_key') String publicKey,@JsonKey(name: 'upload_endpoint') String uploadEndpoint
});




}
/// @nodoc
class _$UploadCredentialsDtoCopyWithImpl<$Res>
    implements $UploadCredentialsDtoCopyWith<$Res> {
  _$UploadCredentialsDtoCopyWithImpl(this._self, this._then);

  final UploadCredentialsDto _self;
  final $Res Function(UploadCredentialsDto) _then;

/// Create a copy of UploadCredentialsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? signature = null,Object? expire = null,Object? publicKey = null,Object? uploadEndpoint = null,}) {
  return _then(UploadCredentialsDto(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,signature: null == signature ? _self.signature : signature // ignore: cast_nullable_to_non_nullable
as String,expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,publicKey: null == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String,uploadEndpoint: null == uploadEndpoint ? _self.uploadEndpoint : uploadEndpoint // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadCredentialsDto].
extension UploadCredentialsDtoPatterns on UploadCredentialsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadCredentialsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadCredentialsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadCredentialsDto value)  $default,){
final _that = this;
switch (_that) {
case _UploadCredentialsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadCredentialsDto value)?  $default,){
final _that = this;
switch (_that) {
case _UploadCredentialsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String signature,  int expire, @JsonKey(name: 'public_key')  String publicKey, @JsonKey(name: 'upload_endpoint')  String uploadEndpoint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadCredentialsDto() when $default != null:
return $default(_that.token,_that.signature,_that.expire,_that.publicKey,_that.uploadEndpoint);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String signature,  int expire, @JsonKey(name: 'public_key')  String publicKey, @JsonKey(name: 'upload_endpoint')  String uploadEndpoint)  $default,) {final _that = this;
switch (_that) {
case _UploadCredentialsDto():
return $default(_that.token,_that.signature,_that.expire,_that.publicKey,_that.uploadEndpoint);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String signature,  int expire, @JsonKey(name: 'public_key')  String publicKey, @JsonKey(name: 'upload_endpoint')  String uploadEndpoint)?  $default,) {final _that = this;
switch (_that) {
case _UploadCredentialsDto() when $default != null:
return $default(_that.token,_that.signature,_that.expire,_that.publicKey,_that.uploadEndpoint);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadCredentialsDto implements UploadCredentialsDto {
  const _UploadCredentialsDto({required this.token, required this.signature, required this.expire, @JsonKey(name: 'public_key') required this.publicKey, @JsonKey(name: 'upload_endpoint') required this.uploadEndpoint});
  factory _UploadCredentialsDto.fromJson(Map<String, dynamic> json) => _$UploadCredentialsDtoFromJson(json);

@override final  String token;
@override final  String signature;
@override final  int expire;
@override@JsonKey(name: 'public_key') final  String publicKey;
@override@JsonKey(name: 'upload_endpoint') final  String uploadEndpoint;

/// Create a copy of UploadCredentialsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadCredentialsDtoCopyWith<_UploadCredentialsDto> get copyWith => __$UploadCredentialsDtoCopyWithImpl<_UploadCredentialsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadCredentialsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadCredentialsDto&&(identical(other.token, token) || other.token == token)&&(identical(other.signature, signature) || other.signature == signature)&&(identical(other.expire, expire) || other.expire == expire)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.uploadEndpoint, uploadEndpoint) || other.uploadEndpoint == uploadEndpoint));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,token,signature,expire,publicKey,uploadEndpoint);
}

@override
String toString() {
    return 'UploadCredentialsDto(token: $token, signature: $signature, expire: $expire, publicKey: $publicKey, uploadEndpoint: $uploadEndpoint)';
}


}

/// @nodoc
abstract mixin class _$UploadCredentialsDtoCopyWith<$Res> implements $UploadCredentialsDtoCopyWith<$Res> {
  factory _$UploadCredentialsDtoCopyWith(_UploadCredentialsDto value, $Res Function(_UploadCredentialsDto) _then) = __$UploadCredentialsDtoCopyWithImpl;
@override @useResult
$Res call({
 String token, String signature, int expire,@JsonKey(name: 'public_key') String publicKey,@JsonKey(name: 'upload_endpoint') String uploadEndpoint
});




}
/// @nodoc
class __$UploadCredentialsDtoCopyWithImpl<$Res>
    implements _$UploadCredentialsDtoCopyWith<$Res> {
  __$UploadCredentialsDtoCopyWithImpl(this._self, this._then);

  final _UploadCredentialsDto _self;
  final $Res Function(_UploadCredentialsDto) _then;

/// Create a copy of UploadCredentialsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? signature = null,Object? expire = null,Object? publicKey = null,Object? uploadEndpoint = null,}) {
  return _then(_UploadCredentialsDto(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,signature: null == signature ? _self.signature : signature // ignore: cast_nullable_to_non_nullable
as String,expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,publicKey: null == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String,uploadEndpoint: null == uploadEndpoint ? _self.uploadEndpoint : uploadEndpoint // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
