// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'github_login_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GithubLoginRequestDto {

 String get code;@JsonKey(name: 'redirect_uri') String get redirectUri;@JsonKey(name: 'code_verifier') String? get codeVerifier;@JsonKey(name: 'client_type') String get clientType;/// Persetujuan legal - wajib untuk akun baru (mode enforce).
@JsonKey(includeIfNull: false) List<LegalConsentDto>? get consents;
/// Create a copy of GithubLoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GithubLoginRequestDtoCopyWith<GithubLoginRequestDto> get copyWith => _$GithubLoginRequestDtoCopyWithImpl<GithubLoginRequestDto>(this as GithubLoginRequestDto, _$identity);

  /// Serializes this GithubLoginRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GithubLoginRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GithubLoginRequestDto&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.redirectUri, _this.redirectUri) || other.redirectUri == _this.redirectUri)&&(identical(other.codeVerifier, _this.codeVerifier) || other.codeVerifier == _this.codeVerifier)&&(identical(other.clientType, _this.clientType) || other.clientType == _this.clientType)&&const DeepCollectionEquality().equals(other.consents, _this.consents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GithubLoginRequestDto;
  return Object.hash(runtimeType,_this.code,_this.redirectUri,_this.codeVerifier,_this.clientType,const DeepCollectionEquality().hash(_this.consents));
}

@override
String toString() {
  final _this = this as GithubLoginRequestDto;
  return 'GithubLoginRequestDto(code: ${_this.code}, redirectUri: ${_this.redirectUri}, codeVerifier: ${_this.codeVerifier}, clientType: ${_this.clientType}, consents: ${_this.consents})';
}


}

/// @nodoc
abstract mixin class $GithubLoginRequestDtoCopyWith<$Res>  {
  factory $GithubLoginRequestDtoCopyWith(GithubLoginRequestDto value, $Res Function(GithubLoginRequestDto) _then) = _$GithubLoginRequestDtoCopyWithImpl;
@useResult
$Res call({
 String code,@JsonKey(name: 'redirect_uri') String redirectUri,@JsonKey(name: 'code_verifier') String? codeVerifier,@JsonKey(name: 'client_type') String clientType,@JsonKey(includeIfNull: false) List<LegalConsentDto>? consents
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
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? redirectUri = null,Object? codeVerifier = freezed,Object? clientType = null,Object? consents = freezed,}) {
  return _then(GithubLoginRequestDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,redirectUri: null == redirectUri ? _self.redirectUri : redirectUri // ignore: cast_nullable_to_non_nullable
as String,codeVerifier: freezed == codeVerifier ? _self.codeVerifier : codeVerifier // ignore: cast_nullable_to_non_nullable
as String?,clientType: null == clientType ? _self.clientType : clientType // ignore: cast_nullable_to_non_nullable
as String,consents: freezed == consents ? _self.consents : consents // ignore: cast_nullable_to_non_nullable
as List<LegalConsentDto>?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code, @JsonKey(name: 'redirect_uri')  String redirectUri, @JsonKey(name: 'code_verifier')  String? codeVerifier, @JsonKey(name: 'client_type')  String clientType, @JsonKey(includeIfNull: false)  List<LegalConsentDto>? consents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GithubLoginRequestDto() when $default != null:
return $default(_that.code,_that.redirectUri,_that.codeVerifier,_that.clientType,_that.consents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code, @JsonKey(name: 'redirect_uri')  String redirectUri, @JsonKey(name: 'code_verifier')  String? codeVerifier, @JsonKey(name: 'client_type')  String clientType, @JsonKey(includeIfNull: false)  List<LegalConsentDto>? consents)  $default,) {final _that = this;
switch (_that) {
case _GithubLoginRequestDto():
return $default(_that.code,_that.redirectUri,_that.codeVerifier,_that.clientType,_that.consents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code, @JsonKey(name: 'redirect_uri')  String redirectUri, @JsonKey(name: 'code_verifier')  String? codeVerifier, @JsonKey(name: 'client_type')  String clientType, @JsonKey(includeIfNull: false)  List<LegalConsentDto>? consents)?  $default,) {final _that = this;
switch (_that) {
case _GithubLoginRequestDto() when $default != null:
return $default(_that.code,_that.redirectUri,_that.codeVerifier,_that.clientType,_that.consents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GithubLoginRequestDto implements GithubLoginRequestDto {
  const _GithubLoginRequestDto({required this.code, @JsonKey(name: 'redirect_uri') required this.redirectUri, @JsonKey(name: 'code_verifier') this.codeVerifier, @JsonKey(name: 'client_type') this.clientType = 'mobile', @JsonKey(includeIfNull: false)  List<LegalConsentDto>? consents}): _consents = consents;
  factory _GithubLoginRequestDto.fromJson(Map<String, dynamic> json) => _$GithubLoginRequestDtoFromJson(json);

@override final  String code;
@override@JsonKey(name: 'redirect_uri') final  String redirectUri;
@override@JsonKey(name: 'code_verifier') final  String? codeVerifier;
@override@JsonKey(name: 'client_type') final  String clientType;
/// Persetujuan legal - wajib untuk akun baru (mode enforce).
 final  List<LegalConsentDto>? _consents;
/// Persetujuan legal - wajib untuk akun baru (mode enforce).
@override@JsonKey(includeIfNull: false) List<LegalConsentDto>? get consents {
  final value = _consents;
  if (value == null) return null;
  if (_consents is EqualUnmodifiableListView) return _consents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GithubLoginRequestDto&&(identical(other.code, code) || other.code == code)&&(identical(other.redirectUri, redirectUri) || other.redirectUri == redirectUri)&&(identical(other.codeVerifier, codeVerifier) || other.codeVerifier == codeVerifier)&&(identical(other.clientType, clientType) || other.clientType == clientType)&&const DeepCollectionEquality().equals(other.consents, _consents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,redirectUri,codeVerifier,clientType,const DeepCollectionEquality().hash(_consents));
}

@override
String toString() {
    return 'GithubLoginRequestDto(code: $code, redirectUri: $redirectUri, codeVerifier: $codeVerifier, clientType: $clientType, consents: $consents)';
}


}

/// @nodoc
abstract mixin class _$GithubLoginRequestDtoCopyWith<$Res> implements $GithubLoginRequestDtoCopyWith<$Res> {
  factory _$GithubLoginRequestDtoCopyWith(_GithubLoginRequestDto value, $Res Function(_GithubLoginRequestDto) _then) = __$GithubLoginRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String code,@JsonKey(name: 'redirect_uri') String redirectUri,@JsonKey(name: 'code_verifier') String? codeVerifier,@JsonKey(name: 'client_type') String clientType,@JsonKey(includeIfNull: false) List<LegalConsentDto>? consents
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
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? redirectUri = null,Object? codeVerifier = freezed,Object? clientType = null,Object? consents = freezed,}) {
  return _then(_GithubLoginRequestDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,redirectUri: null == redirectUri ? _self.redirectUri : redirectUri // ignore: cast_nullable_to_non_nullable
as String,codeVerifier: freezed == codeVerifier ? _self.codeVerifier : codeVerifier // ignore: cast_nullable_to_non_nullable
as String?,clientType: null == clientType ? _self.clientType : clientType // ignore: cast_nullable_to_non_nullable
as String,consents: freezed == consents ? _self._consents : consents // ignore: cast_nullable_to_non_nullable
as List<LegalConsentDto>?,
  ));
}


}

// dart format on
