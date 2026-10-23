// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_providers_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthProvidersDto {

 List<AuthProviderItemDto> get providers;@JsonKey(name: 'has_password') bool get hasPassword;
/// Create a copy of AuthProvidersDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthProvidersDtoCopyWith<AuthProvidersDto> get copyWith => _$AuthProvidersDtoCopyWithImpl<AuthProvidersDto>(this as AuthProvidersDto, _$identity);

  /// Serializes this AuthProvidersDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuthProvidersDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthProvidersDto&&const DeepCollectionEquality().equals(other.providers, _this.providers)&&(identical(other.hasPassword, _this.hasPassword) || other.hasPassword == _this.hasPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuthProvidersDto;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.providers),_this.hasPassword);
}

@override
String toString() {
  final _this = this as AuthProvidersDto;
  return 'AuthProvidersDto(providers: ${_this.providers}, hasPassword: ${_this.hasPassword})';
}


}

/// @nodoc
abstract mixin class $AuthProvidersDtoCopyWith<$Res>  {
  factory $AuthProvidersDtoCopyWith(AuthProvidersDto value, $Res Function(AuthProvidersDto) _then) = _$AuthProvidersDtoCopyWithImpl;
@useResult
$Res call({
 List<AuthProviderItemDto> providers,@JsonKey(name: 'has_password') bool hasPassword
});




}
/// @nodoc
class _$AuthProvidersDtoCopyWithImpl<$Res>
    implements $AuthProvidersDtoCopyWith<$Res> {
  _$AuthProvidersDtoCopyWithImpl(this._self, this._then);

  final AuthProvidersDto _self;
  final $Res Function(AuthProvidersDto) _then;

/// Create a copy of AuthProvidersDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? providers = null,Object? hasPassword = null,}) {
  return _then(AuthProvidersDto(
providers: null == providers ? _self.providers : providers // ignore: cast_nullable_to_non_nullable
as List<AuthProviderItemDto>,hasPassword: null == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthProvidersDto].
extension AuthProvidersDtoPatterns on AuthProvidersDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthProvidersDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthProvidersDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthProvidersDto value)  $default,){
final _that = this;
switch (_that) {
case _AuthProvidersDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthProvidersDto value)?  $default,){
final _that = this;
switch (_that) {
case _AuthProvidersDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AuthProviderItemDto> providers, @JsonKey(name: 'has_password')  bool hasPassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthProvidersDto() when $default != null:
return $default(_that.providers,_that.hasPassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AuthProviderItemDto> providers, @JsonKey(name: 'has_password')  bool hasPassword)  $default,) {final _that = this;
switch (_that) {
case _AuthProvidersDto():
return $default(_that.providers,_that.hasPassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AuthProviderItemDto> providers, @JsonKey(name: 'has_password')  bool hasPassword)?  $default,) {final _that = this;
switch (_that) {
case _AuthProvidersDto() when $default != null:
return $default(_that.providers,_that.hasPassword);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthProvidersDto implements AuthProvidersDto {
  const _AuthProvidersDto({ List<AuthProviderItemDto> providers = const [], @JsonKey(name: 'has_password') this.hasPassword = false}): _providers = providers;
  factory _AuthProvidersDto.fromJson(Map<String, dynamic> json) => _$AuthProvidersDtoFromJson(json);

 final  List<AuthProviderItemDto> _providers;
@override@JsonKey() List<AuthProviderItemDto> get providers {
  if (_providers is EqualUnmodifiableListView) return _providers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providers);
}

@override@JsonKey(name: 'has_password') final  bool hasPassword;

/// Create a copy of AuthProvidersDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthProvidersDtoCopyWith<_AuthProvidersDto> get copyWith => __$AuthProvidersDtoCopyWithImpl<_AuthProvidersDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthProvidersDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthProvidersDto&&const DeepCollectionEquality().equals(other.providers, _providers)&&(identical(other.hasPassword, hasPassword) || other.hasPassword == hasPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_providers),hasPassword);
}

@override
String toString() {
    return 'AuthProvidersDto(providers: $providers, hasPassword: $hasPassword)';
}


}

/// @nodoc
abstract mixin class _$AuthProvidersDtoCopyWith<$Res> implements $AuthProvidersDtoCopyWith<$Res> {
  factory _$AuthProvidersDtoCopyWith(_AuthProvidersDto value, $Res Function(_AuthProvidersDto) _then) = __$AuthProvidersDtoCopyWithImpl;
@override @useResult
$Res call({
 List<AuthProviderItemDto> providers,@JsonKey(name: 'has_password') bool hasPassword
});




}
/// @nodoc
class __$AuthProvidersDtoCopyWithImpl<$Res>
    implements _$AuthProvidersDtoCopyWith<$Res> {
  __$AuthProvidersDtoCopyWithImpl(this._self, this._then);

  final _AuthProvidersDto _self;
  final $Res Function(_AuthProvidersDto) _then;

/// Create a copy of AuthProvidersDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? providers = null,Object? hasPassword = null,}) {
  return _then(_AuthProvidersDto(
providers: null == providers ? _self._providers : providers // ignore: cast_nullable_to_non_nullable
as List<AuthProviderItemDto>,hasPassword: null == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AuthProviderItemDto {

 String get provider;@JsonKey(name: 'linked_at') String get linkedAt;
/// Create a copy of AuthProviderItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthProviderItemDtoCopyWith<AuthProviderItemDto> get copyWith => _$AuthProviderItemDtoCopyWithImpl<AuthProviderItemDto>(this as AuthProviderItemDto, _$identity);

  /// Serializes this AuthProviderItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuthProviderItemDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthProviderItemDto&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.linkedAt, _this.linkedAt) || other.linkedAt == _this.linkedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuthProviderItemDto;
  return Object.hash(runtimeType,_this.provider,_this.linkedAt);
}

@override
String toString() {
  final _this = this as AuthProviderItemDto;
  return 'AuthProviderItemDto(provider: ${_this.provider}, linkedAt: ${_this.linkedAt})';
}


}

/// @nodoc
abstract mixin class $AuthProviderItemDtoCopyWith<$Res>  {
  factory $AuthProviderItemDtoCopyWith(AuthProviderItemDto value, $Res Function(AuthProviderItemDto) _then) = _$AuthProviderItemDtoCopyWithImpl;
@useResult
$Res call({
 String provider,@JsonKey(name: 'linked_at') String linkedAt
});




}
/// @nodoc
class _$AuthProviderItemDtoCopyWithImpl<$Res>
    implements $AuthProviderItemDtoCopyWith<$Res> {
  _$AuthProviderItemDtoCopyWithImpl(this._self, this._then);

  final AuthProviderItemDto _self;
  final $Res Function(AuthProviderItemDto) _then;

/// Create a copy of AuthProviderItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? linkedAt = null,}) {
  return _then(AuthProviderItemDto(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,linkedAt: null == linkedAt ? _self.linkedAt : linkedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthProviderItemDto].
extension AuthProviderItemDtoPatterns on AuthProviderItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthProviderItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthProviderItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthProviderItemDto value)  $default,){
final _that = this;
switch (_that) {
case _AuthProviderItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthProviderItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _AuthProviderItemDto() when $default != null:
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
case _AuthProviderItemDto() when $default != null:
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
case _AuthProviderItemDto():
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
case _AuthProviderItemDto() when $default != null:
return $default(_that.provider,_that.linkedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthProviderItemDto implements AuthProviderItemDto {
  const _AuthProviderItemDto({required this.provider, @JsonKey(name: 'linked_at') required this.linkedAt});
  factory _AuthProviderItemDto.fromJson(Map<String, dynamic> json) => _$AuthProviderItemDtoFromJson(json);

@override final  String provider;
@override@JsonKey(name: 'linked_at') final  String linkedAt;

/// Create a copy of AuthProviderItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthProviderItemDtoCopyWith<_AuthProviderItemDto> get copyWith => __$AuthProviderItemDtoCopyWithImpl<_AuthProviderItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthProviderItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthProviderItemDto&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.linkedAt, linkedAt) || other.linkedAt == linkedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,provider,linkedAt);
}

@override
String toString() {
    return 'AuthProviderItemDto(provider: $provider, linkedAt: $linkedAt)';
}


}

/// @nodoc
abstract mixin class _$AuthProviderItemDtoCopyWith<$Res> implements $AuthProviderItemDtoCopyWith<$Res> {
  factory _$AuthProviderItemDtoCopyWith(_AuthProviderItemDto value, $Res Function(_AuthProviderItemDto) _then) = __$AuthProviderItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String provider,@JsonKey(name: 'linked_at') String linkedAt
});




}
/// @nodoc
class __$AuthProviderItemDtoCopyWithImpl<$Res>
    implements _$AuthProviderItemDtoCopyWith<$Res> {
  __$AuthProviderItemDtoCopyWithImpl(this._self, this._then);

  final _AuthProviderItemDto _self;
  final $Res Function(_AuthProviderItemDto) _then;

/// Create a copy of AuthProviderItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? linkedAt = null,}) {
  return _then(_AuthProviderItemDto(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,linkedAt: null == linkedAt ? _self.linkedAt : linkedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$GoogleLinkRequestDto {

@JsonKey(name: 'id_token') String get idToken;
/// Create a copy of GoogleLinkRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoogleLinkRequestDtoCopyWith<GoogleLinkRequestDto> get copyWith => _$GoogleLinkRequestDtoCopyWithImpl<GoogleLinkRequestDto>(this as GoogleLinkRequestDto, _$identity);

  /// Serializes this GoogleLinkRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GoogleLinkRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoogleLinkRequestDto&&(identical(other.idToken, _this.idToken) || other.idToken == _this.idToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GoogleLinkRequestDto;
  return Object.hash(runtimeType,_this.idToken);
}

@override
String toString() {
  final _this = this as GoogleLinkRequestDto;
  return 'GoogleLinkRequestDto(idToken: ${_this.idToken})';
}


}

/// @nodoc
abstract mixin class $GoogleLinkRequestDtoCopyWith<$Res>  {
  factory $GoogleLinkRequestDtoCopyWith(GoogleLinkRequestDto value, $Res Function(GoogleLinkRequestDto) _then) = _$GoogleLinkRequestDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id_token') String idToken
});




}
/// @nodoc
class _$GoogleLinkRequestDtoCopyWithImpl<$Res>
    implements $GoogleLinkRequestDtoCopyWith<$Res> {
  _$GoogleLinkRequestDtoCopyWithImpl(this._self, this._then);

  final GoogleLinkRequestDto _self;
  final $Res Function(GoogleLinkRequestDto) _then;

/// Create a copy of GoogleLinkRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idToken = null,}) {
  return _then(GoogleLinkRequestDto(
idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GoogleLinkRequestDto].
extension GoogleLinkRequestDtoPatterns on GoogleLinkRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoogleLinkRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoogleLinkRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoogleLinkRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _GoogleLinkRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoogleLinkRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _GoogleLinkRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_token')  String idToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoogleLinkRequestDto() when $default != null:
return $default(_that.idToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_token')  String idToken)  $default,) {final _that = this;
switch (_that) {
case _GoogleLinkRequestDto():
return $default(_that.idToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id_token')  String idToken)?  $default,) {final _that = this;
switch (_that) {
case _GoogleLinkRequestDto() when $default != null:
return $default(_that.idToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoogleLinkRequestDto implements GoogleLinkRequestDto {
  const _GoogleLinkRequestDto({@JsonKey(name: 'id_token') required this.idToken});
  factory _GoogleLinkRequestDto.fromJson(Map<String, dynamic> json) => _$GoogleLinkRequestDtoFromJson(json);

@override@JsonKey(name: 'id_token') final  String idToken;

/// Create a copy of GoogleLinkRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoogleLinkRequestDtoCopyWith<_GoogleLinkRequestDto> get copyWith => __$GoogleLinkRequestDtoCopyWithImpl<_GoogleLinkRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoogleLinkRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoogleLinkRequestDto&&(identical(other.idToken, idToken) || other.idToken == idToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,idToken);
}

@override
String toString() {
    return 'GoogleLinkRequestDto(idToken: $idToken)';
}


}

/// @nodoc
abstract mixin class _$GoogleLinkRequestDtoCopyWith<$Res> implements $GoogleLinkRequestDtoCopyWith<$Res> {
  factory _$GoogleLinkRequestDtoCopyWith(_GoogleLinkRequestDto value, $Res Function(_GoogleLinkRequestDto) _then) = __$GoogleLinkRequestDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id_token') String idToken
});




}
/// @nodoc
class __$GoogleLinkRequestDtoCopyWithImpl<$Res>
    implements _$GoogleLinkRequestDtoCopyWith<$Res> {
  __$GoogleLinkRequestDtoCopyWithImpl(this._self, this._then);

  final _GoogleLinkRequestDto _self;
  final $Res Function(_GoogleLinkRequestDto) _then;

/// Create a copy of GoogleLinkRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idToken = null,}) {
  return _then(_GoogleLinkRequestDto(
idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$GoogleLinkResponseDto {

 String get provider;@JsonKey(name: 'linked_at') String get linkedAt;
/// Create a copy of GoogleLinkResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoogleLinkResponseDtoCopyWith<GoogleLinkResponseDto> get copyWith => _$GoogleLinkResponseDtoCopyWithImpl<GoogleLinkResponseDto>(this as GoogleLinkResponseDto, _$identity);

  /// Serializes this GoogleLinkResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GoogleLinkResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoogleLinkResponseDto&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.linkedAt, _this.linkedAt) || other.linkedAt == _this.linkedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GoogleLinkResponseDto;
  return Object.hash(runtimeType,_this.provider,_this.linkedAt);
}

@override
String toString() {
  final _this = this as GoogleLinkResponseDto;
  return 'GoogleLinkResponseDto(provider: ${_this.provider}, linkedAt: ${_this.linkedAt})';
}


}

/// @nodoc
abstract mixin class $GoogleLinkResponseDtoCopyWith<$Res>  {
  factory $GoogleLinkResponseDtoCopyWith(GoogleLinkResponseDto value, $Res Function(GoogleLinkResponseDto) _then) = _$GoogleLinkResponseDtoCopyWithImpl;
@useResult
$Res call({
 String provider,@JsonKey(name: 'linked_at') String linkedAt
});




}
/// @nodoc
class _$GoogleLinkResponseDtoCopyWithImpl<$Res>
    implements $GoogleLinkResponseDtoCopyWith<$Res> {
  _$GoogleLinkResponseDtoCopyWithImpl(this._self, this._then);

  final GoogleLinkResponseDto _self;
  final $Res Function(GoogleLinkResponseDto) _then;

/// Create a copy of GoogleLinkResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? linkedAt = null,}) {
  return _then(GoogleLinkResponseDto(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,linkedAt: null == linkedAt ? _self.linkedAt : linkedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GoogleLinkResponseDto].
extension GoogleLinkResponseDtoPatterns on GoogleLinkResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoogleLinkResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoogleLinkResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoogleLinkResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _GoogleLinkResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoogleLinkResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _GoogleLinkResponseDto() when $default != null:
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
case _GoogleLinkResponseDto() when $default != null:
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
case _GoogleLinkResponseDto():
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
case _GoogleLinkResponseDto() when $default != null:
return $default(_that.provider,_that.linkedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoogleLinkResponseDto implements GoogleLinkResponseDto {
  const _GoogleLinkResponseDto({required this.provider, @JsonKey(name: 'linked_at') required this.linkedAt});
  factory _GoogleLinkResponseDto.fromJson(Map<String, dynamic> json) => _$GoogleLinkResponseDtoFromJson(json);

@override final  String provider;
@override@JsonKey(name: 'linked_at') final  String linkedAt;

/// Create a copy of GoogleLinkResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoogleLinkResponseDtoCopyWith<_GoogleLinkResponseDto> get copyWith => __$GoogleLinkResponseDtoCopyWithImpl<_GoogleLinkResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoogleLinkResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoogleLinkResponseDto&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.linkedAt, linkedAt) || other.linkedAt == linkedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,provider,linkedAt);
}

@override
String toString() {
    return 'GoogleLinkResponseDto(provider: $provider, linkedAt: $linkedAt)';
}


}

/// @nodoc
abstract mixin class _$GoogleLinkResponseDtoCopyWith<$Res> implements $GoogleLinkResponseDtoCopyWith<$Res> {
  factory _$GoogleLinkResponseDtoCopyWith(_GoogleLinkResponseDto value, $Res Function(_GoogleLinkResponseDto) _then) = __$GoogleLinkResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String provider,@JsonKey(name: 'linked_at') String linkedAt
});




}
/// @nodoc
class __$GoogleLinkResponseDtoCopyWithImpl<$Res>
    implements _$GoogleLinkResponseDtoCopyWith<$Res> {
  __$GoogleLinkResponseDtoCopyWithImpl(this._self, this._then);

  final _GoogleLinkResponseDto _self;
  final $Res Function(_GoogleLinkResponseDto) _then;

/// Create a copy of GoogleLinkResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? linkedAt = null,}) {
  return _then(_GoogleLinkResponseDto(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,linkedAt: null == linkedAt ? _self.linkedAt : linkedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UnlinkMessageDto {

 String get message;
/// Create a copy of UnlinkMessageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnlinkMessageDtoCopyWith<UnlinkMessageDto> get copyWith => _$UnlinkMessageDtoCopyWithImpl<UnlinkMessageDto>(this as UnlinkMessageDto, _$identity);

  /// Serializes this UnlinkMessageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UnlinkMessageDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnlinkMessageDto&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UnlinkMessageDto;
  return Object.hash(runtimeType,_this.message);
}

@override
String toString() {
  final _this = this as UnlinkMessageDto;
  return 'UnlinkMessageDto(message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $UnlinkMessageDtoCopyWith<$Res>  {
  factory $UnlinkMessageDtoCopyWith(UnlinkMessageDto value, $Res Function(UnlinkMessageDto) _then) = _$UnlinkMessageDtoCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$UnlinkMessageDtoCopyWithImpl<$Res>
    implements $UnlinkMessageDtoCopyWith<$Res> {
  _$UnlinkMessageDtoCopyWithImpl(this._self, this._then);

  final UnlinkMessageDto _self;
  final $Res Function(UnlinkMessageDto) _then;

/// Create a copy of UnlinkMessageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(UnlinkMessageDto(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UnlinkMessageDto].
extension UnlinkMessageDtoPatterns on UnlinkMessageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnlinkMessageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnlinkMessageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnlinkMessageDto value)  $default,){
final _that = this;
switch (_that) {
case _UnlinkMessageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnlinkMessageDto value)?  $default,){
final _that = this;
switch (_that) {
case _UnlinkMessageDto() when $default != null:
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
case _UnlinkMessageDto() when $default != null:
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
case _UnlinkMessageDto():
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
case _UnlinkMessageDto() when $default != null:
return $default(_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnlinkMessageDto implements UnlinkMessageDto {
  const _UnlinkMessageDto({required this.message});
  factory _UnlinkMessageDto.fromJson(Map<String, dynamic> json) => _$UnlinkMessageDtoFromJson(json);

@override final  String message;

/// Create a copy of UnlinkMessageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnlinkMessageDtoCopyWith<_UnlinkMessageDto> get copyWith => __$UnlinkMessageDtoCopyWithImpl<_UnlinkMessageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnlinkMessageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnlinkMessageDto&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'UnlinkMessageDto(message: $message)';
}


}

/// @nodoc
abstract mixin class _$UnlinkMessageDtoCopyWith<$Res> implements $UnlinkMessageDtoCopyWith<$Res> {
  factory _$UnlinkMessageDtoCopyWith(_UnlinkMessageDto value, $Res Function(_UnlinkMessageDto) _then) = __$UnlinkMessageDtoCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$UnlinkMessageDtoCopyWithImpl<$Res>
    implements _$UnlinkMessageDtoCopyWith<$Res> {
  __$UnlinkMessageDtoCopyWithImpl(this._self, this._then);

  final _UnlinkMessageDto _self;
  final $Res Function(_UnlinkMessageDto) _then;

/// Create a copy of UnlinkMessageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_UnlinkMessageDto(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
