// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_word_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateWordRequestDto {

 String get lemma;@JsonKey(name: 'language_id') String get languageId;@JsonKey(name: 'dialect_id', includeIfNull: false) String? get dialectId;@JsonKey(name: 'word_type') String get wordType;@JsonKey(name: 'meanings') List<CreateWordMeaningDto> get meanings;@JsonKey(name: 'category_ids') List<String> get categoryIds;@JsonKey(name: 'usage_labels') List<String> get usageLabels;@JsonKey(name: 'notes', includeIfNull: false) String? get notes;@JsonKey(name: 'variants', includeIfNull: false) List<CreateWordVariantDto>? get variants;@JsonKey(name: 'related_words', includeIfNull: false) List<CreateWordRelatedWordDto>? get relatedWords;@JsonKey(name: 'images', includeIfNull: false) List<CreateWordImageDto>? get images;@JsonKey(name: 'search_miss_id', includeIfNull: false) String? get searchMissId;
/// Create a copy of CreateWordRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateWordRequestDtoCopyWith<CreateWordRequestDto> get copyWith => _$CreateWordRequestDtoCopyWithImpl<CreateWordRequestDto>(this as CreateWordRequestDto, _$identity);

  /// Serializes this CreateWordRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateWordRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateWordRequestDto&&(identical(other.lemma, _this.lemma) || other.lemma == _this.lemma)&&(identical(other.languageId, _this.languageId) || other.languageId == _this.languageId)&&(identical(other.dialectId, _this.dialectId) || other.dialectId == _this.dialectId)&&(identical(other.wordType, _this.wordType) || other.wordType == _this.wordType)&&const DeepCollectionEquality().equals(other.meanings, _this.meanings)&&const DeepCollectionEquality().equals(other.categoryIds, _this.categoryIds)&&const DeepCollectionEquality().equals(other.usageLabels, _this.usageLabels)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&const DeepCollectionEquality().equals(other.variants, _this.variants)&&const DeepCollectionEquality().equals(other.relatedWords, _this.relatedWords)&&const DeepCollectionEquality().equals(other.images, _this.images)&&(identical(other.searchMissId, _this.searchMissId) || other.searchMissId == _this.searchMissId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateWordRequestDto;
  return Object.hash(runtimeType,_this.lemma,_this.languageId,_this.dialectId,_this.wordType,const DeepCollectionEquality().hash(_this.meanings),const DeepCollectionEquality().hash(_this.categoryIds),const DeepCollectionEquality().hash(_this.usageLabels),_this.notes,const DeepCollectionEquality().hash(_this.variants),const DeepCollectionEquality().hash(_this.relatedWords),const DeepCollectionEquality().hash(_this.images),_this.searchMissId);
}

@override
String toString() {
  final _this = this as CreateWordRequestDto;
  return 'CreateWordRequestDto(lemma: ${_this.lemma}, languageId: ${_this.languageId}, dialectId: ${_this.dialectId}, wordType: ${_this.wordType}, meanings: ${_this.meanings}, categoryIds: ${_this.categoryIds}, usageLabels: ${_this.usageLabels}, notes: ${_this.notes}, variants: ${_this.variants}, relatedWords: ${_this.relatedWords}, images: ${_this.images}, searchMissId: ${_this.searchMissId})';
}


}

/// @nodoc
abstract mixin class $CreateWordRequestDtoCopyWith<$Res>  {
  factory $CreateWordRequestDtoCopyWith(CreateWordRequestDto value, $Res Function(CreateWordRequestDto) _then) = _$CreateWordRequestDtoCopyWithImpl;
@useResult
$Res call({
 String lemma,@JsonKey(name: 'language_id') String languageId,@JsonKey(name: 'dialect_id', includeIfNull: false) String? dialectId,@JsonKey(name: 'word_type') String wordType,@JsonKey(name: 'meanings') List<CreateWordMeaningDto> meanings,@JsonKey(name: 'category_ids') List<String> categoryIds,@JsonKey(name: 'usage_labels') List<String> usageLabels,@JsonKey(name: 'notes', includeIfNull: false) String? notes,@JsonKey(name: 'variants', includeIfNull: false) List<CreateWordVariantDto>? variants,@JsonKey(name: 'related_words', includeIfNull: false) List<CreateWordRelatedWordDto>? relatedWords,@JsonKey(name: 'images', includeIfNull: false) List<CreateWordImageDto>? images,@JsonKey(name: 'search_miss_id', includeIfNull: false) String? searchMissId
});




}
/// @nodoc
class _$CreateWordRequestDtoCopyWithImpl<$Res>
    implements $CreateWordRequestDtoCopyWith<$Res> {
  _$CreateWordRequestDtoCopyWithImpl(this._self, this._then);

  final CreateWordRequestDto _self;
  final $Res Function(CreateWordRequestDto) _then;

/// Create a copy of CreateWordRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lemma = null,Object? languageId = null,Object? dialectId = freezed,Object? wordType = null,Object? meanings = null,Object? categoryIds = null,Object? usageLabels = null,Object? notes = freezed,Object? variants = freezed,Object? relatedWords = freezed,Object? images = freezed,Object? searchMissId = freezed,}) {
  return _then(CreateWordRequestDto(
lemma: null == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String,languageId: null == languageId ? _self.languageId : languageId // ignore: cast_nullable_to_non_nullable
as String,dialectId: freezed == dialectId ? _self.dialectId : dialectId // ignore: cast_nullable_to_non_nullable
as String?,wordType: null == wordType ? _self.wordType : wordType // ignore: cast_nullable_to_non_nullable
as String,meanings: null == meanings ? _self.meanings : meanings // ignore: cast_nullable_to_non_nullable
as List<CreateWordMeaningDto>,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,usageLabels: null == usageLabels ? _self.usageLabels : usageLabels // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,variants: freezed == variants ? _self.variants : variants // ignore: cast_nullable_to_non_nullable
as List<CreateWordVariantDto>?,relatedWords: freezed == relatedWords ? _self.relatedWords : relatedWords // ignore: cast_nullable_to_non_nullable
as List<CreateWordRelatedWordDto>?,images: freezed == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<CreateWordImageDto>?,searchMissId: freezed == searchMissId ? _self.searchMissId : searchMissId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateWordRequestDto].
extension CreateWordRequestDtoPatterns on CreateWordRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateWordRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateWordRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateWordRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateWordRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateWordRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateWordRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String lemma, @JsonKey(name: 'language_id')  String languageId, @JsonKey(name: 'dialect_id', includeIfNull: false)  String? dialectId, @JsonKey(name: 'word_type')  String wordType, @JsonKey(name: 'meanings')  List<CreateWordMeaningDto> meanings, @JsonKey(name: 'category_ids')  List<String> categoryIds, @JsonKey(name: 'usage_labels')  List<String> usageLabels, @JsonKey(name: 'notes', includeIfNull: false)  String? notes, @JsonKey(name: 'variants', includeIfNull: false)  List<CreateWordVariantDto>? variants, @JsonKey(name: 'related_words', includeIfNull: false)  List<CreateWordRelatedWordDto>? relatedWords, @JsonKey(name: 'images', includeIfNull: false)  List<CreateWordImageDto>? images, @JsonKey(name: 'search_miss_id', includeIfNull: false)  String? searchMissId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateWordRequestDto() when $default != null:
return $default(_that.lemma,_that.languageId,_that.dialectId,_that.wordType,_that.meanings,_that.categoryIds,_that.usageLabels,_that.notes,_that.variants,_that.relatedWords,_that.images,_that.searchMissId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String lemma, @JsonKey(name: 'language_id')  String languageId, @JsonKey(name: 'dialect_id', includeIfNull: false)  String? dialectId, @JsonKey(name: 'word_type')  String wordType, @JsonKey(name: 'meanings')  List<CreateWordMeaningDto> meanings, @JsonKey(name: 'category_ids')  List<String> categoryIds, @JsonKey(name: 'usage_labels')  List<String> usageLabels, @JsonKey(name: 'notes', includeIfNull: false)  String? notes, @JsonKey(name: 'variants', includeIfNull: false)  List<CreateWordVariantDto>? variants, @JsonKey(name: 'related_words', includeIfNull: false)  List<CreateWordRelatedWordDto>? relatedWords, @JsonKey(name: 'images', includeIfNull: false)  List<CreateWordImageDto>? images, @JsonKey(name: 'search_miss_id', includeIfNull: false)  String? searchMissId)  $default,) {final _that = this;
switch (_that) {
case _CreateWordRequestDto():
return $default(_that.lemma,_that.languageId,_that.dialectId,_that.wordType,_that.meanings,_that.categoryIds,_that.usageLabels,_that.notes,_that.variants,_that.relatedWords,_that.images,_that.searchMissId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String lemma, @JsonKey(name: 'language_id')  String languageId, @JsonKey(name: 'dialect_id', includeIfNull: false)  String? dialectId, @JsonKey(name: 'word_type')  String wordType, @JsonKey(name: 'meanings')  List<CreateWordMeaningDto> meanings, @JsonKey(name: 'category_ids')  List<String> categoryIds, @JsonKey(name: 'usage_labels')  List<String> usageLabels, @JsonKey(name: 'notes', includeIfNull: false)  String? notes, @JsonKey(name: 'variants', includeIfNull: false)  List<CreateWordVariantDto>? variants, @JsonKey(name: 'related_words', includeIfNull: false)  List<CreateWordRelatedWordDto>? relatedWords, @JsonKey(name: 'images', includeIfNull: false)  List<CreateWordImageDto>? images, @JsonKey(name: 'search_miss_id', includeIfNull: false)  String? searchMissId)?  $default,) {final _that = this;
switch (_that) {
case _CreateWordRequestDto() when $default != null:
return $default(_that.lemma,_that.languageId,_that.dialectId,_that.wordType,_that.meanings,_that.categoryIds,_that.usageLabels,_that.notes,_that.variants,_that.relatedWords,_that.images,_that.searchMissId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateWordRequestDto implements CreateWordRequestDto {
  const _CreateWordRequestDto({required this.lemma, @JsonKey(name: 'language_id') required this.languageId, @JsonKey(name: 'dialect_id', includeIfNull: false) this.dialectId, @JsonKey(name: 'word_type') this.wordType = 'word', @JsonKey(name: 'meanings') required  List<CreateWordMeaningDto> meanings, @JsonKey(name: 'category_ids')  List<String> categoryIds = const [], @JsonKey(name: 'usage_labels')  List<String> usageLabels = const [], @JsonKey(name: 'notes', includeIfNull: false) this.notes, @JsonKey(name: 'variants', includeIfNull: false)  List<CreateWordVariantDto>? variants, @JsonKey(name: 'related_words', includeIfNull: false)  List<CreateWordRelatedWordDto>? relatedWords, @JsonKey(name: 'images', includeIfNull: false)  List<CreateWordImageDto>? images, @JsonKey(name: 'search_miss_id', includeIfNull: false) this.searchMissId}): _meanings = meanings,_categoryIds = categoryIds,_usageLabels = usageLabels,_variants = variants,_relatedWords = relatedWords,_images = images;
  factory _CreateWordRequestDto.fromJson(Map<String, dynamic> json) => _$CreateWordRequestDtoFromJson(json);

@override final  String lemma;
@override@JsonKey(name: 'language_id') final  String languageId;
@override@JsonKey(name: 'dialect_id', includeIfNull: false) final  String? dialectId;
@override@JsonKey(name: 'word_type') final  String wordType;
 final  List<CreateWordMeaningDto> _meanings;
@override@JsonKey(name: 'meanings') List<CreateWordMeaningDto> get meanings {
  if (_meanings is EqualUnmodifiableListView) return _meanings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_meanings);
}

 final  List<String> _categoryIds;
@override@JsonKey(name: 'category_ids') List<String> get categoryIds {
  if (_categoryIds is EqualUnmodifiableListView) return _categoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryIds);
}

 final  List<String> _usageLabels;
@override@JsonKey(name: 'usage_labels') List<String> get usageLabels {
  if (_usageLabels is EqualUnmodifiableListView) return _usageLabels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_usageLabels);
}

@override@JsonKey(name: 'notes', includeIfNull: false) final  String? notes;
 final  List<CreateWordVariantDto>? _variants;
@override@JsonKey(name: 'variants', includeIfNull: false) List<CreateWordVariantDto>? get variants {
  final value = _variants;
  if (value == null) return null;
  if (_variants is EqualUnmodifiableListView) return _variants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<CreateWordRelatedWordDto>? _relatedWords;
@override@JsonKey(name: 'related_words', includeIfNull: false) List<CreateWordRelatedWordDto>? get relatedWords {
  final value = _relatedWords;
  if (value == null) return null;
  if (_relatedWords is EqualUnmodifiableListView) return _relatedWords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<CreateWordImageDto>? _images;
@override@JsonKey(name: 'images', includeIfNull: false) List<CreateWordImageDto>? get images {
  final value = _images;
  if (value == null) return null;
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'search_miss_id', includeIfNull: false) final  String? searchMissId;

/// Create a copy of CreateWordRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateWordRequestDtoCopyWith<_CreateWordRequestDto> get copyWith => __$CreateWordRequestDtoCopyWithImpl<_CreateWordRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateWordRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateWordRequestDto&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.languageId, languageId) || other.languageId == languageId)&&(identical(other.dialectId, dialectId) || other.dialectId == dialectId)&&(identical(other.wordType, wordType) || other.wordType == wordType)&&const DeepCollectionEquality().equals(other.meanings, _meanings)&&const DeepCollectionEquality().equals(other.categoryIds, _categoryIds)&&const DeepCollectionEquality().equals(other.usageLabels, _usageLabels)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.variants, _variants)&&const DeepCollectionEquality().equals(other.relatedWords, _relatedWords)&&const DeepCollectionEquality().equals(other.images, _images)&&(identical(other.searchMissId, searchMissId) || other.searchMissId == searchMissId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lemma,languageId,dialectId,wordType,const DeepCollectionEquality().hash(_meanings),const DeepCollectionEquality().hash(_categoryIds),const DeepCollectionEquality().hash(_usageLabels),notes,const DeepCollectionEquality().hash(_variants),const DeepCollectionEquality().hash(_relatedWords),const DeepCollectionEquality().hash(_images),searchMissId);
}

@override
String toString() {
    return 'CreateWordRequestDto(lemma: $lemma, languageId: $languageId, dialectId: $dialectId, wordType: $wordType, meanings: $meanings, categoryIds: $categoryIds, usageLabels: $usageLabels, notes: $notes, variants: $variants, relatedWords: $relatedWords, images: $images, searchMissId: $searchMissId)';
}


}

/// @nodoc
abstract mixin class _$CreateWordRequestDtoCopyWith<$Res> implements $CreateWordRequestDtoCopyWith<$Res> {
  factory _$CreateWordRequestDtoCopyWith(_CreateWordRequestDto value, $Res Function(_CreateWordRequestDto) _then) = __$CreateWordRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String lemma,@JsonKey(name: 'language_id') String languageId,@JsonKey(name: 'dialect_id', includeIfNull: false) String? dialectId,@JsonKey(name: 'word_type') String wordType,@JsonKey(name: 'meanings') List<CreateWordMeaningDto> meanings,@JsonKey(name: 'category_ids') List<String> categoryIds,@JsonKey(name: 'usage_labels') List<String> usageLabels,@JsonKey(name: 'notes', includeIfNull: false) String? notes,@JsonKey(name: 'variants', includeIfNull: false) List<CreateWordVariantDto>? variants,@JsonKey(name: 'related_words', includeIfNull: false) List<CreateWordRelatedWordDto>? relatedWords,@JsonKey(name: 'images', includeIfNull: false) List<CreateWordImageDto>? images,@JsonKey(name: 'search_miss_id', includeIfNull: false) String? searchMissId
});




}
/// @nodoc
class __$CreateWordRequestDtoCopyWithImpl<$Res>
    implements _$CreateWordRequestDtoCopyWith<$Res> {
  __$CreateWordRequestDtoCopyWithImpl(this._self, this._then);

  final _CreateWordRequestDto _self;
  final $Res Function(_CreateWordRequestDto) _then;

/// Create a copy of CreateWordRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lemma = null,Object? languageId = null,Object? dialectId = freezed,Object? wordType = null,Object? meanings = null,Object? categoryIds = null,Object? usageLabels = null,Object? notes = freezed,Object? variants = freezed,Object? relatedWords = freezed,Object? images = freezed,Object? searchMissId = freezed,}) {
  return _then(_CreateWordRequestDto(
lemma: null == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String,languageId: null == languageId ? _self.languageId : languageId // ignore: cast_nullable_to_non_nullable
as String,dialectId: freezed == dialectId ? _self.dialectId : dialectId // ignore: cast_nullable_to_non_nullable
as String?,wordType: null == wordType ? _self.wordType : wordType // ignore: cast_nullable_to_non_nullable
as String,meanings: null == meanings ? _self._meanings : meanings // ignore: cast_nullable_to_non_nullable
as List<CreateWordMeaningDto>,categoryIds: null == categoryIds ? _self._categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,usageLabels: null == usageLabels ? _self._usageLabels : usageLabels // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,variants: freezed == variants ? _self._variants : variants // ignore: cast_nullable_to_non_nullable
as List<CreateWordVariantDto>?,relatedWords: freezed == relatedWords ? _self._relatedWords : relatedWords // ignore: cast_nullable_to_non_nullable
as List<CreateWordRelatedWordDto>?,images: freezed == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<CreateWordImageDto>?,searchMissId: freezed == searchMissId ? _self.searchMissId : searchMissId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
