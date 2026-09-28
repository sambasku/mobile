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

 String get kind;@JsonKey(name: 'occurred_at') String get occurredAt;@JsonKey(name: 'word_id') String? get wordId; String? get lemma; String get summary;
/// Create a copy of PublicActivityItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicActivityItemDtoCopyWith<PublicActivityItemDto> get copyWith => _$PublicActivityItemDtoCopyWithImpl<PublicActivityItemDto>(this as PublicActivityItemDto, _$identity);

  /// Serializes this PublicActivityItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicActivityItemDto&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,occurredAt,wordId,lemma,summary);

@override
String toString() {
  return 'PublicActivityItemDto(kind: $kind, occurredAt: $occurredAt, wordId: $wordId, lemma: $lemma, summary: $summary)';
}


}

/// @nodoc
abstract mixin class $PublicActivityItemDtoCopyWith<$Res>  {
  factory $PublicActivityItemDtoCopyWith(PublicActivityItemDto value, $Res Function(PublicActivityItemDto) _then) = _$PublicActivityItemDtoCopyWithImpl;
@useResult
$Res call({
 String kind,@JsonKey(name: 'occurred_at') String occurredAt,@JsonKey(name: 'word_id') String? wordId, String? lemma, String summary
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
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? occurredAt = null,Object? wordId = freezed,Object? lemma = freezed,Object? summary = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String kind, @JsonKey(name: 'occurred_at')  String occurredAt, @JsonKey(name: 'word_id')  String? wordId,  String? lemma,  String summary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicActivityItemDto() when $default != null:
return $default(_that.kind,_that.occurredAt,_that.wordId,_that.lemma,_that.summary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String kind, @JsonKey(name: 'occurred_at')  String occurredAt, @JsonKey(name: 'word_id')  String? wordId,  String? lemma,  String summary)  $default,) {final _that = this;
switch (_that) {
case _PublicActivityItemDto():
return $default(_that.kind,_that.occurredAt,_that.wordId,_that.lemma,_that.summary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String kind, @JsonKey(name: 'occurred_at')  String occurredAt, @JsonKey(name: 'word_id')  String? wordId,  String? lemma,  String summary)?  $default,) {final _that = this;
switch (_that) {
case _PublicActivityItemDto() when $default != null:
return $default(_that.kind,_that.occurredAt,_that.wordId,_that.lemma,_that.summary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublicActivityItemDto implements PublicActivityItemDto {
  const _PublicActivityItemDto({required this.kind, @JsonKey(name: 'occurred_at') required this.occurredAt, @JsonKey(name: 'word_id') this.wordId, this.lemma, required this.summary});
  factory _PublicActivityItemDto.fromJson(Map<String, dynamic> json) => _$PublicActivityItemDtoFromJson(json);

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicActivityItemDto&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,occurredAt,wordId,lemma,summary);

@override
String toString() {
  return 'PublicActivityItemDto(kind: $kind, occurredAt: $occurredAt, wordId: $wordId, lemma: $lemma, summary: $summary)';
}


}

/// @nodoc
abstract mixin class _$PublicActivityItemDtoCopyWith<$Res> implements $PublicActivityItemDtoCopyWith<$Res> {
  factory _$PublicActivityItemDtoCopyWith(_PublicActivityItemDto value, $Res Function(_PublicActivityItemDto) _then) = __$PublicActivityItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String kind,@JsonKey(name: 'occurred_at') String occurredAt,@JsonKey(name: 'word_id') String? wordId, String? lemma, String summary
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
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? occurredAt = null,Object? wordId = freezed,Object? lemma = freezed,Object? summary = null,}) {
  return _then(_PublicActivityItemDto(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,wordId: freezed == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String?,lemma: freezed == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String?,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PublicActivityDto {

 List<PublicActivityItemDto> get items;
/// Create a copy of PublicActivityDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicActivityDtoCopyWith<PublicActivityDto> get copyWith => _$PublicActivityDtoCopyWithImpl<PublicActivityDto>(this as PublicActivityDto, _$identity);

  /// Serializes this PublicActivityDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicActivityDto&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'PublicActivityDto(items: $items)';
}


}

/// @nodoc
abstract mixin class $PublicActivityDtoCopyWith<$Res>  {
  factory $PublicActivityDtoCopyWith(PublicActivityDto value, $Res Function(PublicActivityDto) _then) = _$PublicActivityDtoCopyWithImpl;
@useResult
$Res call({
 List<PublicActivityItemDto> items
});




}
/// @nodoc
class _$PublicActivityDtoCopyWithImpl<$Res>
    implements $PublicActivityDtoCopyWith<$Res> {
  _$PublicActivityDtoCopyWithImpl(this._self, this._then);

  final PublicActivityDto _self;
  final $Res Function(PublicActivityDto) _then;

/// Create a copy of PublicActivityDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PublicActivityItemDto>,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PublicActivityItemDto> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicActivityDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PublicActivityItemDto> items)  $default,) {final _that = this;
switch (_that) {
case _PublicActivityDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PublicActivityItemDto> items)?  $default,) {final _that = this;
switch (_that) {
case _PublicActivityDto() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _PublicActivityDto implements PublicActivityDto {
  const _PublicActivityDto({final  List<PublicActivityItemDto> items = const []}): _items = items;
  factory _PublicActivityDto.fromJson(Map<String, dynamic> json) => _$PublicActivityDtoFromJson(json);

 final  List<PublicActivityItemDto> _items;
@override@JsonKey() List<PublicActivityItemDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicActivityDto&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'PublicActivityDto(items: $items)';
}


}

/// @nodoc
abstract mixin class _$PublicActivityDtoCopyWith<$Res> implements $PublicActivityDtoCopyWith<$Res> {
  factory _$PublicActivityDtoCopyWith(_PublicActivityDto value, $Res Function(_PublicActivityDto) _then) = __$PublicActivityDtoCopyWithImpl;
@override @useResult
$Res call({
 List<PublicActivityItemDto> items
});




}
/// @nodoc
class __$PublicActivityDtoCopyWithImpl<$Res>
    implements _$PublicActivityDtoCopyWith<$Res> {
  __$PublicActivityDtoCopyWithImpl(this._self, this._then);

  final _PublicActivityDto _self;
  final $Res Function(_PublicActivityDto) _then;

/// Create a copy of PublicActivityDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_PublicActivityDto(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PublicActivityItemDto>,
  ));
}


}

// dart format on
