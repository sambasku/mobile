// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vote_toggle_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoteToggleRequestDto {

@JsonKey(name: 'target_type') String get targetType;@JsonKey(name: 'target_id') String get targetId; int get value;
/// Create a copy of VoteToggleRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteToggleRequestDtoCopyWith<VoteToggleRequestDto> get copyWith => _$VoteToggleRequestDtoCopyWithImpl<VoteToggleRequestDto>(this as VoteToggleRequestDto, _$identity);

  /// Serializes this VoteToggleRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VoteToggleRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoteToggleRequestDto&&(identical(other.targetType, _this.targetType) || other.targetType == _this.targetType)&&(identical(other.targetId, _this.targetId) || other.targetId == _this.targetId)&&(identical(other.value, _this.value) || other.value == _this.value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VoteToggleRequestDto;
  return Object.hash(runtimeType,_this.targetType,_this.targetId,_this.value);
}

@override
String toString() {
  final _this = this as VoteToggleRequestDto;
  return 'VoteToggleRequestDto(targetType: ${_this.targetType}, targetId: ${_this.targetId}, value: ${_this.value})';
}


}

/// @nodoc
abstract mixin class $VoteToggleRequestDtoCopyWith<$Res>  {
  factory $VoteToggleRequestDtoCopyWith(VoteToggleRequestDto value, $Res Function(VoteToggleRequestDto) _then) = _$VoteToggleRequestDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'target_type') String targetType,@JsonKey(name: 'target_id') String targetId, int value
});




}
/// @nodoc
class _$VoteToggleRequestDtoCopyWithImpl<$Res>
    implements $VoteToggleRequestDtoCopyWith<$Res> {
  _$VoteToggleRequestDtoCopyWithImpl(this._self, this._then);

  final VoteToggleRequestDto _self;
  final $Res Function(VoteToggleRequestDto) _then;

/// Create a copy of VoteToggleRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetType = null,Object? targetId = null,Object? value = null,}) {
  return _then(VoteToggleRequestDto(
targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VoteToggleRequestDto].
extension VoteToggleRequestDtoPatterns on VoteToggleRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoteToggleRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoteToggleRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoteToggleRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _VoteToggleRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoteToggleRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoteToggleRequestDto() when $default != null:
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
case _VoteToggleRequestDto() when $default != null:
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
case _VoteToggleRequestDto():
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
case _VoteToggleRequestDto() when $default != null:
return $default(_that.targetType,_that.targetId,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoteToggleRequestDto implements VoteToggleRequestDto {
  const _VoteToggleRequestDto({@JsonKey(name: 'target_type') required this.targetType, @JsonKey(name: 'target_id') required this.targetId, required this.value});
  factory _VoteToggleRequestDto.fromJson(Map<String, dynamic> json) => _$VoteToggleRequestDtoFromJson(json);

@override@JsonKey(name: 'target_type') final  String targetType;
@override@JsonKey(name: 'target_id') final  String targetId;
@override final  int value;

/// Create a copy of VoteToggleRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteToggleRequestDtoCopyWith<_VoteToggleRequestDto> get copyWith => __$VoteToggleRequestDtoCopyWithImpl<_VoteToggleRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoteToggleRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteToggleRequestDto&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,targetType,targetId,value);
}

@override
String toString() {
    return 'VoteToggleRequestDto(targetType: $targetType, targetId: $targetId, value: $value)';
}


}

/// @nodoc
abstract mixin class _$VoteToggleRequestDtoCopyWith<$Res> implements $VoteToggleRequestDtoCopyWith<$Res> {
  factory _$VoteToggleRequestDtoCopyWith(_VoteToggleRequestDto value, $Res Function(_VoteToggleRequestDto) _then) = __$VoteToggleRequestDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'target_type') String targetType,@JsonKey(name: 'target_id') String targetId, int value
});




}
/// @nodoc
class __$VoteToggleRequestDtoCopyWithImpl<$Res>
    implements _$VoteToggleRequestDtoCopyWith<$Res> {
  __$VoteToggleRequestDtoCopyWithImpl(this._self, this._then);

  final _VoteToggleRequestDto _self;
  final $Res Function(_VoteToggleRequestDto) _then;

/// Create a copy of VoteToggleRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetType = null,Object? targetId = null,Object? value = null,}) {
  return _then(_VoteToggleRequestDto(
targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
