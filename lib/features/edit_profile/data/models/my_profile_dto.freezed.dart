// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_profile_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyProfileDto {

 String get username;@JsonKey(name: 'display_name') String get displayName; String? get bio;@JsonKey(name: 'region_id') String? get regionId;@JsonKey(name: 'village_id') String? get villageId;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'has_read_contribution_guide') bool get hasReadContributionGuide;
/// Create a copy of MyProfileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyProfileDtoCopyWith<MyProfileDto> get copyWith => _$MyProfileDtoCopyWithImpl<MyProfileDto>(this as MyProfileDto, _$identity);

  /// Serializes this MyProfileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyProfileDto&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.villageId, villageId) || other.villageId == villageId)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.hasReadContributionGuide, hasReadContributionGuide) || other.hasReadContributionGuide == hasReadContributionGuide));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,displayName,bio,regionId,villageId,avatarUrl,hasReadContributionGuide);

@override
String toString() {
  return 'MyProfileDto(username: $username, displayName: $displayName, bio: $bio, regionId: $regionId, villageId: $villageId, avatarUrl: $avatarUrl, hasReadContributionGuide: $hasReadContributionGuide)';
}


}

/// @nodoc
abstract mixin class $MyProfileDtoCopyWith<$Res>  {
  factory $MyProfileDtoCopyWith(MyProfileDto value, $Res Function(MyProfileDto) _then) = _$MyProfileDtoCopyWithImpl;
@useResult
$Res call({
 String username,@JsonKey(name: 'display_name') String displayName, String? bio,@JsonKey(name: 'region_id') String? regionId,@JsonKey(name: 'village_id') String? villageId,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'has_read_contribution_guide') bool hasReadContributionGuide
});




}
/// @nodoc
class _$MyProfileDtoCopyWithImpl<$Res>
    implements $MyProfileDtoCopyWith<$Res> {
  _$MyProfileDtoCopyWithImpl(this._self, this._then);

  final MyProfileDto _self;
  final $Res Function(MyProfileDto) _then;

/// Create a copy of MyProfileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? displayName = null,Object? bio = freezed,Object? regionId = freezed,Object? villageId = freezed,Object? avatarUrl = freezed,Object? hasReadContributionGuide = null,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String?,villageId: freezed == villageId ? _self.villageId : villageId // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,hasReadContributionGuide: null == hasReadContributionGuide ? _self.hasReadContributionGuide : hasReadContributionGuide // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MyProfileDto].
extension MyProfileDtoPatterns on MyProfileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyProfileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyProfileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyProfileDto value)  $default,){
final _that = this;
switch (_that) {
case _MyProfileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyProfileDto value)?  $default,){
final _that = this;
switch (_that) {
case _MyProfileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username, @JsonKey(name: 'display_name')  String displayName,  String? bio, @JsonKey(name: 'region_id')  String? regionId, @JsonKey(name: 'village_id')  String? villageId, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'has_read_contribution_guide')  bool hasReadContributionGuide)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyProfileDto() when $default != null:
return $default(_that.username,_that.displayName,_that.bio,_that.regionId,_that.villageId,_that.avatarUrl,_that.hasReadContributionGuide);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username, @JsonKey(name: 'display_name')  String displayName,  String? bio, @JsonKey(name: 'region_id')  String? regionId, @JsonKey(name: 'village_id')  String? villageId, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'has_read_contribution_guide')  bool hasReadContributionGuide)  $default,) {final _that = this;
switch (_that) {
case _MyProfileDto():
return $default(_that.username,_that.displayName,_that.bio,_that.regionId,_that.villageId,_that.avatarUrl,_that.hasReadContributionGuide);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username, @JsonKey(name: 'display_name')  String displayName,  String? bio, @JsonKey(name: 'region_id')  String? regionId, @JsonKey(name: 'village_id')  String? villageId, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'has_read_contribution_guide')  bool hasReadContributionGuide)?  $default,) {final _that = this;
switch (_that) {
case _MyProfileDto() when $default != null:
return $default(_that.username,_that.displayName,_that.bio,_that.regionId,_that.villageId,_that.avatarUrl,_that.hasReadContributionGuide);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MyProfileDto implements MyProfileDto {
  const _MyProfileDto({required this.username, @JsonKey(name: 'display_name') required this.displayName, this.bio, @JsonKey(name: 'region_id') this.regionId, @JsonKey(name: 'village_id') this.villageId, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'has_read_contribution_guide') this.hasReadContributionGuide = false});
  factory _MyProfileDto.fromJson(Map<String, dynamic> json) => _$MyProfileDtoFromJson(json);

@override final  String username;
@override@JsonKey(name: 'display_name') final  String displayName;
@override final  String? bio;
@override@JsonKey(name: 'region_id') final  String? regionId;
@override@JsonKey(name: 'village_id') final  String? villageId;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'has_read_contribution_guide') final  bool hasReadContributionGuide;

/// Create a copy of MyProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyProfileDtoCopyWith<_MyProfileDto> get copyWith => __$MyProfileDtoCopyWithImpl<_MyProfileDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyProfileDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyProfileDto&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.villageId, villageId) || other.villageId == villageId)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.hasReadContributionGuide, hasReadContributionGuide) || other.hasReadContributionGuide == hasReadContributionGuide));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,displayName,bio,regionId,villageId,avatarUrl,hasReadContributionGuide);

@override
String toString() {
  return 'MyProfileDto(username: $username, displayName: $displayName, bio: $bio, regionId: $regionId, villageId: $villageId, avatarUrl: $avatarUrl, hasReadContributionGuide: $hasReadContributionGuide)';
}


}

/// @nodoc
abstract mixin class _$MyProfileDtoCopyWith<$Res> implements $MyProfileDtoCopyWith<$Res> {
  factory _$MyProfileDtoCopyWith(_MyProfileDto value, $Res Function(_MyProfileDto) _then) = __$MyProfileDtoCopyWithImpl;
@override @useResult
$Res call({
 String username,@JsonKey(name: 'display_name') String displayName, String? bio,@JsonKey(name: 'region_id') String? regionId,@JsonKey(name: 'village_id') String? villageId,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'has_read_contribution_guide') bool hasReadContributionGuide
});




}
/// @nodoc
class __$MyProfileDtoCopyWithImpl<$Res>
    implements _$MyProfileDtoCopyWith<$Res> {
  __$MyProfileDtoCopyWithImpl(this._self, this._then);

  final _MyProfileDto _self;
  final $Res Function(_MyProfileDto) _then;

/// Create a copy of MyProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? displayName = null,Object? bio = freezed,Object? regionId = freezed,Object? villageId = freezed,Object? avatarUrl = freezed,Object? hasReadContributionGuide = null,}) {
  return _then(_MyProfileDto(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String?,villageId: freezed == villageId ? _self.villageId : villageId // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,hasReadContributionGuide: null == hasReadContributionGuide ? _self.hasReadContributionGuide : hasReadContributionGuide // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$UpdateMyProfileRequestDto {

@JsonKey(includeIfNull: false) String? get username;@JsonKey(name: 'display_name') String? get displayName; String? get bio;@JsonKey(name: 'region_id') String? get regionId;@JsonKey(name: 'village_id') String? get villageId;@JsonKey(name: 'has_read_contribution_guide', includeIfNull: false) bool? get hasReadContributionGuide;
/// Create a copy of UpdateMyProfileRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateMyProfileRequestDtoCopyWith<UpdateMyProfileRequestDto> get copyWith => _$UpdateMyProfileRequestDtoCopyWithImpl<UpdateMyProfileRequestDto>(this as UpdateMyProfileRequestDto, _$identity);

  /// Serializes this UpdateMyProfileRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateMyProfileRequestDto&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.villageId, villageId) || other.villageId == villageId)&&(identical(other.hasReadContributionGuide, hasReadContributionGuide) || other.hasReadContributionGuide == hasReadContributionGuide));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,displayName,bio,regionId,villageId,hasReadContributionGuide);

@override
String toString() {
  return 'UpdateMyProfileRequestDto(username: $username, displayName: $displayName, bio: $bio, regionId: $regionId, villageId: $villageId, hasReadContributionGuide: $hasReadContributionGuide)';
}


}

/// @nodoc
abstract mixin class $UpdateMyProfileRequestDtoCopyWith<$Res>  {
  factory $UpdateMyProfileRequestDtoCopyWith(UpdateMyProfileRequestDto value, $Res Function(UpdateMyProfileRequestDto) _then) = _$UpdateMyProfileRequestDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? username,@JsonKey(name: 'display_name') String? displayName, String? bio,@JsonKey(name: 'region_id') String? regionId,@JsonKey(name: 'village_id') String? villageId,@JsonKey(name: 'has_read_contribution_guide', includeIfNull: false) bool? hasReadContributionGuide
});




}
/// @nodoc
class _$UpdateMyProfileRequestDtoCopyWithImpl<$Res>
    implements $UpdateMyProfileRequestDtoCopyWith<$Res> {
  _$UpdateMyProfileRequestDtoCopyWithImpl(this._self, this._then);

  final UpdateMyProfileRequestDto _self;
  final $Res Function(UpdateMyProfileRequestDto) _then;

/// Create a copy of UpdateMyProfileRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = freezed,Object? displayName = freezed,Object? bio = freezed,Object? regionId = freezed,Object? villageId = freezed,Object? hasReadContributionGuide = freezed,}) {
  return _then(_self.copyWith(
username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String?,villageId: freezed == villageId ? _self.villageId : villageId // ignore: cast_nullable_to_non_nullable
as String?,hasReadContributionGuide: freezed == hasReadContributionGuide ? _self.hasReadContributionGuide : hasReadContributionGuide // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateMyProfileRequestDto].
extension UpdateMyProfileRequestDtoPatterns on UpdateMyProfileRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateMyProfileRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateMyProfileRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateMyProfileRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdateMyProfileRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateMyProfileRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateMyProfileRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? username, @JsonKey(name: 'display_name')  String? displayName,  String? bio, @JsonKey(name: 'region_id')  String? regionId, @JsonKey(name: 'village_id')  String? villageId, @JsonKey(name: 'has_read_contribution_guide', includeIfNull: false)  bool? hasReadContributionGuide)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateMyProfileRequestDto() when $default != null:
return $default(_that.username,_that.displayName,_that.bio,_that.regionId,_that.villageId,_that.hasReadContributionGuide);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? username, @JsonKey(name: 'display_name')  String? displayName,  String? bio, @JsonKey(name: 'region_id')  String? regionId, @JsonKey(name: 'village_id')  String? villageId, @JsonKey(name: 'has_read_contribution_guide', includeIfNull: false)  bool? hasReadContributionGuide)  $default,) {final _that = this;
switch (_that) {
case _UpdateMyProfileRequestDto():
return $default(_that.username,_that.displayName,_that.bio,_that.regionId,_that.villageId,_that.hasReadContributionGuide);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? username, @JsonKey(name: 'display_name')  String? displayName,  String? bio, @JsonKey(name: 'region_id')  String? regionId, @JsonKey(name: 'village_id')  String? villageId, @JsonKey(name: 'has_read_contribution_guide', includeIfNull: false)  bool? hasReadContributionGuide)?  $default,) {final _that = this;
switch (_that) {
case _UpdateMyProfileRequestDto() when $default != null:
return $default(_that.username,_that.displayName,_that.bio,_that.regionId,_that.villageId,_that.hasReadContributionGuide);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateMyProfileRequestDto implements UpdateMyProfileRequestDto {
  const _UpdateMyProfileRequestDto({@JsonKey(includeIfNull: false) this.username, @JsonKey(name: 'display_name') this.displayName, this.bio, @JsonKey(name: 'region_id') this.regionId, @JsonKey(name: 'village_id') this.villageId, @JsonKey(name: 'has_read_contribution_guide', includeIfNull: false) this.hasReadContributionGuide});
  factory _UpdateMyProfileRequestDto.fromJson(Map<String, dynamic> json) => _$UpdateMyProfileRequestDtoFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? username;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override final  String? bio;
@override@JsonKey(name: 'region_id') final  String? regionId;
@override@JsonKey(name: 'village_id') final  String? villageId;
@override@JsonKey(name: 'has_read_contribution_guide', includeIfNull: false) final  bool? hasReadContributionGuide;

/// Create a copy of UpdateMyProfileRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateMyProfileRequestDtoCopyWith<_UpdateMyProfileRequestDto> get copyWith => __$UpdateMyProfileRequestDtoCopyWithImpl<_UpdateMyProfileRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateMyProfileRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateMyProfileRequestDto&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.villageId, villageId) || other.villageId == villageId)&&(identical(other.hasReadContributionGuide, hasReadContributionGuide) || other.hasReadContributionGuide == hasReadContributionGuide));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,displayName,bio,regionId,villageId,hasReadContributionGuide);

@override
String toString() {
  return 'UpdateMyProfileRequestDto(username: $username, displayName: $displayName, bio: $bio, regionId: $regionId, villageId: $villageId, hasReadContributionGuide: $hasReadContributionGuide)';
}


}

/// @nodoc
abstract mixin class _$UpdateMyProfileRequestDtoCopyWith<$Res> implements $UpdateMyProfileRequestDtoCopyWith<$Res> {
  factory _$UpdateMyProfileRequestDtoCopyWith(_UpdateMyProfileRequestDto value, $Res Function(_UpdateMyProfileRequestDto) _then) = __$UpdateMyProfileRequestDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? username,@JsonKey(name: 'display_name') String? displayName, String? bio,@JsonKey(name: 'region_id') String? regionId,@JsonKey(name: 'village_id') String? villageId,@JsonKey(name: 'has_read_contribution_guide', includeIfNull: false) bool? hasReadContributionGuide
});




}
/// @nodoc
class __$UpdateMyProfileRequestDtoCopyWithImpl<$Res>
    implements _$UpdateMyProfileRequestDtoCopyWith<$Res> {
  __$UpdateMyProfileRequestDtoCopyWithImpl(this._self, this._then);

  final _UpdateMyProfileRequestDto _self;
  final $Res Function(_UpdateMyProfileRequestDto) _then;

/// Create a copy of UpdateMyProfileRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = freezed,Object? displayName = freezed,Object? bio = freezed,Object? regionId = freezed,Object? villageId = freezed,Object? hasReadContributionGuide = freezed,}) {
  return _then(_UpdateMyProfileRequestDto(
username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String?,villageId: freezed == villageId ? _self.villageId : villageId // ignore: cast_nullable_to_non_nullable
as String?,hasReadContributionGuide: freezed == hasReadContributionGuide ? _self.hasReadContributionGuide : hasReadContributionGuide // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
