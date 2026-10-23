// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_word_example_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateWordExampleDto {

@JsonKey(name: 'source_language_id') String get sourceLanguageId;@JsonKey(name: 'source_sentence') String get sourceSentence;
/// Create a copy of CreateWordExampleDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateWordExampleDtoCopyWith<CreateWordExampleDto> get copyWith => _$CreateWordExampleDtoCopyWithImpl<CreateWordExampleDto>(this as CreateWordExampleDto, _$identity);

  /// Serializes this CreateWordExampleDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateWordExampleDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateWordExampleDto&&(identical(other.sourceLanguageId, _this.sourceLanguageId) || other.sourceLanguageId == _this.sourceLanguageId)&&(identical(other.sourceSentence, _this.sourceSentence) || other.sourceSentence == _this.sourceSentence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateWordExampleDto;
  return Object.hash(runtimeType,_this.sourceLanguageId,_this.sourceSentence);
}

@override
String toString() {
  final _this = this as CreateWordExampleDto;
  return 'CreateWordExampleDto(sourceLanguageId: ${_this.sourceLanguageId}, sourceSentence: ${_this.sourceSentence})';
}


}

/// @nodoc
abstract mixin class $CreateWordExampleDtoCopyWith<$Res>  {
  factory $CreateWordExampleDtoCopyWith(CreateWordExampleDto value, $Res Function(CreateWordExampleDto) _then) = _$CreateWordExampleDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'source_language_id') String sourceLanguageId,@JsonKey(name: 'source_sentence') String sourceSentence
});




}
/// @nodoc
class _$CreateWordExampleDtoCopyWithImpl<$Res>
    implements $CreateWordExampleDtoCopyWith<$Res> {
  _$CreateWordExampleDtoCopyWithImpl(this._self, this._then);

  final CreateWordExampleDto _self;
  final $Res Function(CreateWordExampleDto) _then;

/// Create a copy of CreateWordExampleDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sourceLanguageId = null,Object? sourceSentence = null,}) {
  return _then(CreateWordExampleDto(
sourceLanguageId: null == sourceLanguageId ? _self.sourceLanguageId : sourceLanguageId // ignore: cast_nullable_to_non_nullable
as String,sourceSentence: null == sourceSentence ? _self.sourceSentence : sourceSentence // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateWordExampleDto].
extension CreateWordExampleDtoPatterns on CreateWordExampleDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateWordExampleDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateWordExampleDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateWordExampleDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateWordExampleDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateWordExampleDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateWordExampleDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'source_language_id')  String sourceLanguageId, @JsonKey(name: 'source_sentence')  String sourceSentence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateWordExampleDto() when $default != null:
return $default(_that.sourceLanguageId,_that.sourceSentence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'source_language_id')  String sourceLanguageId, @JsonKey(name: 'source_sentence')  String sourceSentence)  $default,) {final _that = this;
switch (_that) {
case _CreateWordExampleDto():
return $default(_that.sourceLanguageId,_that.sourceSentence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'source_language_id')  String sourceLanguageId, @JsonKey(name: 'source_sentence')  String sourceSentence)?  $default,) {final _that = this;
switch (_that) {
case _CreateWordExampleDto() when $default != null:
return $default(_that.sourceLanguageId,_that.sourceSentence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateWordExampleDto implements CreateWordExampleDto {
  const _CreateWordExampleDto({@JsonKey(name: 'source_language_id') required this.sourceLanguageId, @JsonKey(name: 'source_sentence') required this.sourceSentence});
  factory _CreateWordExampleDto.fromJson(Map<String, dynamic> json) => _$CreateWordExampleDtoFromJson(json);

@override@JsonKey(name: 'source_language_id') final  String sourceLanguageId;
@override@JsonKey(name: 'source_sentence') final  String sourceSentence;

/// Create a copy of CreateWordExampleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateWordExampleDtoCopyWith<_CreateWordExampleDto> get copyWith => __$CreateWordExampleDtoCopyWithImpl<_CreateWordExampleDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateWordExampleDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateWordExampleDto&&(identical(other.sourceLanguageId, sourceLanguageId) || other.sourceLanguageId == sourceLanguageId)&&(identical(other.sourceSentence, sourceSentence) || other.sourceSentence == sourceSentence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sourceLanguageId,sourceSentence);
}

@override
String toString() {
    return 'CreateWordExampleDto(sourceLanguageId: $sourceLanguageId, sourceSentence: $sourceSentence)';
}


}

/// @nodoc
abstract mixin class _$CreateWordExampleDtoCopyWith<$Res> implements $CreateWordExampleDtoCopyWith<$Res> {
  factory _$CreateWordExampleDtoCopyWith(_CreateWordExampleDto value, $Res Function(_CreateWordExampleDto) _then) = __$CreateWordExampleDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'source_language_id') String sourceLanguageId,@JsonKey(name: 'source_sentence') String sourceSentence
});




}
/// @nodoc
class __$CreateWordExampleDtoCopyWithImpl<$Res>
    implements _$CreateWordExampleDtoCopyWith<$Res> {
  __$CreateWordExampleDtoCopyWithImpl(this._self, this._then);

  final _CreateWordExampleDto _self;
  final $Res Function(_CreateWordExampleDto) _then;

/// Create a copy of CreateWordExampleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceLanguageId = null,Object? sourceSentence = null,}) {
  return _then(_CreateWordExampleDto(
sourceLanguageId: null == sourceLanguageId ? _self.sourceLanguageId : sourceLanguageId // ignore: cast_nullable_to_non_nullable
as String,sourceSentence: null == sourceSentence ? _self.sourceSentence : sourceSentence // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
