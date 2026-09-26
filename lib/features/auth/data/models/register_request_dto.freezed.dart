// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LegalConsentDto {

@JsonKey(name: 'document_type') String get documentType;@JsonKey(name: 'document_version') String get documentVersion;
/// Create a copy of LegalConsentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LegalConsentDtoCopyWith<LegalConsentDto> get copyWith => _$LegalConsentDtoCopyWithImpl<LegalConsentDto>(this as LegalConsentDto, _$identity);

  /// Serializes this LegalConsentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LegalConsentDto&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.documentVersion, documentVersion) || other.documentVersion == documentVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentType,documentVersion);

@override
String toString() {
  return 'LegalConsentDto(documentType: $documentType, documentVersion: $documentVersion)';
}


}

/// @nodoc
abstract mixin class $LegalConsentDtoCopyWith<$Res>  {
  factory $LegalConsentDtoCopyWith(LegalConsentDto value, $Res Function(LegalConsentDto) _then) = _$LegalConsentDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'document_type') String documentType,@JsonKey(name: 'document_version') String documentVersion
});




}
/// @nodoc
class _$LegalConsentDtoCopyWithImpl<$Res>
    implements $LegalConsentDtoCopyWith<$Res> {
  _$LegalConsentDtoCopyWithImpl(this._self, this._then);

  final LegalConsentDto _self;
  final $Res Function(LegalConsentDto) _then;

/// Create a copy of LegalConsentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentType = null,Object? documentVersion = null,}) {
  return _then(_self.copyWith(
documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,documentVersion: null == documentVersion ? _self.documentVersion : documentVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LegalConsentDto].
extension LegalConsentDtoPatterns on LegalConsentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LegalConsentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LegalConsentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LegalConsentDto value)  $default,){
final _that = this;
switch (_that) {
case _LegalConsentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LegalConsentDto value)?  $default,){
final _that = this;
switch (_that) {
case _LegalConsentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'document_type')  String documentType, @JsonKey(name: 'document_version')  String documentVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LegalConsentDto() when $default != null:
return $default(_that.documentType,_that.documentVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'document_type')  String documentType, @JsonKey(name: 'document_version')  String documentVersion)  $default,) {final _that = this;
switch (_that) {
case _LegalConsentDto():
return $default(_that.documentType,_that.documentVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'document_type')  String documentType, @JsonKey(name: 'document_version')  String documentVersion)?  $default,) {final _that = this;
switch (_that) {
case _LegalConsentDto() when $default != null:
return $default(_that.documentType,_that.documentVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LegalConsentDto implements LegalConsentDto {
  const _LegalConsentDto({@JsonKey(name: 'document_type') required this.documentType, @JsonKey(name: 'document_version') required this.documentVersion});
  factory _LegalConsentDto.fromJson(Map<String, dynamic> json) => _$LegalConsentDtoFromJson(json);

@override@JsonKey(name: 'document_type') final  String documentType;
@override@JsonKey(name: 'document_version') final  String documentVersion;

/// Create a copy of LegalConsentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LegalConsentDtoCopyWith<_LegalConsentDto> get copyWith => __$LegalConsentDtoCopyWithImpl<_LegalConsentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LegalConsentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LegalConsentDto&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.documentVersion, documentVersion) || other.documentVersion == documentVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentType,documentVersion);

@override
String toString() {
  return 'LegalConsentDto(documentType: $documentType, documentVersion: $documentVersion)';
}


}

/// @nodoc
abstract mixin class _$LegalConsentDtoCopyWith<$Res> implements $LegalConsentDtoCopyWith<$Res> {
  factory _$LegalConsentDtoCopyWith(_LegalConsentDto value, $Res Function(_LegalConsentDto) _then) = __$LegalConsentDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'document_type') String documentType,@JsonKey(name: 'document_version') String documentVersion
});




}
/// @nodoc
class __$LegalConsentDtoCopyWithImpl<$Res>
    implements _$LegalConsentDtoCopyWith<$Res> {
  __$LegalConsentDtoCopyWithImpl(this._self, this._then);

  final _LegalConsentDto _self;
  final $Res Function(_LegalConsentDto) _then;

/// Create a copy of LegalConsentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentType = null,Object? documentVersion = null,}) {
  return _then(_LegalConsentDto(
documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,documentVersion: null == documentVersion ? _self.documentVersion : documentVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RegisterRequestDto {

 String get name; String get email;@JsonKey(includeIfNull: false) String? get phone; String get password;@JsonKey(name: 'confirm_password') String get confirmPassword;@JsonKey(name: 'client_id') String get clientId; List<LegalConsentDto> get consents;
/// Create a copy of RegisterRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterRequestDtoCopyWith<RegisterRequestDto> get copyWith => _$RegisterRequestDtoCopyWithImpl<RegisterRequestDto>(this as RegisterRequestDto, _$identity);

  /// Serializes this RegisterRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterRequestDto&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.password, password) || other.password == password)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&const DeepCollectionEquality().equals(other.consents, consents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,phone,password,confirmPassword,clientId,const DeepCollectionEquality().hash(consents));

@override
String toString() {
  return 'RegisterRequestDto(name: $name, email: $email, phone: $phone, password: $password, confirmPassword: $confirmPassword, clientId: $clientId, consents: $consents)';
}


}

/// @nodoc
abstract mixin class $RegisterRequestDtoCopyWith<$Res>  {
  factory $RegisterRequestDtoCopyWith(RegisterRequestDto value, $Res Function(RegisterRequestDto) _then) = _$RegisterRequestDtoCopyWithImpl;
@useResult
$Res call({
 String name, String email,@JsonKey(includeIfNull: false) String? phone, String password,@JsonKey(name: 'confirm_password') String confirmPassword,@JsonKey(name: 'client_id') String clientId, List<LegalConsentDto> consents
});




}
/// @nodoc
class _$RegisterRequestDtoCopyWithImpl<$Res>
    implements $RegisterRequestDtoCopyWith<$Res> {
  _$RegisterRequestDtoCopyWithImpl(this._self, this._then);

  final RegisterRequestDto _self;
  final $Res Function(RegisterRequestDto) _then;

/// Create a copy of RegisterRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? email = null,Object? phone = freezed,Object? password = null,Object? confirmPassword = null,Object? clientId = null,Object? consents = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,consents: null == consents ? _self.consents : consents // ignore: cast_nullable_to_non_nullable
as List<LegalConsentDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterRequestDto].
extension RegisterRequestDtoPatterns on RegisterRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _RegisterRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String email, @JsonKey(includeIfNull: false)  String? phone,  String password, @JsonKey(name: 'confirm_password')  String confirmPassword, @JsonKey(name: 'client_id')  String clientId,  List<LegalConsentDto> consents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterRequestDto() when $default != null:
return $default(_that.name,_that.email,_that.phone,_that.password,_that.confirmPassword,_that.clientId,_that.consents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String email, @JsonKey(includeIfNull: false)  String? phone,  String password, @JsonKey(name: 'confirm_password')  String confirmPassword, @JsonKey(name: 'client_id')  String clientId,  List<LegalConsentDto> consents)  $default,) {final _that = this;
switch (_that) {
case _RegisterRequestDto():
return $default(_that.name,_that.email,_that.phone,_that.password,_that.confirmPassword,_that.clientId,_that.consents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String email, @JsonKey(includeIfNull: false)  String? phone,  String password, @JsonKey(name: 'confirm_password')  String confirmPassword, @JsonKey(name: 'client_id')  String clientId,  List<LegalConsentDto> consents)?  $default,) {final _that = this;
switch (_that) {
case _RegisterRequestDto() when $default != null:
return $default(_that.name,_that.email,_that.phone,_that.password,_that.confirmPassword,_that.clientId,_that.consents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterRequestDto implements RegisterRequestDto {
  const _RegisterRequestDto({required this.name, required this.email, @JsonKey(includeIfNull: false) this.phone, required this.password, @JsonKey(name: 'confirm_password') required this.confirmPassword, @JsonKey(name: 'client_id') this.clientId = 'sambasku-mobile', required final  List<LegalConsentDto> consents}): _consents = consents;
  factory _RegisterRequestDto.fromJson(Map<String, dynamic> json) => _$RegisterRequestDtoFromJson(json);

@override final  String name;
@override final  String email;
@override@JsonKey(includeIfNull: false) final  String? phone;
@override final  String password;
@override@JsonKey(name: 'confirm_password') final  String confirmPassword;
@override@JsonKey(name: 'client_id') final  String clientId;
 final  List<LegalConsentDto> _consents;
@override List<LegalConsentDto> get consents {
  if (_consents is EqualUnmodifiableListView) return _consents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_consents);
}


/// Create a copy of RegisterRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterRequestDtoCopyWith<_RegisterRequestDto> get copyWith => __$RegisterRequestDtoCopyWithImpl<_RegisterRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterRequestDto&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.password, password) || other.password == password)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&const DeepCollectionEquality().equals(other._consents, _consents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,phone,password,confirmPassword,clientId,const DeepCollectionEquality().hash(_consents));

@override
String toString() {
  return 'RegisterRequestDto(name: $name, email: $email, phone: $phone, password: $password, confirmPassword: $confirmPassword, clientId: $clientId, consents: $consents)';
}


}

/// @nodoc
abstract mixin class _$RegisterRequestDtoCopyWith<$Res> implements $RegisterRequestDtoCopyWith<$Res> {
  factory _$RegisterRequestDtoCopyWith(_RegisterRequestDto value, $Res Function(_RegisterRequestDto) _then) = __$RegisterRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String email,@JsonKey(includeIfNull: false) String? phone, String password,@JsonKey(name: 'confirm_password') String confirmPassword,@JsonKey(name: 'client_id') String clientId, List<LegalConsentDto> consents
});




}
/// @nodoc
class __$RegisterRequestDtoCopyWithImpl<$Res>
    implements _$RegisterRequestDtoCopyWith<$Res> {
  __$RegisterRequestDtoCopyWithImpl(this._self, this._then);

  final _RegisterRequestDto _self;
  final $Res Function(_RegisterRequestDto) _then;

/// Create a copy of RegisterRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? email = null,Object? phone = freezed,Object? password = null,Object? confirmPassword = null,Object? clientId = null,Object? consents = null,}) {
  return _then(_RegisterRequestDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,consents: null == consents ? _self._consents : consents // ignore: cast_nullable_to_non_nullable
as List<LegalConsentDto>,
  ));
}


}


/// @nodoc
mixin _$RegisterResponseDto {

@JsonKey(name: 'user_id') String get userId; String get username; String get email; String? get phone;@JsonKey(name: 'verification_required') bool get verificationRequired;
/// Create a copy of RegisterResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterResponseDtoCopyWith<RegisterResponseDto> get copyWith => _$RegisterResponseDtoCopyWithImpl<RegisterResponseDto>(this as RegisterResponseDto, _$identity);

  /// Serializes this RegisterResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterResponseDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.verificationRequired, verificationRequired) || other.verificationRequired == verificationRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,email,phone,verificationRequired);

@override
String toString() {
  return 'RegisterResponseDto(userId: $userId, username: $username, email: $email, phone: $phone, verificationRequired: $verificationRequired)';
}


}

/// @nodoc
abstract mixin class $RegisterResponseDtoCopyWith<$Res>  {
  factory $RegisterResponseDtoCopyWith(RegisterResponseDto value, $Res Function(RegisterResponseDto) _then) = _$RegisterResponseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String username, String email, String? phone,@JsonKey(name: 'verification_required') bool verificationRequired
});




}
/// @nodoc
class _$RegisterResponseDtoCopyWithImpl<$Res>
    implements $RegisterResponseDtoCopyWith<$Res> {
  _$RegisterResponseDtoCopyWithImpl(this._self, this._then);

  final RegisterResponseDto _self;
  final $Res Function(RegisterResponseDto) _then;

/// Create a copy of RegisterResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? email = null,Object? phone = freezed,Object? verificationRequired = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,verificationRequired: null == verificationRequired ? _self.verificationRequired : verificationRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterResponseDto].
extension RegisterResponseDtoPatterns on RegisterResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _RegisterResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String username,  String email,  String? phone, @JsonKey(name: 'verification_required')  bool verificationRequired)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterResponseDto() when $default != null:
return $default(_that.userId,_that.username,_that.email,_that.phone,_that.verificationRequired);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String username,  String email,  String? phone, @JsonKey(name: 'verification_required')  bool verificationRequired)  $default,) {final _that = this;
switch (_that) {
case _RegisterResponseDto():
return $default(_that.userId,_that.username,_that.email,_that.phone,_that.verificationRequired);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId,  String username,  String email,  String? phone, @JsonKey(name: 'verification_required')  bool verificationRequired)?  $default,) {final _that = this;
switch (_that) {
case _RegisterResponseDto() when $default != null:
return $default(_that.userId,_that.username,_that.email,_that.phone,_that.verificationRequired);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterResponseDto implements RegisterResponseDto {
  const _RegisterResponseDto({@JsonKey(name: 'user_id') required this.userId, required this.username, required this.email, this.phone, @JsonKey(name: 'verification_required') this.verificationRequired = true});
  factory _RegisterResponseDto.fromJson(Map<String, dynamic> json) => _$RegisterResponseDtoFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override final  String username;
@override final  String email;
@override final  String? phone;
@override@JsonKey(name: 'verification_required') final  bool verificationRequired;

/// Create a copy of RegisterResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterResponseDtoCopyWith<_RegisterResponseDto> get copyWith => __$RegisterResponseDtoCopyWithImpl<_RegisterResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterResponseDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.verificationRequired, verificationRequired) || other.verificationRequired == verificationRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,email,phone,verificationRequired);

@override
String toString() {
  return 'RegisterResponseDto(userId: $userId, username: $username, email: $email, phone: $phone, verificationRequired: $verificationRequired)';
}


}

/// @nodoc
abstract mixin class _$RegisterResponseDtoCopyWith<$Res> implements $RegisterResponseDtoCopyWith<$Res> {
  factory _$RegisterResponseDtoCopyWith(_RegisterResponseDto value, $Res Function(_RegisterResponseDto) _then) = __$RegisterResponseDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String username, String email, String? phone,@JsonKey(name: 'verification_required') bool verificationRequired
});




}
/// @nodoc
class __$RegisterResponseDtoCopyWithImpl<$Res>
    implements _$RegisterResponseDtoCopyWith<$Res> {
  __$RegisterResponseDtoCopyWithImpl(this._self, this._then);

  final _RegisterResponseDto _self;
  final $Res Function(_RegisterResponseDto) _then;

/// Create a copy of RegisterResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? email = null,Object? phone = freezed,Object? verificationRequired = null,}) {
  return _then(_RegisterResponseDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,verificationRequired: null == verificationRequired ? _self.verificationRequired : verificationRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
