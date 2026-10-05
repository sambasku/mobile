// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_profile_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublicProfileDto {

 String get username;@JsonKey(name: 'display_name') String? get displayName; String? get bio; String get role;@JsonKey(name: 'is_verifier') bool get isVerifier;@JsonKey(name: 'joined_at') String get joinedAt;@JsonKey(name: 'avatar_url') String? get avatarUrl; PublicProfileStatsDto get stats;
/// Create a copy of PublicProfileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicProfileDtoCopyWith<PublicProfileDto> get copyWith => _$PublicProfileDtoCopyWithImpl<PublicProfileDto>(this as PublicProfileDto, _$identity);

  /// Serializes this PublicProfileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicProfileDto&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.role, role) || other.role == role)&&(identical(other.isVerifier, isVerifier) || other.isVerifier == isVerifier)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.stats, stats) || other.stats == stats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,displayName,bio,role,isVerifier,joinedAt,avatarUrl,stats);

@override
String toString() {
  return 'PublicProfileDto(username: $username, displayName: $displayName, bio: $bio, role: $role, isVerifier: $isVerifier, joinedAt: $joinedAt, avatarUrl: $avatarUrl, stats: $stats)';
}


}

/// @nodoc
abstract mixin class $PublicProfileDtoCopyWith<$Res>  {
  factory $PublicProfileDtoCopyWith(PublicProfileDto value, $Res Function(PublicProfileDto) _then) = _$PublicProfileDtoCopyWithImpl;
@useResult
$Res call({
 String username,@JsonKey(name: 'display_name') String? displayName, String? bio, String role,@JsonKey(name: 'is_verifier') bool isVerifier,@JsonKey(name: 'joined_at') String joinedAt,@JsonKey(name: 'avatar_url') String? avatarUrl, PublicProfileStatsDto stats
});


$PublicProfileStatsDtoCopyWith<$Res> get stats;

}
/// @nodoc
class _$PublicProfileDtoCopyWithImpl<$Res>
    implements $PublicProfileDtoCopyWith<$Res> {
  _$PublicProfileDtoCopyWithImpl(this._self, this._then);

  final PublicProfileDto _self;
  final $Res Function(PublicProfileDto) _then;

/// Create a copy of PublicProfileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? displayName = freezed,Object? bio = freezed,Object? role = null,Object? isVerifier = null,Object? joinedAt = null,Object? avatarUrl = freezed,Object? stats = null,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isVerifier: null == isVerifier ? _self.isVerifier : isVerifier // ignore: cast_nullable_to_non_nullable
as bool,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as PublicProfileStatsDto,
  ));
}
/// Create a copy of PublicProfileDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PublicProfileStatsDtoCopyWith<$Res> get stats {
  
  return $PublicProfileStatsDtoCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [PublicProfileDto].
extension PublicProfileDtoPatterns on PublicProfileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicProfileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicProfileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicProfileDto value)  $default,){
final _that = this;
switch (_that) {
case _PublicProfileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicProfileDto value)?  $default,){
final _that = this;
switch (_that) {
case _PublicProfileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username, @JsonKey(name: 'display_name')  String? displayName,  String? bio,  String role, @JsonKey(name: 'is_verifier')  bool isVerifier, @JsonKey(name: 'joined_at')  String joinedAt, @JsonKey(name: 'avatar_url')  String? avatarUrl,  PublicProfileStatsDto stats)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicProfileDto() when $default != null:
return $default(_that.username,_that.displayName,_that.bio,_that.role,_that.isVerifier,_that.joinedAt,_that.avatarUrl,_that.stats);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username, @JsonKey(name: 'display_name')  String? displayName,  String? bio,  String role, @JsonKey(name: 'is_verifier')  bool isVerifier, @JsonKey(name: 'joined_at')  String joinedAt, @JsonKey(name: 'avatar_url')  String? avatarUrl,  PublicProfileStatsDto stats)  $default,) {final _that = this;
switch (_that) {
case _PublicProfileDto():
return $default(_that.username,_that.displayName,_that.bio,_that.role,_that.isVerifier,_that.joinedAt,_that.avatarUrl,_that.stats);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username, @JsonKey(name: 'display_name')  String? displayName,  String? bio,  String role, @JsonKey(name: 'is_verifier')  bool isVerifier, @JsonKey(name: 'joined_at')  String joinedAt, @JsonKey(name: 'avatar_url')  String? avatarUrl,  PublicProfileStatsDto stats)?  $default,) {final _that = this;
switch (_that) {
case _PublicProfileDto() when $default != null:
return $default(_that.username,_that.displayName,_that.bio,_that.role,_that.isVerifier,_that.joinedAt,_that.avatarUrl,_that.stats);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublicProfileDto implements PublicProfileDto {
  const _PublicProfileDto({required this.username, @JsonKey(name: 'display_name') this.displayName, this.bio, required this.role, @JsonKey(name: 'is_verifier') this.isVerifier = false, @JsonKey(name: 'joined_at') required this.joinedAt, @JsonKey(name: 'avatar_url') this.avatarUrl, required this.stats});
  factory _PublicProfileDto.fromJson(Map<String, dynamic> json) => _$PublicProfileDtoFromJson(json);

@override final  String username;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override final  String? bio;
@override final  String role;
@override@JsonKey(name: 'is_verifier') final  bool isVerifier;
@override@JsonKey(name: 'joined_at') final  String joinedAt;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override final  PublicProfileStatsDto stats;

/// Create a copy of PublicProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicProfileDtoCopyWith<_PublicProfileDto> get copyWith => __$PublicProfileDtoCopyWithImpl<_PublicProfileDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicProfileDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicProfileDto&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.role, role) || other.role == role)&&(identical(other.isVerifier, isVerifier) || other.isVerifier == isVerifier)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.stats, stats) || other.stats == stats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,displayName,bio,role,isVerifier,joinedAt,avatarUrl,stats);

@override
String toString() {
  return 'PublicProfileDto(username: $username, displayName: $displayName, bio: $bio, role: $role, isVerifier: $isVerifier, joinedAt: $joinedAt, avatarUrl: $avatarUrl, stats: $stats)';
}


}

/// @nodoc
abstract mixin class _$PublicProfileDtoCopyWith<$Res> implements $PublicProfileDtoCopyWith<$Res> {
  factory _$PublicProfileDtoCopyWith(_PublicProfileDto value, $Res Function(_PublicProfileDto) _then) = __$PublicProfileDtoCopyWithImpl;
@override @useResult
$Res call({
 String username,@JsonKey(name: 'display_name') String? displayName, String? bio, String role,@JsonKey(name: 'is_verifier') bool isVerifier,@JsonKey(name: 'joined_at') String joinedAt,@JsonKey(name: 'avatar_url') String? avatarUrl, PublicProfileStatsDto stats
});


@override $PublicProfileStatsDtoCopyWith<$Res> get stats;

}
/// @nodoc
class __$PublicProfileDtoCopyWithImpl<$Res>
    implements _$PublicProfileDtoCopyWith<$Res> {
  __$PublicProfileDtoCopyWithImpl(this._self, this._then);

  final _PublicProfileDto _self;
  final $Res Function(_PublicProfileDto) _then;

/// Create a copy of PublicProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? displayName = freezed,Object? bio = freezed,Object? role = null,Object? isVerifier = null,Object? joinedAt = null,Object? avatarUrl = freezed,Object? stats = null,}) {
  return _then(_PublicProfileDto(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isVerifier: null == isVerifier ? _self.isVerifier : isVerifier // ignore: cast_nullable_to_non_nullable
as bool,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as PublicProfileStatsDto,
  ));
}

/// Create a copy of PublicProfileDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PublicProfileStatsDtoCopyWith<$Res> get stats {
  
  return $PublicProfileStatsDtoCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// @nodoc
mixin _$PublicProfileStatsDto {

@JsonKey(name: 'contributions_approved') int get contributionsApproved;@JsonKey(name: 'verifications_done') int get verificationsDone;@JsonKey(name: 'comments_published') int get commentsPublished;
/// Create a copy of PublicProfileStatsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicProfileStatsDtoCopyWith<PublicProfileStatsDto> get copyWith => _$PublicProfileStatsDtoCopyWithImpl<PublicProfileStatsDto>(this as PublicProfileStatsDto, _$identity);

  /// Serializes this PublicProfileStatsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicProfileStatsDto&&(identical(other.contributionsApproved, contributionsApproved) || other.contributionsApproved == contributionsApproved)&&(identical(other.verificationsDone, verificationsDone) || other.verificationsDone == verificationsDone)&&(identical(other.commentsPublished, commentsPublished) || other.commentsPublished == commentsPublished));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contributionsApproved,verificationsDone,commentsPublished);

@override
String toString() {
  return 'PublicProfileStatsDto(contributionsApproved: $contributionsApproved, verificationsDone: $verificationsDone, commentsPublished: $commentsPublished)';
}


}

/// @nodoc
abstract mixin class $PublicProfileStatsDtoCopyWith<$Res>  {
  factory $PublicProfileStatsDtoCopyWith(PublicProfileStatsDto value, $Res Function(PublicProfileStatsDto) _then) = _$PublicProfileStatsDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'contributions_approved') int contributionsApproved,@JsonKey(name: 'verifications_done') int verificationsDone,@JsonKey(name: 'comments_published') int commentsPublished
});




}
/// @nodoc
class _$PublicProfileStatsDtoCopyWithImpl<$Res>
    implements $PublicProfileStatsDtoCopyWith<$Res> {
  _$PublicProfileStatsDtoCopyWithImpl(this._self, this._then);

  final PublicProfileStatsDto _self;
  final $Res Function(PublicProfileStatsDto) _then;

/// Create a copy of PublicProfileStatsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contributionsApproved = null,Object? verificationsDone = null,Object? commentsPublished = null,}) {
  return _then(_self.copyWith(
contributionsApproved: null == contributionsApproved ? _self.contributionsApproved : contributionsApproved // ignore: cast_nullable_to_non_nullable
as int,verificationsDone: null == verificationsDone ? _self.verificationsDone : verificationsDone // ignore: cast_nullable_to_non_nullable
as int,commentsPublished: null == commentsPublished ? _self.commentsPublished : commentsPublished // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicProfileStatsDto].
extension PublicProfileStatsDtoPatterns on PublicProfileStatsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicProfileStatsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicProfileStatsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicProfileStatsDto value)  $default,){
final _that = this;
switch (_that) {
case _PublicProfileStatsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicProfileStatsDto value)?  $default,){
final _that = this;
switch (_that) {
case _PublicProfileStatsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'contributions_approved')  int contributionsApproved, @JsonKey(name: 'verifications_done')  int verificationsDone, @JsonKey(name: 'comments_published')  int commentsPublished)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicProfileStatsDto() when $default != null:
return $default(_that.contributionsApproved,_that.verificationsDone,_that.commentsPublished);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'contributions_approved')  int contributionsApproved, @JsonKey(name: 'verifications_done')  int verificationsDone, @JsonKey(name: 'comments_published')  int commentsPublished)  $default,) {final _that = this;
switch (_that) {
case _PublicProfileStatsDto():
return $default(_that.contributionsApproved,_that.verificationsDone,_that.commentsPublished);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'contributions_approved')  int contributionsApproved, @JsonKey(name: 'verifications_done')  int verificationsDone, @JsonKey(name: 'comments_published')  int commentsPublished)?  $default,) {final _that = this;
switch (_that) {
case _PublicProfileStatsDto() when $default != null:
return $default(_that.contributionsApproved,_that.verificationsDone,_that.commentsPublished);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublicProfileStatsDto implements PublicProfileStatsDto {
  const _PublicProfileStatsDto({@JsonKey(name: 'contributions_approved') this.contributionsApproved = 0, @JsonKey(name: 'verifications_done') this.verificationsDone = 0, @JsonKey(name: 'comments_published') this.commentsPublished = 0});
  factory _PublicProfileStatsDto.fromJson(Map<String, dynamic> json) => _$PublicProfileStatsDtoFromJson(json);

@override@JsonKey(name: 'contributions_approved') final  int contributionsApproved;
@override@JsonKey(name: 'verifications_done') final  int verificationsDone;
@override@JsonKey(name: 'comments_published') final  int commentsPublished;

/// Create a copy of PublicProfileStatsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicProfileStatsDtoCopyWith<_PublicProfileStatsDto> get copyWith => __$PublicProfileStatsDtoCopyWithImpl<_PublicProfileStatsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicProfileStatsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicProfileStatsDto&&(identical(other.contributionsApproved, contributionsApproved) || other.contributionsApproved == contributionsApproved)&&(identical(other.verificationsDone, verificationsDone) || other.verificationsDone == verificationsDone)&&(identical(other.commentsPublished, commentsPublished) || other.commentsPublished == commentsPublished));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contributionsApproved,verificationsDone,commentsPublished);

@override
String toString() {
  return 'PublicProfileStatsDto(contributionsApproved: $contributionsApproved, verificationsDone: $verificationsDone, commentsPublished: $commentsPublished)';
}


}

/// @nodoc
abstract mixin class _$PublicProfileStatsDtoCopyWith<$Res> implements $PublicProfileStatsDtoCopyWith<$Res> {
  factory _$PublicProfileStatsDtoCopyWith(_PublicProfileStatsDto value, $Res Function(_PublicProfileStatsDto) _then) = __$PublicProfileStatsDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'contributions_approved') int contributionsApproved,@JsonKey(name: 'verifications_done') int verificationsDone,@JsonKey(name: 'comments_published') int commentsPublished
});




}
/// @nodoc
class __$PublicProfileStatsDtoCopyWithImpl<$Res>
    implements _$PublicProfileStatsDtoCopyWith<$Res> {
  __$PublicProfileStatsDtoCopyWithImpl(this._self, this._then);

  final _PublicProfileStatsDto _self;
  final $Res Function(_PublicProfileStatsDto) _then;

/// Create a copy of PublicProfileStatsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contributionsApproved = null,Object? verificationsDone = null,Object? commentsPublished = null,}) {
  return _then(_PublicProfileStatsDto(
contributionsApproved: null == contributionsApproved ? _self.contributionsApproved : contributionsApproved // ignore: cast_nullable_to_non_nullable
as int,verificationsDone: null == verificationsDone ? _self.verificationsDone : verificationsDone // ignore: cast_nullable_to_non_nullable
as int,commentsPublished: null == commentsPublished ? _self.commentsPublished : commentsPublished // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PublicActivityItemDto {

 String get id; String get kind;@JsonKey(name: 'occurred_at') String get occurredAt;@JsonKey(name: 'word_id') String? get wordId; String? get lemma; String get summary;
/// Create a copy of PublicActivityItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicActivityItemDtoCopyWith<PublicActivityItemDto> get copyWith => _$PublicActivityItemDtoCopyWithImpl<PublicActivityItemDto>(this as PublicActivityItemDto, _$identity);

  /// Serializes this PublicActivityItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicActivityItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,occurredAt,wordId,lemma,summary);

@override
String toString() {
  return 'PublicActivityItemDto(id: $id, kind: $kind, occurredAt: $occurredAt, wordId: $wordId, lemma: $lemma, summary: $summary)';
}


}

/// @nodoc
abstract mixin class $PublicActivityItemDtoCopyWith<$Res>  {
  factory $PublicActivityItemDtoCopyWith(PublicActivityItemDto value, $Res Function(PublicActivityItemDto) _then) = _$PublicActivityItemDtoCopyWithImpl;
@useResult
$Res call({
 String id, String kind,@JsonKey(name: 'occurred_at') String occurredAt,@JsonKey(name: 'word_id') String? wordId, String? lemma, String summary
});




}
/// @nodoc
class _$PublicActivityItemDtoCopyWithImpl<$Res>
    implements $PublicActivityItemDtoCopyWith<$Res> {
  _$PublicActivityItemDtoCopyWithImpl(this._self, this._then);

  final PublicActivityItemDto _self;
  final $Res Function(PublicActivityItemDto) _then;

/// Create a copy of PublicActivityItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? occurredAt = null,Object? wordId = freezed,Object? lemma = freezed,Object? summary = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,wordId: freezed == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String?,lemma: freezed == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String?,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicActivityItemDto].
extension PublicActivityItemDtoPatterns on PublicActivityItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicActivityItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicActivityItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicActivityItemDto value)  $default,){
final _that = this;
switch (_that) {
case _PublicActivityItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicActivityItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _PublicActivityItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String kind, @JsonKey(name: 'occurred_at')  String occurredAt, @JsonKey(name: 'word_id')  String? wordId,  String? lemma,  String summary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicActivityItemDto() when $default != null:
return $default(_that.id,_that.kind,_that.occurredAt,_that.wordId,_that.lemma,_that.summary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String kind, @JsonKey(name: 'occurred_at')  String occurredAt, @JsonKey(name: 'word_id')  String? wordId,  String? lemma,  String summary)  $default,) {final _that = this;
switch (_that) {
case _PublicActivityItemDto():
return $default(_that.id,_that.kind,_that.occurredAt,_that.wordId,_that.lemma,_that.summary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String kind, @JsonKey(name: 'occurred_at')  String occurredAt, @JsonKey(name: 'word_id')  String? wordId,  String? lemma,  String summary)?  $default,) {final _that = this;
switch (_that) {
case _PublicActivityItemDto() when $default != null:
return $default(_that.id,_that.kind,_that.occurredAt,_that.wordId,_that.lemma,_that.summary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublicActivityItemDto implements PublicActivityItemDto {
  const _PublicActivityItemDto({required this.id, required this.kind, @JsonKey(name: 'occurred_at') required this.occurredAt, @JsonKey(name: 'word_id') this.wordId, this.lemma, required this.summary});
  factory _PublicActivityItemDto.fromJson(Map<String, dynamic> json) => _$PublicActivityItemDtoFromJson(json);

@override final  String id;
@override final  String kind;
@override@JsonKey(name: 'occurred_at') final  String occurredAt;
@override@JsonKey(name: 'word_id') final  String? wordId;
@override final  String? lemma;
@override final  String summary;

/// Create a copy of PublicActivityItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicActivityItemDtoCopyWith<_PublicActivityItemDto> get copyWith => __$PublicActivityItemDtoCopyWithImpl<_PublicActivityItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicActivityItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicActivityItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,occurredAt,wordId,lemma,summary);

@override
String toString() {
  return 'PublicActivityItemDto(id: $id, kind: $kind, occurredAt: $occurredAt, wordId: $wordId, lemma: $lemma, summary: $summary)';
}


}

/// @nodoc
abstract mixin class _$PublicActivityItemDtoCopyWith<$Res> implements $PublicActivityItemDtoCopyWith<$Res> {
  factory _$PublicActivityItemDtoCopyWith(_PublicActivityItemDto value, $Res Function(_PublicActivityItemDto) _then) = __$PublicActivityItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String kind,@JsonKey(name: 'occurred_at') String occurredAt,@JsonKey(name: 'word_id') String? wordId, String? lemma, String summary
});




}
/// @nodoc
class __$PublicActivityItemDtoCopyWithImpl<$Res>
    implements _$PublicActivityItemDtoCopyWith<$Res> {
  __$PublicActivityItemDtoCopyWithImpl(this._self, this._then);

  final _PublicActivityItemDto _self;
  final $Res Function(_PublicActivityItemDto) _then;

/// Create a copy of PublicActivityItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? occurredAt = null,Object? wordId = freezed,Object? lemma = freezed,Object? summary = null,}) {
  return _then(_PublicActivityItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,wordId: freezed == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String?,lemma: freezed == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String?,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PublicActivityMetaDto {

 int get limit;@JsonKey(name: 'next_cursor') String? get nextCursor;@JsonKey(name: 'has_more') bool get hasMore;
/// Create a copy of PublicActivityMetaDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicActivityMetaDtoCopyWith<PublicActivityMetaDto> get copyWith => _$PublicActivityMetaDtoCopyWithImpl<PublicActivityMetaDto>(this as PublicActivityMetaDto, _$identity);

  /// Serializes this PublicActivityMetaDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicActivityMetaDto&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,limit,nextCursor,hasMore);

@override
String toString() {
  return 'PublicActivityMetaDto(limit: $limit, nextCursor: $nextCursor, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $PublicActivityMetaDtoCopyWith<$Res>  {
  factory $PublicActivityMetaDtoCopyWith(PublicActivityMetaDto value, $Res Function(PublicActivityMetaDto) _then) = _$PublicActivityMetaDtoCopyWithImpl;
@useResult
$Res call({
 int limit,@JsonKey(name: 'next_cursor') String? nextCursor,@JsonKey(name: 'has_more') bool hasMore
});




}
/// @nodoc
class _$PublicActivityMetaDtoCopyWithImpl<$Res>
    implements $PublicActivityMetaDtoCopyWith<$Res> {
  _$PublicActivityMetaDtoCopyWithImpl(this._self, this._then);

  final PublicActivityMetaDto _self;
  final $Res Function(PublicActivityMetaDto) _then;

/// Create a copy of PublicActivityMetaDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? limit = null,Object? nextCursor = freezed,Object? hasMore = null,}) {
  return _then(_self.copyWith(
limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicActivityMetaDto].
extension PublicActivityMetaDtoPatterns on PublicActivityMetaDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicActivityMetaDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicActivityMetaDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicActivityMetaDto value)  $default,){
final _that = this;
switch (_that) {
case _PublicActivityMetaDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicActivityMetaDto value)?  $default,){
final _that = this;
switch (_that) {
case _PublicActivityMetaDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int limit, @JsonKey(name: 'next_cursor')  String? nextCursor, @JsonKey(name: 'has_more')  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicActivityMetaDto() when $default != null:
return $default(_that.limit,_that.nextCursor,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int limit, @JsonKey(name: 'next_cursor')  String? nextCursor, @JsonKey(name: 'has_more')  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _PublicActivityMetaDto():
return $default(_that.limit,_that.nextCursor,_that.hasMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int limit, @JsonKey(name: 'next_cursor')  String? nextCursor, @JsonKey(name: 'has_more')  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _PublicActivityMetaDto() when $default != null:
return $default(_that.limit,_that.nextCursor,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublicActivityMetaDto implements PublicActivityMetaDto {
  const _PublicActivityMetaDto({required this.limit, @JsonKey(name: 'next_cursor') this.nextCursor, @JsonKey(name: 'has_more') required this.hasMore});
  factory _PublicActivityMetaDto.fromJson(Map<String, dynamic> json) => _$PublicActivityMetaDtoFromJson(json);

@override final  int limit;
@override@JsonKey(name: 'next_cursor') final  String? nextCursor;
@override@JsonKey(name: 'has_more') final  bool hasMore;

/// Create a copy of PublicActivityMetaDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicActivityMetaDtoCopyWith<_PublicActivityMetaDto> get copyWith => __$PublicActivityMetaDtoCopyWithImpl<_PublicActivityMetaDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicActivityMetaDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicActivityMetaDto&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,limit,nextCursor,hasMore);

@override
String toString() {
  return 'PublicActivityMetaDto(limit: $limit, nextCursor: $nextCursor, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$PublicActivityMetaDtoCopyWith<$Res> implements $PublicActivityMetaDtoCopyWith<$Res> {
  factory _$PublicActivityMetaDtoCopyWith(_PublicActivityMetaDto value, $Res Function(_PublicActivityMetaDto) _then) = __$PublicActivityMetaDtoCopyWithImpl;
@override @useResult
$Res call({
 int limit,@JsonKey(name: 'next_cursor') String? nextCursor,@JsonKey(name: 'has_more') bool hasMore
});




}
/// @nodoc
class __$PublicActivityMetaDtoCopyWithImpl<$Res>
    implements _$PublicActivityMetaDtoCopyWith<$Res> {
  __$PublicActivityMetaDtoCopyWithImpl(this._self, this._then);

  final _PublicActivityMetaDto _self;
  final $Res Function(_PublicActivityMetaDto) _then;

/// Create a copy of PublicActivityMetaDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? limit = null,Object? nextCursor = freezed,Object? hasMore = null,}) {
  return _then(_PublicActivityMetaDto(
limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PublicActivityDto {

 List<PublicActivityItemDto> get items; PublicActivityMetaDto? get meta;
/// Create a copy of PublicActivityDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicActivityDtoCopyWith<PublicActivityDto> get copyWith => _$PublicActivityDtoCopyWithImpl<PublicActivityDto>(this as PublicActivityDto, _$identity);

  /// Serializes this PublicActivityDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicActivityDto&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.meta, meta) || other.meta == meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),meta);

@override
String toString() {
  return 'PublicActivityDto(items: $items, meta: $meta)';
}


}

/// @nodoc
abstract mixin class $PublicActivityDtoCopyWith<$Res>  {
  factory $PublicActivityDtoCopyWith(PublicActivityDto value, $Res Function(PublicActivityDto) _then) = _$PublicActivityDtoCopyWithImpl;
@useResult
$Res call({
 List<PublicActivityItemDto> items, PublicActivityMetaDto? meta
});


$PublicActivityMetaDtoCopyWith<$Res>? get meta;

}
/// @nodoc
class _$PublicActivityDtoCopyWithImpl<$Res>
    implements $PublicActivityDtoCopyWith<$Res> {
  _$PublicActivityDtoCopyWithImpl(this._self, this._then);

  final PublicActivityDto _self;
  final $Res Function(PublicActivityDto) _then;

/// Create a copy of PublicActivityDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? meta = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PublicActivityItemDto>,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as PublicActivityMetaDto?,
  ));
}
/// Create a copy of PublicActivityDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PublicActivityMetaDtoCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $PublicActivityMetaDtoCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// Adds pattern-matching-related methods to [PublicActivityDto].
extension PublicActivityDtoPatterns on PublicActivityDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicActivityDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicActivityDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicActivityDto value)  $default,){
final _that = this;
switch (_that) {
case _PublicActivityDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicActivityDto value)?  $default,){
final _that = this;
switch (_that) {
case _PublicActivityDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PublicActivityItemDto> items,  PublicActivityMetaDto? meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicActivityDto() when $default != null:
return $default(_that.items,_that.meta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PublicActivityItemDto> items,  PublicActivityMetaDto? meta)  $default,) {final _that = this;
switch (_that) {
case _PublicActivityDto():
return $default(_that.items,_that.meta);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PublicActivityItemDto> items,  PublicActivityMetaDto? meta)?  $default,) {final _that = this;
switch (_that) {
case _PublicActivityDto() when $default != null:
return $default(_that.items,_that.meta);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublicActivityDto implements PublicActivityDto {
  const _PublicActivityDto({final  List<PublicActivityItemDto> items = const <PublicActivityItemDto>[], this.meta}): _items = items;
  factory _PublicActivityDto.fromJson(Map<String, dynamic> json) => _$PublicActivityDtoFromJson(json);

 final  List<PublicActivityItemDto> _items;
@override@JsonKey() List<PublicActivityItemDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  PublicActivityMetaDto? meta;

/// Create a copy of PublicActivityDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicActivityDtoCopyWith<_PublicActivityDto> get copyWith => __$PublicActivityDtoCopyWithImpl<_PublicActivityDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicActivityDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicActivityDto&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.meta, meta) || other.meta == meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),meta);

@override
String toString() {
  return 'PublicActivityDto(items: $items, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$PublicActivityDtoCopyWith<$Res> implements $PublicActivityDtoCopyWith<$Res> {
  factory _$PublicActivityDtoCopyWith(_PublicActivityDto value, $Res Function(_PublicActivityDto) _then) = __$PublicActivityDtoCopyWithImpl;
@override @useResult
$Res call({
 List<PublicActivityItemDto> items, PublicActivityMetaDto? meta
});


@override $PublicActivityMetaDtoCopyWith<$Res>? get meta;

}
/// @nodoc
class __$PublicActivityDtoCopyWithImpl<$Res>
    implements _$PublicActivityDtoCopyWith<$Res> {
  __$PublicActivityDtoCopyWithImpl(this._self, this._then);

  final _PublicActivityDto _self;
  final $Res Function(_PublicActivityDto) _then;

/// Create a copy of PublicActivityDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? meta = freezed,}) {
  return _then(_PublicActivityDto(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PublicActivityItemDto>,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as PublicActivityMetaDto?,
  ));
}

/// Create a copy of PublicActivityDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PublicActivityMetaDtoCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $PublicActivityMetaDtoCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// @nodoc
mixin _$MentionSuggestItemDto {

 String get id; String get username;@JsonKey(name: 'display_name') String? get displayName;@JsonKey(name: 'avatar_url') String? get avatarUrl;
/// Create a copy of MentionSuggestItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MentionSuggestItemDtoCopyWith<MentionSuggestItemDto> get copyWith => _$MentionSuggestItemDtoCopyWithImpl<MentionSuggestItemDto>(this as MentionSuggestItemDto, _$identity);

  /// Serializes this MentionSuggestItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MentionSuggestItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,displayName,avatarUrl);

@override
String toString() {
  return 'MentionSuggestItemDto(id: $id, username: $username, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $MentionSuggestItemDtoCopyWith<$Res>  {
  factory $MentionSuggestItemDtoCopyWith(MentionSuggestItemDto value, $Res Function(MentionSuggestItemDto) _then) = _$MentionSuggestItemDtoCopyWithImpl;
@useResult
$Res call({
 String id, String username,@JsonKey(name: 'display_name') String? displayName,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class _$MentionSuggestItemDtoCopyWithImpl<$Res>
    implements $MentionSuggestItemDtoCopyWith<$Res> {
  _$MentionSuggestItemDtoCopyWithImpl(this._self, this._then);

  final MentionSuggestItemDto _self;
  final $Res Function(MentionSuggestItemDto) _then;

/// Create a copy of MentionSuggestItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? displayName = freezed,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MentionSuggestItemDto].
extension MentionSuggestItemDtoPatterns on MentionSuggestItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MentionSuggestItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MentionSuggestItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MentionSuggestItemDto value)  $default,){
final _that = this;
switch (_that) {
case _MentionSuggestItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MentionSuggestItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _MentionSuggestItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MentionSuggestItemDto() when $default != null:
return $default(_that.id,_that.username,_that.displayName,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _MentionSuggestItemDto():
return $default(_that.id,_that.username,_that.displayName,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _MentionSuggestItemDto() when $default != null:
return $default(_that.id,_that.username,_that.displayName,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MentionSuggestItemDto implements MentionSuggestItemDto {
  const _MentionSuggestItemDto({required this.id, required this.username, @JsonKey(name: 'display_name') this.displayName, @JsonKey(name: 'avatar_url') this.avatarUrl});
  factory _MentionSuggestItemDto.fromJson(Map<String, dynamic> json) => _$MentionSuggestItemDtoFromJson(json);

@override final  String id;
@override final  String username;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;

/// Create a copy of MentionSuggestItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MentionSuggestItemDtoCopyWith<_MentionSuggestItemDto> get copyWith => __$MentionSuggestItemDtoCopyWithImpl<_MentionSuggestItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MentionSuggestItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MentionSuggestItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,displayName,avatarUrl);

@override
String toString() {
  return 'MentionSuggestItemDto(id: $id, username: $username, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$MentionSuggestItemDtoCopyWith<$Res> implements $MentionSuggestItemDtoCopyWith<$Res> {
  factory _$MentionSuggestItemDtoCopyWith(_MentionSuggestItemDto value, $Res Function(_MentionSuggestItemDto) _then) = __$MentionSuggestItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String username,@JsonKey(name: 'display_name') String? displayName,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class __$MentionSuggestItemDtoCopyWithImpl<$Res>
    implements _$MentionSuggestItemDtoCopyWith<$Res> {
  __$MentionSuggestItemDtoCopyWithImpl(this._self, this._then);

  final _MentionSuggestItemDto _self;
  final $Res Function(_MentionSuggestItemDto) _then;

/// Create a copy of MentionSuggestItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? displayName = freezed,Object? avatarUrl = freezed,}) {
  return _then(_MentionSuggestItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MentionSuggestDto {

 List<MentionSuggestItemDto> get items;
/// Create a copy of MentionSuggestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MentionSuggestDtoCopyWith<MentionSuggestDto> get copyWith => _$MentionSuggestDtoCopyWithImpl<MentionSuggestDto>(this as MentionSuggestDto, _$identity);

  /// Serializes this MentionSuggestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MentionSuggestDto&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'MentionSuggestDto(items: $items)';
}


}

/// @nodoc
abstract mixin class $MentionSuggestDtoCopyWith<$Res>  {
  factory $MentionSuggestDtoCopyWith(MentionSuggestDto value, $Res Function(MentionSuggestDto) _then) = _$MentionSuggestDtoCopyWithImpl;
@useResult
$Res call({
 List<MentionSuggestItemDto> items
});




}
/// @nodoc
class _$MentionSuggestDtoCopyWithImpl<$Res>
    implements $MentionSuggestDtoCopyWith<$Res> {
  _$MentionSuggestDtoCopyWithImpl(this._self, this._then);

  final MentionSuggestDto _self;
  final $Res Function(MentionSuggestDto) _then;

/// Create a copy of MentionSuggestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MentionSuggestItemDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [MentionSuggestDto].
extension MentionSuggestDtoPatterns on MentionSuggestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MentionSuggestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MentionSuggestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MentionSuggestDto value)  $default,){
final _that = this;
switch (_that) {
case _MentionSuggestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MentionSuggestDto value)?  $default,){
final _that = this;
switch (_that) {
case _MentionSuggestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MentionSuggestItemDto> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MentionSuggestDto() when $default != null:
return $default(_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MentionSuggestItemDto> items)  $default,) {final _that = this;
switch (_that) {
case _MentionSuggestDto():
return $default(_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MentionSuggestItemDto> items)?  $default,) {final _that = this;
switch (_that) {
case _MentionSuggestDto() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MentionSuggestDto implements MentionSuggestDto {
  const _MentionSuggestDto({final  List<MentionSuggestItemDto> items = const <MentionSuggestItemDto>[]}): _items = items;
  factory _MentionSuggestDto.fromJson(Map<String, dynamic> json) => _$MentionSuggestDtoFromJson(json);

 final  List<MentionSuggestItemDto> _items;
@override@JsonKey() List<MentionSuggestItemDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of MentionSuggestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MentionSuggestDtoCopyWith<_MentionSuggestDto> get copyWith => __$MentionSuggestDtoCopyWithImpl<_MentionSuggestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MentionSuggestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MentionSuggestDto&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'MentionSuggestDto(items: $items)';
}


}

/// @nodoc
abstract mixin class _$MentionSuggestDtoCopyWith<$Res> implements $MentionSuggestDtoCopyWith<$Res> {
  factory _$MentionSuggestDtoCopyWith(_MentionSuggestDto value, $Res Function(_MentionSuggestDto) _then) = __$MentionSuggestDtoCopyWithImpl;
@override @useResult
$Res call({
 List<MentionSuggestItemDto> items
});




}
/// @nodoc
class __$MentionSuggestDtoCopyWithImpl<$Res>
    implements _$MentionSuggestDtoCopyWith<$Res> {
  __$MentionSuggestDtoCopyWithImpl(this._self, this._then);

  final _MentionSuggestDto _self;
  final $Res Function(_MentionSuggestDto) _then;

/// Create a copy of MentionSuggestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_MentionSuggestDto(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MentionSuggestItemDto>,
  ));
}


}

// dart format on
