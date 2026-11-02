// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AchievementDto {

 String get id; String get code; String get title; String get description; String get category;@JsonKey(name: 'reward_type') String get rewardType;@JsonKey(name: 'badge_url') String? get badgeUrl; String? get family; int? get level;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'user_achievement_id') String? get userAchievementId;/// Unix epoch detik (format waktu wire backend).
@JsonKey(name: 'awarded_at') int? get awardedAt;@JsonKey(name: 'is_active_border') bool get isActiveBorder; AchievementProgressDto? get progress;
/// Create a copy of AchievementDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AchievementDtoCopyWith<AchievementDto> get copyWith => _$AchievementDtoCopyWithImpl<AchievementDto>(this as AchievementDto, _$identity);

  /// Serializes this AchievementDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AchievementDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AchievementDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.rewardType, _this.rewardType) || other.rewardType == _this.rewardType)&&(identical(other.badgeUrl, _this.badgeUrl) || other.badgeUrl == _this.badgeUrl)&&(identical(other.family, _this.family) || other.family == _this.family)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.userAchievementId, _this.userAchievementId) || other.userAchievementId == _this.userAchievementId)&&(identical(other.awardedAt, _this.awardedAt) || other.awardedAt == _this.awardedAt)&&(identical(other.isActiveBorder, _this.isActiveBorder) || other.isActiveBorder == _this.isActiveBorder)&&(identical(other.progress, _this.progress) || other.progress == _this.progress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AchievementDto;
  return Object.hash(runtimeType,_this.id,_this.code,_this.title,_this.description,_this.category,_this.rewardType,_this.badgeUrl,_this.family,_this.level,_this.isActive,_this.userAchievementId,_this.awardedAt,_this.isActiveBorder,_this.progress);
}

@override
String toString() {
  final _this = this as AchievementDto;
  return 'AchievementDto(id: ${_this.id}, code: ${_this.code}, title: ${_this.title}, description: ${_this.description}, category: ${_this.category}, rewardType: ${_this.rewardType}, badgeUrl: ${_this.badgeUrl}, family: ${_this.family}, level: ${_this.level}, isActive: ${_this.isActive}, userAchievementId: ${_this.userAchievementId}, awardedAt: ${_this.awardedAt}, isActiveBorder: ${_this.isActiveBorder}, progress: ${_this.progress})';
}


}

/// @nodoc
abstract mixin class $AchievementDtoCopyWith<$Res>  {
  factory $AchievementDtoCopyWith(AchievementDto value, $Res Function(AchievementDto) _then) = _$AchievementDtoCopyWithImpl;
@useResult
$Res call({
 String id, String code, String title, String description, String category,@JsonKey(name: 'reward_type') String rewardType,@JsonKey(name: 'badge_url') String? badgeUrl, String? family, int? level,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'user_achievement_id') String? userAchievementId,@JsonKey(name: 'awarded_at') int? awardedAt,@JsonKey(name: 'is_active_border') bool isActiveBorder, AchievementProgressDto? progress
});


$AchievementProgressDtoCopyWith<$Res>? get progress;

}
/// @nodoc
class _$AchievementDtoCopyWithImpl<$Res>
    implements $AchievementDtoCopyWith<$Res> {
  _$AchievementDtoCopyWithImpl(this._self, this._then);

  final AchievementDto _self;
  final $Res Function(AchievementDto) _then;

/// Create a copy of AchievementDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? title = null,Object? description = null,Object? category = null,Object? rewardType = null,Object? badgeUrl = freezed,Object? family = freezed,Object? level = freezed,Object? isActive = null,Object? userAchievementId = freezed,Object? awardedAt = freezed,Object? isActiveBorder = null,Object? progress = freezed,}) {
  return _then(AchievementDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,rewardType: null == rewardType ? _self.rewardType : rewardType // ignore: cast_nullable_to_non_nullable
as String,badgeUrl: freezed == badgeUrl ? _self.badgeUrl : badgeUrl // ignore: cast_nullable_to_non_nullable
as String?,family: freezed == family ? _self.family : family // ignore: cast_nullable_to_non_nullable
as String?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,userAchievementId: freezed == userAchievementId ? _self.userAchievementId : userAchievementId // ignore: cast_nullable_to_non_nullable
as String?,awardedAt: freezed == awardedAt ? _self.awardedAt : awardedAt // ignore: cast_nullable_to_non_nullable
as int?,isActiveBorder: null == isActiveBorder ? _self.isActiveBorder : isActiveBorder // ignore: cast_nullable_to_non_nullable
as bool,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as AchievementProgressDto?,
  ));
}
/// Create a copy of AchievementDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AchievementProgressDtoCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $AchievementProgressDtoCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}


/// Adds pattern-matching-related methods to [AchievementDto].
extension AchievementDtoPatterns on AchievementDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AchievementDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AchievementDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AchievementDto value)  $default,){
final _that = this;
switch (_that) {
case _AchievementDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AchievementDto value)?  $default,){
final _that = this;
switch (_that) {
case _AchievementDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  String title,  String description,  String category, @JsonKey(name: 'reward_type')  String rewardType, @JsonKey(name: 'badge_url')  String? badgeUrl,  String? family,  int? level, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'user_achievement_id')  String? userAchievementId, @JsonKey(name: 'awarded_at')  int? awardedAt, @JsonKey(name: 'is_active_border')  bool isActiveBorder,  AchievementProgressDto? progress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AchievementDto() when $default != null:
return $default(_that.id,_that.code,_that.title,_that.description,_that.category,_that.rewardType,_that.badgeUrl,_that.family,_that.level,_that.isActive,_that.userAchievementId,_that.awardedAt,_that.isActiveBorder,_that.progress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  String title,  String description,  String category, @JsonKey(name: 'reward_type')  String rewardType, @JsonKey(name: 'badge_url')  String? badgeUrl,  String? family,  int? level, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'user_achievement_id')  String? userAchievementId, @JsonKey(name: 'awarded_at')  int? awardedAt, @JsonKey(name: 'is_active_border')  bool isActiveBorder,  AchievementProgressDto? progress)  $default,) {final _that = this;
switch (_that) {
case _AchievementDto():
return $default(_that.id,_that.code,_that.title,_that.description,_that.category,_that.rewardType,_that.badgeUrl,_that.family,_that.level,_that.isActive,_that.userAchievementId,_that.awardedAt,_that.isActiveBorder,_that.progress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  String title,  String description,  String category, @JsonKey(name: 'reward_type')  String rewardType, @JsonKey(name: 'badge_url')  String? badgeUrl,  String? family,  int? level, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'user_achievement_id')  String? userAchievementId, @JsonKey(name: 'awarded_at')  int? awardedAt, @JsonKey(name: 'is_active_border')  bool isActiveBorder,  AchievementProgressDto? progress)?  $default,) {final _that = this;
switch (_that) {
case _AchievementDto() when $default != null:
return $default(_that.id,_that.code,_that.title,_that.description,_that.category,_that.rewardType,_that.badgeUrl,_that.family,_that.level,_that.isActive,_that.userAchievementId,_that.awardedAt,_that.isActiveBorder,_that.progress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AchievementDto implements AchievementDto {
  const _AchievementDto({required this.id, required this.code, required this.title, required this.description, required this.category, @JsonKey(name: 'reward_type') required this.rewardType, @JsonKey(name: 'badge_url') this.badgeUrl, this.family, this.level, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'user_achievement_id') this.userAchievementId, @JsonKey(name: 'awarded_at') this.awardedAt, @JsonKey(name: 'is_active_border') this.isActiveBorder = false, this.progress});
  factory _AchievementDto.fromJson(Map<String, dynamic> json) => _$AchievementDtoFromJson(json);

@override final  String id;
@override final  String code;
@override final  String title;
@override final  String description;
@override final  String category;
@override@JsonKey(name: 'reward_type') final  String rewardType;
@override@JsonKey(name: 'badge_url') final  String? badgeUrl;
@override final  String? family;
@override final  int? level;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'user_achievement_id') final  String? userAchievementId;
/// Unix epoch detik (format waktu wire backend).
@override@JsonKey(name: 'awarded_at') final  int? awardedAt;
@override@JsonKey(name: 'is_active_border') final  bool isActiveBorder;
@override final  AchievementProgressDto? progress;

/// Create a copy of AchievementDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AchievementDtoCopyWith<_AchievementDto> get copyWith => __$AchievementDtoCopyWithImpl<_AchievementDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AchievementDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AchievementDto&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.rewardType, rewardType) || other.rewardType == rewardType)&&(identical(other.badgeUrl, badgeUrl) || other.badgeUrl == badgeUrl)&&(identical(other.family, family) || other.family == family)&&(identical(other.level, level) || other.level == level)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.userAchievementId, userAchievementId) || other.userAchievementId == userAchievementId)&&(identical(other.awardedAt, awardedAt) || other.awardedAt == awardedAt)&&(identical(other.isActiveBorder, isActiveBorder) || other.isActiveBorder == isActiveBorder)&&(identical(other.progress, progress) || other.progress == progress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,title,description,category,rewardType,badgeUrl,family,level,isActive,userAchievementId,awardedAt,isActiveBorder,progress);
}

@override
String toString() {
    return 'AchievementDto(id: $id, code: $code, title: $title, description: $description, category: $category, rewardType: $rewardType, badgeUrl: $badgeUrl, family: $family, level: $level, isActive: $isActive, userAchievementId: $userAchievementId, awardedAt: $awardedAt, isActiveBorder: $isActiveBorder, progress: $progress)';
}


}

/// @nodoc
abstract mixin class _$AchievementDtoCopyWith<$Res> implements $AchievementDtoCopyWith<$Res> {
  factory _$AchievementDtoCopyWith(_AchievementDto value, $Res Function(_AchievementDto) _then) = __$AchievementDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, String title, String description, String category,@JsonKey(name: 'reward_type') String rewardType,@JsonKey(name: 'badge_url') String? badgeUrl, String? family, int? level,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'user_achievement_id') String? userAchievementId,@JsonKey(name: 'awarded_at') int? awardedAt,@JsonKey(name: 'is_active_border') bool isActiveBorder, AchievementProgressDto? progress
});


@override $AchievementProgressDtoCopyWith<$Res>? get progress;

}
/// @nodoc
class __$AchievementDtoCopyWithImpl<$Res>
    implements _$AchievementDtoCopyWith<$Res> {
  __$AchievementDtoCopyWithImpl(this._self, this._then);

  final _AchievementDto _self;
  final $Res Function(_AchievementDto) _then;

/// Create a copy of AchievementDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? title = null,Object? description = null,Object? category = null,Object? rewardType = null,Object? badgeUrl = freezed,Object? family = freezed,Object? level = freezed,Object? isActive = null,Object? userAchievementId = freezed,Object? awardedAt = freezed,Object? isActiveBorder = null,Object? progress = freezed,}) {
  return _then(_AchievementDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,rewardType: null == rewardType ? _self.rewardType : rewardType // ignore: cast_nullable_to_non_nullable
as String,badgeUrl: freezed == badgeUrl ? _self.badgeUrl : badgeUrl // ignore: cast_nullable_to_non_nullable
as String?,family: freezed == family ? _self.family : family // ignore: cast_nullable_to_non_nullable
as String?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,userAchievementId: freezed == userAchievementId ? _self.userAchievementId : userAchievementId // ignore: cast_nullable_to_non_nullable
as String?,awardedAt: freezed == awardedAt ? _self.awardedAt : awardedAt // ignore: cast_nullable_to_non_nullable
as int?,isActiveBorder: null == isActiveBorder ? _self.isActiveBorder : isActiveBorder // ignore: cast_nullable_to_non_nullable
as bool,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as AchievementProgressDto?,
  ));
}

/// Create a copy of AchievementDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AchievementProgressDtoCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $AchievementProgressDtoCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}


/// @nodoc
mixin _$AchievementProgressDto {

 int get current; int get target;
/// Create a copy of AchievementProgressDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AchievementProgressDtoCopyWith<AchievementProgressDto> get copyWith => _$AchievementProgressDtoCopyWithImpl<AchievementProgressDto>(this as AchievementProgressDto, _$identity);

  /// Serializes this AchievementProgressDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AchievementProgressDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AchievementProgressDto&&(identical(other.current, _this.current) || other.current == _this.current)&&(identical(other.target, _this.target) || other.target == _this.target));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AchievementProgressDto;
  return Object.hash(runtimeType,_this.current,_this.target);
}

@override
String toString() {
  final _this = this as AchievementProgressDto;
  return 'AchievementProgressDto(current: ${_this.current}, target: ${_this.target})';
}


}

/// @nodoc
abstract mixin class $AchievementProgressDtoCopyWith<$Res>  {
  factory $AchievementProgressDtoCopyWith(AchievementProgressDto value, $Res Function(AchievementProgressDto) _then) = _$AchievementProgressDtoCopyWithImpl;
@useResult
$Res call({
 int current, int target
});




}
/// @nodoc
class _$AchievementProgressDtoCopyWithImpl<$Res>
    implements $AchievementProgressDtoCopyWith<$Res> {
  _$AchievementProgressDtoCopyWithImpl(this._self, this._then);

  final AchievementProgressDto _self;
  final $Res Function(AchievementProgressDto) _then;

/// Create a copy of AchievementProgressDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? target = null,}) {
  return _then(AchievementProgressDto(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AchievementProgressDto].
extension AchievementProgressDtoPatterns on AchievementProgressDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AchievementProgressDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AchievementProgressDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AchievementProgressDto value)  $default,){
final _that = this;
switch (_that) {
case _AchievementProgressDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AchievementProgressDto value)?  $default,){
final _that = this;
switch (_that) {
case _AchievementProgressDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int current,  int target)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AchievementProgressDto() when $default != null:
return $default(_that.current,_that.target);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int current,  int target)  $default,) {final _that = this;
switch (_that) {
case _AchievementProgressDto():
return $default(_that.current,_that.target);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int current,  int target)?  $default,) {final _that = this;
switch (_that) {
case _AchievementProgressDto() when $default != null:
return $default(_that.current,_that.target);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AchievementProgressDto implements AchievementProgressDto {
  const _AchievementProgressDto({required this.current, required this.target});
  factory _AchievementProgressDto.fromJson(Map<String, dynamic> json) => _$AchievementProgressDtoFromJson(json);

@override final  int current;
@override final  int target;

/// Create a copy of AchievementProgressDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AchievementProgressDtoCopyWith<_AchievementProgressDto> get copyWith => __$AchievementProgressDtoCopyWithImpl<_AchievementProgressDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AchievementProgressDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AchievementProgressDto&&(identical(other.current, current) || other.current == current)&&(identical(other.target, target) || other.target == target));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,current,target);
}

@override
String toString() {
    return 'AchievementProgressDto(current: $current, target: $target)';
}


}

/// @nodoc
abstract mixin class _$AchievementProgressDtoCopyWith<$Res> implements $AchievementProgressDtoCopyWith<$Res> {
  factory _$AchievementProgressDtoCopyWith(_AchievementProgressDto value, $Res Function(_AchievementProgressDto) _then) = __$AchievementProgressDtoCopyWithImpl;
@override @useResult
$Res call({
 int current, int target
});




}
/// @nodoc
class __$AchievementProgressDtoCopyWithImpl<$Res>
    implements _$AchievementProgressDtoCopyWith<$Res> {
  __$AchievementProgressDtoCopyWithImpl(this._self, this._then);

  final _AchievementProgressDto _self;
  final $Res Function(_AchievementProgressDto) _then;

/// Create a copy of AchievementProgressDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? target = null,}) {
  return _then(_AchievementProgressDto(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AchievementListDto {

 List<AchievementDto> get items;@JsonKey(name: 'next_cursor') String? get nextCursor;
/// Create a copy of AchievementListDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AchievementListDtoCopyWith<AchievementListDto> get copyWith => _$AchievementListDtoCopyWithImpl<AchievementListDto>(this as AchievementListDto, _$identity);

  /// Serializes this AchievementListDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AchievementListDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AchievementListDto&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.nextCursor, _this.nextCursor) || other.nextCursor == _this.nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AchievementListDto;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.nextCursor);
}

@override
String toString() {
  final _this = this as AchievementListDto;
  return 'AchievementListDto(items: ${_this.items}, nextCursor: ${_this.nextCursor})';
}


}

/// @nodoc
abstract mixin class $AchievementListDtoCopyWith<$Res>  {
  factory $AchievementListDtoCopyWith(AchievementListDto value, $Res Function(AchievementListDto) _then) = _$AchievementListDtoCopyWithImpl;
@useResult
$Res call({
 List<AchievementDto> items,@JsonKey(name: 'next_cursor') String? nextCursor
});




}
/// @nodoc
class _$AchievementListDtoCopyWithImpl<$Res>
    implements $AchievementListDtoCopyWith<$Res> {
  _$AchievementListDtoCopyWithImpl(this._self, this._then);

  final AchievementListDto _self;
  final $Res Function(AchievementListDto) _then;

/// Create a copy of AchievementListDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(AchievementListDto(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AchievementDto>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AchievementListDto].
extension AchievementListDtoPatterns on AchievementListDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AchievementListDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AchievementListDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AchievementListDto value)  $default,){
final _that = this;
switch (_that) {
case _AchievementListDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AchievementListDto value)?  $default,){
final _that = this;
switch (_that) {
case _AchievementListDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AchievementDto> items, @JsonKey(name: 'next_cursor')  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AchievementListDto() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AchievementDto> items, @JsonKey(name: 'next_cursor')  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _AchievementListDto():
return $default(_that.items,_that.nextCursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AchievementDto> items, @JsonKey(name: 'next_cursor')  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _AchievementListDto() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AchievementListDto implements AchievementListDto {
  const _AchievementListDto({ List<AchievementDto> items = const <AchievementDto>[], @JsonKey(name: 'next_cursor') this.nextCursor}): _items = items;
  factory _AchievementListDto.fromJson(Map<String, dynamic> json) => _$AchievementListDtoFromJson(json);

 final  List<AchievementDto> _items;
@override@JsonKey() List<AchievementDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey(name: 'next_cursor') final  String? nextCursor;

/// Create a copy of AchievementListDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AchievementListDtoCopyWith<_AchievementListDto> get copyWith => __$AchievementListDtoCopyWithImpl<_AchievementListDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AchievementListDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AchievementListDto&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor);
}

@override
String toString() {
    return 'AchievementListDto(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$AchievementListDtoCopyWith<$Res> implements $AchievementListDtoCopyWith<$Res> {
  factory _$AchievementListDtoCopyWith(_AchievementListDto value, $Res Function(_AchievementListDto) _then) = __$AchievementListDtoCopyWithImpl;
@override @useResult
$Res call({
 List<AchievementDto> items,@JsonKey(name: 'next_cursor') String? nextCursor
});




}
/// @nodoc
class __$AchievementListDtoCopyWithImpl<$Res>
    implements _$AchievementListDtoCopyWith<$Res> {
  __$AchievementListDtoCopyWithImpl(this._self, this._then);

  final _AchievementListDto _self;
  final $Res Function(_AchievementListDto) _then;

/// Create a copy of AchievementListDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_AchievementListDto(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AchievementDto>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SetBorderRequestDto {

@JsonKey(name: 'border_id') String? get borderId;
/// Create a copy of SetBorderRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetBorderRequestDtoCopyWith<SetBorderRequestDto> get copyWith => _$SetBorderRequestDtoCopyWithImpl<SetBorderRequestDto>(this as SetBorderRequestDto, _$identity);

  /// Serializes this SetBorderRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SetBorderRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetBorderRequestDto&&(identical(other.borderId, _this.borderId) || other.borderId == _this.borderId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SetBorderRequestDto;
  return Object.hash(runtimeType,_this.borderId);
}

@override
String toString() {
  final _this = this as SetBorderRequestDto;
  return 'SetBorderRequestDto(borderId: ${_this.borderId})';
}


}

/// @nodoc
abstract mixin class $SetBorderRequestDtoCopyWith<$Res>  {
  factory $SetBorderRequestDtoCopyWith(SetBorderRequestDto value, $Res Function(SetBorderRequestDto) _then) = _$SetBorderRequestDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'border_id') String? borderId
});




}
/// @nodoc
class _$SetBorderRequestDtoCopyWithImpl<$Res>
    implements $SetBorderRequestDtoCopyWith<$Res> {
  _$SetBorderRequestDtoCopyWithImpl(this._self, this._then);

  final SetBorderRequestDto _self;
  final $Res Function(SetBorderRequestDto) _then;

/// Create a copy of SetBorderRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? borderId = freezed,}) {
  return _then(SetBorderRequestDto(
borderId: freezed == borderId ? _self.borderId : borderId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SetBorderRequestDto].
extension SetBorderRequestDtoPatterns on SetBorderRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetBorderRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetBorderRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetBorderRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _SetBorderRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetBorderRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _SetBorderRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'border_id')  String? borderId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetBorderRequestDto() when $default != null:
return $default(_that.borderId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'border_id')  String? borderId)  $default,) {final _that = this;
switch (_that) {
case _SetBorderRequestDto():
return $default(_that.borderId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'border_id')  String? borderId)?  $default,) {final _that = this;
switch (_that) {
case _SetBorderRequestDto() when $default != null:
return $default(_that.borderId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetBorderRequestDto implements SetBorderRequestDto {
  const _SetBorderRequestDto({@JsonKey(name: 'border_id') required this.borderId});
  factory _SetBorderRequestDto.fromJson(Map<String, dynamic> json) => _$SetBorderRequestDtoFromJson(json);

@override@JsonKey(name: 'border_id') final  String? borderId;

/// Create a copy of SetBorderRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetBorderRequestDtoCopyWith<_SetBorderRequestDto> get copyWith => __$SetBorderRequestDtoCopyWithImpl<_SetBorderRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetBorderRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetBorderRequestDto&&(identical(other.borderId, borderId) || other.borderId == borderId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,borderId);
}

@override
String toString() {
    return 'SetBorderRequestDto(borderId: $borderId)';
}


}

/// @nodoc
abstract mixin class _$SetBorderRequestDtoCopyWith<$Res> implements $SetBorderRequestDtoCopyWith<$Res> {
  factory _$SetBorderRequestDtoCopyWith(_SetBorderRequestDto value, $Res Function(_SetBorderRequestDto) _then) = __$SetBorderRequestDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'border_id') String? borderId
});




}
/// @nodoc
class __$SetBorderRequestDtoCopyWithImpl<$Res>
    implements _$SetBorderRequestDtoCopyWith<$Res> {
  __$SetBorderRequestDtoCopyWithImpl(this._self, this._then);

  final _SetBorderRequestDto _self;
  final $Res Function(_SetBorderRequestDto) _then;

/// Create a copy of SetBorderRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? borderId = freezed,}) {
  return _then(_SetBorderRequestDto(
borderId: freezed == borderId ? _self.borderId : borderId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SetBorderResponseDto {

@JsonKey(name: 'active_border_id') String? get activeBorderId;
/// Create a copy of SetBorderResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetBorderResponseDtoCopyWith<SetBorderResponseDto> get copyWith => _$SetBorderResponseDtoCopyWithImpl<SetBorderResponseDto>(this as SetBorderResponseDto, _$identity);

  /// Serializes this SetBorderResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SetBorderResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetBorderResponseDto&&(identical(other.activeBorderId, _this.activeBorderId) || other.activeBorderId == _this.activeBorderId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SetBorderResponseDto;
  return Object.hash(runtimeType,_this.activeBorderId);
}

@override
String toString() {
  final _this = this as SetBorderResponseDto;
  return 'SetBorderResponseDto(activeBorderId: ${_this.activeBorderId})';
}


}

/// @nodoc
abstract mixin class $SetBorderResponseDtoCopyWith<$Res>  {
  factory $SetBorderResponseDtoCopyWith(SetBorderResponseDto value, $Res Function(SetBorderResponseDto) _then) = _$SetBorderResponseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'active_border_id') String? activeBorderId
});




}
/// @nodoc
class _$SetBorderResponseDtoCopyWithImpl<$Res>
    implements $SetBorderResponseDtoCopyWith<$Res> {
  _$SetBorderResponseDtoCopyWithImpl(this._self, this._then);

  final SetBorderResponseDto _self;
  final $Res Function(SetBorderResponseDto) _then;

/// Create a copy of SetBorderResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activeBorderId = freezed,}) {
  return _then(SetBorderResponseDto(
activeBorderId: freezed == activeBorderId ? _self.activeBorderId : activeBorderId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SetBorderResponseDto].
extension SetBorderResponseDtoPatterns on SetBorderResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetBorderResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetBorderResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetBorderResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _SetBorderResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetBorderResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _SetBorderResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'active_border_id')  String? activeBorderId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetBorderResponseDto() when $default != null:
return $default(_that.activeBorderId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'active_border_id')  String? activeBorderId)  $default,) {final _that = this;
switch (_that) {
case _SetBorderResponseDto():
return $default(_that.activeBorderId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'active_border_id')  String? activeBorderId)?  $default,) {final _that = this;
switch (_that) {
case _SetBorderResponseDto() when $default != null:
return $default(_that.activeBorderId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetBorderResponseDto implements SetBorderResponseDto {
  const _SetBorderResponseDto({@JsonKey(name: 'active_border_id') this.activeBorderId});
  factory _SetBorderResponseDto.fromJson(Map<String, dynamic> json) => _$SetBorderResponseDtoFromJson(json);

@override@JsonKey(name: 'active_border_id') final  String? activeBorderId;

/// Create a copy of SetBorderResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetBorderResponseDtoCopyWith<_SetBorderResponseDto> get copyWith => __$SetBorderResponseDtoCopyWithImpl<_SetBorderResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetBorderResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetBorderResponseDto&&(identical(other.activeBorderId, activeBorderId) || other.activeBorderId == activeBorderId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,activeBorderId);
}

@override
String toString() {
    return 'SetBorderResponseDto(activeBorderId: $activeBorderId)';
}


}

/// @nodoc
abstract mixin class _$SetBorderResponseDtoCopyWith<$Res> implements $SetBorderResponseDtoCopyWith<$Res> {
  factory _$SetBorderResponseDtoCopyWith(_SetBorderResponseDto value, $Res Function(_SetBorderResponseDto) _then) = __$SetBorderResponseDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'active_border_id') String? activeBorderId
});




}
/// @nodoc
class __$SetBorderResponseDtoCopyWithImpl<$Res>
    implements _$SetBorderResponseDtoCopyWith<$Res> {
  __$SetBorderResponseDtoCopyWithImpl(this._self, this._then);

  final _SetBorderResponseDto _self;
  final $Res Function(_SetBorderResponseDto) _then;

/// Create a copy of SetBorderResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activeBorderId = freezed,}) {
  return _then(_SetBorderResponseDto(
activeBorderId: freezed == activeBorderId ? _self.activeBorderId : activeBorderId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
