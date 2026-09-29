// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_word_meaning_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateWordMeaningDto {

@JsonKey(name: 'word_class_id') String get wordClassId; String get definition;@JsonKey(name: 'is_have_definition') bool get isHaveDefinition;@JsonKey(name: 'is_have_translation') bool get isHaveTranslation;@JsonKey(name: 'meaning_source') String get meaningSource;@JsonKey(name: 'order_index') int get orderIndex; List<CreateWordTranslationDto> get translations;@JsonKey(includeIfNull: false) List<CreateWordExampleDto>? get examples;
/// Create a copy of CreateWordMeaningDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateWordMeaningDtoCopyWith<CreateWordMeaningDto> get copyWith => _$CreateWordMeaningDtoCopyWithImpl<CreateWordMeaningDto>(this as CreateWordMeaningDto, _$identity);

  /// Serializes this CreateWordMeaningDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateWordMeaningDto&&(identical(other.wordClassId, wordClassId) || other.wordClassId == wordClassId)&&(identical(other.definition, definition) || other.definition == definition)&&(identical(other.isHaveDefinition, isHaveDefinition) || other.isHaveDefinition == isHaveDefinition)&&(identical(other.isHaveTranslation, isHaveTranslation) || other.isHaveTranslation == isHaveTranslation)&&(identical(other.meaningSource, meaningSource) || other.meaningSource == meaningSource)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&const DeepCollectionEquality().equals(other.translations, translations)&&const DeepCollectionEquality().equals(other.examples, examples));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wordClassId,definition,isHaveDefinition,isHaveTranslation,meaningSource,orderIndex,const DeepCollectionEquality().hash(translations),const DeepCollectionEquality().hash(examples));

@override
String toString() {
  return 'CreateWordMeaningDto(wordClassId: $wordClassId, definition: $definition, isHaveDefinition: $isHaveDefinition, isHaveTranslation: $isHaveTranslation, meaningSource: $meaningSource, orderIndex: $orderIndex, translations: $translations, examples: $examples)';
}


}

/// @nodoc
abstract mixin class $CreateWordMeaningDtoCopyWith<$Res>  {
  factory $CreateWordMeaningDtoCopyWith(CreateWordMeaningDto value, $Res Function(CreateWordMeaningDto) _then) = _$CreateWordMeaningDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'word_class_id') String wordClassId, String definition,@JsonKey(name: 'is_have_definition') bool isHaveDefinition,@JsonKey(name: 'is_have_translation') bool isHaveTranslation,@JsonKey(name: 'meaning_source') String meaningSource,@JsonKey(name: 'order_index') int orderIndex, List<CreateWordTranslationDto> translations,@JsonKey(includeIfNull: false) List<CreateWordExampleDto>? examples
});




}
/// @nodoc
class _$CreateWordMeaningDtoCopyWithImpl<$Res>
    implements $CreateWordMeaningDtoCopyWith<$Res> {
  _$CreateWordMeaningDtoCopyWithImpl(this._self, this._then);

  final CreateWordMeaningDto _self;
  final $Res Function(CreateWordMeaningDto) _then;

/// Create a copy of CreateWordMeaningDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wordClassId = null,Object? definition = null,Object? isHaveDefinition = null,Object? isHaveTranslation = null,Object? meaningSource = null,Object? orderIndex = null,Object? translations = null,Object? examples = freezed,}) {
  return _then(_self.copyWith(
wordClassId: null == wordClassId ? _self.wordClassId : wordClassId // ignore: cast_nullable_to_non_nullable
as String,definition: null == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String,isHaveDefinition: null == isHaveDefinition ? _self.isHaveDefinition : isHaveDefinition // ignore: cast_nullable_to_non_nullable
as bool,isHaveTranslation: null == isHaveTranslation ? _self.isHaveTranslation : isHaveTranslation // ignore: cast_nullable_to_non_nullable
as bool,meaningSource: null == meaningSource ? _self.meaningSource : meaningSource // ignore: cast_nullable_to_non_nullable
as String,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,translations: null == translations ? _self.translations : translations // ignore: cast_nullable_to_non_nullable
as List<CreateWordTranslationDto>,examples: freezed == examples ? _self.examples : examples // ignore: cast_nullable_to_non_nullable
as List<CreateWordExampleDto>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateWordMeaningDto].
extension CreateWordMeaningDtoPatterns on CreateWordMeaningDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateWordMeaningDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateWordMeaningDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateWordMeaningDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateWordMeaningDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateWordMeaningDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateWordMeaningDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'word_class_id')  String wordClassId,  String definition, @JsonKey(name: 'is_have_definition')  bool isHaveDefinition, @JsonKey(name: 'is_have_translation')  bool isHaveTranslation, @JsonKey(name: 'meaning_source')  String meaningSource, @JsonKey(name: 'order_index')  int orderIndex,  List<CreateWordTranslationDto> translations, @JsonKey(includeIfNull: false)  List<CreateWordExampleDto>? examples)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateWordMeaningDto() when $default != null:
return $default(_that.wordClassId,_that.definition,_that.isHaveDefinition,_that.isHaveTranslation,_that.meaningSource,_that.orderIndex,_that.translations,_that.examples);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'word_class_id')  String wordClassId,  String definition, @JsonKey(name: 'is_have_definition')  bool isHaveDefinition, @JsonKey(name: 'is_have_translation')  bool isHaveTranslation, @JsonKey(name: 'meaning_source')  String meaningSource, @JsonKey(name: 'order_index')  int orderIndex,  List<CreateWordTranslationDto> translations, @JsonKey(includeIfNull: false)  List<CreateWordExampleDto>? examples)  $default,) {final _that = this;
switch (_that) {
case _CreateWordMeaningDto():
return $default(_that.wordClassId,_that.definition,_that.isHaveDefinition,_that.isHaveTranslation,_that.meaningSource,_that.orderIndex,_that.translations,_that.examples);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'word_class_id')  String wordClassId,  String definition, @JsonKey(name: 'is_have_definition')  bool isHaveDefinition, @JsonKey(name: 'is_have_translation')  bool isHaveTranslation, @JsonKey(name: 'meaning_source')  String meaningSource, @JsonKey(name: 'order_index')  int orderIndex,  List<CreateWordTranslationDto> translations, @JsonKey(includeIfNull: false)  List<CreateWordExampleDto>? examples)?  $default,) {final _that = this;
switch (_that) {
case _CreateWordMeaningDto() when $default != null:
return $default(_that.wordClassId,_that.definition,_that.isHaveDefinition,_that.isHaveTranslation,_that.meaningSource,_that.orderIndex,_that.translations,_that.examples);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateWordMeaningDto implements CreateWordMeaningDto {
  const _CreateWordMeaningDto({@JsonKey(name: 'word_class_id') required this.wordClassId, required this.definition, @JsonKey(name: 'is_have_definition') this.isHaveDefinition = true, @JsonKey(name: 'is_have_translation') this.isHaveTranslation = true, @JsonKey(name: 'meaning_source') this.meaningSource = 'manual', @JsonKey(name: 'order_index') this.orderIndex = 1, required final  List<CreateWordTranslationDto> translations, @JsonKey(includeIfNull: false) final  List<CreateWordExampleDto>? examples}): _translations = translations,_examples = examples;
  factory _CreateWordMeaningDto.fromJson(Map<String, dynamic> json) => _$CreateWordMeaningDtoFromJson(json);

@override@JsonKey(name: 'word_class_id') final  String wordClassId;
@override final  String definition;
@override@JsonKey(name: 'is_have_definition') final  bool isHaveDefinition;
@override@JsonKey(name: 'is_have_translation') final  bool isHaveTranslation;
@override@JsonKey(name: 'meaning_source') final  String meaningSource;
@override@JsonKey(name: 'order_index') final  int orderIndex;
 final  List<CreateWordTranslationDto> _translations;
@override List<CreateWordTranslationDto> get translations {
  if (_translations is EqualUnmodifiableListView) return _translations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_translations);
}

 final  List<CreateWordExampleDto>? _examples;
@override@JsonKey(includeIfNull: false) List<CreateWordExampleDto>? get examples {
  final value = _examples;
  if (value == null) return null;
  if (_examples is EqualUnmodifiableListView) return _examples;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of CreateWordMeaningDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateWordMeaningDtoCopyWith<_CreateWordMeaningDto> get copyWith => __$CreateWordMeaningDtoCopyWithImpl<_CreateWordMeaningDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateWordMeaningDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateWordMeaningDto&&(identical(other.wordClassId, wordClassId) || other.wordClassId == wordClassId)&&(identical(other.definition, definition) || other.definition == definition)&&(identical(other.isHaveDefinition, isHaveDefinition) || other.isHaveDefinition == isHaveDefinition)&&(identical(other.isHaveTranslation, isHaveTranslation) || other.isHaveTranslation == isHaveTranslation)&&(identical(other.meaningSource, meaningSource) || other.meaningSource == meaningSource)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&const DeepCollectionEquality().equals(other._translations, _translations)&&const DeepCollectionEquality().equals(other._examples, _examples));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wordClassId,definition,isHaveDefinition,isHaveTranslation,meaningSource,orderIndex,const DeepCollectionEquality().hash(_translations),const DeepCollectionEquality().hash(_examples));

@override
String toString() {
  return 'CreateWordMeaningDto(wordClassId: $wordClassId, definition: $definition, isHaveDefinition: $isHaveDefinition, isHaveTranslation: $isHaveTranslation, meaningSource: $meaningSource, orderIndex: $orderIndex, translations: $translations, examples: $examples)';
}


}

/// @nodoc
abstract mixin class _$CreateWordMeaningDtoCopyWith<$Res> implements $CreateWordMeaningDtoCopyWith<$Res> {
  factory _$CreateWordMeaningDtoCopyWith(_CreateWordMeaningDto value, $Res Function(_CreateWordMeaningDto) _then) = __$CreateWordMeaningDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'word_class_id') String wordClassId, String definition,@JsonKey(name: 'is_have_definition') bool isHaveDefinition,@JsonKey(name: 'is_have_translation') bool isHaveTranslation,@JsonKey(name: 'meaning_source') String meaningSource,@JsonKey(name: 'order_index') int orderIndex, List<CreateWordTranslationDto> translations,@JsonKey(includeIfNull: false) List<CreateWordExampleDto>? examples
});




}
/// @nodoc
class __$CreateWordMeaningDtoCopyWithImpl<$Res>
    implements _$CreateWordMeaningDtoCopyWith<$Res> {
  __$CreateWordMeaningDtoCopyWithImpl(this._self, this._then);

  final _CreateWordMeaningDto _self;
  final $Res Function(_CreateWordMeaningDto) _then;

/// Create a copy of CreateWordMeaningDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wordClassId = null,Object? definition = null,Object? isHaveDefinition = null,Object? isHaveTranslation = null,Object? meaningSource = null,Object? orderIndex = null,Object? translations = null,Object? examples = freezed,}) {
  return _then(_CreateWordMeaningDto(
wordClassId: null == wordClassId ? _self.wordClassId : wordClassId // ignore: cast_nullable_to_non_nullable
as String,definition: null == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String,isHaveDefinition: null == isHaveDefinition ? _self.isHaveDefinition : isHaveDefinition // ignore: cast_nullable_to_non_nullable
as bool,isHaveTranslation: null == isHaveTranslation ? _self.isHaveTranslation : isHaveTranslation // ignore: cast_nullable_to_non_nullable
as bool,meaningSource: null == meaningSource ? _self.meaningSource : meaningSource // ignore: cast_nullable_to_non_nullable
as String,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,translations: null == translations ? _self._translations : translations // ignore: cast_nullable_to_non_nullable
as List<CreateWordTranslationDto>,examples: freezed == examples ? _self._examples : examples // ignore: cast_nullable_to_non_nullable
as List<CreateWordExampleDto>?,
  ));
}


}

// dart format on
