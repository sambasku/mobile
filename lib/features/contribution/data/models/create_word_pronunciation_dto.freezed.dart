// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_word_pronunciation_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateWordPronunciationDto {

 String get notation; String get value;
/// Create a copy of CreateWordPronunciationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateWordPronunciationDtoCopyWith<CreateWordPronunciationDto> get copyWith => _$CreateWordPronunciationDtoCopyWithImpl<CreateWordPronunciationDto>(this as CreateWordPronunciationDto, _$identity);

  /// Serializes this CreateWordPronunciationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateWordPronunciationDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateWordPronunciationDto&&(identical(other.notation, _this.notation) || other.notation == _this.notation)&&(identical(other.value, _this.value) || other.value == _this.value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateWordPronunciationDto;
  return Object.hash(runtimeType,_this.notation,_this.value);
}

@override
String toString() {
  final _this = this as CreateWordPronunciationDto;
  return 'CreateWordPronunciationDto(notation: ${_this.notation}, value: ${_this.value})';
}


}

/// @nodoc
abstract mixin class $CreateWordPronunciationDtoCopyWith<$Res>  {
  factory $CreateWordPronunciationDtoCopyWith(CreateWordPronunciationDto value, $Res Function(CreateWordPronunciationDto) _then) = _$CreateWordPronunciationDtoCopyWithImpl;
@useResult
$Res call({
 String notation, String value
});




}
/// @nodoc
class _$CreateWordPronunciationDtoCopyWithImpl<$Res>
    implements $CreateWordPronunciationDtoCopyWith<$Res> {
  _$CreateWordPronunciationDtoCopyWithImpl(this._self, this._then);

  final CreateWordPronunciationDto _self;
  final $Res Function(CreateWordPronunciationDto) _then;

/// Create a copy of CreateWordPronunciationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? notation = null,Object? value = null,}) {
  return _then(CreateWordPronunciationDto(
notation: null == notation ? _self.notation : notation // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateWordPronunciationDto].
extension CreateWordPronunciationDtoPatterns on CreateWordPronunciationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateWordPronunciationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateWordPronunciationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateWordPronunciationDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateWordPronunciationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateWordPronunciationDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateWordPronunciationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String notation,  String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateWordPronunciationDto() when $default != null:
return $default(_that.notation,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String notation,  String value)  $default,) {final _that = this;
switch (_that) {
case _CreateWordPronunciationDto():
return $default(_that.notation,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String notation,  String value)?  $default,) {final _that = this;
switch (_that) {
case _CreateWordPronunciationDto() when $default != null:
return $default(_that.notation,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateWordPronunciationDto implements CreateWordPronunciationDto {
  const _CreateWordPronunciationDto({this.notation = 'ipa', required this.value});
  factory _CreateWordPronunciationDto.fromJson(Map<String, dynamic> json) => _$CreateWordPronunciationDtoFromJson(json);

@override@JsonKey() final  String notation;
@override final  String value;

/// Create a copy of CreateWordPronunciationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateWordPronunciationDtoCopyWith<_CreateWordPronunciationDto> get copyWith => __$CreateWordPronunciationDtoCopyWithImpl<_CreateWordPronunciationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateWordPronunciationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateWordPronunciationDto&&(identical(other.notation, notation) || other.notation == notation)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,notation,value);
}

@override
String toString() {
    return 'CreateWordPronunciationDto(notation: $notation, value: $value)';
}


}

/// @nodoc
abstract mixin class _$CreateWordPronunciationDtoCopyWith<$Res> implements $CreateWordPronunciationDtoCopyWith<$Res> {
  factory _$CreateWordPronunciationDtoCopyWith(_CreateWordPronunciationDto value, $Res Function(_CreateWordPronunciationDto) _then) = __$CreateWordPronunciationDtoCopyWithImpl;
@override @useResult
$Res call({
 String notation, String value
});




}
/// @nodoc
class __$CreateWordPronunciationDtoCopyWithImpl<$Res>
    implements _$CreateWordPronunciationDtoCopyWith<$Res> {
  __$CreateWordPronunciationDtoCopyWithImpl(this._self, this._then);

  final _CreateWordPronunciationDto _self;
  final $Res Function(_CreateWordPronunciationDto) _then;

/// Create a copy of CreateWordPronunciationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? notation = null,Object? value = null,}) {
  return _then(_CreateWordPronunciationDto(
notation: null == notation ? _self.notation : notation // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
