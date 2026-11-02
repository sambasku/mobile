// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'google_login_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GoogleLoginRequestDto {

@JsonKey(name: 'id_token') String get idToken;@JsonKey(name: 'client_type') String get clientType;/// Persetujuan legal - wajib untuk akun baru (mode enforce).
@JsonKey(includeIfNull: false) List<LegalConsentDto>? get consents;
/// Create a copy of GoogleLoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoogleLoginRequestDtoCopyWith<GoogleLoginRequestDto> get copyWith => _$GoogleLoginRequestDtoCopyWithImpl<GoogleLoginRequestDto>(this as GoogleLoginRequestDto, _$identity);

  /// Serializes this GoogleLoginRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GoogleLoginRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoogleLoginRequestDto&&(identical(other.idToken, _this.idToken) || other.idToken == _this.idToken)&&(identical(other.clientType, _this.clientType) || other.clientType == _this.clientType)&&const DeepCollectionEquality().equals(other.consents, _this.consents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GoogleLoginRequestDto;
  return Object.hash(runtimeType,_this.idToken,_this.clientType,const DeepCollectionEquality().hash(_this.consents));
}

@override
String toString() {
  final _this = this as GoogleLoginRequestDto;
  return 'GoogleLoginRequestDto(idToken: ${_this.idToken}, clientType: ${_this.clientType}, consents: ${_this.consents})';
}


}

/// @nodoc
abstract mixin class $GoogleLoginRequestDtoCopyWith<$Res>  {
  factory $GoogleLoginRequestDtoCopyWith(GoogleLoginRequestDto value, $Res Function(GoogleLoginRequestDto) _then) = _$GoogleLoginRequestDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id_token') String idToken,@JsonKey(name: 'client_type') String clientType,@JsonKey(includeIfNull: false) List<LegalConsentDto>? consents
});




}
/// @nodoc
class _$GoogleLoginRequestDtoCopyWithImpl<$Res>
    implements $GoogleLoginRequestDtoCopyWith<$Res> {
  _$GoogleLoginRequestDtoCopyWithImpl(this._self, this._then);

  final GoogleLoginRequestDto _self;
  final $Res Function(GoogleLoginRequestDto) _then;

/// Create a copy of GoogleLoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idToken = null,Object? clientType = null,Object? consents = freezed,}) {
  return _then(GoogleLoginRequestDto(
idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,clientType: null == clientType ? _self.clientType : clientType // ignore: cast_nullable_to_non_nullable
as String,consents: freezed == consents ? _self.consents : consents // ignore: cast_nullable_to_non_nullable
as List<LegalConsentDto>?,
  ));
}

}


/// Adds pattern-matching-related methods to [GoogleLoginRequestDto].
extension GoogleLoginRequestDtoPatterns on GoogleLoginRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoogleLoginRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoogleLoginRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoogleLoginRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _GoogleLoginRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoogleLoginRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _GoogleLoginRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_token')  String idToken, @JsonKey(name: 'client_type')  String clientType, @JsonKey(includeIfNull: false)  List<LegalConsentDto>? consents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoogleLoginRequestDto() when $default != null:
return $default(_that.idToken,_that.clientType,_that.consents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_token')  String idToken, @JsonKey(name: 'client_type')  String clientType, @JsonKey(includeIfNull: false)  List<LegalConsentDto>? consents)  $default,) {final _that = this;
switch (_that) {
case _GoogleLoginRequestDto():
return $default(_that.idToken,_that.clientType,_that.consents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id_token')  String idToken, @JsonKey(name: 'client_type')  String clientType, @JsonKey(includeIfNull: false)  List<LegalConsentDto>? consents)?  $default,) {final _that = this;
switch (_that) {
case _GoogleLoginRequestDto() when $default != null:
return $default(_that.idToken,_that.clientType,_that.consents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoogleLoginRequestDto implements GoogleLoginRequestDto {
  const _GoogleLoginRequestDto({@JsonKey(name: 'id_token') required this.idToken, @JsonKey(name: 'client_type') this.clientType = 'mobile', @JsonKey(includeIfNull: false)  List<LegalConsentDto>? consents}): _consents = consents;
  factory _GoogleLoginRequestDto.fromJson(Map<String, dynamic> json) => _$GoogleLoginRequestDtoFromJson(json);

@override@JsonKey(name: 'id_token') final  String idToken;
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


/// Create a copy of GoogleLoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoogleLoginRequestDtoCopyWith<_GoogleLoginRequestDto> get copyWith => __$GoogleLoginRequestDtoCopyWithImpl<_GoogleLoginRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoogleLoginRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoogleLoginRequestDto&&(identical(other.idToken, idToken) || other.idToken == idToken)&&(identical(other.clientType, clientType) || other.clientType == clientType)&&const DeepCollectionEquality().equals(other.consents, _consents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,idToken,clientType,const DeepCollectionEquality().hash(_consents));
}

@override
String toString() {
    return 'GoogleLoginRequestDto(idToken: $idToken, clientType: $clientType, consents: $consents)';
}


}

/// @nodoc
abstract mixin class _$GoogleLoginRequestDtoCopyWith<$Res> implements $GoogleLoginRequestDtoCopyWith<$Res> {
  factory _$GoogleLoginRequestDtoCopyWith(_GoogleLoginRequestDto value, $Res Function(_GoogleLoginRequestDto) _then) = __$GoogleLoginRequestDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id_token') String idToken,@JsonKey(name: 'client_type') String clientType,@JsonKey(includeIfNull: false) List<LegalConsentDto>? consents
});




}
/// @nodoc
class __$GoogleLoginRequestDtoCopyWithImpl<$Res>
    implements _$GoogleLoginRequestDtoCopyWith<$Res> {
  __$GoogleLoginRequestDtoCopyWithImpl(this._self, this._then);

  final _GoogleLoginRequestDto _self;
  final $Res Function(_GoogleLoginRequestDto) _then;

/// Create a copy of GoogleLoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idToken = null,Object? clientType = null,Object? consents = freezed,}) {
  return _then(_GoogleLoginRequestDto(
idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,clientType: null == clientType ? _self.clientType : clientType // ignore: cast_nullable_to_non_nullable
as String,consents: freezed == consents ? _self._consents : consents // ignore: cast_nullable_to_non_nullable
as List<LegalConsentDto>?,
  ));
}


}

// dart format on
