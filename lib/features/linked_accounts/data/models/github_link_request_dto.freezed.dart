// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'github_link_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GithubLinkRequestDto {

 String get code;@JsonKey(name: 'redirect_uri') String get redirectUri;@JsonKey(name: 'code_verifier') String? get codeVerifier;
/// Create a copy of GithubLinkRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GithubLinkRequestDtoCopyWith<GithubLinkRequestDto> get copyWith => _$GithubLinkRequestDtoCopyWithImpl<GithubLinkRequestDto>(this as GithubLinkRequestDto, _$identity);

  /// Serializes this GithubLinkRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GithubLinkRequestDto&&(identical(other.code, code) || other.code == code)&&(identical(other.redirectUri, redirectUri) || other.redirectUri == redirectUri)&&(identical(other.codeVerifier, codeVerifier) || other.codeVerifier == codeVerifier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,redirectUri,codeVerifier);

@override
String toString() {
  return 'GithubLinkRequestDto(code: $code, redirectUri: $redirectUri, codeVerifier: $codeVerifier)';
}


}

/// @nodoc
abstract mixin class $GithubLinkRequestDtoCopyWith<$Res>  {
  factory $GithubLinkRequestDtoCopyWith(GithubLinkRequestDto value, $Res Function(GithubLinkRequestDto) _then) = _$GithubLinkRequestDtoCopyWithImpl;
@useResult
$Res call({
 String code,@JsonKey(name: 'redirect_uri') String redirectUri,@JsonKey(name: 'code_verifier') String? codeVerifier
});




}
/// @nodoc
class _$GithubLinkRequestDtoCopyWithImpl<$Res>
    implements $GithubLinkRequestDtoCopyWith<$Res> {
  _$GithubLinkRequestDtoCopyWithImpl(this._self, this._then);

  final GithubLinkRequestDto _self;
  final $Res Function(GithubLinkRequestDto) _then;

/// Create a copy of GithubLinkRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? redirectUri = null,Object? codeVerifier = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,redirectUri: null == redirectUri ? _self.redirectUri : redirectUri // ignore: cast_nullable_to_non_nullable
as String,codeVerifier: freezed == codeVerifier ? _self.codeVerifier : codeVerifier // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GithubLinkRequestDto].
extension GithubLinkRequestDtoPatterns on GithubLinkRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GithubLinkRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GithubLinkRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GithubLinkRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _GithubLinkRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GithubLinkRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _GithubLinkRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code, @JsonKey(name: 'redirect_uri')  String redirectUri, @JsonKey(name: 'code_verifier')  String? codeVerifier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GithubLinkRequestDto() when $default != null:
return $default(_that.code,_that.redirectUri,_that.codeVerifier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code, @JsonKey(name: 'redirect_uri')  String redirectUri, @JsonKey(name: 'code_verifier')  String? codeVerifier)  $default,) {final _that = this;
switch (_that) {
case _GithubLinkRequestDto():
return $default(_that.code,_that.redirectUri,_that.codeVerifier);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code, @JsonKey(name: 'redirect_uri')  String redirectUri, @JsonKey(name: 'code_verifier')  String? codeVerifier)?  $default,) {final _that = this;
switch (_that) {
case _GithubLinkRequestDto() when $default != null:
return $default(_that.code,_that.redirectUri,_that.codeVerifier);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GithubLinkRequestDto implements GithubLinkRequestDto {
  const _GithubLinkRequestDto({required this.code, @JsonKey(name: 'redirect_uri') required this.redirectUri, @JsonKey(name: 'code_verifier') this.codeVerifier});
  factory _GithubLinkRequestDto.fromJson(Map<String, dynamic> json) => _$GithubLinkRequestDtoFromJson(json);

@override final  String code;
@override@JsonKey(name: 'redirect_uri') final  String redirectUri;
@override@JsonKey(name: 'code_verifier') final  String? codeVerifier;

/// Create a copy of GithubLinkRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GithubLinkRequestDtoCopyWith<_GithubLinkRequestDto> get copyWith => __$GithubLinkRequestDtoCopyWithImpl<_GithubLinkRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GithubLinkRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GithubLinkRequestDto&&(identical(other.code, code) || other.code == code)&&(identical(other.redirectUri, redirectUri) || other.redirectUri == redirectUri)&&(identical(other.codeVerifier, codeVerifier) || other.codeVerifier == codeVerifier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,redirectUri,codeVerifier);

@override
String toString() {
  return 'GithubLinkRequestDto(code: $code, redirectUri: $redirectUri, codeVerifier: $codeVerifier)';
}


}

/// @nodoc
abstract mixin class _$GithubLinkRequestDtoCopyWith<$Res> implements $GithubLinkRequestDtoCopyWith<$Res> {
  factory _$GithubLinkRequestDtoCopyWith(_GithubLinkRequestDto value, $Res Function(_GithubLinkRequestDto) _then) = __$GithubLinkRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String code,@JsonKey(name: 'redirect_uri') String redirectUri,@JsonKey(name: 'code_verifier') String? codeVerifier
});




}
/// @nodoc
class __$GithubLinkRequestDtoCopyWithImpl<$Res>
    implements _$GithubLinkRequestDtoCopyWith<$Res> {
  __$GithubLinkRequestDtoCopyWithImpl(this._self, this._then);

  final _GithubLinkRequestDto _self;
  final $Res Function(_GithubLinkRequestDto) _then;

/// Create a copy of GithubLinkRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? redirectUri = null,Object? codeVerifier = freezed,}) {
  return _then(_GithubLinkRequestDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,redirectUri: null == redirectUri ? _self.redirectUri : redirectUri // ignore: cast_nullable_to_non_nullable
as String,codeVerifier: freezed == codeVerifier ? _self.codeVerifier : codeVerifier // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$GithubLinkResponseDto {

 String get provider;@JsonKey(name: 'linked_at') String get linkedAt;
/// Create a copy of GithubLinkResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GithubLinkResponseDtoCopyWith<GithubLinkResponseDto> get copyWith => _$GithubLinkResponseDtoCopyWithImpl<GithubLinkResponseDto>(this as GithubLinkResponseDto, _$identity);

  /// Serializes this GithubLinkResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GithubLinkResponseDto&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.linkedAt, linkedAt) || other.linkedAt == linkedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,provider,linkedAt);

@override
String toString() {
  return 'GithubLinkResponseDto(provider: $provider, linkedAt: $linkedAt)';
}


}

/// @nodoc
abstract mixin class $GithubLinkResponseDtoCopyWith<$Res>  {
  factory $GithubLinkResponseDtoCopyWith(GithubLinkResponseDto value, $Res Function(GithubLinkResponseDto) _then) = _$GithubLinkResponseDtoCopyWithImpl;
@useResult
$Res call({
 String provider,@JsonKey(name: 'linked_at') String linkedAt
});




}
/// @nodoc
class _$GithubLinkResponseDtoCopyWithImpl<$Res>
    implements $GithubLinkResponseDtoCopyWith<$Res> {
  _$GithubLinkResponseDtoCopyWithImpl(this._self, this._then);

  final GithubLinkResponseDto _self;
  final $Res Function(GithubLinkResponseDto) _then;

/// Create a copy of GithubLinkResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? linkedAt = null,}) {
  return _then(_self.copyWith(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,linkedAt: null == linkedAt ? _self.linkedAt : linkedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GithubLinkResponseDto].
extension GithubLinkResponseDtoPatterns on GithubLinkResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GithubLinkResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GithubLinkResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GithubLinkResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _GithubLinkResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GithubLinkResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _GithubLinkResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String provider, @JsonKey(name: 'linked_at')  String linkedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GithubLinkResponseDto() when $default != null:
return $default(_that.provider,_that.linkedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String provider, @JsonKey(name: 'linked_at')  String linkedAt)  $default,) {final _that = this;
switch (_that) {
case _GithubLinkResponseDto():
return $default(_that.provider,_that.linkedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String provider, @JsonKey(name: 'linked_at')  String linkedAt)?  $default,) {final _that = this;
switch (_that) {
case _GithubLinkResponseDto() when $default != null:
return $default(_that.provider,_that.linkedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GithubLinkResponseDto implements GithubLinkResponseDto {
  const _GithubLinkResponseDto({required this.provider, @JsonKey(name: 'linked_at') required this.linkedAt});
  factory _GithubLinkResponseDto.fromJson(Map<String, dynamic> json) => _$GithubLinkResponseDtoFromJson(json);

@override final  String provider;
@override@JsonKey(name: 'linked_at') final  String linkedAt;

/// Create a copy of GithubLinkResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GithubLinkResponseDtoCopyWith<_GithubLinkResponseDto> get copyWith => __$GithubLinkResponseDtoCopyWithImpl<_GithubLinkResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GithubLinkResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GithubLinkResponseDto&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.linkedAt, linkedAt) || other.linkedAt == linkedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,provider,linkedAt);

@override
String toString() {
  return 'GithubLinkResponseDto(provider: $provider, linkedAt: $linkedAt)';
}


}

/// @nodoc
abstract mixin class _$GithubLinkResponseDtoCopyWith<$Res> implements $GithubLinkResponseDtoCopyWith<$Res> {
  factory _$GithubLinkResponseDtoCopyWith(_GithubLinkResponseDto value, $Res Function(_GithubLinkResponseDto) _then) = __$GithubLinkResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String provider,@JsonKey(name: 'linked_at') String linkedAt
});




}
/// @nodoc
class __$GithubLinkResponseDtoCopyWithImpl<$Res>
    implements _$GithubLinkResponseDtoCopyWith<$Res> {
  __$GithubLinkResponseDtoCopyWithImpl(this._self, this._then);

  final _GithubLinkResponseDto _self;
  final $Res Function(_GithubLinkResponseDto) _then;

/// Create a copy of GithubLinkResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? linkedAt = null,}) {
  return _then(_GithubLinkResponseDto(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,linkedAt: null == linkedAt ? _self.linkedAt : linkedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
