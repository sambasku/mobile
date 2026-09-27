// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'github_login_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GithubLoginRequestDto {

 String get code;@JsonKey(name: 'redirect_uri') String get redirectUri;@JsonKey(name: 'code_verifier') String? get codeVerifier;@JsonKey(name: 'client_type') String get clientType;
/// Create a copy of GithubLoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GithubLoginRequestDtoCopyWith<GithubLoginRequestDto> get copyWith => _$GithubLoginRequestDtoCopyWithImpl<GithubLoginRequestDto>(this as GithubLoginRequestDto, _$identity);

  /// Serializes this GithubLoginRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GithubLoginRequestDto&&(identical(other.code, code) || other.code == code)&&(identical(other.redirectUri, redirectUri) || other.redirectUri == redirectUri)&&(identical(other.codeVerifier, codeVerifier) || other.codeVerifier == codeVerifier)&&(identical(other.clientType, clientType) || other.clientType == clientType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,redirectUri,codeVerifier,clientType);

@override
String toString() {
  return 'GithubLoginRequestDto(code: $code, redirectUri: $redirectUri, codeVerifier: $codeVerifier, clientType: $clientType)';
}


}

/// @nodoc
abstract mixin class $GithubLoginRequestDtoCopyWith<$Res>  {
  factory $GithubLoginRequestDtoCopyWith(GithubLoginRequestDto value, $Res Function(GithubLoginRequestDto) _then) = _$GithubLoginRequestDtoCopyWithImpl;
@useResult
$Res call({
 String code,@JsonKey(name: 'redirect_uri') String redirectUri,@JsonKey(name: 'code_verifier') String? codeVerifier,@JsonKey(name: 'client_type') String clientType
});




}
/// @nodoc
class _$GithubLoginRequestDtoCopyWithImpl<$Res>
    implements $GithubLoginRequestDtoCopyWith<$Res> {
  _$GithubLoginRequestDtoCopyWithImpl(this._self, this._then);

  final GithubLoginRequestDto _self;
  final $Res Function(GithubLoginRequestDto) _then;

/// Create a copy of GithubLoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? redirectUri = null,Object? codeVerifier = freezed,Object? clientType = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,redirectUri: null == redirectUri ? _self.redirectUri : redirectUri // ignore: cast_nullable_to_non_nullable
as String,codeVerifier: freezed == codeVerifier ? _self.codeVerifier : codeVerifier // ignore: cast_nullable_to_non_nullable
as String?,clientType: null == clientType ? _self.clientType : clientType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GithubLoginRequestDto].
extension GithubLoginRequestDtoPatterns on GithubLoginRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GithubLoginRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GithubLoginRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GithubLoginRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _GithubLoginRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GithubLoginRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _GithubLoginRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code, @JsonKey(name: 'redirect_uri')  String redirectUri, @JsonKey(name: 'code_verifier')  String? codeVerifier, @JsonKey(name: 'client_type')  String clientType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GithubLoginRequestDto() when $default != null:
return $default(_that.code,_that.redirectUri,_that.codeVerifier,_that.clientType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code, @JsonKey(name: 'redirect_uri')  String redirectUri, @JsonKey(name: 'code_verifier')  String? codeVerifier, @JsonKey(name: 'client_type')  String clientType)  $default,) {final _that = this;
switch (_that) {
case _GithubLoginRequestDto():
return $default(_that.code,_that.redirectUri,_that.codeVerifier,_that.clientType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code, @JsonKey(name: 'redirect_uri')  String redirectUri, @JsonKey(name: 'code_verifier')  String? codeVerifier, @JsonKey(name: 'client_type')  String clientType)?  $default,) {final _that = this;
switch (_that) {
case _GithubLoginRequestDto() when $default != null:
return $default(_that.code,_that.redirectUri,_that.codeVerifier,_that.clientType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GithubLoginRequestDto implements GithubLoginRequestDto {
  const _GithubLoginRequestDto({required this.code, @JsonKey(name: 'redirect_uri') required this.redirectUri, @JsonKey(name: 'code_verifier') this.codeVerifier, @JsonKey(name: 'client_type') this.clientType = 'mobile'});
  factory _GithubLoginRequestDto.fromJson(Map<String, dynamic> json) => _$GithubLoginRequestDtoFromJson(json);

@override final  String code;
@override@JsonKey(name: 'redirect_uri') final  String redirectUri;
@override@JsonKey(name: 'code_verifier') final  String? codeVerifier;
@override@JsonKey(name: 'client_type') final  String clientType;

/// Create a copy of GithubLoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GithubLoginRequestDtoCopyWith<_GithubLoginRequestDto> get copyWith => __$GithubLoginRequestDtoCopyWithImpl<_GithubLoginRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GithubLoginRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GithubLoginRequestDto&&(identical(other.code, code) || other.code == code)&&(identical(other.redirectUri, redirectUri) || other.redirectUri == redirectUri)&&(identical(other.codeVerifier, codeVerifier) || other.codeVerifier == codeVerifier)&&(identical(other.clientType, clientType) || other.clientType == clientType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,redirectUri,codeVerifier,clientType);

@override
String toString() {
  return 'GithubLoginRequestDto(code: $code, redirectUri: $redirectUri, codeVerifier: $codeVerifier, clientType: $clientType)';
}


}

/// @nodoc
abstract mixin class _$GithubLoginRequestDtoCopyWith<$Res> implements $GithubLoginRequestDtoCopyWith<$Res> {
  factory _$GithubLoginRequestDtoCopyWith(_GithubLoginRequestDto value, $Res Function(_GithubLoginRequestDto) _then) = __$GithubLoginRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String code,@JsonKey(name: 'redirect_uri') String redirectUri,@JsonKey(name: 'code_verifier') String? codeVerifier,@JsonKey(name: 'client_type') String clientType
});




}
/// @nodoc
class __$GithubLoginRequestDtoCopyWithImpl<$Res>
    implements _$GithubLoginRequestDtoCopyWith<$Res> {
  __$GithubLoginRequestDtoCopyWithImpl(this._self, this._then);

  final _GithubLoginRequestDto _self;
  final $Res Function(_GithubLoginRequestDto) _then;

/// Create a copy of GithubLoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? redirectUri = null,Object? codeVerifier = freezed,Object? clientType = null,}) {
  return _then(_GithubLoginRequestDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,redirectUri: null == redirectUri ? _self.redirectUri : redirectUri // ignore: cast_nullable_to_non_nullable
as String,codeVerifier: freezed == codeVerifier ? _self.codeVerifier : codeVerifier // ignore: cast_nullable_to_non_nullable
as String?,clientType: null == clientType ? _self.clientType : clientType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
