// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'toggle_bookmark_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ToggleBookmarkRequestDto {

@JsonKey(name: 'word_id') String get wordId;
/// Create a copy of ToggleBookmarkRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToggleBookmarkRequestDtoCopyWith<ToggleBookmarkRequestDto> get copyWith => _$ToggleBookmarkRequestDtoCopyWithImpl<ToggleBookmarkRequestDto>(this as ToggleBookmarkRequestDto, _$identity);

  /// Serializes this ToggleBookmarkRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ToggleBookmarkRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToggleBookmarkRequestDto&&(identical(other.wordId, _this.wordId) || other.wordId == _this.wordId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ToggleBookmarkRequestDto;
  return Object.hash(runtimeType,_this.wordId);
}

@override
String toString() {
  final _this = this as ToggleBookmarkRequestDto;
  return 'ToggleBookmarkRequestDto(wordId: ${_this.wordId})';
}


}

/// @nodoc
abstract mixin class $ToggleBookmarkRequestDtoCopyWith<$Res>  {
  factory $ToggleBookmarkRequestDtoCopyWith(ToggleBookmarkRequestDto value, $Res Function(ToggleBookmarkRequestDto) _then) = _$ToggleBookmarkRequestDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'word_id') String wordId
});




}
/// @nodoc
class _$ToggleBookmarkRequestDtoCopyWithImpl<$Res>
    implements $ToggleBookmarkRequestDtoCopyWith<$Res> {
  _$ToggleBookmarkRequestDtoCopyWithImpl(this._self, this._then);

  final ToggleBookmarkRequestDto _self;
  final $Res Function(ToggleBookmarkRequestDto) _then;

/// Create a copy of ToggleBookmarkRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wordId = null,}) {
  return _then(ToggleBookmarkRequestDto(
wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ToggleBookmarkRequestDto].
extension ToggleBookmarkRequestDtoPatterns on ToggleBookmarkRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ToggleBookmarkRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToggleBookmarkRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ToggleBookmarkRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _ToggleBookmarkRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ToggleBookmarkRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _ToggleBookmarkRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'word_id')  String wordId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToggleBookmarkRequestDto() when $default != null:
return $default(_that.wordId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'word_id')  String wordId)  $default,) {final _that = this;
switch (_that) {
case _ToggleBookmarkRequestDto():
return $default(_that.wordId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'word_id')  String wordId)?  $default,) {final _that = this;
switch (_that) {
case _ToggleBookmarkRequestDto() when $default != null:
return $default(_that.wordId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ToggleBookmarkRequestDto implements ToggleBookmarkRequestDto {
  const _ToggleBookmarkRequestDto({@JsonKey(name: 'word_id') required this.wordId});
  factory _ToggleBookmarkRequestDto.fromJson(Map<String, dynamic> json) => _$ToggleBookmarkRequestDtoFromJson(json);

@override@JsonKey(name: 'word_id') final  String wordId;

/// Create a copy of ToggleBookmarkRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToggleBookmarkRequestDtoCopyWith<_ToggleBookmarkRequestDto> get copyWith => __$ToggleBookmarkRequestDtoCopyWithImpl<_ToggleBookmarkRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ToggleBookmarkRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToggleBookmarkRequestDto&&(identical(other.wordId, wordId) || other.wordId == wordId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,wordId);
}

@override
String toString() {
    return 'ToggleBookmarkRequestDto(wordId: $wordId)';
}


}

/// @nodoc
abstract mixin class _$ToggleBookmarkRequestDtoCopyWith<$Res> implements $ToggleBookmarkRequestDtoCopyWith<$Res> {
  factory _$ToggleBookmarkRequestDtoCopyWith(_ToggleBookmarkRequestDto value, $Res Function(_ToggleBookmarkRequestDto) _then) = __$ToggleBookmarkRequestDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'word_id') String wordId
});




}
/// @nodoc
class __$ToggleBookmarkRequestDtoCopyWithImpl<$Res>
    implements _$ToggleBookmarkRequestDtoCopyWith<$Res> {
  __$ToggleBookmarkRequestDtoCopyWithImpl(this._self, this._then);

  final _ToggleBookmarkRequestDto _self;
  final $Res Function(_ToggleBookmarkRequestDto) _then;

/// Create a copy of ToggleBookmarkRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wordId = null,}) {
  return _then(_ToggleBookmarkRequestDto(
wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
