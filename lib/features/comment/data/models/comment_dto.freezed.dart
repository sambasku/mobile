// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommentDto {

 String get id;@JsonKey(name: 'word_id') String get wordId;@JsonKey(name: 'user_id') String get userId; String? get username;@JsonKey(name: 'display_name') String? get displayName;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'is_verifier') bool get isVerifier; String? get body;@JsonKey(name: 'audio_url') String? get audioUrl;@JsonKey(name: 'audio_mime_type') String? get audioMimeType;@JsonKey(name: 'audio_duration_ms') int? get audioDurationMs;@JsonKey(name: 'created_at') String? get createdAt; int get upvotes; int get downvotes; String? get status;
/// Create a copy of CommentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentDtoCopyWith<CommentDto> get copyWith => _$CommentDtoCopyWithImpl<CommentDto>(this as CommentDto, _$identity);

  /// Serializes this CommentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isVerifier, isVerifier) || other.isVerifier == isVerifier)&&(identical(other.body, body) || other.body == body)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.audioMimeType, audioMimeType) || other.audioMimeType == audioMimeType)&&(identical(other.audioDurationMs, audioDurationMs) || other.audioDurationMs == audioDurationMs)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,wordId,userId,username,displayName,avatarUrl,isVerifier,body,audioUrl,audioMimeType,audioDurationMs,createdAt,upvotes,downvotes,status);

@override
String toString() {
  return 'CommentDto(id: $id, wordId: $wordId, userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, isVerifier: $isVerifier, body: $body, audioUrl: $audioUrl, audioMimeType: $audioMimeType, audioDurationMs: $audioDurationMs, createdAt: $createdAt, upvotes: $upvotes, downvotes: $downvotes, status: $status)';
}


}

/// @nodoc
abstract mixin class $CommentDtoCopyWith<$Res>  {
  factory $CommentDtoCopyWith(CommentDto value, $Res Function(CommentDto) _then) = _$CommentDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'word_id') String wordId,@JsonKey(name: 'user_id') String userId, String? username,@JsonKey(name: 'display_name') String? displayName,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'is_verifier') bool isVerifier, String? body,@JsonKey(name: 'audio_url') String? audioUrl,@JsonKey(name: 'audio_mime_type') String? audioMimeType,@JsonKey(name: 'audio_duration_ms') int? audioDurationMs,@JsonKey(name: 'created_at') String? createdAt, int upvotes, int downvotes, String? status
});




}
/// @nodoc
class _$CommentDtoCopyWithImpl<$Res>
    implements $CommentDtoCopyWith<$Res> {
  _$CommentDtoCopyWithImpl(this._self, this._then);

  final CommentDto _self;
  final $Res Function(CommentDto) _then;

/// Create a copy of CommentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? wordId = null,Object? userId = null,Object? username = freezed,Object? displayName = freezed,Object? avatarUrl = freezed,Object? isVerifier = null,Object? body = freezed,Object? audioUrl = freezed,Object? audioMimeType = freezed,Object? audioDurationMs = freezed,Object? createdAt = freezed,Object? upvotes = null,Object? downvotes = null,Object? status = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isVerifier: null == isVerifier ? _self.isVerifier : isVerifier // ignore: cast_nullable_to_non_nullable
as bool,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,audioMimeType: freezed == audioMimeType ? _self.audioMimeType : audioMimeType // ignore: cast_nullable_to_non_nullable
as String?,audioDurationMs: freezed == audioDurationMs ? _self.audioDurationMs : audioDurationMs // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentDto].
extension CommentDtoPatterns on CommentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentDto value)  $default,){
final _that = this;
switch (_that) {
case _CommentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentDto value)?  $default,){
final _that = this;
switch (_that) {
case _CommentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'word_id')  String wordId, @JsonKey(name: 'user_id')  String userId,  String? username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_verifier')  bool isVerifier,  String? body, @JsonKey(name: 'audio_url')  String? audioUrl, @JsonKey(name: 'audio_mime_type')  String? audioMimeType, @JsonKey(name: 'audio_duration_ms')  int? audioDurationMs, @JsonKey(name: 'created_at')  String? createdAt,  int upvotes,  int downvotes,  String? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentDto() when $default != null:
return $default(_that.id,_that.wordId,_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.isVerifier,_that.body,_that.audioUrl,_that.audioMimeType,_that.audioDurationMs,_that.createdAt,_that.upvotes,_that.downvotes,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'word_id')  String wordId, @JsonKey(name: 'user_id')  String userId,  String? username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_verifier')  bool isVerifier,  String? body, @JsonKey(name: 'audio_url')  String? audioUrl, @JsonKey(name: 'audio_mime_type')  String? audioMimeType, @JsonKey(name: 'audio_duration_ms')  int? audioDurationMs, @JsonKey(name: 'created_at')  String? createdAt,  int upvotes,  int downvotes,  String? status)  $default,) {final _that = this;
switch (_that) {
case _CommentDto():
return $default(_that.id,_that.wordId,_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.isVerifier,_that.body,_that.audioUrl,_that.audioMimeType,_that.audioDurationMs,_that.createdAt,_that.upvotes,_that.downvotes,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'word_id')  String wordId, @JsonKey(name: 'user_id')  String userId,  String? username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_verifier')  bool isVerifier,  String? body, @JsonKey(name: 'audio_url')  String? audioUrl, @JsonKey(name: 'audio_mime_type')  String? audioMimeType, @JsonKey(name: 'audio_duration_ms')  int? audioDurationMs, @JsonKey(name: 'created_at')  String? createdAt,  int upvotes,  int downvotes,  String? status)?  $default,) {final _that = this;
switch (_that) {
case _CommentDto() when $default != null:
return $default(_that.id,_that.wordId,_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.isVerifier,_that.body,_that.audioUrl,_that.audioMimeType,_that.audioDurationMs,_that.createdAt,_that.upvotes,_that.downvotes,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommentDto implements CommentDto {
  const _CommentDto({required this.id, @JsonKey(name: 'word_id') required this.wordId, @JsonKey(name: 'user_id') required this.userId, this.username, @JsonKey(name: 'display_name') this.displayName, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'is_verifier') this.isVerifier = false, this.body, @JsonKey(name: 'audio_url') this.audioUrl, @JsonKey(name: 'audio_mime_type') this.audioMimeType, @JsonKey(name: 'audio_duration_ms') this.audioDurationMs, @JsonKey(name: 'created_at') this.createdAt, this.upvotes = 0, this.downvotes = 0, this.status});
  factory _CommentDto.fromJson(Map<String, dynamic> json) => _$CommentDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'word_id') final  String wordId;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String? username;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'is_verifier') final  bool isVerifier;
@override final  String? body;
@override@JsonKey(name: 'audio_url') final  String? audioUrl;
@override@JsonKey(name: 'audio_mime_type') final  String? audioMimeType;
@override@JsonKey(name: 'audio_duration_ms') final  int? audioDurationMs;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey() final  int upvotes;
@override@JsonKey() final  int downvotes;
@override final  String? status;

/// Create a copy of CommentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentDtoCopyWith<_CommentDto> get copyWith => __$CommentDtoCopyWithImpl<_CommentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isVerifier, isVerifier) || other.isVerifier == isVerifier)&&(identical(other.body, body) || other.body == body)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.audioMimeType, audioMimeType) || other.audioMimeType == audioMimeType)&&(identical(other.audioDurationMs, audioDurationMs) || other.audioDurationMs == audioDurationMs)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,wordId,userId,username,displayName,avatarUrl,isVerifier,body,audioUrl,audioMimeType,audioDurationMs,createdAt,upvotes,downvotes,status);

@override
String toString() {
  return 'CommentDto(id: $id, wordId: $wordId, userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, isVerifier: $isVerifier, body: $body, audioUrl: $audioUrl, audioMimeType: $audioMimeType, audioDurationMs: $audioDurationMs, createdAt: $createdAt, upvotes: $upvotes, downvotes: $downvotes, status: $status)';
}


}

/// @nodoc
abstract mixin class _$CommentDtoCopyWith<$Res> implements $CommentDtoCopyWith<$Res> {
  factory _$CommentDtoCopyWith(_CommentDto value, $Res Function(_CommentDto) _then) = __$CommentDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'word_id') String wordId,@JsonKey(name: 'user_id') String userId, String? username,@JsonKey(name: 'display_name') String? displayName,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'is_verifier') bool isVerifier, String? body,@JsonKey(name: 'audio_url') String? audioUrl,@JsonKey(name: 'audio_mime_type') String? audioMimeType,@JsonKey(name: 'audio_duration_ms') int? audioDurationMs,@JsonKey(name: 'created_at') String? createdAt, int upvotes, int downvotes, String? status
});




}
/// @nodoc
class __$CommentDtoCopyWithImpl<$Res>
    implements _$CommentDtoCopyWith<$Res> {
  __$CommentDtoCopyWithImpl(this._self, this._then);

  final _CommentDto _self;
  final $Res Function(_CommentDto) _then;

/// Create a copy of CommentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? wordId = null,Object? userId = null,Object? username = freezed,Object? displayName = freezed,Object? avatarUrl = freezed,Object? isVerifier = null,Object? body = freezed,Object? audioUrl = freezed,Object? audioMimeType = freezed,Object? audioDurationMs = freezed,Object? createdAt = freezed,Object? upvotes = null,Object? downvotes = null,Object? status = freezed,}) {
  return _then(_CommentDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isVerifier: null == isVerifier ? _self.isVerifier : isVerifier // ignore: cast_nullable_to_non_nullable
as bool,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,audioMimeType: freezed == audioMimeType ? _self.audioMimeType : audioMimeType // ignore: cast_nullable_to_non_nullable
as String?,audioDurationMs: freezed == audioDurationMs ? _self.audioDurationMs : audioDurationMs // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
