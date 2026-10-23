// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vote_toggle_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoteToggleResponseDto {

@JsonKey(name: 'target_type') String get targetType;@JsonKey(name: 'target_id') String get targetId;@JsonKey(name: 'my_vote') int? get myVote; int get upvotes; int get downvotes;
/// Create a copy of VoteToggleResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteToggleResponseDtoCopyWith<VoteToggleResponseDto> get copyWith => _$VoteToggleResponseDtoCopyWithImpl<VoteToggleResponseDto>(this as VoteToggleResponseDto, _$identity);

  /// Serializes this VoteToggleResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VoteToggleResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoteToggleResponseDto&&(identical(other.targetType, _this.targetType) || other.targetType == _this.targetType)&&(identical(other.targetId, _this.targetId) || other.targetId == _this.targetId)&&(identical(other.myVote, _this.myVote) || other.myVote == _this.myVote)&&(identical(other.upvotes, _this.upvotes) || other.upvotes == _this.upvotes)&&(identical(other.downvotes, _this.downvotes) || other.downvotes == _this.downvotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VoteToggleResponseDto;
  return Object.hash(runtimeType,_this.targetType,_this.targetId,_this.myVote,_this.upvotes,_this.downvotes);
}

@override
String toString() {
  final _this = this as VoteToggleResponseDto;
  return 'VoteToggleResponseDto(targetType: ${_this.targetType}, targetId: ${_this.targetId}, myVote: ${_this.myVote}, upvotes: ${_this.upvotes}, downvotes: ${_this.downvotes})';
}


}

/// @nodoc
abstract mixin class $VoteToggleResponseDtoCopyWith<$Res>  {
  factory $VoteToggleResponseDtoCopyWith(VoteToggleResponseDto value, $Res Function(VoteToggleResponseDto) _then) = _$VoteToggleResponseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'target_type') String targetType,@JsonKey(name: 'target_id') String targetId,@JsonKey(name: 'my_vote') int? myVote, int upvotes, int downvotes
});




}
/// @nodoc
class _$VoteToggleResponseDtoCopyWithImpl<$Res>
    implements $VoteToggleResponseDtoCopyWith<$Res> {
  _$VoteToggleResponseDtoCopyWithImpl(this._self, this._then);

  final VoteToggleResponseDto _self;
  final $Res Function(VoteToggleResponseDto) _then;

/// Create a copy of VoteToggleResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetType = null,Object? targetId = null,Object? myVote = freezed,Object? upvotes = null,Object? downvotes = null,}) {
  return _then(VoteToggleResponseDto(
targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,myVote: freezed == myVote ? _self.myVote : myVote // ignore: cast_nullable_to_non_nullable
as int?,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VoteToggleResponseDto].
extension VoteToggleResponseDtoPatterns on VoteToggleResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoteToggleResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoteToggleResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoteToggleResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _VoteToggleResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoteToggleResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoteToggleResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'target_type')  String targetType, @JsonKey(name: 'target_id')  String targetId, @JsonKey(name: 'my_vote')  int? myVote,  int upvotes,  int downvotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoteToggleResponseDto() when $default != null:
return $default(_that.targetType,_that.targetId,_that.myVote,_that.upvotes,_that.downvotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'target_type')  String targetType, @JsonKey(name: 'target_id')  String targetId, @JsonKey(name: 'my_vote')  int? myVote,  int upvotes,  int downvotes)  $default,) {final _that = this;
switch (_that) {
case _VoteToggleResponseDto():
return $default(_that.targetType,_that.targetId,_that.myVote,_that.upvotes,_that.downvotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'target_type')  String targetType, @JsonKey(name: 'target_id')  String targetId, @JsonKey(name: 'my_vote')  int? myVote,  int upvotes,  int downvotes)?  $default,) {final _that = this;
switch (_that) {
case _VoteToggleResponseDto() when $default != null:
return $default(_that.targetType,_that.targetId,_that.myVote,_that.upvotes,_that.downvotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoteToggleResponseDto implements VoteToggleResponseDto {
  const _VoteToggleResponseDto({@JsonKey(name: 'target_type') required this.targetType, @JsonKey(name: 'target_id') required this.targetId, @JsonKey(name: 'my_vote') this.myVote, this.upvotes = 0, this.downvotes = 0});
  factory _VoteToggleResponseDto.fromJson(Map<String, dynamic> json) => _$VoteToggleResponseDtoFromJson(json);

@override@JsonKey(name: 'target_type') final  String targetType;
@override@JsonKey(name: 'target_id') final  String targetId;
@override@JsonKey(name: 'my_vote') final  int? myVote;
@override@JsonKey() final  int upvotes;
@override@JsonKey() final  int downvotes;

/// Create a copy of VoteToggleResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteToggleResponseDtoCopyWith<_VoteToggleResponseDto> get copyWith => __$VoteToggleResponseDtoCopyWithImpl<_VoteToggleResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoteToggleResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteToggleResponseDto&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.myVote, myVote) || other.myVote == myVote)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,targetType,targetId,myVote,upvotes,downvotes);
}

@override
String toString() {
    return 'VoteToggleResponseDto(targetType: $targetType, targetId: $targetId, myVote: $myVote, upvotes: $upvotes, downvotes: $downvotes)';
}


}

/// @nodoc
abstract mixin class _$VoteToggleResponseDtoCopyWith<$Res> implements $VoteToggleResponseDtoCopyWith<$Res> {
  factory _$VoteToggleResponseDtoCopyWith(_VoteToggleResponseDto value, $Res Function(_VoteToggleResponseDto) _then) = __$VoteToggleResponseDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'target_type') String targetType,@JsonKey(name: 'target_id') String targetId,@JsonKey(name: 'my_vote') int? myVote, int upvotes, int downvotes
});




}
/// @nodoc
class __$VoteToggleResponseDtoCopyWithImpl<$Res>
    implements _$VoteToggleResponseDtoCopyWith<$Res> {
  __$VoteToggleResponseDtoCopyWithImpl(this._self, this._then);

  final _VoteToggleResponseDto _self;
  final $Res Function(_VoteToggleResponseDto) _then;

/// Create a copy of VoteToggleResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetType = null,Object? targetId = null,Object? myVote = freezed,Object? upvotes = null,Object? downvotes = null,}) {
  return _then(_VoteToggleResponseDto(
targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,myVote: freezed == myVote ? _self.myVote : myVote // ignore: cast_nullable_to_non_nullable
as int?,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
