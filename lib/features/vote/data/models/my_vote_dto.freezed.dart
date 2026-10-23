// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_vote_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyVoteDto {

@JsonKey(name: 'target_type') String get targetType;@JsonKey(name: 'target_id') String get targetId; int get value;
/// Create a copy of MyVoteDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyVoteDtoCopyWith<MyVoteDto> get copyWith => _$MyVoteDtoCopyWithImpl<MyVoteDto>(this as MyVoteDto, _$identity);

  /// Serializes this MyVoteDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MyVoteDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyVoteDto&&(identical(other.targetType, _this.targetType) || other.targetType == _this.targetType)&&(identical(other.targetId, _this.targetId) || other.targetId == _this.targetId)&&(identical(other.value, _this.value) || other.value == _this.value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MyVoteDto;
  return Object.hash(runtimeType,_this.targetType,_this.targetId,_this.value);
}

@override
String toString() {
  final _this = this as MyVoteDto;
  return 'MyVoteDto(targetType: ${_this.targetType}, targetId: ${_this.targetId}, value: ${_this.value})';
}


}

/// @nodoc
abstract mixin class $MyVoteDtoCopyWith<$Res>  {
  factory $MyVoteDtoCopyWith(MyVoteDto value, $Res Function(MyVoteDto) _then) = _$MyVoteDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'target_type') String targetType,@JsonKey(name: 'target_id') String targetId, int value
});




}
/// @nodoc
class _$MyVoteDtoCopyWithImpl<$Res>
    implements $MyVoteDtoCopyWith<$Res> {
  _$MyVoteDtoCopyWithImpl(this._self, this._then);

  final MyVoteDto _self;
  final $Res Function(MyVoteDto) _then;

/// Create a copy of MyVoteDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetType = null,Object? targetId = null,Object? value = null,}) {
  return _then(MyVoteDto(
targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MyVoteDto].
extension MyVoteDtoPatterns on MyVoteDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyVoteDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyVoteDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyVoteDto value)  $default,){
final _that = this;
switch (_that) {
case _MyVoteDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyVoteDto value)?  $default,){
final _that = this;
switch (_that) {
case _MyVoteDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'target_type')  String targetType, @JsonKey(name: 'target_id')  String targetId,  int value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyVoteDto() when $default != null:
return $default(_that.targetType,_that.targetId,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'target_type')  String targetType, @JsonKey(name: 'target_id')  String targetId,  int value)  $default,) {final _that = this;
switch (_that) {
case _MyVoteDto():
return $default(_that.targetType,_that.targetId,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'target_type')  String targetType, @JsonKey(name: 'target_id')  String targetId,  int value)?  $default,) {final _that = this;
switch (_that) {
case _MyVoteDto() when $default != null:
return $default(_that.targetType,_that.targetId,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MyVoteDto implements MyVoteDto {
  const _MyVoteDto({@JsonKey(name: 'target_type') required this.targetType, @JsonKey(name: 'target_id') required this.targetId, required this.value});
  factory _MyVoteDto.fromJson(Map<String, dynamic> json) => _$MyVoteDtoFromJson(json);

@override@JsonKey(name: 'target_type') final  String targetType;
@override@JsonKey(name: 'target_id') final  String targetId;
@override final  int value;

/// Create a copy of MyVoteDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyVoteDtoCopyWith<_MyVoteDto> get copyWith => __$MyVoteDtoCopyWithImpl<_MyVoteDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyVoteDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyVoteDto&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,targetType,targetId,value);
}

@override
String toString() {
    return 'MyVoteDto(targetType: $targetType, targetId: $targetId, value: $value)';
}


}

/// @nodoc
abstract mixin class _$MyVoteDtoCopyWith<$Res> implements $MyVoteDtoCopyWith<$Res> {
  factory _$MyVoteDtoCopyWith(_MyVoteDto value, $Res Function(_MyVoteDto) _then) = __$MyVoteDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'target_type') String targetType,@JsonKey(name: 'target_id') String targetId, int value
});




}
/// @nodoc
class __$MyVoteDtoCopyWithImpl<$Res>
    implements _$MyVoteDtoCopyWith<$Res> {
  __$MyVoteDtoCopyWithImpl(this._self, this._then);

  final _MyVoteDto _self;
  final $Res Function(_MyVoteDto) _then;

/// Create a copy of MyVoteDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetType = null,Object? targetId = null,Object? value = null,}) {
  return _then(_MyVoteDto(
targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
