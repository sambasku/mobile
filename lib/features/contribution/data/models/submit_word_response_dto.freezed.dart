// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'submit_word_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubmitWordResponseDto {

@JsonKey(name: 'word_id') String get wordId; String get status;
/// Create a copy of SubmitWordResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubmitWordResponseDtoCopyWith<SubmitWordResponseDto> get copyWith => _$SubmitWordResponseDtoCopyWithImpl<SubmitWordResponseDto>(this as SubmitWordResponseDto, _$identity);

  /// Serializes this SubmitWordResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubmitWordResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubmitWordResponseDto&&(identical(other.wordId, _this.wordId) || other.wordId == _this.wordId)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubmitWordResponseDto;
  return Object.hash(runtimeType,_this.wordId,_this.status);
}

@override
String toString() {
  final _this = this as SubmitWordResponseDto;
  return 'SubmitWordResponseDto(wordId: ${_this.wordId}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $SubmitWordResponseDtoCopyWith<$Res>  {
  factory $SubmitWordResponseDtoCopyWith(SubmitWordResponseDto value, $Res Function(SubmitWordResponseDto) _then) = _$SubmitWordResponseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'word_id') String wordId, String status
});




}
/// @nodoc
class _$SubmitWordResponseDtoCopyWithImpl<$Res>
    implements $SubmitWordResponseDtoCopyWith<$Res> {
  _$SubmitWordResponseDtoCopyWithImpl(this._self, this._then);

  final SubmitWordResponseDto _self;
  final $Res Function(SubmitWordResponseDto) _then;

/// Create a copy of SubmitWordResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wordId = null,Object? status = null,}) {
  return _then(SubmitWordResponseDto(
wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SubmitWordResponseDto].
extension SubmitWordResponseDtoPatterns on SubmitWordResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubmitWordResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubmitWordResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubmitWordResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _SubmitWordResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubmitWordResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _SubmitWordResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'word_id')  String wordId,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubmitWordResponseDto() when $default != null:
return $default(_that.wordId,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'word_id')  String wordId,  String status)  $default,) {final _that = this;
switch (_that) {
case _SubmitWordResponseDto():
return $default(_that.wordId,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'word_id')  String wordId,  String status)?  $default,) {final _that = this;
switch (_that) {
case _SubmitWordResponseDto() when $default != null:
return $default(_that.wordId,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubmitWordResponseDto implements SubmitWordResponseDto {
  const _SubmitWordResponseDto({@JsonKey(name: 'word_id') required this.wordId, required this.status});
  factory _SubmitWordResponseDto.fromJson(Map<String, dynamic> json) => _$SubmitWordResponseDtoFromJson(json);

@override@JsonKey(name: 'word_id') final  String wordId;
@override final  String status;

/// Create a copy of SubmitWordResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubmitWordResponseDtoCopyWith<_SubmitWordResponseDto> get copyWith => __$SubmitWordResponseDtoCopyWithImpl<_SubmitWordResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubmitWordResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmitWordResponseDto&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,wordId,status);
}

@override
String toString() {
    return 'SubmitWordResponseDto(wordId: $wordId, status: $status)';
}


}

/// @nodoc
abstract mixin class _$SubmitWordResponseDtoCopyWith<$Res> implements $SubmitWordResponseDtoCopyWith<$Res> {
  factory _$SubmitWordResponseDtoCopyWith(_SubmitWordResponseDto value, $Res Function(_SubmitWordResponseDto) _then) = __$SubmitWordResponseDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'word_id') String wordId, String status
});




}
/// @nodoc
class __$SubmitWordResponseDtoCopyWithImpl<$Res>
    implements _$SubmitWordResponseDtoCopyWith<$Res> {
  __$SubmitWordResponseDtoCopyWithImpl(this._self, this._then);

  final _SubmitWordResponseDto _self;
  final $Res Function(_SubmitWordResponseDto) _then;

/// Create a copy of SubmitWordResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wordId = null,Object? status = null,}) {
  return _then(_SubmitWordResponseDto(
wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
