// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verifier_application_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SocialScreenshotDto {

 String get url;@JsonKey(name: 'provider_file_id') String get providerFileId;
/// Create a copy of SocialScreenshotDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialScreenshotDtoCopyWith<SocialScreenshotDto> get copyWith => _$SocialScreenshotDtoCopyWithImpl<SocialScreenshotDto>(this as SocialScreenshotDto, _$identity);

  /// Serializes this SocialScreenshotDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SocialScreenshotDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialScreenshotDto&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.providerFileId, _this.providerFileId) || other.providerFileId == _this.providerFileId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SocialScreenshotDto;
  return Object.hash(runtimeType,_this.url,_this.providerFileId);
}

@override
String toString() {
  final _this = this as SocialScreenshotDto;
  return 'SocialScreenshotDto(url: ${_this.url}, providerFileId: ${_this.providerFileId})';
}


}

/// @nodoc
abstract mixin class $SocialScreenshotDtoCopyWith<$Res>  {
  factory $SocialScreenshotDtoCopyWith(SocialScreenshotDto value, $Res Function(SocialScreenshotDto) _then) = _$SocialScreenshotDtoCopyWithImpl;
@useResult
$Res call({
 String url,@JsonKey(name: 'provider_file_id') String providerFileId
});




}
/// @nodoc
class _$SocialScreenshotDtoCopyWithImpl<$Res>
    implements $SocialScreenshotDtoCopyWith<$Res> {
  _$SocialScreenshotDtoCopyWithImpl(this._self, this._then);

  final SocialScreenshotDto _self;
  final $Res Function(SocialScreenshotDto) _then;

/// Create a copy of SocialScreenshotDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? providerFileId = null,}) {
  return _then(SocialScreenshotDto(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,providerFileId: null == providerFileId ? _self.providerFileId : providerFileId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SocialScreenshotDto].
extension SocialScreenshotDtoPatterns on SocialScreenshotDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialScreenshotDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialScreenshotDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialScreenshotDto value)  $default,){
final _that = this;
switch (_that) {
case _SocialScreenshotDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialScreenshotDto value)?  $default,){
final _that = this;
switch (_that) {
case _SocialScreenshotDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url, @JsonKey(name: 'provider_file_id')  String providerFileId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialScreenshotDto() when $default != null:
return $default(_that.url,_that.providerFileId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url, @JsonKey(name: 'provider_file_id')  String providerFileId)  $default,) {final _that = this;
switch (_that) {
case _SocialScreenshotDto():
return $default(_that.url,_that.providerFileId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url, @JsonKey(name: 'provider_file_id')  String providerFileId)?  $default,) {final _that = this;
switch (_that) {
case _SocialScreenshotDto() when $default != null:
return $default(_that.url,_that.providerFileId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SocialScreenshotDto implements SocialScreenshotDto {
  const _SocialScreenshotDto({required this.url, @JsonKey(name: 'provider_file_id') required this.providerFileId});
  factory _SocialScreenshotDto.fromJson(Map<String, dynamic> json) => _$SocialScreenshotDtoFromJson(json);

@override final  String url;
@override@JsonKey(name: 'provider_file_id') final  String providerFileId;

/// Create a copy of SocialScreenshotDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialScreenshotDtoCopyWith<_SocialScreenshotDto> get copyWith => __$SocialScreenshotDtoCopyWithImpl<_SocialScreenshotDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocialScreenshotDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialScreenshotDto&&(identical(other.url, url) || other.url == url)&&(identical(other.providerFileId, providerFileId) || other.providerFileId == providerFileId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,providerFileId);
}

@override
String toString() {
    return 'SocialScreenshotDto(url: $url, providerFileId: $providerFileId)';
}


}

/// @nodoc
abstract mixin class _$SocialScreenshotDtoCopyWith<$Res> implements $SocialScreenshotDtoCopyWith<$Res> {
  factory _$SocialScreenshotDtoCopyWith(_SocialScreenshotDto value, $Res Function(_SocialScreenshotDto) _then) = __$SocialScreenshotDtoCopyWithImpl;
@override @useResult
$Res call({
 String url,@JsonKey(name: 'provider_file_id') String providerFileId
});




}
/// @nodoc
class __$SocialScreenshotDtoCopyWithImpl<$Res>
    implements _$SocialScreenshotDtoCopyWith<$Res> {
  __$SocialScreenshotDtoCopyWithImpl(this._self, this._then);

  final _SocialScreenshotDto _self;
  final $Res Function(_SocialScreenshotDto) _then;

/// Create a copy of SocialScreenshotDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? providerFileId = null,}) {
  return _then(_SocialScreenshotDto(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,providerFileId: null == providerFileId ? _self.providerFileId : providerFileId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SocialLinkDto {

 String get platform; String get username; SocialScreenshotDto get screenshot;
/// Create a copy of SocialLinkDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialLinkDtoCopyWith<SocialLinkDto> get copyWith => _$SocialLinkDtoCopyWithImpl<SocialLinkDto>(this as SocialLinkDto, _$identity);

  /// Serializes this SocialLinkDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SocialLinkDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialLinkDto&&(identical(other.platform, _this.platform) || other.platform == _this.platform)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.screenshot, _this.screenshot) || other.screenshot == _this.screenshot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SocialLinkDto;
  return Object.hash(runtimeType,_this.platform,_this.username,_this.screenshot);
}

@override
String toString() {
  final _this = this as SocialLinkDto;
  return 'SocialLinkDto(platform: ${_this.platform}, username: ${_this.username}, screenshot: ${_this.screenshot})';
}


}

/// @nodoc
abstract mixin class $SocialLinkDtoCopyWith<$Res>  {
  factory $SocialLinkDtoCopyWith(SocialLinkDto value, $Res Function(SocialLinkDto) _then) = _$SocialLinkDtoCopyWithImpl;
@useResult
$Res call({
 String platform, String username, SocialScreenshotDto screenshot
});


$SocialScreenshotDtoCopyWith<$Res> get screenshot;

}
/// @nodoc
class _$SocialLinkDtoCopyWithImpl<$Res>
    implements $SocialLinkDtoCopyWith<$Res> {
  _$SocialLinkDtoCopyWithImpl(this._self, this._then);

  final SocialLinkDto _self;
  final $Res Function(SocialLinkDto) _then;

/// Create a copy of SocialLinkDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? username = null,Object? screenshot = null,}) {
  return _then(SocialLinkDto(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,screenshot: null == screenshot ? _self.screenshot : screenshot // ignore: cast_nullable_to_non_nullable
as SocialScreenshotDto,
  ));
}
/// Create a copy of SocialLinkDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialScreenshotDtoCopyWith<$Res> get screenshot {
  
  return $SocialScreenshotDtoCopyWith<$Res>(_self.screenshot, (value) {
    return _then(_self.copyWith(screenshot: value));
  });
}
}


/// Adds pattern-matching-related methods to [SocialLinkDto].
extension SocialLinkDtoPatterns on SocialLinkDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialLinkDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialLinkDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialLinkDto value)  $default,){
final _that = this;
switch (_that) {
case _SocialLinkDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialLinkDto value)?  $default,){
final _that = this;
switch (_that) {
case _SocialLinkDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String platform,  String username,  SocialScreenshotDto screenshot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialLinkDto() when $default != null:
return $default(_that.platform,_that.username,_that.screenshot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String platform,  String username,  SocialScreenshotDto screenshot)  $default,) {final _that = this;
switch (_that) {
case _SocialLinkDto():
return $default(_that.platform,_that.username,_that.screenshot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String platform,  String username,  SocialScreenshotDto screenshot)?  $default,) {final _that = this;
switch (_that) {
case _SocialLinkDto() when $default != null:
return $default(_that.platform,_that.username,_that.screenshot);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _SocialLinkDto implements SocialLinkDto {
  const _SocialLinkDto({required this.platform, required this.username, required this.screenshot});
  factory _SocialLinkDto.fromJson(Map<String, dynamic> json) => _$SocialLinkDtoFromJson(json);

@override final  String platform;
@override final  String username;
@override final  SocialScreenshotDto screenshot;

/// Create a copy of SocialLinkDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialLinkDtoCopyWith<_SocialLinkDto> get copyWith => __$SocialLinkDtoCopyWithImpl<_SocialLinkDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocialLinkDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialLinkDto&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.username, username) || other.username == username)&&(identical(other.screenshot, screenshot) || other.screenshot == screenshot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,platform,username,screenshot);
}

@override
String toString() {
    return 'SocialLinkDto(platform: $platform, username: $username, screenshot: $screenshot)';
}


}

/// @nodoc
abstract mixin class _$SocialLinkDtoCopyWith<$Res> implements $SocialLinkDtoCopyWith<$Res> {
  factory _$SocialLinkDtoCopyWith(_SocialLinkDto value, $Res Function(_SocialLinkDto) _then) = __$SocialLinkDtoCopyWithImpl;
@override @useResult
$Res call({
 String platform, String username, SocialScreenshotDto screenshot
});


@override $SocialScreenshotDtoCopyWith<$Res> get screenshot;

}
/// @nodoc
class __$SocialLinkDtoCopyWithImpl<$Res>
    implements _$SocialLinkDtoCopyWith<$Res> {
  __$SocialLinkDtoCopyWithImpl(this._self, this._then);

  final _SocialLinkDto _self;
  final $Res Function(_SocialLinkDto) _then;

/// Create a copy of SocialLinkDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? username = null,Object? screenshot = null,}) {
  return _then(_SocialLinkDto(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,screenshot: null == screenshot ? _self.screenshot : screenshot // ignore: cast_nullable_to_non_nullable
as SocialScreenshotDto,
  ));
}

/// Create a copy of SocialLinkDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialScreenshotDtoCopyWith<$Res> get screenshot {
  
  return $SocialScreenshotDtoCopyWith<$Res>(_self.screenshot, (value) {
    return _then(_self.copyWith(screenshot: value));
  });
}
}


/// @nodoc
mixin _$VerifierApplicationDto {

 String get id; String get status; String get phone; String get address;@JsonKey(name: 'social_links') List<SocialLinkDto> get socialLinks;@JsonKey(name: 'admin_comment') String? get adminComment;@JsonKey(name: 'reviewed_at') String? get reviewedAt;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of VerifierApplicationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifierApplicationDtoCopyWith<VerifierApplicationDto> get copyWith => _$VerifierApplicationDtoCopyWithImpl<VerifierApplicationDto>(this as VerifierApplicationDto, _$identity);

  /// Serializes this VerifierApplicationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VerifierApplicationDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifierApplicationDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.address, _this.address) || other.address == _this.address)&&const DeepCollectionEquality().equals(other.socialLinks, _this.socialLinks)&&(identical(other.adminComment, _this.adminComment) || other.adminComment == _this.adminComment)&&(identical(other.reviewedAt, _this.reviewedAt) || other.reviewedAt == _this.reviewedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VerifierApplicationDto;
  return Object.hash(runtimeType,_this.id,_this.status,_this.phone,_this.address,const DeepCollectionEquality().hash(_this.socialLinks),_this.adminComment,_this.reviewedAt,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as VerifierApplicationDto;
  return 'VerifierApplicationDto(id: ${_this.id}, status: ${_this.status}, phone: ${_this.phone}, address: ${_this.address}, socialLinks: ${_this.socialLinks}, adminComment: ${_this.adminComment}, reviewedAt: ${_this.reviewedAt}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $VerifierApplicationDtoCopyWith<$Res>  {
  factory $VerifierApplicationDtoCopyWith(VerifierApplicationDto value, $Res Function(VerifierApplicationDto) _then) = _$VerifierApplicationDtoCopyWithImpl;
@useResult
$Res call({
 String id, String status, String phone, String address,@JsonKey(name: 'social_links') List<SocialLinkDto> socialLinks,@JsonKey(name: 'admin_comment') String? adminComment,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$VerifierApplicationDtoCopyWithImpl<$Res>
    implements $VerifierApplicationDtoCopyWith<$Res> {
  _$VerifierApplicationDtoCopyWithImpl(this._self, this._then);

  final VerifierApplicationDto _self;
  final $Res Function(VerifierApplicationDto) _then;

/// Create a copy of VerifierApplicationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? phone = null,Object? address = null,Object? socialLinks = null,Object? adminComment = freezed,Object? reviewedAt = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(VerifierApplicationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,socialLinks: null == socialLinks ? _self.socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as List<SocialLinkDto>,adminComment: freezed == adminComment ? _self.adminComment : adminComment // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VerifierApplicationDto].
extension VerifierApplicationDtoPatterns on VerifierApplicationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifierApplicationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifierApplicationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifierApplicationDto value)  $default,){
final _that = this;
switch (_that) {
case _VerifierApplicationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifierApplicationDto value)?  $default,){
final _that = this;
switch (_that) {
case _VerifierApplicationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status,  String phone,  String address, @JsonKey(name: 'social_links')  List<SocialLinkDto> socialLinks, @JsonKey(name: 'admin_comment')  String? adminComment, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifierApplicationDto() when $default != null:
return $default(_that.id,_that.status,_that.phone,_that.address,_that.socialLinks,_that.adminComment,_that.reviewedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status,  String phone,  String address, @JsonKey(name: 'social_links')  List<SocialLinkDto> socialLinks, @JsonKey(name: 'admin_comment')  String? adminComment, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _VerifierApplicationDto():
return $default(_that.id,_that.status,_that.phone,_that.address,_that.socialLinks,_that.adminComment,_that.reviewedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status,  String phone,  String address, @JsonKey(name: 'social_links')  List<SocialLinkDto> socialLinks, @JsonKey(name: 'admin_comment')  String? adminComment, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _VerifierApplicationDto() when $default != null:
return $default(_that.id,_that.status,_that.phone,_that.address,_that.socialLinks,_that.adminComment,_that.reviewedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _VerifierApplicationDto implements VerifierApplicationDto {
  const _VerifierApplicationDto({required this.id, required this.status, required this.phone, required this.address, @JsonKey(name: 'social_links') required  List<SocialLinkDto> socialLinks, @JsonKey(name: 'admin_comment') this.adminComment, @JsonKey(name: 'reviewed_at') this.reviewedAt, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _socialLinks = socialLinks;
  factory _VerifierApplicationDto.fromJson(Map<String, dynamic> json) => _$VerifierApplicationDtoFromJson(json);

@override final  String id;
@override final  String status;
@override final  String phone;
@override final  String address;
 final  List<SocialLinkDto> _socialLinks;
@override@JsonKey(name: 'social_links') List<SocialLinkDto> get socialLinks {
  if (_socialLinks is EqualUnmodifiableListView) return _socialLinks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_socialLinks);
}

@override@JsonKey(name: 'admin_comment') final  String? adminComment;
@override@JsonKey(name: 'reviewed_at') final  String? reviewedAt;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of VerifierApplicationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifierApplicationDtoCopyWith<_VerifierApplicationDto> get copyWith => __$VerifierApplicationDtoCopyWithImpl<_VerifierApplicationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerifierApplicationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifierApplicationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&const DeepCollectionEquality().equals(other.socialLinks, _socialLinks)&&(identical(other.adminComment, adminComment) || other.adminComment == adminComment)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,status,phone,address,const DeepCollectionEquality().hash(_socialLinks),adminComment,reviewedAt,createdAt,updatedAt);
}

@override
String toString() {
    return 'VerifierApplicationDto(id: $id, status: $status, phone: $phone, address: $address, socialLinks: $socialLinks, adminComment: $adminComment, reviewedAt: $reviewedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$VerifierApplicationDtoCopyWith<$Res> implements $VerifierApplicationDtoCopyWith<$Res> {
  factory _$VerifierApplicationDtoCopyWith(_VerifierApplicationDto value, $Res Function(_VerifierApplicationDto) _then) = __$VerifierApplicationDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String status, String phone, String address,@JsonKey(name: 'social_links') List<SocialLinkDto> socialLinks,@JsonKey(name: 'admin_comment') String? adminComment,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$VerifierApplicationDtoCopyWithImpl<$Res>
    implements _$VerifierApplicationDtoCopyWith<$Res> {
  __$VerifierApplicationDtoCopyWithImpl(this._self, this._then);

  final _VerifierApplicationDto _self;
  final $Res Function(_VerifierApplicationDto) _then;

/// Create a copy of VerifierApplicationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? phone = null,Object? address = null,Object? socialLinks = null,Object? adminComment = freezed,Object? reviewedAt = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_VerifierApplicationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,socialLinks: null == socialLinks ? _self._socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as List<SocialLinkDto>,adminComment: freezed == adminComment ? _self.adminComment : adminComment // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SubmitVerifierApplicationRequestDto {

 String get phone; String get address;@JsonKey(name: 'social_links') List<SocialLinkDto> get socialLinks;
/// Create a copy of SubmitVerifierApplicationRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubmitVerifierApplicationRequestDtoCopyWith<SubmitVerifierApplicationRequestDto> get copyWith => _$SubmitVerifierApplicationRequestDtoCopyWithImpl<SubmitVerifierApplicationRequestDto>(this as SubmitVerifierApplicationRequestDto, _$identity);

  /// Serializes this SubmitVerifierApplicationRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubmitVerifierApplicationRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubmitVerifierApplicationRequestDto&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.address, _this.address) || other.address == _this.address)&&const DeepCollectionEquality().equals(other.socialLinks, _this.socialLinks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubmitVerifierApplicationRequestDto;
  return Object.hash(runtimeType,_this.phone,_this.address,const DeepCollectionEquality().hash(_this.socialLinks));
}

@override
String toString() {
  final _this = this as SubmitVerifierApplicationRequestDto;
  return 'SubmitVerifierApplicationRequestDto(phone: ${_this.phone}, address: ${_this.address}, socialLinks: ${_this.socialLinks})';
}


}

/// @nodoc
abstract mixin class $SubmitVerifierApplicationRequestDtoCopyWith<$Res>  {
  factory $SubmitVerifierApplicationRequestDtoCopyWith(SubmitVerifierApplicationRequestDto value, $Res Function(SubmitVerifierApplicationRequestDto) _then) = _$SubmitVerifierApplicationRequestDtoCopyWithImpl;
@useResult
$Res call({
 String phone, String address,@JsonKey(name: 'social_links') List<SocialLinkDto> socialLinks
});




}
/// @nodoc
class _$SubmitVerifierApplicationRequestDtoCopyWithImpl<$Res>
    implements $SubmitVerifierApplicationRequestDtoCopyWith<$Res> {
  _$SubmitVerifierApplicationRequestDtoCopyWithImpl(this._self, this._then);

  final SubmitVerifierApplicationRequestDto _self;
  final $Res Function(SubmitVerifierApplicationRequestDto) _then;

/// Create a copy of SubmitVerifierApplicationRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phone = null,Object? address = null,Object? socialLinks = null,}) {
  return _then(SubmitVerifierApplicationRequestDto(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,socialLinks: null == socialLinks ? _self.socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as List<SocialLinkDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [SubmitVerifierApplicationRequestDto].
extension SubmitVerifierApplicationRequestDtoPatterns on SubmitVerifierApplicationRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubmitVerifierApplicationRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubmitVerifierApplicationRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubmitVerifierApplicationRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _SubmitVerifierApplicationRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubmitVerifierApplicationRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _SubmitVerifierApplicationRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String phone,  String address, @JsonKey(name: 'social_links')  List<SocialLinkDto> socialLinks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubmitVerifierApplicationRequestDto() when $default != null:
return $default(_that.phone,_that.address,_that.socialLinks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String phone,  String address, @JsonKey(name: 'social_links')  List<SocialLinkDto> socialLinks)  $default,) {final _that = this;
switch (_that) {
case _SubmitVerifierApplicationRequestDto():
return $default(_that.phone,_that.address,_that.socialLinks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String phone,  String address, @JsonKey(name: 'social_links')  List<SocialLinkDto> socialLinks)?  $default,) {final _that = this;
switch (_that) {
case _SubmitVerifierApplicationRequestDto() when $default != null:
return $default(_that.phone,_that.address,_that.socialLinks);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _SubmitVerifierApplicationRequestDto implements SubmitVerifierApplicationRequestDto {
  const _SubmitVerifierApplicationRequestDto({required this.phone, required this.address, @JsonKey(name: 'social_links') required  List<SocialLinkDto> socialLinks}): _socialLinks = socialLinks;
  factory _SubmitVerifierApplicationRequestDto.fromJson(Map<String, dynamic> json) => _$SubmitVerifierApplicationRequestDtoFromJson(json);

@override final  String phone;
@override final  String address;
 final  List<SocialLinkDto> _socialLinks;
@override@JsonKey(name: 'social_links') List<SocialLinkDto> get socialLinks {
  if (_socialLinks is EqualUnmodifiableListView) return _socialLinks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_socialLinks);
}


/// Create a copy of SubmitVerifierApplicationRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubmitVerifierApplicationRequestDtoCopyWith<_SubmitVerifierApplicationRequestDto> get copyWith => __$SubmitVerifierApplicationRequestDtoCopyWithImpl<_SubmitVerifierApplicationRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubmitVerifierApplicationRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmitVerifierApplicationRequestDto&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&const DeepCollectionEquality().equals(other.socialLinks, _socialLinks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,phone,address,const DeepCollectionEquality().hash(_socialLinks));
}

@override
String toString() {
    return 'SubmitVerifierApplicationRequestDto(phone: $phone, address: $address, socialLinks: $socialLinks)';
}


}

/// @nodoc
abstract mixin class _$SubmitVerifierApplicationRequestDtoCopyWith<$Res> implements $SubmitVerifierApplicationRequestDtoCopyWith<$Res> {
  factory _$SubmitVerifierApplicationRequestDtoCopyWith(_SubmitVerifierApplicationRequestDto value, $Res Function(_SubmitVerifierApplicationRequestDto) _then) = __$SubmitVerifierApplicationRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String phone, String address,@JsonKey(name: 'social_links') List<SocialLinkDto> socialLinks
});




}
/// @nodoc
class __$SubmitVerifierApplicationRequestDtoCopyWithImpl<$Res>
    implements _$SubmitVerifierApplicationRequestDtoCopyWith<$Res> {
  __$SubmitVerifierApplicationRequestDtoCopyWithImpl(this._self, this._then);

  final _SubmitVerifierApplicationRequestDto _self;
  final $Res Function(_SubmitVerifierApplicationRequestDto) _then;

/// Create a copy of SubmitVerifierApplicationRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phone = null,Object? address = null,Object? socialLinks = null,}) {
  return _then(_SubmitVerifierApplicationRequestDto(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,socialLinks: null == socialLinks ? _self._socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as List<SocialLinkDto>,
  ));
}


}

// dart format on
