// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vote_count_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoteCountDto {

@JsonKey(name: 'target_type') String get targetType;@JsonKey(name: 'target_id') String get targetId; int get upvotes; int get downvotes;
/// Create a copy of VoteCountDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteCountDtoCopyWith<VoteCountDto> get copyWith => _$VoteCountDtoCopyWithImpl<VoteCountDto>(this as VoteCountDto, _$identity);

  /// Serializes this VoteCountDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VoteCountDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoteCountDto&&(identical(other.targetType, _this.targetType) || other.targetType == _this.targetType)&&(identical(other.targetId, _this.targetId) || other.targetId == _this.targetId)&&(identical(other.upvotes, _this.upvotes) || other.upvotes == _this.upvotes)&&(identical(other.downvotes, _this.downvotes) || other.downvotes == _this.downvotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VoteCountDto;
  return Object.hash(runtimeType,_this.targetType,_this.targetId,_this.upvotes,_this.downvotes);
}

@override
String toString() {
  final _this = this as VoteCountDto;
  return 'VoteCountDto(targetType: ${_this.targetType}, targetId: ${_this.targetId}, upvotes: ${_this.upvotes}, downvotes: ${_this.downvotes})';
}


}

/// @nodoc
abstract mixin class $VoteCountDtoCopyWith<$Res>  {
  factory $VoteCountDtoCopyWith(VoteCountDto value, $Res Function(VoteCountDto) _then) = _$VoteCountDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'target_type') String targetType,@JsonKey(name: 'target_id') String targetId, int upvotes, int downvotes
});




}
/// @nodoc
class _$VoteCountDtoCopyWithImpl<$Res>
    implements $VoteCountDtoCopyWith<$Res> {
  _$VoteCountDtoCopyWithImpl(this._self, this._then);

  final VoteCountDto _self;
  final $Res Function(VoteCountDto) _then;

/// Create a copy of VoteCountDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetType = null,Object? targetId = null,Object? upvotes = null,Object? downvotes = null,}) {
  return _then(VoteCountDto(
targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VoteCountDto].
extension VoteCountDtoPatterns on VoteCountDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoteCountDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoteCountDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoteCountDto value)  $default,){
final _that = this;
switch (_that) {
case _VoteCountDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoteCountDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoteCountDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'target_type')  String targetType, @JsonKey(name: 'target_id')  String targetId,  int upvotes,  int downvotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoteCountDto() when $default != null:
return $default(_that.targetType,_that.targetId,_that.upvotes,_that.downvotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'target_type')  String targetType, @JsonKey(name: 'target_id')  String targetId,  int upvotes,  int downvotes)  $default,) {final _that = this;
switch (_that) {
case _VoteCountDto():
return $default(_that.targetType,_that.targetId,_that.upvotes,_that.downvotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'target_type')  String targetType, @JsonKey(name: 'target_id')  String targetId,  int upvotes,  int downvotes)?  $default,) {final _that = this;
switch (_that) {
case _VoteCountDto() when $default != null:
return $default(_that.targetType,_that.targetId,_that.upvotes,_that.downvotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoteCountDto implements VoteCountDto {
  const _VoteCountDto({@JsonKey(name: 'target_type') required this.targetType, @JsonKey(name: 'target_id') required this.targetId, this.upvotes = 0, this.downvotes = 0});
  factory _VoteCountDto.fromJson(Map<String, dynamic> json) => _$VoteCountDtoFromJson(json);

@override@JsonKey(name: 'target_type') final  String targetType;
@override@JsonKey(name: 'target_id') final  String targetId;
@override@JsonKey() final  int upvotes;
@override@JsonKey() final  int downvotes;

/// Create a copy of VoteCountDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteCountDtoCopyWith<_VoteCountDto> get copyWith => __$VoteCountDtoCopyWithImpl<_VoteCountDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoteCountDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteCountDto&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,targetType,targetId,upvotes,downvotes);
}

@override
String toString() {
    return 'VoteCountDto(targetType: $targetType, targetId: $targetId, upvotes: $upvotes, downvotes: $downvotes)';
}


}

/// @nodoc
abstract mixin class _$VoteCountDtoCopyWith<$Res> implements $VoteCountDtoCopyWith<$Res> {
  factory _$VoteCountDtoCopyWith(_VoteCountDto value, $Res Function(_VoteCountDto) _then) = __$VoteCountDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'target_type') String targetType,@JsonKey(name: 'target_id') String targetId, int upvotes, int downvotes
});




}
/// @nodoc
class __$VoteCountDtoCopyWithImpl<$Res>
    implements _$VoteCountDtoCopyWith<$Res> {
  __$VoteCountDtoCopyWithImpl(this._self, this._then);

  final _VoteCountDto _self;
  final $Res Function(_VoteCountDto) _then;

/// Create a copy of VoteCountDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetType = null,Object? targetId = null,Object? upvotes = null,Object? downvotes = null,}) {
  return _then(_VoteCountDto(
targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
