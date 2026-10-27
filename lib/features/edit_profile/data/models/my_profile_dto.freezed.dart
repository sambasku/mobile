// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_profile_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyProfileDto {

 String get username;@JsonKey(name: 'display_name') String get displayName; String? get bio;@JsonKey(name: 'region_id') String? get regionId;@JsonKey(name: 'village_id') String? get villageId;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'has_read_contribution_guide') bool get hasReadContributionGuide;/// True bila user belum menyetujui terms/privacy versi aktif.
@JsonKey(name: 'requires_consent') bool get requiresConsent;@JsonKey(name: 'notify_streak_reminder') bool get notifyStreakReminder;@JsonKey(name: 'notify_level_up') bool get notifyLevelUp;
/// Create a copy of MyProfileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyProfileDtoCopyWith<MyProfileDto> get copyWith => _$MyProfileDtoCopyWithImpl<MyProfileDto>(this as MyProfileDto, _$identity);

  /// Serializes this MyProfileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MyProfileDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyProfileDto&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.regionId, _this.regionId) || other.regionId == _this.regionId)&&(identical(other.villageId, _this.villageId) || other.villageId == _this.villageId)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl)&&(identical(other.hasReadContributionGuide, _this.hasReadContributionGuide) || other.hasReadContributionGuide == _this.hasReadContributionGuide)&&(identical(other.requiresConsent, _this.requiresConsent) || other.requiresConsent == _this.requiresConsent)&&(identical(other.notifyStreakReminder, _this.notifyStreakReminder) || other.notifyStreakReminder == _this.notifyStreakReminder)&&(identical(other.notifyLevelUp, _this.notifyLevelUp) || other.notifyLevelUp == _this.notifyLevelUp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MyProfileDto;
  return Object.hash(runtimeType,_this.username,_this.displayName,_this.bio,_this.regionId,_this.villageId,_this.avatarUrl,_this.hasReadContributionGuide,_this.requiresConsent,_this.notifyStreakReminder,_this.notifyLevelUp);
}

@override
String toString() {
  final _this = this as MyProfileDto;
  return 'MyProfileDto(username: ${_this.username}, displayName: ${_this.displayName}, bio: ${_this.bio}, regionId: ${_this.regionId}, villageId: ${_this.villageId}, avatarUrl: ${_this.avatarUrl}, hasReadContributionGuide: ${_this.hasReadContributionGuide}, requiresConsent: ${_this.requiresConsent}, notifyStreakReminder: ${_this.notifyStreakReminder}, notifyLevelUp: ${_this.notifyLevelUp})';
}


}

/// @nodoc
abstract mixin class $MyProfileDtoCopyWith<$Res>  {
  factory $MyProfileDtoCopyWith(MyProfileDto value, $Res Function(MyProfileDto) _then) = _$MyProfileDtoCopyWithImpl;
@useResult
$Res call({
 String username,@JsonKey(name: 'display_name') String displayName, String? bio,@JsonKey(name: 'region_id') String? regionId,@JsonKey(name: 'village_id') String? villageId,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'has_read_contribution_guide') bool hasReadContributionGuide,@JsonKey(name: 'requires_consent') bool requiresConsent,@JsonKey(name: 'notify_streak_reminder') bool notifyStreakReminder,@JsonKey(name: 'notify_level_up') bool notifyLevelUp
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
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? displayName = null,Object? bio = freezed,Object? regionId = freezed,Object? villageId = freezed,Object? avatarUrl = freezed,Object? hasReadContributionGuide = null,Object? requiresConsent = null,Object? notifyStreakReminder = null,Object? notifyLevelUp = null,}) {
  return _then(MyProfileDto(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String?,villageId: freezed == villageId ? _self.villageId : villageId // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,hasReadContributionGuide: null == hasReadContributionGuide ? _self.hasReadContributionGuide : hasReadContributionGuide // ignore: cast_nullable_to_non_nullable
as bool,requiresConsent: null == requiresConsent ? _self.requiresConsent : requiresConsent // ignore: cast_nullable_to_non_nullable
as bool,notifyStreakReminder: null == notifyStreakReminder ? _self.notifyStreakReminder : notifyStreakReminder // ignore: cast_nullable_to_non_nullable
as bool,notifyLevelUp: null == notifyLevelUp ? _self.notifyLevelUp : notifyLevelUp // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username, @JsonKey(name: 'display_name')  String displayName,  String? bio, @JsonKey(name: 'region_id')  String? regionId, @JsonKey(name: 'village_id')  String? villageId, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'has_read_contribution_guide')  bool hasReadContributionGuide, @JsonKey(name: 'requires_consent')  bool requiresConsent, @JsonKey(name: 'notify_streak_reminder')  bool notifyStreakReminder, @JsonKey(name: 'notify_level_up')  bool notifyLevelUp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyProfileDto() when $default != null:
return $default(_that.username,_that.displayName,_that.bio,_that.regionId,_that.villageId,_that.avatarUrl,_that.hasReadContributionGuide,_that.requiresConsent,_that.notifyStreakReminder,_that.notifyLevelUp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username, @JsonKey(name: 'display_name')  String displayName,  String? bio, @JsonKey(name: 'region_id')  String? regionId, @JsonKey(name: 'village_id')  String? villageId, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'has_read_contribution_guide')  bool hasReadContributionGuide, @JsonKey(name: 'requires_consent')  bool requiresConsent, @JsonKey(name: 'notify_streak_reminder')  bool notifyStreakReminder, @JsonKey(name: 'notify_level_up')  bool notifyLevelUp)  $default,) {final _that = this;
switch (_that) {
case _MyProfileDto():
return $default(_that.username,_that.displayName,_that.bio,_that.regionId,_that.villageId,_that.avatarUrl,_that.hasReadContributionGuide,_that.requiresConsent,_that.notifyStreakReminder,_that.notifyLevelUp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username, @JsonKey(name: 'display_name')  String displayName,  String? bio, @JsonKey(name: 'region_id')  String? regionId, @JsonKey(name: 'village_id')  String? villageId, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'has_read_contribution_guide')  bool hasReadContributionGuide, @JsonKey(name: 'requires_consent')  bool requiresConsent, @JsonKey(name: 'notify_streak_reminder')  bool notifyStreakReminder, @JsonKey(name: 'notify_level_up')  bool notifyLevelUp)?  $default,) {final _that = this;
switch (_that) {
case _MyProfileDto() when $default != null:
return $default(_that.username,_that.displayName,_that.bio,_that.regionId,_that.villageId,_that.avatarUrl,_that.hasReadContributionGuide,_that.requiresConsent,_that.notifyStreakReminder,_that.notifyLevelUp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MyProfileDto implements MyProfileDto {
  const _MyProfileDto({required this.username, @JsonKey(name: 'display_name') required this.displayName, this.bio, @JsonKey(name: 'region_id') this.regionId, @JsonKey(name: 'village_id') this.villageId, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'has_read_contribution_guide') this.hasReadContributionGuide = false, @JsonKey(name: 'requires_consent') this.requiresConsent = false, @JsonKey(name: 'notify_streak_reminder') this.notifyStreakReminder = true, @JsonKey(name: 'notify_level_up') this.notifyLevelUp = true});
  factory _MyProfileDto.fromJson(Map<String, dynamic> json) => _$MyProfileDtoFromJson(json);

@override final  String username;
@override@JsonKey(name: 'display_name') final  String displayName;
@override final  String? bio;
@override@JsonKey(name: 'region_id') final  String? regionId;
@override@JsonKey(name: 'village_id') final  String? villageId;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'has_read_contribution_guide') final  bool hasReadContributionGuide;
/// True bila user belum menyetujui terms/privacy versi aktif.
@override@JsonKey(name: 'requires_consent') final  bool requiresConsent;
@override@JsonKey(name: 'notify_streak_reminder') final  bool notifyStreakReminder;
@override@JsonKey(name: 'notify_level_up') final  bool notifyLevelUp;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyProfileDto&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.villageId, villageId) || other.villageId == villageId)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.hasReadContributionGuide, hasReadContributionGuide) || other.hasReadContributionGuide == hasReadContributionGuide)&&(identical(other.requiresConsent, requiresConsent) || other.requiresConsent == requiresConsent)&&(identical(other.notifyStreakReminder, notifyStreakReminder) || other.notifyStreakReminder == notifyStreakReminder)&&(identical(other.notifyLevelUp, notifyLevelUp) || other.notifyLevelUp == notifyLevelUp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,username,displayName,bio,regionId,villageId,avatarUrl,hasReadContributionGuide,requiresConsent,notifyStreakReminder,notifyLevelUp);
}

@override
String toString() {
    return 'MyProfileDto(username: $username, displayName: $displayName, bio: $bio, regionId: $regionId, villageId: $villageId, avatarUrl: $avatarUrl, hasReadContributionGuide: $hasReadContributionGuide, requiresConsent: $requiresConsent, notifyStreakReminder: $notifyStreakReminder, notifyLevelUp: $notifyLevelUp)';
}


}

/// @nodoc
abstract mixin class _$MyProfileDtoCopyWith<$Res> implements $MyProfileDtoCopyWith<$Res> {
  factory _$MyProfileDtoCopyWith(_MyProfileDto value, $Res Function(_MyProfileDto) _then) = __$MyProfileDtoCopyWithImpl;
@override @useResult
$Res call({
 String username,@JsonKey(name: 'display_name') String displayName, String? bio,@JsonKey(name: 'region_id') String? regionId,@JsonKey(name: 'village_id') String? villageId,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'has_read_contribution_guide') bool hasReadContributionGuide,@JsonKey(name: 'requires_consent') bool requiresConsent,@JsonKey(name: 'notify_streak_reminder') bool notifyStreakReminder,@JsonKey(name: 'notify_level_up') bool notifyLevelUp
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
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? displayName = null,Object? bio = freezed,Object? regionId = freezed,Object? villageId = freezed,Object? avatarUrl = freezed,Object? hasReadContributionGuide = null,Object? requiresConsent = null,Object? notifyStreakReminder = null,Object? notifyLevelUp = null,}) {
  return _then(_MyProfileDto(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String?,villageId: freezed == villageId ? _self.villageId : villageId // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,hasReadContributionGuide: null == hasReadContributionGuide ? _self.hasReadContributionGuide : hasReadContributionGuide // ignore: cast_nullable_to_non_nullable
as bool,requiresConsent: null == requiresConsent ? _self.requiresConsent : requiresConsent // ignore: cast_nullable_to_non_nullable
as bool,notifyStreakReminder: null == notifyStreakReminder ? _self.notifyStreakReminder : notifyStreakReminder // ignore: cast_nullable_to_non_nullable
as bool,notifyLevelUp: null == notifyLevelUp ? _self.notifyLevelUp : notifyLevelUp // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$UpdateMyProfileRequestDto {

@JsonKey(includeIfNull: false) String? get username;@JsonKey(name: 'display_name') String? get displayName; String? get bio;@JsonKey(name: 'region_id') String? get regionId;@JsonKey(name: 'village_id') String? get villageId;@JsonKey(name: 'has_read_contribution_guide', includeIfNull: false) bool? get hasReadContributionGuide;@JsonKey(name: 'notify_streak_reminder', includeIfNull: false) bool? get notifyStreakReminder;@JsonKey(name: 'notify_level_up', includeIfNull: false) bool? get notifyLevelUp;
/// Create a copy of UpdateMyProfileRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateMyProfileRequestDtoCopyWith<UpdateMyProfileRequestDto> get copyWith => _$UpdateMyProfileRequestDtoCopyWithImpl<UpdateMyProfileRequestDto>(this as UpdateMyProfileRequestDto, _$identity);

  /// Serializes this UpdateMyProfileRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateMyProfileRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateMyProfileRequestDto&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.regionId, _this.regionId) || other.regionId == _this.regionId)&&(identical(other.villageId, _this.villageId) || other.villageId == _this.villageId)&&(identical(other.hasReadContributionGuide, _this.hasReadContributionGuide) || other.hasReadContributionGuide == _this.hasReadContributionGuide)&&(identical(other.notifyStreakReminder, _this.notifyStreakReminder) || other.notifyStreakReminder == _this.notifyStreakReminder)&&(identical(other.notifyLevelUp, _this.notifyLevelUp) || other.notifyLevelUp == _this.notifyLevelUp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateMyProfileRequestDto;
  return Object.hash(runtimeType,_this.username,_this.displayName,_this.bio,_this.regionId,_this.villageId,_this.hasReadContributionGuide,_this.notifyStreakReminder,_this.notifyLevelUp);
}

@override
String toString() {
  final _this = this as UpdateMyProfileRequestDto;
  return 'UpdateMyProfileRequestDto(username: ${_this.username}, displayName: ${_this.displayName}, bio: ${_this.bio}, regionId: ${_this.regionId}, villageId: ${_this.villageId}, hasReadContributionGuide: ${_this.hasReadContributionGuide}, notifyStreakReminder: ${_this.notifyStreakReminder}, notifyLevelUp: ${_this.notifyLevelUp})';
}


}

/// @nodoc
abstract mixin class $UpdateMyProfileRequestDtoCopyWith<$Res>  {
  factory $UpdateMyProfileRequestDtoCopyWith(UpdateMyProfileRequestDto value, $Res Function(UpdateMyProfileRequestDto) _then) = _$UpdateMyProfileRequestDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? username,@JsonKey(name: 'display_name') String? displayName, String? bio,@JsonKey(name: 'region_id') String? regionId,@JsonKey(name: 'village_id') String? villageId,@JsonKey(name: 'has_read_contribution_guide', includeIfNull: false) bool? hasReadContributionGuide,@JsonKey(name: 'notify_streak_reminder', includeIfNull: false) bool? notifyStreakReminder,@JsonKey(name: 'notify_level_up', includeIfNull: false) bool? notifyLevelUp
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
@pragma('vm:prefer-inline') @override $Res call({Object? username = freezed,Object? displayName = freezed,Object? bio = freezed,Object? regionId = freezed,Object? villageId = freezed,Object? hasReadContributionGuide = freezed,Object? notifyStreakReminder = freezed,Object? notifyLevelUp = freezed,}) {
  return _then(UpdateMyProfileRequestDto(
username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String?,villageId: freezed == villageId ? _self.villageId : villageId // ignore: cast_nullable_to_non_nullable
as String?,hasReadContributionGuide: freezed == hasReadContributionGuide ? _self.hasReadContributionGuide : hasReadContributionGuide // ignore: cast_nullable_to_non_nullable
as bool?,notifyStreakReminder: freezed == notifyStreakReminder ? _self.notifyStreakReminder : notifyStreakReminder // ignore: cast_nullable_to_non_nullable
as bool?,notifyLevelUp: freezed == notifyLevelUp ? _self.notifyLevelUp : notifyLevelUp // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? username, @JsonKey(name: 'display_name')  String? displayName,  String? bio, @JsonKey(name: 'region_id')  String? regionId, @JsonKey(name: 'village_id')  String? villageId, @JsonKey(name: 'has_read_contribution_guide', includeIfNull: false)  bool? hasReadContributionGuide, @JsonKey(name: 'notify_streak_reminder', includeIfNull: false)  bool? notifyStreakReminder, @JsonKey(name: 'notify_level_up', includeIfNull: false)  bool? notifyLevelUp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateMyProfileRequestDto() when $default != null:
return $default(_that.username,_that.displayName,_that.bio,_that.regionId,_that.villageId,_that.hasReadContributionGuide,_that.notifyStreakReminder,_that.notifyLevelUp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? username, @JsonKey(name: 'display_name')  String? displayName,  String? bio, @JsonKey(name: 'region_id')  String? regionId, @JsonKey(name: 'village_id')  String? villageId, @JsonKey(name: 'has_read_contribution_guide', includeIfNull: false)  bool? hasReadContributionGuide, @JsonKey(name: 'notify_streak_reminder', includeIfNull: false)  bool? notifyStreakReminder, @JsonKey(name: 'notify_level_up', includeIfNull: false)  bool? notifyLevelUp)  $default,) {final _that = this;
switch (_that) {
case _UpdateMyProfileRequestDto():
return $default(_that.username,_that.displayName,_that.bio,_that.regionId,_that.villageId,_that.hasReadContributionGuide,_that.notifyStreakReminder,_that.notifyLevelUp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? username, @JsonKey(name: 'display_name')  String? displayName,  String? bio, @JsonKey(name: 'region_id')  String? regionId, @JsonKey(name: 'village_id')  String? villageId, @JsonKey(name: 'has_read_contribution_guide', includeIfNull: false)  bool? hasReadContributionGuide, @JsonKey(name: 'notify_streak_reminder', includeIfNull: false)  bool? notifyStreakReminder, @JsonKey(name: 'notify_level_up', includeIfNull: false)  bool? notifyLevelUp)?  $default,) {final _that = this;
switch (_that) {
case _UpdateMyProfileRequestDto() when $default != null:
return $default(_that.username,_that.displayName,_that.bio,_that.regionId,_that.villageId,_that.hasReadContributionGuide,_that.notifyStreakReminder,_that.notifyLevelUp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateMyProfileRequestDto implements UpdateMyProfileRequestDto {
  const _UpdateMyProfileRequestDto({@JsonKey(includeIfNull: false) this.username, @JsonKey(name: 'display_name') this.displayName, this.bio, @JsonKey(name: 'region_id') this.regionId, @JsonKey(name: 'village_id') this.villageId, @JsonKey(name: 'has_read_contribution_guide', includeIfNull: false) this.hasReadContributionGuide, @JsonKey(name: 'notify_streak_reminder', includeIfNull: false) this.notifyStreakReminder, @JsonKey(name: 'notify_level_up', includeIfNull: false) this.notifyLevelUp});
  factory _UpdateMyProfileRequestDto.fromJson(Map<String, dynamic> json) => _$UpdateMyProfileRequestDtoFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? username;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override final  String? bio;
@override@JsonKey(name: 'region_id') final  String? regionId;
@override@JsonKey(name: 'village_id') final  String? villageId;
@override@JsonKey(name: 'has_read_contribution_guide', includeIfNull: false) final  bool? hasReadContributionGuide;
@override@JsonKey(name: 'notify_streak_reminder', includeIfNull: false) final  bool? notifyStreakReminder;
@override@JsonKey(name: 'notify_level_up', includeIfNull: false) final  bool? notifyLevelUp;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateMyProfileRequestDto&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.villageId, villageId) || other.villageId == villageId)&&(identical(other.hasReadContributionGuide, hasReadContributionGuide) || other.hasReadContributionGuide == hasReadContributionGuide)&&(identical(other.notifyStreakReminder, notifyStreakReminder) || other.notifyStreakReminder == notifyStreakReminder)&&(identical(other.notifyLevelUp, notifyLevelUp) || other.notifyLevelUp == notifyLevelUp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,username,displayName,bio,regionId,villageId,hasReadContributionGuide,notifyStreakReminder,notifyLevelUp);
}

@override
String toString() {
    return 'UpdateMyProfileRequestDto(username: $username, displayName: $displayName, bio: $bio, regionId: $regionId, villageId: $villageId, hasReadContributionGuide: $hasReadContributionGuide, notifyStreakReminder: $notifyStreakReminder, notifyLevelUp: $notifyLevelUp)';
}


}

/// @nodoc
abstract mixin class _$UpdateMyProfileRequestDtoCopyWith<$Res> implements $UpdateMyProfileRequestDtoCopyWith<$Res> {
  factory _$UpdateMyProfileRequestDtoCopyWith(_UpdateMyProfileRequestDto value, $Res Function(_UpdateMyProfileRequestDto) _then) = __$UpdateMyProfileRequestDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? username,@JsonKey(name: 'display_name') String? displayName, String? bio,@JsonKey(name: 'region_id') String? regionId,@JsonKey(name: 'village_id') String? villageId,@JsonKey(name: 'has_read_contribution_guide', includeIfNull: false) bool? hasReadContributionGuide,@JsonKey(name: 'notify_streak_reminder', includeIfNull: false) bool? notifyStreakReminder,@JsonKey(name: 'notify_level_up', includeIfNull: false) bool? notifyLevelUp
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
@override @pragma('vm:prefer-inline') $Res call({Object? username = freezed,Object? displayName = freezed,Object? bio = freezed,Object? regionId = freezed,Object? villageId = freezed,Object? hasReadContributionGuide = freezed,Object? notifyStreakReminder = freezed,Object? notifyLevelUp = freezed,}) {
  return _then(_UpdateMyProfileRequestDto(
username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String?,villageId: freezed == villageId ? _self.villageId : villageId // ignore: cast_nullable_to_non_nullable
as String?,hasReadContributionGuide: freezed == hasReadContributionGuide ? _self.hasReadContributionGuide : hasReadContributionGuide // ignore: cast_nullable_to_non_nullable
as bool?,notifyStreakReminder: freezed == notifyStreakReminder ? _self.notifyStreakReminder : notifyStreakReminder // ignore: cast_nullable_to_non_nullable
as bool?,notifyLevelUp: freezed == notifyLevelUp ? _self.notifyLevelUp : notifyLevelUp // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
