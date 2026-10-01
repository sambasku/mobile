// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_detail_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WordDetailDto {

 String get id; String get lemma;@JsonKey(name: 'language_id') String get languageId; String? get notes;@JsonKey(name: 'word_type') String get wordType; String get status;@JsonKey(name: 'is_verified') bool get isVerified;@JsonKey(name: 'is_corrected') bool get isCorrected;@JsonKey(name: 'self_verified') bool get selfVerified;@JsonKey(name: 'verified_at') String? get verifiedAt;@JsonKey(name: 'verified_by') WordVerifierDto? get verifiedBy;@JsonKey(name: 'created_by') WordVerifierDto? get createdBy; List<MeaningDto> get meanings; List<CategoryDto> get categories;@JsonKey(name: 'usage_labels') List<String> get usageLabels; List<PronunciationDto> get pronunciations; List<WordAudioDto> get audios; List<WordImageDto> get images;@JsonKey(name: 'related_words') List<RelatedWordDto> get relatedWords;@JsonKey(name: 'appears_in') List<RelatedWordDto> get appearsIn; List<WordVariantDto> get variants;/// Hanya diisi GET /words/today; detail biasa mengabaikan (null/false).
 String? get date;@JsonKey(name: 'is_new_this_week') bool get isNewThisWeek;
/// Create a copy of WordDetailDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordDetailDtoCopyWith<WordDetailDto> get copyWith => _$WordDetailDtoCopyWithImpl<WordDetailDto>(this as WordDetailDto, _$identity);

  /// Serializes this WordDetailDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.languageId, languageId) || other.languageId == languageId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.wordType, wordType) || other.wordType == wordType)&&(identical(other.status, status) || other.status == status)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isCorrected, isCorrected) || other.isCorrected == isCorrected)&&(identical(other.selfVerified, selfVerified) || other.selfVerified == selfVerified)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&const DeepCollectionEquality().equals(other.meanings, meanings)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.usageLabels, usageLabels)&&const DeepCollectionEquality().equals(other.pronunciations, pronunciations)&&const DeepCollectionEquality().equals(other.audios, audios)&&const DeepCollectionEquality().equals(other.images, images)&&const DeepCollectionEquality().equals(other.relatedWords, relatedWords)&&const DeepCollectionEquality().equals(other.appearsIn, appearsIn)&&const DeepCollectionEquality().equals(other.variants, variants)&&(identical(other.date, date) || other.date == date)&&(identical(other.isNewThisWeek, isNewThisWeek) || other.isNewThisWeek == isNewThisWeek));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,lemma,languageId,notes,wordType,status,isVerified,isCorrected,selfVerified,verifiedAt,verifiedBy,createdBy,const DeepCollectionEquality().hash(meanings),const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(usageLabels),const DeepCollectionEquality().hash(pronunciations),const DeepCollectionEquality().hash(audios),const DeepCollectionEquality().hash(images),const DeepCollectionEquality().hash(relatedWords),const DeepCollectionEquality().hash(appearsIn),const DeepCollectionEquality().hash(variants),date,isNewThisWeek]);

@override
String toString() {
  return 'WordDetailDto(id: $id, lemma: $lemma, languageId: $languageId, notes: $notes, wordType: $wordType, status: $status, isVerified: $isVerified, isCorrected: $isCorrected, selfVerified: $selfVerified, verifiedAt: $verifiedAt, verifiedBy: $verifiedBy, createdBy: $createdBy, meanings: $meanings, categories: $categories, usageLabels: $usageLabels, pronunciations: $pronunciations, audios: $audios, images: $images, relatedWords: $relatedWords, appearsIn: $appearsIn, variants: $variants, date: $date, isNewThisWeek: $isNewThisWeek)';
}


}

/// @nodoc
abstract mixin class $WordDetailDtoCopyWith<$Res>  {
  factory $WordDetailDtoCopyWith(WordDetailDto value, $Res Function(WordDetailDto) _then) = _$WordDetailDtoCopyWithImpl;
@useResult
$Res call({
 String id, String lemma,@JsonKey(name: 'language_id') String languageId, String? notes,@JsonKey(name: 'word_type') String wordType, String status,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'is_corrected') bool isCorrected,@JsonKey(name: 'self_verified') bool selfVerified,@JsonKey(name: 'verified_at') String? verifiedAt,@JsonKey(name: 'verified_by') WordVerifierDto? verifiedBy,@JsonKey(name: 'created_by') WordVerifierDto? createdBy, List<MeaningDto> meanings, List<CategoryDto> categories,@JsonKey(name: 'usage_labels') List<String> usageLabels, List<PronunciationDto> pronunciations, List<WordAudioDto> audios, List<WordImageDto> images,@JsonKey(name: 'related_words') List<RelatedWordDto> relatedWords,@JsonKey(name: 'appears_in') List<RelatedWordDto> appearsIn, List<WordVariantDto> variants, String? date,@JsonKey(name: 'is_new_this_week') bool isNewThisWeek
});


$WordVerifierDtoCopyWith<$Res>? get verifiedBy;$WordVerifierDtoCopyWith<$Res>? get createdBy;

}
/// @nodoc
class _$WordDetailDtoCopyWithImpl<$Res>
    implements $WordDetailDtoCopyWith<$Res> {
  _$WordDetailDtoCopyWithImpl(this._self, this._then);

  final WordDetailDto _self;
  final $Res Function(WordDetailDto) _then;

/// Create a copy of WordDetailDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lemma = null,Object? languageId = null,Object? notes = freezed,Object? wordType = null,Object? status = null,Object? isVerified = null,Object? isCorrected = null,Object? selfVerified = null,Object? verifiedAt = freezed,Object? verifiedBy = freezed,Object? createdBy = freezed,Object? meanings = null,Object? categories = null,Object? usageLabels = null,Object? pronunciations = null,Object? audios = null,Object? images = null,Object? relatedWords = null,Object? appearsIn = null,Object? variants = null,Object? date = freezed,Object? isNewThisWeek = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lemma: null == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String,languageId: null == languageId ? _self.languageId : languageId // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,wordType: null == wordType ? _self.wordType : wordType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isCorrected: null == isCorrected ? _self.isCorrected : isCorrected // ignore: cast_nullable_to_non_nullable
as bool,selfVerified: null == selfVerified ? _self.selfVerified : selfVerified // ignore: cast_nullable_to_non_nullable
as bool,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as String?,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as WordVerifierDto?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as WordVerifierDto?,meanings: null == meanings ? _self.meanings : meanings // ignore: cast_nullable_to_non_nullable
as List<MeaningDto>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryDto>,usageLabels: null == usageLabels ? _self.usageLabels : usageLabels // ignore: cast_nullable_to_non_nullable
as List<String>,pronunciations: null == pronunciations ? _self.pronunciations : pronunciations // ignore: cast_nullable_to_non_nullable
as List<PronunciationDto>,audios: null == audios ? _self.audios : audios // ignore: cast_nullable_to_non_nullable
as List<WordAudioDto>,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<WordImageDto>,relatedWords: null == relatedWords ? _self.relatedWords : relatedWords // ignore: cast_nullable_to_non_nullable
as List<RelatedWordDto>,appearsIn: null == appearsIn ? _self.appearsIn : appearsIn // ignore: cast_nullable_to_non_nullable
as List<RelatedWordDto>,variants: null == variants ? _self.variants : variants // ignore: cast_nullable_to_non_nullable
as List<WordVariantDto>,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,isNewThisWeek: null == isNewThisWeek ? _self.isNewThisWeek : isNewThisWeek // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of WordDetailDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WordVerifierDtoCopyWith<$Res>? get verifiedBy {
    if (_self.verifiedBy == null) {
    return null;
  }

  return $WordVerifierDtoCopyWith<$Res>(_self.verifiedBy!, (value) {
    return _then(_self.copyWith(verifiedBy: value));
  });
}/// Create a copy of WordDetailDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WordVerifierDtoCopyWith<$Res>? get createdBy {
    if (_self.createdBy == null) {
    return null;
  }

  return $WordVerifierDtoCopyWith<$Res>(_self.createdBy!, (value) {
    return _then(_self.copyWith(createdBy: value));
  });
}
}


/// Adds pattern-matching-related methods to [WordDetailDto].
extension WordDetailDtoPatterns on WordDetailDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordDetailDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordDetailDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordDetailDto value)  $default,){
final _that = this;
switch (_that) {
case _WordDetailDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordDetailDto value)?  $default,){
final _that = this;
switch (_that) {
case _WordDetailDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String lemma, @JsonKey(name: 'language_id')  String languageId,  String? notes, @JsonKey(name: 'word_type')  String wordType,  String status, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'is_corrected')  bool isCorrected, @JsonKey(name: 'self_verified')  bool selfVerified, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'verified_by')  WordVerifierDto? verifiedBy, @JsonKey(name: 'created_by')  WordVerifierDto? createdBy,  List<MeaningDto> meanings,  List<CategoryDto> categories, @JsonKey(name: 'usage_labels')  List<String> usageLabels,  List<PronunciationDto> pronunciations,  List<WordAudioDto> audios,  List<WordImageDto> images, @JsonKey(name: 'related_words')  List<RelatedWordDto> relatedWords, @JsonKey(name: 'appears_in')  List<RelatedWordDto> appearsIn,  List<WordVariantDto> variants,  String? date, @JsonKey(name: 'is_new_this_week')  bool isNewThisWeek)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordDetailDto() when $default != null:
return $default(_that.id,_that.lemma,_that.languageId,_that.notes,_that.wordType,_that.status,_that.isVerified,_that.isCorrected,_that.selfVerified,_that.verifiedAt,_that.verifiedBy,_that.createdBy,_that.meanings,_that.categories,_that.usageLabels,_that.pronunciations,_that.audios,_that.images,_that.relatedWords,_that.appearsIn,_that.variants,_that.date,_that.isNewThisWeek);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String lemma, @JsonKey(name: 'language_id')  String languageId,  String? notes, @JsonKey(name: 'word_type')  String wordType,  String status, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'is_corrected')  bool isCorrected, @JsonKey(name: 'self_verified')  bool selfVerified, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'verified_by')  WordVerifierDto? verifiedBy, @JsonKey(name: 'created_by')  WordVerifierDto? createdBy,  List<MeaningDto> meanings,  List<CategoryDto> categories, @JsonKey(name: 'usage_labels')  List<String> usageLabels,  List<PronunciationDto> pronunciations,  List<WordAudioDto> audios,  List<WordImageDto> images, @JsonKey(name: 'related_words')  List<RelatedWordDto> relatedWords, @JsonKey(name: 'appears_in')  List<RelatedWordDto> appearsIn,  List<WordVariantDto> variants,  String? date, @JsonKey(name: 'is_new_this_week')  bool isNewThisWeek)  $default,) {final _that = this;
switch (_that) {
case _WordDetailDto():
return $default(_that.id,_that.lemma,_that.languageId,_that.notes,_that.wordType,_that.status,_that.isVerified,_that.isCorrected,_that.selfVerified,_that.verifiedAt,_that.verifiedBy,_that.createdBy,_that.meanings,_that.categories,_that.usageLabels,_that.pronunciations,_that.audios,_that.images,_that.relatedWords,_that.appearsIn,_that.variants,_that.date,_that.isNewThisWeek);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String lemma, @JsonKey(name: 'language_id')  String languageId,  String? notes, @JsonKey(name: 'word_type')  String wordType,  String status, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'is_corrected')  bool isCorrected, @JsonKey(name: 'self_verified')  bool selfVerified, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'verified_by')  WordVerifierDto? verifiedBy, @JsonKey(name: 'created_by')  WordVerifierDto? createdBy,  List<MeaningDto> meanings,  List<CategoryDto> categories, @JsonKey(name: 'usage_labels')  List<String> usageLabels,  List<PronunciationDto> pronunciations,  List<WordAudioDto> audios,  List<WordImageDto> images, @JsonKey(name: 'related_words')  List<RelatedWordDto> relatedWords, @JsonKey(name: 'appears_in')  List<RelatedWordDto> appearsIn,  List<WordVariantDto> variants,  String? date, @JsonKey(name: 'is_new_this_week')  bool isNewThisWeek)?  $default,) {final _that = this;
switch (_that) {
case _WordDetailDto() when $default != null:
return $default(_that.id,_that.lemma,_that.languageId,_that.notes,_that.wordType,_that.status,_that.isVerified,_that.isCorrected,_that.selfVerified,_that.verifiedAt,_that.verifiedBy,_that.createdBy,_that.meanings,_that.categories,_that.usageLabels,_that.pronunciations,_that.audios,_that.images,_that.relatedWords,_that.appearsIn,_that.variants,_that.date,_that.isNewThisWeek);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WordDetailDto implements WordDetailDto {
  const _WordDetailDto({required this.id, required this.lemma, @JsonKey(name: 'language_id') required this.languageId, this.notes, @JsonKey(name: 'word_type') required this.wordType, required this.status, @JsonKey(name: 'is_verified') required this.isVerified, @JsonKey(name: 'is_corrected') this.isCorrected = false, @JsonKey(name: 'self_verified') this.selfVerified = false, @JsonKey(name: 'verified_at') this.verifiedAt, @JsonKey(name: 'verified_by') this.verifiedBy, @JsonKey(name: 'created_by') this.createdBy, final  List<MeaningDto> meanings = const [], final  List<CategoryDto> categories = const [], @JsonKey(name: 'usage_labels') final  List<String> usageLabels = const [], final  List<PronunciationDto> pronunciations = const [], final  List<WordAudioDto> audios = const [], final  List<WordImageDto> images = const [], @JsonKey(name: 'related_words') final  List<RelatedWordDto> relatedWords = const [], @JsonKey(name: 'appears_in') final  List<RelatedWordDto> appearsIn = const [], final  List<WordVariantDto> variants = const [], this.date, @JsonKey(name: 'is_new_this_week') this.isNewThisWeek = false}): _meanings = meanings,_categories = categories,_usageLabels = usageLabels,_pronunciations = pronunciations,_audios = audios,_images = images,_relatedWords = relatedWords,_appearsIn = appearsIn,_variants = variants;
  factory _WordDetailDto.fromJson(Map<String, dynamic> json) => _$WordDetailDtoFromJson(json);

@override final  String id;
@override final  String lemma;
@override@JsonKey(name: 'language_id') final  String languageId;
@override final  String? notes;
@override@JsonKey(name: 'word_type') final  String wordType;
@override final  String status;
@override@JsonKey(name: 'is_verified') final  bool isVerified;
@override@JsonKey(name: 'is_corrected') final  bool isCorrected;
@override@JsonKey(name: 'self_verified') final  bool selfVerified;
@override@JsonKey(name: 'verified_at') final  String? verifiedAt;
@override@JsonKey(name: 'verified_by') final  WordVerifierDto? verifiedBy;
@override@JsonKey(name: 'created_by') final  WordVerifierDto? createdBy;
 final  List<MeaningDto> _meanings;
@override@JsonKey() List<MeaningDto> get meanings {
  if (_meanings is EqualUnmodifiableListView) return _meanings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_meanings);
}

 final  List<CategoryDto> _categories;
@override@JsonKey() List<CategoryDto> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<String> _usageLabels;
@override@JsonKey(name: 'usage_labels') List<String> get usageLabels {
  if (_usageLabels is EqualUnmodifiableListView) return _usageLabels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_usageLabels);
}

 final  List<PronunciationDto> _pronunciations;
@override@JsonKey() List<PronunciationDto> get pronunciations {
  if (_pronunciations is EqualUnmodifiableListView) return _pronunciations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pronunciations);
}

 final  List<WordAudioDto> _audios;
@override@JsonKey() List<WordAudioDto> get audios {
  if (_audios is EqualUnmodifiableListView) return _audios;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_audios);
}

 final  List<WordImageDto> _images;
@override@JsonKey() List<WordImageDto> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

 final  List<RelatedWordDto> _relatedWords;
@override@JsonKey(name: 'related_words') List<RelatedWordDto> get relatedWords {
  if (_relatedWords is EqualUnmodifiableListView) return _relatedWords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_relatedWords);
}

 final  List<RelatedWordDto> _appearsIn;
@override@JsonKey(name: 'appears_in') List<RelatedWordDto> get appearsIn {
  if (_appearsIn is EqualUnmodifiableListView) return _appearsIn;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_appearsIn);
}

 final  List<WordVariantDto> _variants;
@override@JsonKey() List<WordVariantDto> get variants {
  if (_variants is EqualUnmodifiableListView) return _variants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_variants);
}

/// Hanya diisi GET /words/today; detail biasa mengabaikan (null/false).
@override final  String? date;
@override@JsonKey(name: 'is_new_this_week') final  bool isNewThisWeek;

/// Create a copy of WordDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordDetailDtoCopyWith<_WordDetailDto> get copyWith => __$WordDetailDtoCopyWithImpl<_WordDetailDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WordDetailDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.languageId, languageId) || other.languageId == languageId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.wordType, wordType) || other.wordType == wordType)&&(identical(other.status, status) || other.status == status)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isCorrected, isCorrected) || other.isCorrected == isCorrected)&&(identical(other.selfVerified, selfVerified) || other.selfVerified == selfVerified)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&const DeepCollectionEquality().equals(other._meanings, _meanings)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._usageLabels, _usageLabels)&&const DeepCollectionEquality().equals(other._pronunciations, _pronunciations)&&const DeepCollectionEquality().equals(other._audios, _audios)&&const DeepCollectionEquality().equals(other._images, _images)&&const DeepCollectionEquality().equals(other._relatedWords, _relatedWords)&&const DeepCollectionEquality().equals(other._appearsIn, _appearsIn)&&const DeepCollectionEquality().equals(other._variants, _variants)&&(identical(other.date, date) || other.date == date)&&(identical(other.isNewThisWeek, isNewThisWeek) || other.isNewThisWeek == isNewThisWeek));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,lemma,languageId,notes,wordType,status,isVerified,isCorrected,selfVerified,verifiedAt,verifiedBy,createdBy,const DeepCollectionEquality().hash(_meanings),const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_usageLabels),const DeepCollectionEquality().hash(_pronunciations),const DeepCollectionEquality().hash(_audios),const DeepCollectionEquality().hash(_images),const DeepCollectionEquality().hash(_relatedWords),const DeepCollectionEquality().hash(_appearsIn),const DeepCollectionEquality().hash(_variants),date,isNewThisWeek]);

@override
String toString() {
  return 'WordDetailDto(id: $id, lemma: $lemma, languageId: $languageId, notes: $notes, wordType: $wordType, status: $status, isVerified: $isVerified, isCorrected: $isCorrected, selfVerified: $selfVerified, verifiedAt: $verifiedAt, verifiedBy: $verifiedBy, createdBy: $createdBy, meanings: $meanings, categories: $categories, usageLabels: $usageLabels, pronunciations: $pronunciations, audios: $audios, images: $images, relatedWords: $relatedWords, appearsIn: $appearsIn, variants: $variants, date: $date, isNewThisWeek: $isNewThisWeek)';
}


}

/// @nodoc
abstract mixin class _$WordDetailDtoCopyWith<$Res> implements $WordDetailDtoCopyWith<$Res> {
  factory _$WordDetailDtoCopyWith(_WordDetailDto value, $Res Function(_WordDetailDto) _then) = __$WordDetailDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String lemma,@JsonKey(name: 'language_id') String languageId, String? notes,@JsonKey(name: 'word_type') String wordType, String status,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'is_corrected') bool isCorrected,@JsonKey(name: 'self_verified') bool selfVerified,@JsonKey(name: 'verified_at') String? verifiedAt,@JsonKey(name: 'verified_by') WordVerifierDto? verifiedBy,@JsonKey(name: 'created_by') WordVerifierDto? createdBy, List<MeaningDto> meanings, List<CategoryDto> categories,@JsonKey(name: 'usage_labels') List<String> usageLabels, List<PronunciationDto> pronunciations, List<WordAudioDto> audios, List<WordImageDto> images,@JsonKey(name: 'related_words') List<RelatedWordDto> relatedWords,@JsonKey(name: 'appears_in') List<RelatedWordDto> appearsIn, List<WordVariantDto> variants, String? date,@JsonKey(name: 'is_new_this_week') bool isNewThisWeek
});


@override $WordVerifierDtoCopyWith<$Res>? get verifiedBy;@override $WordVerifierDtoCopyWith<$Res>? get createdBy;

}
/// @nodoc
class __$WordDetailDtoCopyWithImpl<$Res>
    implements _$WordDetailDtoCopyWith<$Res> {
  __$WordDetailDtoCopyWithImpl(this._self, this._then);

  final _WordDetailDto _self;
  final $Res Function(_WordDetailDto) _then;

/// Create a copy of WordDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lemma = null,Object? languageId = null,Object? notes = freezed,Object? wordType = null,Object? status = null,Object? isVerified = null,Object? isCorrected = null,Object? selfVerified = null,Object? verifiedAt = freezed,Object? verifiedBy = freezed,Object? createdBy = freezed,Object? meanings = null,Object? categories = null,Object? usageLabels = null,Object? pronunciations = null,Object? audios = null,Object? images = null,Object? relatedWords = null,Object? appearsIn = null,Object? variants = null,Object? date = freezed,Object? isNewThisWeek = null,}) {
  return _then(_WordDetailDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lemma: null == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String,languageId: null == languageId ? _self.languageId : languageId // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,wordType: null == wordType ? _self.wordType : wordType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isCorrected: null == isCorrected ? _self.isCorrected : isCorrected // ignore: cast_nullable_to_non_nullable
as bool,selfVerified: null == selfVerified ? _self.selfVerified : selfVerified // ignore: cast_nullable_to_non_nullable
as bool,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as String?,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as WordVerifierDto?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as WordVerifierDto?,meanings: null == meanings ? _self._meanings : meanings // ignore: cast_nullable_to_non_nullable
as List<MeaningDto>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryDto>,usageLabels: null == usageLabels ? _self._usageLabels : usageLabels // ignore: cast_nullable_to_non_nullable
as List<String>,pronunciations: null == pronunciations ? _self._pronunciations : pronunciations // ignore: cast_nullable_to_non_nullable
as List<PronunciationDto>,audios: null == audios ? _self._audios : audios // ignore: cast_nullable_to_non_nullable
as List<WordAudioDto>,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<WordImageDto>,relatedWords: null == relatedWords ? _self._relatedWords : relatedWords // ignore: cast_nullable_to_non_nullable
as List<RelatedWordDto>,appearsIn: null == appearsIn ? _self._appearsIn : appearsIn // ignore: cast_nullable_to_non_nullable
as List<RelatedWordDto>,variants: null == variants ? _self._variants : variants // ignore: cast_nullable_to_non_nullable
as List<WordVariantDto>,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,isNewThisWeek: null == isNewThisWeek ? _self.isNewThisWeek : isNewThisWeek // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of WordDetailDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WordVerifierDtoCopyWith<$Res>? get verifiedBy {
    if (_self.verifiedBy == null) {
    return null;
  }

  return $WordVerifierDtoCopyWith<$Res>(_self.verifiedBy!, (value) {
    return _then(_self.copyWith(verifiedBy: value));
  });
}/// Create a copy of WordDetailDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WordVerifierDtoCopyWith<$Res>? get createdBy {
    if (_self.createdBy == null) {
    return null;
  }

  return $WordVerifierDtoCopyWith<$Res>(_self.createdBy!, (value) {
    return _then(_self.copyWith(createdBy: value));
  });
}
}


/// @nodoc
mixin _$WordVerifierDto {

 String get username;@JsonKey(name: 'display_name') String? get displayName; String get role;
/// Create a copy of WordVerifierDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordVerifierDtoCopyWith<WordVerifierDto> get copyWith => _$WordVerifierDtoCopyWithImpl<WordVerifierDto>(this as WordVerifierDto, _$identity);

  /// Serializes this WordVerifierDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordVerifierDto&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,displayName,role);

@override
String toString() {
  return 'WordVerifierDto(username: $username, displayName: $displayName, role: $role)';
}


}

/// @nodoc
abstract mixin class $WordVerifierDtoCopyWith<$Res>  {
  factory $WordVerifierDtoCopyWith(WordVerifierDto value, $Res Function(WordVerifierDto) _then) = _$WordVerifierDtoCopyWithImpl;
@useResult
$Res call({
 String username,@JsonKey(name: 'display_name') String? displayName, String role
});




}
/// @nodoc
class _$WordVerifierDtoCopyWithImpl<$Res>
    implements $WordVerifierDtoCopyWith<$Res> {
  _$WordVerifierDtoCopyWithImpl(this._self, this._then);

  final WordVerifierDto _self;
  final $Res Function(WordVerifierDto) _then;

/// Create a copy of WordVerifierDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? displayName = freezed,Object? role = null,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WordVerifierDto].
extension WordVerifierDtoPatterns on WordVerifierDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordVerifierDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordVerifierDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordVerifierDto value)  $default,){
final _that = this;
switch (_that) {
case _WordVerifierDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordVerifierDto value)?  $default,){
final _that = this;
switch (_that) {
case _WordVerifierDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username, @JsonKey(name: 'display_name')  String? displayName,  String role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordVerifierDto() when $default != null:
return $default(_that.username,_that.displayName,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username, @JsonKey(name: 'display_name')  String? displayName,  String role)  $default,) {final _that = this;
switch (_that) {
case _WordVerifierDto():
return $default(_that.username,_that.displayName,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username, @JsonKey(name: 'display_name')  String? displayName,  String role)?  $default,) {final _that = this;
switch (_that) {
case _WordVerifierDto() when $default != null:
return $default(_that.username,_that.displayName,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WordVerifierDto implements WordVerifierDto {
  const _WordVerifierDto({required this.username, @JsonKey(name: 'display_name') this.displayName, required this.role});
  factory _WordVerifierDto.fromJson(Map<String, dynamic> json) => _$WordVerifierDtoFromJson(json);

@override final  String username;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override final  String role;

/// Create a copy of WordVerifierDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordVerifierDtoCopyWith<_WordVerifierDto> get copyWith => __$WordVerifierDtoCopyWithImpl<_WordVerifierDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WordVerifierDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordVerifierDto&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,displayName,role);

@override
String toString() {
  return 'WordVerifierDto(username: $username, displayName: $displayName, role: $role)';
}


}

/// @nodoc
abstract mixin class _$WordVerifierDtoCopyWith<$Res> implements $WordVerifierDtoCopyWith<$Res> {
  factory _$WordVerifierDtoCopyWith(_WordVerifierDto value, $Res Function(_WordVerifierDto) _then) = __$WordVerifierDtoCopyWithImpl;
@override @useResult
$Res call({
 String username,@JsonKey(name: 'display_name') String? displayName, String role
});




}
/// @nodoc
class __$WordVerifierDtoCopyWithImpl<$Res>
    implements _$WordVerifierDtoCopyWith<$Res> {
  __$WordVerifierDtoCopyWithImpl(this._self, this._then);

  final _WordVerifierDto _self;
  final $Res Function(_WordVerifierDto) _then;

/// Create a copy of WordVerifierDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? displayName = freezed,Object? role = null,}) {
  return _then(_WordVerifierDto(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MeaningDto {

 String get id;@JsonKey(name: 'word_class') WordClassDto? get wordClass;@JsonKey(name: 'inherited_from_meaning_id') String? get inheritedFromMeaningId; String? get definition;@JsonKey(name: 'order_index') int get orderIndex; List<TranslationDto> get translations; List<ExampleDto> get examples;
/// Create a copy of MeaningDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeaningDtoCopyWith<MeaningDto> get copyWith => _$MeaningDtoCopyWithImpl<MeaningDto>(this as MeaningDto, _$identity);

  /// Serializes this MeaningDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeaningDto&&(identical(other.id, id) || other.id == id)&&(identical(other.wordClass, wordClass) || other.wordClass == wordClass)&&(identical(other.inheritedFromMeaningId, inheritedFromMeaningId) || other.inheritedFromMeaningId == inheritedFromMeaningId)&&(identical(other.definition, definition) || other.definition == definition)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&const DeepCollectionEquality().equals(other.translations, translations)&&const DeepCollectionEquality().equals(other.examples, examples));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,wordClass,inheritedFromMeaningId,definition,orderIndex,const DeepCollectionEquality().hash(translations),const DeepCollectionEquality().hash(examples));

@override
String toString() {
  return 'MeaningDto(id: $id, wordClass: $wordClass, inheritedFromMeaningId: $inheritedFromMeaningId, definition: $definition, orderIndex: $orderIndex, translations: $translations, examples: $examples)';
}


}

/// @nodoc
abstract mixin class $MeaningDtoCopyWith<$Res>  {
  factory $MeaningDtoCopyWith(MeaningDto value, $Res Function(MeaningDto) _then) = _$MeaningDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'word_class') WordClassDto? wordClass,@JsonKey(name: 'inherited_from_meaning_id') String? inheritedFromMeaningId, String? definition,@JsonKey(name: 'order_index') int orderIndex, List<TranslationDto> translations, List<ExampleDto> examples
});


$WordClassDtoCopyWith<$Res>? get wordClass;

}
/// @nodoc
class _$MeaningDtoCopyWithImpl<$Res>
    implements $MeaningDtoCopyWith<$Res> {
  _$MeaningDtoCopyWithImpl(this._self, this._then);

  final MeaningDto _self;
  final $Res Function(MeaningDto) _then;

/// Create a copy of MeaningDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? wordClass = freezed,Object? inheritedFromMeaningId = freezed,Object? definition = freezed,Object? orderIndex = null,Object? translations = null,Object? examples = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,wordClass: freezed == wordClass ? _self.wordClass : wordClass // ignore: cast_nullable_to_non_nullable
as WordClassDto?,inheritedFromMeaningId: freezed == inheritedFromMeaningId ? _self.inheritedFromMeaningId : inheritedFromMeaningId // ignore: cast_nullable_to_non_nullable
as String?,definition: freezed == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String?,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,translations: null == translations ? _self.translations : translations // ignore: cast_nullable_to_non_nullable
as List<TranslationDto>,examples: null == examples ? _self.examples : examples // ignore: cast_nullable_to_non_nullable
as List<ExampleDto>,
  ));
}
/// Create a copy of MeaningDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WordClassDtoCopyWith<$Res>? get wordClass {
    if (_self.wordClass == null) {
    return null;
  }

  return $WordClassDtoCopyWith<$Res>(_self.wordClass!, (value) {
    return _then(_self.copyWith(wordClass: value));
  });
}
}


/// Adds pattern-matching-related methods to [MeaningDto].
extension MeaningDtoPatterns on MeaningDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeaningDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeaningDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeaningDto value)  $default,){
final _that = this;
switch (_that) {
case _MeaningDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeaningDto value)?  $default,){
final _that = this;
switch (_that) {
case _MeaningDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'word_class')  WordClassDto? wordClass, @JsonKey(name: 'inherited_from_meaning_id')  String? inheritedFromMeaningId,  String? definition, @JsonKey(name: 'order_index')  int orderIndex,  List<TranslationDto> translations,  List<ExampleDto> examples)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeaningDto() when $default != null:
return $default(_that.id,_that.wordClass,_that.inheritedFromMeaningId,_that.definition,_that.orderIndex,_that.translations,_that.examples);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'word_class')  WordClassDto? wordClass, @JsonKey(name: 'inherited_from_meaning_id')  String? inheritedFromMeaningId,  String? definition, @JsonKey(name: 'order_index')  int orderIndex,  List<TranslationDto> translations,  List<ExampleDto> examples)  $default,) {final _that = this;
switch (_that) {
case _MeaningDto():
return $default(_that.id,_that.wordClass,_that.inheritedFromMeaningId,_that.definition,_that.orderIndex,_that.translations,_that.examples);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'word_class')  WordClassDto? wordClass, @JsonKey(name: 'inherited_from_meaning_id')  String? inheritedFromMeaningId,  String? definition, @JsonKey(name: 'order_index')  int orderIndex,  List<TranslationDto> translations,  List<ExampleDto> examples)?  $default,) {final _that = this;
switch (_that) {
case _MeaningDto() when $default != null:
return $default(_that.id,_that.wordClass,_that.inheritedFromMeaningId,_that.definition,_that.orderIndex,_that.translations,_that.examples);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeaningDto implements MeaningDto {
  const _MeaningDto({required this.id, @JsonKey(name: 'word_class') this.wordClass, @JsonKey(name: 'inherited_from_meaning_id') this.inheritedFromMeaningId, this.definition, @JsonKey(name: 'order_index') this.orderIndex = 0, final  List<TranslationDto> translations = const [], final  List<ExampleDto> examples = const []}): _translations = translations,_examples = examples;
  factory _MeaningDto.fromJson(Map<String, dynamic> json) => _$MeaningDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'word_class') final  WordClassDto? wordClass;
@override@JsonKey(name: 'inherited_from_meaning_id') final  String? inheritedFromMeaningId;
@override final  String? definition;
@override@JsonKey(name: 'order_index') final  int orderIndex;
 final  List<TranslationDto> _translations;
@override@JsonKey() List<TranslationDto> get translations {
  if (_translations is EqualUnmodifiableListView) return _translations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_translations);
}

 final  List<ExampleDto> _examples;
@override@JsonKey() List<ExampleDto> get examples {
  if (_examples is EqualUnmodifiableListView) return _examples;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_examples);
}


/// Create a copy of MeaningDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeaningDtoCopyWith<_MeaningDto> get copyWith => __$MeaningDtoCopyWithImpl<_MeaningDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeaningDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeaningDto&&(identical(other.id, id) || other.id == id)&&(identical(other.wordClass, wordClass) || other.wordClass == wordClass)&&(identical(other.inheritedFromMeaningId, inheritedFromMeaningId) || other.inheritedFromMeaningId == inheritedFromMeaningId)&&(identical(other.definition, definition) || other.definition == definition)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&const DeepCollectionEquality().equals(other._translations, _translations)&&const DeepCollectionEquality().equals(other._examples, _examples));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,wordClass,inheritedFromMeaningId,definition,orderIndex,const DeepCollectionEquality().hash(_translations),const DeepCollectionEquality().hash(_examples));

@override
String toString() {
  return 'MeaningDto(id: $id, wordClass: $wordClass, inheritedFromMeaningId: $inheritedFromMeaningId, definition: $definition, orderIndex: $orderIndex, translations: $translations, examples: $examples)';
}


}

/// @nodoc
abstract mixin class _$MeaningDtoCopyWith<$Res> implements $MeaningDtoCopyWith<$Res> {
  factory _$MeaningDtoCopyWith(_MeaningDto value, $Res Function(_MeaningDto) _then) = __$MeaningDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'word_class') WordClassDto? wordClass,@JsonKey(name: 'inherited_from_meaning_id') String? inheritedFromMeaningId, String? definition,@JsonKey(name: 'order_index') int orderIndex, List<TranslationDto> translations, List<ExampleDto> examples
});


@override $WordClassDtoCopyWith<$Res>? get wordClass;

}
/// @nodoc
class __$MeaningDtoCopyWithImpl<$Res>
    implements _$MeaningDtoCopyWith<$Res> {
  __$MeaningDtoCopyWithImpl(this._self, this._then);

  final _MeaningDto _self;
  final $Res Function(_MeaningDto) _then;

/// Create a copy of MeaningDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? wordClass = freezed,Object? inheritedFromMeaningId = freezed,Object? definition = freezed,Object? orderIndex = null,Object? translations = null,Object? examples = null,}) {
  return _then(_MeaningDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,wordClass: freezed == wordClass ? _self.wordClass : wordClass // ignore: cast_nullable_to_non_nullable
as WordClassDto?,inheritedFromMeaningId: freezed == inheritedFromMeaningId ? _self.inheritedFromMeaningId : inheritedFromMeaningId // ignore: cast_nullable_to_non_nullable
as String?,definition: freezed == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String?,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,translations: null == translations ? _self._translations : translations // ignore: cast_nullable_to_non_nullable
as List<TranslationDto>,examples: null == examples ? _self._examples : examples // ignore: cast_nullable_to_non_nullable
as List<ExampleDto>,
  ));
}

/// Create a copy of MeaningDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WordClassDtoCopyWith<$Res>? get wordClass {
    if (_self.wordClass == null) {
    return null;
  }

  return $WordClassDtoCopyWith<$Res>(_self.wordClass!, (value) {
    return _then(_self.copyWith(wordClass: value));
  });
}
}


/// @nodoc
mixin _$WordClassDto {

 String get id; String get code; String get name; String? get alias;@JsonKey(name: 'parent_id') String? get parentId;
/// Create a copy of WordClassDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordClassDtoCopyWith<WordClassDto> get copyWith => _$WordClassDtoCopyWithImpl<WordClassDto>(this as WordClassDto, _$identity);

  /// Serializes this WordClassDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordClassDto&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.alias, alias) || other.alias == alias)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,name,alias,parentId);

@override
String toString() {
  return 'WordClassDto(id: $id, code: $code, name: $name, alias: $alias, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class $WordClassDtoCopyWith<$Res>  {
  factory $WordClassDtoCopyWith(WordClassDto value, $Res Function(WordClassDto) _then) = _$WordClassDtoCopyWithImpl;
@useResult
$Res call({
 String id, String code, String name, String? alias,@JsonKey(name: 'parent_id') String? parentId
});




}
/// @nodoc
class _$WordClassDtoCopyWithImpl<$Res>
    implements $WordClassDtoCopyWith<$Res> {
  _$WordClassDtoCopyWithImpl(this._self, this._then);

  final WordClassDto _self;
  final $Res Function(WordClassDto) _then;

/// Create a copy of WordClassDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? alias = freezed,Object? parentId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,alias: freezed == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WordClassDto].
extension WordClassDtoPatterns on WordClassDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordClassDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordClassDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordClassDto value)  $default,){
final _that = this;
switch (_that) {
case _WordClassDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordClassDto value)?  $default,){
final _that = this;
switch (_that) {
case _WordClassDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  String name,  String? alias, @JsonKey(name: 'parent_id')  String? parentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordClassDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.alias,_that.parentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  String name,  String? alias, @JsonKey(name: 'parent_id')  String? parentId)  $default,) {final _that = this;
switch (_that) {
case _WordClassDto():
return $default(_that.id,_that.code,_that.name,_that.alias,_that.parentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  String name,  String? alias, @JsonKey(name: 'parent_id')  String? parentId)?  $default,) {final _that = this;
switch (_that) {
case _WordClassDto() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.alias,_that.parentId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WordClassDto implements WordClassDto {
  const _WordClassDto({required this.id, required this.code, required this.name, this.alias, @JsonKey(name: 'parent_id') this.parentId});
  factory _WordClassDto.fromJson(Map<String, dynamic> json) => _$WordClassDtoFromJson(json);

@override final  String id;
@override final  String code;
@override final  String name;
@override final  String? alias;
@override@JsonKey(name: 'parent_id') final  String? parentId;

/// Create a copy of WordClassDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordClassDtoCopyWith<_WordClassDto> get copyWith => __$WordClassDtoCopyWithImpl<_WordClassDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WordClassDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordClassDto&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.alias, alias) || other.alias == alias)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,name,alias,parentId);

@override
String toString() {
  return 'WordClassDto(id: $id, code: $code, name: $name, alias: $alias, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class _$WordClassDtoCopyWith<$Res> implements $WordClassDtoCopyWith<$Res> {
  factory _$WordClassDtoCopyWith(_WordClassDto value, $Res Function(_WordClassDto) _then) = __$WordClassDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, String name, String? alias,@JsonKey(name: 'parent_id') String? parentId
});




}
/// @nodoc
class __$WordClassDtoCopyWithImpl<$Res>
    implements _$WordClassDtoCopyWith<$Res> {
  __$WordClassDtoCopyWithImpl(this._self, this._then);

  final _WordClassDto _self;
  final $Res Function(_WordClassDto) _then;

/// Create a copy of WordClassDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? alias = freezed,Object? parentId = freezed,}) {
  return _then(_WordClassDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,alias: freezed == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TranslationDto {

@JsonKey(name: 'language_id') String get languageId;@JsonKey(name: 'translation_text') String get translationText;@JsonKey(name: 'translation_type') String get translationType;
/// Create a copy of TranslationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslationDtoCopyWith<TranslationDto> get copyWith => _$TranslationDtoCopyWithImpl<TranslationDto>(this as TranslationDto, _$identity);

  /// Serializes this TranslationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslationDto&&(identical(other.languageId, languageId) || other.languageId == languageId)&&(identical(other.translationText, translationText) || other.translationText == translationText)&&(identical(other.translationType, translationType) || other.translationType == translationType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,languageId,translationText,translationType);

@override
String toString() {
  return 'TranslationDto(languageId: $languageId, translationText: $translationText, translationType: $translationType)';
}


}

/// @nodoc
abstract mixin class $TranslationDtoCopyWith<$Res>  {
  factory $TranslationDtoCopyWith(TranslationDto value, $Res Function(TranslationDto) _then) = _$TranslationDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'language_id') String languageId,@JsonKey(name: 'translation_text') String translationText,@JsonKey(name: 'translation_type') String translationType
});




}
/// @nodoc
class _$TranslationDtoCopyWithImpl<$Res>
    implements $TranslationDtoCopyWith<$Res> {
  _$TranslationDtoCopyWithImpl(this._self, this._then);

  final TranslationDto _self;
  final $Res Function(TranslationDto) _then;

/// Create a copy of TranslationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? languageId = null,Object? translationText = null,Object? translationType = null,}) {
  return _then(_self.copyWith(
languageId: null == languageId ? _self.languageId : languageId // ignore: cast_nullable_to_non_nullable
as String,translationText: null == translationText ? _self.translationText : translationText // ignore: cast_nullable_to_non_nullable
as String,translationType: null == translationType ? _self.translationType : translationType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TranslationDto].
extension TranslationDtoPatterns on TranslationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranslationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranslationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranslationDto value)  $default,){
final _that = this;
switch (_that) {
case _TranslationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranslationDto value)?  $default,){
final _that = this;
switch (_that) {
case _TranslationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'language_id')  String languageId, @JsonKey(name: 'translation_text')  String translationText, @JsonKey(name: 'translation_type')  String translationType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslationDto() when $default != null:
return $default(_that.languageId,_that.translationText,_that.translationType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'language_id')  String languageId, @JsonKey(name: 'translation_text')  String translationText, @JsonKey(name: 'translation_type')  String translationType)  $default,) {final _that = this;
switch (_that) {
case _TranslationDto():
return $default(_that.languageId,_that.translationText,_that.translationType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'language_id')  String languageId, @JsonKey(name: 'translation_text')  String translationText, @JsonKey(name: 'translation_type')  String translationType)?  $default,) {final _that = this;
switch (_that) {
case _TranslationDto() when $default != null:
return $default(_that.languageId,_that.translationText,_that.translationType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranslationDto implements TranslationDto {
  const _TranslationDto({@JsonKey(name: 'language_id') required this.languageId, @JsonKey(name: 'translation_text') required this.translationText, @JsonKey(name: 'translation_type') required this.translationType});
  factory _TranslationDto.fromJson(Map<String, dynamic> json) => _$TranslationDtoFromJson(json);

@override@JsonKey(name: 'language_id') final  String languageId;
@override@JsonKey(name: 'translation_text') final  String translationText;
@override@JsonKey(name: 'translation_type') final  String translationType;

/// Create a copy of TranslationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslationDtoCopyWith<_TranslationDto> get copyWith => __$TranslationDtoCopyWithImpl<_TranslationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranslationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslationDto&&(identical(other.languageId, languageId) || other.languageId == languageId)&&(identical(other.translationText, translationText) || other.translationText == translationText)&&(identical(other.translationType, translationType) || other.translationType == translationType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,languageId,translationText,translationType);

@override
String toString() {
  return 'TranslationDto(languageId: $languageId, translationText: $translationText, translationType: $translationType)';
}


}

/// @nodoc
abstract mixin class _$TranslationDtoCopyWith<$Res> implements $TranslationDtoCopyWith<$Res> {
  factory _$TranslationDtoCopyWith(_TranslationDto value, $Res Function(_TranslationDto) _then) = __$TranslationDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'language_id') String languageId,@JsonKey(name: 'translation_text') String translationText,@JsonKey(name: 'translation_type') String translationType
});




}
/// @nodoc
class __$TranslationDtoCopyWithImpl<$Res>
    implements _$TranslationDtoCopyWith<$Res> {
  __$TranslationDtoCopyWithImpl(this._self, this._then);

  final _TranslationDto _self;
  final $Res Function(_TranslationDto) _then;

/// Create a copy of TranslationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? languageId = null,Object? translationText = null,Object? translationType = null,}) {
  return _then(_TranslationDto(
languageId: null == languageId ? _self.languageId : languageId // ignore: cast_nullable_to_non_nullable
as String,translationText: null == translationText ? _self.translationText : translationText // ignore: cast_nullable_to_non_nullable
as String,translationType: null == translationType ? _self.translationType : translationType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ExampleDto {

 String get id;@JsonKey(name: 'source_language_id') String get sourceLanguageId;@JsonKey(name: 'source_sentence') String get sourceSentence;@JsonKey(name: 'target_language_id', fromJson: nullableStringFromJson) String? get targetLanguageId;@JsonKey(name: 'target_sentence', fromJson: nullableStringFromJson) String? get targetSentence;@JsonKey(name: 'source_type', fromJson: nullableStringFromJson) String? get sourceType; List<WordAudioDto> get audios;
/// Create a copy of ExampleDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExampleDtoCopyWith<ExampleDto> get copyWith => _$ExampleDtoCopyWithImpl<ExampleDto>(this as ExampleDto, _$identity);

  /// Serializes this ExampleDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExampleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceLanguageId, sourceLanguageId) || other.sourceLanguageId == sourceLanguageId)&&(identical(other.sourceSentence, sourceSentence) || other.sourceSentence == sourceSentence)&&(identical(other.targetLanguageId, targetLanguageId) || other.targetLanguageId == targetLanguageId)&&(identical(other.targetSentence, targetSentence) || other.targetSentence == targetSentence)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&const DeepCollectionEquality().equals(other.audios, audios));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceLanguageId,sourceSentence,targetLanguageId,targetSentence,sourceType,const DeepCollectionEquality().hash(audios));

@override
String toString() {
  return 'ExampleDto(id: $id, sourceLanguageId: $sourceLanguageId, sourceSentence: $sourceSentence, targetLanguageId: $targetLanguageId, targetSentence: $targetSentence, sourceType: $sourceType, audios: $audios)';
}


}

/// @nodoc
abstract mixin class $ExampleDtoCopyWith<$Res>  {
  factory $ExampleDtoCopyWith(ExampleDto value, $Res Function(ExampleDto) _then) = _$ExampleDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'source_language_id') String sourceLanguageId,@JsonKey(name: 'source_sentence') String sourceSentence,@JsonKey(name: 'target_language_id', fromJson: nullableStringFromJson) String? targetLanguageId,@JsonKey(name: 'target_sentence', fromJson: nullableStringFromJson) String? targetSentence,@JsonKey(name: 'source_type', fromJson: nullableStringFromJson) String? sourceType, List<WordAudioDto> audios
});




}
/// @nodoc
class _$ExampleDtoCopyWithImpl<$Res>
    implements $ExampleDtoCopyWith<$Res> {
  _$ExampleDtoCopyWithImpl(this._self, this._then);

  final ExampleDto _self;
  final $Res Function(ExampleDto) _then;

/// Create a copy of ExampleDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sourceLanguageId = null,Object? sourceSentence = null,Object? targetLanguageId = freezed,Object? targetSentence = freezed,Object? sourceType = freezed,Object? audios = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceLanguageId: null == sourceLanguageId ? _self.sourceLanguageId : sourceLanguageId // ignore: cast_nullable_to_non_nullable
as String,sourceSentence: null == sourceSentence ? _self.sourceSentence : sourceSentence // ignore: cast_nullable_to_non_nullable
as String,targetLanguageId: freezed == targetLanguageId ? _self.targetLanguageId : targetLanguageId // ignore: cast_nullable_to_non_nullable
as String?,targetSentence: freezed == targetSentence ? _self.targetSentence : targetSentence // ignore: cast_nullable_to_non_nullable
as String?,sourceType: freezed == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String?,audios: null == audios ? _self.audios : audios // ignore: cast_nullable_to_non_nullable
as List<WordAudioDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExampleDto].
extension ExampleDtoPatterns on ExampleDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExampleDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExampleDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExampleDto value)  $default,){
final _that = this;
switch (_that) {
case _ExampleDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExampleDto value)?  $default,){
final _that = this;
switch (_that) {
case _ExampleDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'source_language_id')  String sourceLanguageId, @JsonKey(name: 'source_sentence')  String sourceSentence, @JsonKey(name: 'target_language_id', fromJson: nullableStringFromJson)  String? targetLanguageId, @JsonKey(name: 'target_sentence', fromJson: nullableStringFromJson)  String? targetSentence, @JsonKey(name: 'source_type', fromJson: nullableStringFromJson)  String? sourceType,  List<WordAudioDto> audios)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExampleDto() when $default != null:
return $default(_that.id,_that.sourceLanguageId,_that.sourceSentence,_that.targetLanguageId,_that.targetSentence,_that.sourceType,_that.audios);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'source_language_id')  String sourceLanguageId, @JsonKey(name: 'source_sentence')  String sourceSentence, @JsonKey(name: 'target_language_id', fromJson: nullableStringFromJson)  String? targetLanguageId, @JsonKey(name: 'target_sentence', fromJson: nullableStringFromJson)  String? targetSentence, @JsonKey(name: 'source_type', fromJson: nullableStringFromJson)  String? sourceType,  List<WordAudioDto> audios)  $default,) {final _that = this;
switch (_that) {
case _ExampleDto():
return $default(_that.id,_that.sourceLanguageId,_that.sourceSentence,_that.targetLanguageId,_that.targetSentence,_that.sourceType,_that.audios);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'source_language_id')  String sourceLanguageId, @JsonKey(name: 'source_sentence')  String sourceSentence, @JsonKey(name: 'target_language_id', fromJson: nullableStringFromJson)  String? targetLanguageId, @JsonKey(name: 'target_sentence', fromJson: nullableStringFromJson)  String? targetSentence, @JsonKey(name: 'source_type', fromJson: nullableStringFromJson)  String? sourceType,  List<WordAudioDto> audios)?  $default,) {final _that = this;
switch (_that) {
case _ExampleDto() when $default != null:
return $default(_that.id,_that.sourceLanguageId,_that.sourceSentence,_that.targetLanguageId,_that.targetSentence,_that.sourceType,_that.audios);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExampleDto implements ExampleDto {
  const _ExampleDto({required this.id, @JsonKey(name: 'source_language_id') required this.sourceLanguageId, @JsonKey(name: 'source_sentence') required this.sourceSentence, @JsonKey(name: 'target_language_id', fromJson: nullableStringFromJson) this.targetLanguageId, @JsonKey(name: 'target_sentence', fromJson: nullableStringFromJson) this.targetSentence, @JsonKey(name: 'source_type', fromJson: nullableStringFromJson) this.sourceType, final  List<WordAudioDto> audios = const []}): _audios = audios;
  factory _ExampleDto.fromJson(Map<String, dynamic> json) => _$ExampleDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'source_language_id') final  String sourceLanguageId;
@override@JsonKey(name: 'source_sentence') final  String sourceSentence;
@override@JsonKey(name: 'target_language_id', fromJson: nullableStringFromJson) final  String? targetLanguageId;
@override@JsonKey(name: 'target_sentence', fromJson: nullableStringFromJson) final  String? targetSentence;
@override@JsonKey(name: 'source_type', fromJson: nullableStringFromJson) final  String? sourceType;
 final  List<WordAudioDto> _audios;
@override@JsonKey() List<WordAudioDto> get audios {
  if (_audios is EqualUnmodifiableListView) return _audios;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_audios);
}


/// Create a copy of ExampleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExampleDtoCopyWith<_ExampleDto> get copyWith => __$ExampleDtoCopyWithImpl<_ExampleDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExampleDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExampleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceLanguageId, sourceLanguageId) || other.sourceLanguageId == sourceLanguageId)&&(identical(other.sourceSentence, sourceSentence) || other.sourceSentence == sourceSentence)&&(identical(other.targetLanguageId, targetLanguageId) || other.targetLanguageId == targetLanguageId)&&(identical(other.targetSentence, targetSentence) || other.targetSentence == targetSentence)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&const DeepCollectionEquality().equals(other._audios, _audios));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceLanguageId,sourceSentence,targetLanguageId,targetSentence,sourceType,const DeepCollectionEquality().hash(_audios));

@override
String toString() {
  return 'ExampleDto(id: $id, sourceLanguageId: $sourceLanguageId, sourceSentence: $sourceSentence, targetLanguageId: $targetLanguageId, targetSentence: $targetSentence, sourceType: $sourceType, audios: $audios)';
}


}

/// @nodoc
abstract mixin class _$ExampleDtoCopyWith<$Res> implements $ExampleDtoCopyWith<$Res> {
  factory _$ExampleDtoCopyWith(_ExampleDto value, $Res Function(_ExampleDto) _then) = __$ExampleDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'source_language_id') String sourceLanguageId,@JsonKey(name: 'source_sentence') String sourceSentence,@JsonKey(name: 'target_language_id', fromJson: nullableStringFromJson) String? targetLanguageId,@JsonKey(name: 'target_sentence', fromJson: nullableStringFromJson) String? targetSentence,@JsonKey(name: 'source_type', fromJson: nullableStringFromJson) String? sourceType, List<WordAudioDto> audios
});




}
/// @nodoc
class __$ExampleDtoCopyWithImpl<$Res>
    implements _$ExampleDtoCopyWith<$Res> {
  __$ExampleDtoCopyWithImpl(this._self, this._then);

  final _ExampleDto _self;
  final $Res Function(_ExampleDto) _then;

/// Create a copy of ExampleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sourceLanguageId = null,Object? sourceSentence = null,Object? targetLanguageId = freezed,Object? targetSentence = freezed,Object? sourceType = freezed,Object? audios = null,}) {
  return _then(_ExampleDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceLanguageId: null == sourceLanguageId ? _self.sourceLanguageId : sourceLanguageId // ignore: cast_nullable_to_non_nullable
as String,sourceSentence: null == sourceSentence ? _self.sourceSentence : sourceSentence // ignore: cast_nullable_to_non_nullable
as String,targetLanguageId: freezed == targetLanguageId ? _self.targetLanguageId : targetLanguageId // ignore: cast_nullable_to_non_nullable
as String?,targetSentence: freezed == targetSentence ? _self.targetSentence : targetSentence // ignore: cast_nullable_to_non_nullable
as String?,sourceType: freezed == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String?,audios: null == audios ? _self._audios : audios // ignore: cast_nullable_to_non_nullable
as List<WordAudioDto>,
  ));
}


}


/// @nodoc
mixin _$CategoryDto {

 String get id; String get name;
/// Create a copy of CategoryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryDtoCopyWith<CategoryDto> get copyWith => _$CategoryDtoCopyWithImpl<CategoryDto>(this as CategoryDto, _$identity);

  /// Serializes this CategoryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'CategoryDto(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $CategoryDtoCopyWith<$Res>  {
  factory $CategoryDtoCopyWith(CategoryDto value, $Res Function(CategoryDto) _then) = _$CategoryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$CategoryDtoCopyWithImpl<$Res>
    implements $CategoryDtoCopyWith<$Res> {
  _$CategoryDtoCopyWithImpl(this._self, this._then);

  final CategoryDto _self;
  final $Res Function(CategoryDto) _then;

/// Create a copy of CategoryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryDto].
extension CategoryDtoPatterns on CategoryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryDto value)  $default,){
final _that = this;
switch (_that) {
case _CategoryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryDto value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryDto() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _CategoryDto():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _CategoryDto() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryDto implements CategoryDto {
  const _CategoryDto({required this.id, required this.name});
  factory _CategoryDto.fromJson(Map<String, dynamic> json) => _$CategoryDtoFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of CategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryDtoCopyWith<_CategoryDto> get copyWith => __$CategoryDtoCopyWithImpl<_CategoryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'CategoryDto(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$CategoryDtoCopyWith<$Res> implements $CategoryDtoCopyWith<$Res> {
  factory _$CategoryDtoCopyWith(_CategoryDto value, $Res Function(_CategoryDto) _then) = __$CategoryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$CategoryDtoCopyWithImpl<$Res>
    implements _$CategoryDtoCopyWith<$Res> {
  __$CategoryDtoCopyWithImpl(this._self, this._then);

  final _CategoryDto _self;
  final $Res Function(_CategoryDto) _then;

/// Create a copy of CategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_CategoryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PronunciationDto {

 String get id; String get notation; String get value;@JsonKey(name: 'dialect_id') String? get dialectId;
/// Create a copy of PronunciationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PronunciationDtoCopyWith<PronunciationDto> get copyWith => _$PronunciationDtoCopyWithImpl<PronunciationDto>(this as PronunciationDto, _$identity);

  /// Serializes this PronunciationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PronunciationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.notation, notation) || other.notation == notation)&&(identical(other.value, value) || other.value == value)&&(identical(other.dialectId, dialectId) || other.dialectId == dialectId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,notation,value,dialectId);

@override
String toString() {
  return 'PronunciationDto(id: $id, notation: $notation, value: $value, dialectId: $dialectId)';
}


}

/// @nodoc
abstract mixin class $PronunciationDtoCopyWith<$Res>  {
  factory $PronunciationDtoCopyWith(PronunciationDto value, $Res Function(PronunciationDto) _then) = _$PronunciationDtoCopyWithImpl;
@useResult
$Res call({
 String id, String notation, String value,@JsonKey(name: 'dialect_id') String? dialectId
});




}
/// @nodoc
class _$PronunciationDtoCopyWithImpl<$Res>
    implements $PronunciationDtoCopyWith<$Res> {
  _$PronunciationDtoCopyWithImpl(this._self, this._then);

  final PronunciationDto _self;
  final $Res Function(PronunciationDto) _then;

/// Create a copy of PronunciationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? notation = null,Object? value = null,Object? dialectId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,notation: null == notation ? _self.notation : notation // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,dialectId: freezed == dialectId ? _self.dialectId : dialectId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PronunciationDto].
extension PronunciationDtoPatterns on PronunciationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PronunciationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PronunciationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PronunciationDto value)  $default,){
final _that = this;
switch (_that) {
case _PronunciationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PronunciationDto value)?  $default,){
final _that = this;
switch (_that) {
case _PronunciationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String notation,  String value, @JsonKey(name: 'dialect_id')  String? dialectId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PronunciationDto() when $default != null:
return $default(_that.id,_that.notation,_that.value,_that.dialectId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String notation,  String value, @JsonKey(name: 'dialect_id')  String? dialectId)  $default,) {final _that = this;
switch (_that) {
case _PronunciationDto():
return $default(_that.id,_that.notation,_that.value,_that.dialectId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String notation,  String value, @JsonKey(name: 'dialect_id')  String? dialectId)?  $default,) {final _that = this;
switch (_that) {
case _PronunciationDto() when $default != null:
return $default(_that.id,_that.notation,_that.value,_that.dialectId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PronunciationDto implements PronunciationDto {
  const _PronunciationDto({required this.id, required this.notation, required this.value, @JsonKey(name: 'dialect_id') this.dialectId});
  factory _PronunciationDto.fromJson(Map<String, dynamic> json) => _$PronunciationDtoFromJson(json);

@override final  String id;
@override final  String notation;
@override final  String value;
@override@JsonKey(name: 'dialect_id') final  String? dialectId;

/// Create a copy of PronunciationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PronunciationDtoCopyWith<_PronunciationDto> get copyWith => __$PronunciationDtoCopyWithImpl<_PronunciationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PronunciationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PronunciationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.notation, notation) || other.notation == notation)&&(identical(other.value, value) || other.value == value)&&(identical(other.dialectId, dialectId) || other.dialectId == dialectId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,notation,value,dialectId);

@override
String toString() {
  return 'PronunciationDto(id: $id, notation: $notation, value: $value, dialectId: $dialectId)';
}


}

/// @nodoc
abstract mixin class _$PronunciationDtoCopyWith<$Res> implements $PronunciationDtoCopyWith<$Res> {
  factory _$PronunciationDtoCopyWith(_PronunciationDto value, $Res Function(_PronunciationDto) _then) = __$PronunciationDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String notation, String value,@JsonKey(name: 'dialect_id') String? dialectId
});




}
/// @nodoc
class __$PronunciationDtoCopyWithImpl<$Res>
    implements _$PronunciationDtoCopyWith<$Res> {
  __$PronunciationDtoCopyWithImpl(this._self, this._then);

  final _PronunciationDto _self;
  final $Res Function(_PronunciationDto) _then;

/// Create a copy of PronunciationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? notation = null,Object? value = null,Object? dialectId = freezed,}) {
  return _then(_PronunciationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,notation: null == notation ? _self.notation : notation // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,dialectId: freezed == dialectId ? _self.dialectId : dialectId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$WordImageDto {

 String get id; String get url;@JsonKey(name: 'alt_text') String? get altText;@JsonKey(name: 'is_primary') bool get isPrimary;/// false = gambar staging belum diverifikasi. Default true agar
/// response lama (tanpa field ini) tetap bekerja normal.
@JsonKey(name: 'is_verified') bool get isVerified;/// Peringatan konten visual per gambar. V1: ['kekerasan'].
@JsonKey(name: 'content_warnings') List<String> get contentWarnings;/// Kredit foto stock (+ `provider`); null = upload / data lama.
 Map<String, dynamic>? get attribution;
/// Create a copy of WordImageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordImageDtoCopyWith<WordImageDto> get copyWith => _$WordImageDtoCopyWithImpl<WordImageDto>(this as WordImageDto, _$identity);

  /// Serializes this WordImageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordImageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.altText, altText) || other.altText == altText)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&const DeepCollectionEquality().equals(other.contentWarnings, contentWarnings)&&const DeepCollectionEquality().equals(other.attribution, attribution));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,altText,isPrimary,isVerified,const DeepCollectionEquality().hash(contentWarnings),const DeepCollectionEquality().hash(attribution));

@override
String toString() {
  return 'WordImageDto(id: $id, url: $url, altText: $altText, isPrimary: $isPrimary, isVerified: $isVerified, contentWarnings: $contentWarnings, attribution: $attribution)';
}


}

/// @nodoc
abstract mixin class $WordImageDtoCopyWith<$Res>  {
  factory $WordImageDtoCopyWith(WordImageDto value, $Res Function(WordImageDto) _then) = _$WordImageDtoCopyWithImpl;
@useResult
$Res call({
 String id, String url,@JsonKey(name: 'alt_text') String? altText,@JsonKey(name: 'is_primary') bool isPrimary,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'content_warnings') List<String> contentWarnings, Map<String, dynamic>? attribution
});




}
/// @nodoc
class _$WordImageDtoCopyWithImpl<$Res>
    implements $WordImageDtoCopyWith<$Res> {
  _$WordImageDtoCopyWithImpl(this._self, this._then);

  final WordImageDto _self;
  final $Res Function(WordImageDto) _then;

/// Create a copy of WordImageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? altText = freezed,Object? isPrimary = null,Object? isVerified = null,Object? contentWarnings = null,Object? attribution = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,contentWarnings: null == contentWarnings ? _self.contentWarnings : contentWarnings // ignore: cast_nullable_to_non_nullable
as List<String>,attribution: freezed == attribution ? _self.attribution : attribution // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [WordImageDto].
extension WordImageDtoPatterns on WordImageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordImageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordImageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordImageDto value)  $default,){
final _that = this;
switch (_that) {
case _WordImageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordImageDto value)?  $default,){
final _that = this;
switch (_that) {
case _WordImageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url, @JsonKey(name: 'alt_text')  String? altText, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'content_warnings')  List<String> contentWarnings,  Map<String, dynamic>? attribution)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordImageDto() when $default != null:
return $default(_that.id,_that.url,_that.altText,_that.isPrimary,_that.isVerified,_that.contentWarnings,_that.attribution);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url, @JsonKey(name: 'alt_text')  String? altText, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'content_warnings')  List<String> contentWarnings,  Map<String, dynamic>? attribution)  $default,) {final _that = this;
switch (_that) {
case _WordImageDto():
return $default(_that.id,_that.url,_that.altText,_that.isPrimary,_that.isVerified,_that.contentWarnings,_that.attribution);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url, @JsonKey(name: 'alt_text')  String? altText, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'content_warnings')  List<String> contentWarnings,  Map<String, dynamic>? attribution)?  $default,) {final _that = this;
switch (_that) {
case _WordImageDto() when $default != null:
return $default(_that.id,_that.url,_that.altText,_that.isPrimary,_that.isVerified,_that.contentWarnings,_that.attribution);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WordImageDto implements WordImageDto {
  const _WordImageDto({required this.id, required this.url, @JsonKey(name: 'alt_text') this.altText, @JsonKey(name: 'is_primary') this.isPrimary = false, @JsonKey(name: 'is_verified') this.isVerified = true, @JsonKey(name: 'content_warnings') final  List<String> contentWarnings = const [], final  Map<String, dynamic>? attribution}): _contentWarnings = contentWarnings,_attribution = attribution;
  factory _WordImageDto.fromJson(Map<String, dynamic> json) => _$WordImageDtoFromJson(json);

@override final  String id;
@override final  String url;
@override@JsonKey(name: 'alt_text') final  String? altText;
@override@JsonKey(name: 'is_primary') final  bool isPrimary;
/// false = gambar staging belum diverifikasi. Default true agar
/// response lama (tanpa field ini) tetap bekerja normal.
@override@JsonKey(name: 'is_verified') final  bool isVerified;
/// Peringatan konten visual per gambar. V1: ['kekerasan'].
 final  List<String> _contentWarnings;
/// Peringatan konten visual per gambar. V1: ['kekerasan'].
@override@JsonKey(name: 'content_warnings') List<String> get contentWarnings {
  if (_contentWarnings is EqualUnmodifiableListView) return _contentWarnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_contentWarnings);
}

/// Kredit foto stock (+ `provider`); null = upload / data lama.
 final  Map<String, dynamic>? _attribution;
/// Kredit foto stock (+ `provider`); null = upload / data lama.
@override Map<String, dynamic>? get attribution {
  final value = _attribution;
  if (value == null) return null;
  if (_attribution is EqualUnmodifiableMapView) return _attribution;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of WordImageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordImageDtoCopyWith<_WordImageDto> get copyWith => __$WordImageDtoCopyWithImpl<_WordImageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WordImageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordImageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.altText, altText) || other.altText == altText)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&const DeepCollectionEquality().equals(other._contentWarnings, _contentWarnings)&&const DeepCollectionEquality().equals(other._attribution, _attribution));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,altText,isPrimary,isVerified,const DeepCollectionEquality().hash(_contentWarnings),const DeepCollectionEquality().hash(_attribution));

@override
String toString() {
  return 'WordImageDto(id: $id, url: $url, altText: $altText, isPrimary: $isPrimary, isVerified: $isVerified, contentWarnings: $contentWarnings, attribution: $attribution)';
}


}

/// @nodoc
abstract mixin class _$WordImageDtoCopyWith<$Res> implements $WordImageDtoCopyWith<$Res> {
  factory _$WordImageDtoCopyWith(_WordImageDto value, $Res Function(_WordImageDto) _then) = __$WordImageDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String url,@JsonKey(name: 'alt_text') String? altText,@JsonKey(name: 'is_primary') bool isPrimary,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'content_warnings') List<String> contentWarnings, Map<String, dynamic>? attribution
});




}
/// @nodoc
class __$WordImageDtoCopyWithImpl<$Res>
    implements _$WordImageDtoCopyWith<$Res> {
  __$WordImageDtoCopyWithImpl(this._self, this._then);

  final _WordImageDto _self;
  final $Res Function(_WordImageDto) _then;

/// Create a copy of WordImageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? altText = freezed,Object? isPrimary = null,Object? isVerified = null,Object? contentWarnings = null,Object? attribution = freezed,}) {
  return _then(_WordImageDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,contentWarnings: null == contentWarnings ? _self._contentWarnings : contentWarnings // ignore: cast_nullable_to_non_nullable
as List<String>,attribution: freezed == attribution ? _self._attribution : attribution // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$RelatedWordDto {

@JsonKey(name: 'word_id') String get wordId; String get lemma;@JsonKey(name: 'relation_type') String get relationType;
/// Create a copy of RelatedWordDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RelatedWordDtoCopyWith<RelatedWordDto> get copyWith => _$RelatedWordDtoCopyWithImpl<RelatedWordDto>(this as RelatedWordDto, _$identity);

  /// Serializes this RelatedWordDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RelatedWordDto&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.relationType, relationType) || other.relationType == relationType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wordId,lemma,relationType);

@override
String toString() {
  return 'RelatedWordDto(wordId: $wordId, lemma: $lemma, relationType: $relationType)';
}


}

/// @nodoc
abstract mixin class $RelatedWordDtoCopyWith<$Res>  {
  factory $RelatedWordDtoCopyWith(RelatedWordDto value, $Res Function(RelatedWordDto) _then) = _$RelatedWordDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'word_id') String wordId, String lemma,@JsonKey(name: 'relation_type') String relationType
});




}
/// @nodoc
class _$RelatedWordDtoCopyWithImpl<$Res>
    implements $RelatedWordDtoCopyWith<$Res> {
  _$RelatedWordDtoCopyWithImpl(this._self, this._then);

  final RelatedWordDto _self;
  final $Res Function(RelatedWordDto) _then;

/// Create a copy of RelatedWordDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wordId = null,Object? lemma = null,Object? relationType = null,}) {
  return _then(_self.copyWith(
wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,lemma: null == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String,relationType: null == relationType ? _self.relationType : relationType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RelatedWordDto].
extension RelatedWordDtoPatterns on RelatedWordDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RelatedWordDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RelatedWordDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RelatedWordDto value)  $default,){
final _that = this;
switch (_that) {
case _RelatedWordDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RelatedWordDto value)?  $default,){
final _that = this;
switch (_that) {
case _RelatedWordDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'word_id')  String wordId,  String lemma, @JsonKey(name: 'relation_type')  String relationType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RelatedWordDto() when $default != null:
return $default(_that.wordId,_that.lemma,_that.relationType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'word_id')  String wordId,  String lemma, @JsonKey(name: 'relation_type')  String relationType)  $default,) {final _that = this;
switch (_that) {
case _RelatedWordDto():
return $default(_that.wordId,_that.lemma,_that.relationType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'word_id')  String wordId,  String lemma, @JsonKey(name: 'relation_type')  String relationType)?  $default,) {final _that = this;
switch (_that) {
case _RelatedWordDto() when $default != null:
return $default(_that.wordId,_that.lemma,_that.relationType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RelatedWordDto implements RelatedWordDto {
  const _RelatedWordDto({@JsonKey(name: 'word_id') required this.wordId, required this.lemma, @JsonKey(name: 'relation_type') required this.relationType});
  factory _RelatedWordDto.fromJson(Map<String, dynamic> json) => _$RelatedWordDtoFromJson(json);

@override@JsonKey(name: 'word_id') final  String wordId;
@override final  String lemma;
@override@JsonKey(name: 'relation_type') final  String relationType;

/// Create a copy of RelatedWordDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RelatedWordDtoCopyWith<_RelatedWordDto> get copyWith => __$RelatedWordDtoCopyWithImpl<_RelatedWordDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RelatedWordDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RelatedWordDto&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.relationType, relationType) || other.relationType == relationType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wordId,lemma,relationType);

@override
String toString() {
  return 'RelatedWordDto(wordId: $wordId, lemma: $lemma, relationType: $relationType)';
}


}

/// @nodoc
abstract mixin class _$RelatedWordDtoCopyWith<$Res> implements $RelatedWordDtoCopyWith<$Res> {
  factory _$RelatedWordDtoCopyWith(_RelatedWordDto value, $Res Function(_RelatedWordDto) _then) = __$RelatedWordDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'word_id') String wordId, String lemma,@JsonKey(name: 'relation_type') String relationType
});




}
/// @nodoc
class __$RelatedWordDtoCopyWithImpl<$Res>
    implements _$RelatedWordDtoCopyWith<$Res> {
  __$RelatedWordDtoCopyWithImpl(this._self, this._then);

  final _RelatedWordDto _self;
  final $Res Function(_RelatedWordDto) _then;

/// Create a copy of RelatedWordDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wordId = null,Object? lemma = null,Object? relationType = null,}) {
  return _then(_RelatedWordDto(
wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,lemma: null == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String,relationType: null == relationType ? _self.relationType : relationType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$WordVariantDto {

 String get id; String get form;@JsonKey(name: 'variant_type') String get variantType;@JsonKey(name: 'affix_type') String? get affixType;@JsonKey(name: 'affix_value') String? get affixValue;@JsonKey(name: 'dialect_id') String? get dialectId; String? get notes;
/// Create a copy of WordVariantDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordVariantDtoCopyWith<WordVariantDto> get copyWith => _$WordVariantDtoCopyWithImpl<WordVariantDto>(this as WordVariantDto, _$identity);

  /// Serializes this WordVariantDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordVariantDto&&(identical(other.id, id) || other.id == id)&&(identical(other.form, form) || other.form == form)&&(identical(other.variantType, variantType) || other.variantType == variantType)&&(identical(other.affixType, affixType) || other.affixType == affixType)&&(identical(other.affixValue, affixValue) || other.affixValue == affixValue)&&(identical(other.dialectId, dialectId) || other.dialectId == dialectId)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,form,variantType,affixType,affixValue,dialectId,notes);

@override
String toString() {
  return 'WordVariantDto(id: $id, form: $form, variantType: $variantType, affixType: $affixType, affixValue: $affixValue, dialectId: $dialectId, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $WordVariantDtoCopyWith<$Res>  {
  factory $WordVariantDtoCopyWith(WordVariantDto value, $Res Function(WordVariantDto) _then) = _$WordVariantDtoCopyWithImpl;
@useResult
$Res call({
 String id, String form,@JsonKey(name: 'variant_type') String variantType,@JsonKey(name: 'affix_type') String? affixType,@JsonKey(name: 'affix_value') String? affixValue,@JsonKey(name: 'dialect_id') String? dialectId, String? notes
});




}
/// @nodoc
class _$WordVariantDtoCopyWithImpl<$Res>
    implements $WordVariantDtoCopyWith<$Res> {
  _$WordVariantDtoCopyWithImpl(this._self, this._then);

  final WordVariantDto _self;
  final $Res Function(WordVariantDto) _then;

/// Create a copy of WordVariantDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? form = null,Object? variantType = null,Object? affixType = freezed,Object? affixValue = freezed,Object? dialectId = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,form: null == form ? _self.form : form // ignore: cast_nullable_to_non_nullable
as String,variantType: null == variantType ? _self.variantType : variantType // ignore: cast_nullable_to_non_nullable
as String,affixType: freezed == affixType ? _self.affixType : affixType // ignore: cast_nullable_to_non_nullable
as String?,affixValue: freezed == affixValue ? _self.affixValue : affixValue // ignore: cast_nullable_to_non_nullable
as String?,dialectId: freezed == dialectId ? _self.dialectId : dialectId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WordVariantDto].
extension WordVariantDtoPatterns on WordVariantDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordVariantDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordVariantDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordVariantDto value)  $default,){
final _that = this;
switch (_that) {
case _WordVariantDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordVariantDto value)?  $default,){
final _that = this;
switch (_that) {
case _WordVariantDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String form, @JsonKey(name: 'variant_type')  String variantType, @JsonKey(name: 'affix_type')  String? affixType, @JsonKey(name: 'affix_value')  String? affixValue, @JsonKey(name: 'dialect_id')  String? dialectId,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordVariantDto() when $default != null:
return $default(_that.id,_that.form,_that.variantType,_that.affixType,_that.affixValue,_that.dialectId,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String form, @JsonKey(name: 'variant_type')  String variantType, @JsonKey(name: 'affix_type')  String? affixType, @JsonKey(name: 'affix_value')  String? affixValue, @JsonKey(name: 'dialect_id')  String? dialectId,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _WordVariantDto():
return $default(_that.id,_that.form,_that.variantType,_that.affixType,_that.affixValue,_that.dialectId,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String form, @JsonKey(name: 'variant_type')  String variantType, @JsonKey(name: 'affix_type')  String? affixType, @JsonKey(name: 'affix_value')  String? affixValue, @JsonKey(name: 'dialect_id')  String? dialectId,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _WordVariantDto() when $default != null:
return $default(_that.id,_that.form,_that.variantType,_that.affixType,_that.affixValue,_that.dialectId,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WordVariantDto implements WordVariantDto {
  const _WordVariantDto({required this.id, required this.form, @JsonKey(name: 'variant_type') required this.variantType, @JsonKey(name: 'affix_type') this.affixType, @JsonKey(name: 'affix_value') this.affixValue, @JsonKey(name: 'dialect_id') this.dialectId, this.notes});
  factory _WordVariantDto.fromJson(Map<String, dynamic> json) => _$WordVariantDtoFromJson(json);

@override final  String id;
@override final  String form;
@override@JsonKey(name: 'variant_type') final  String variantType;
@override@JsonKey(name: 'affix_type') final  String? affixType;
@override@JsonKey(name: 'affix_value') final  String? affixValue;
@override@JsonKey(name: 'dialect_id') final  String? dialectId;
@override final  String? notes;

/// Create a copy of WordVariantDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordVariantDtoCopyWith<_WordVariantDto> get copyWith => __$WordVariantDtoCopyWithImpl<_WordVariantDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WordVariantDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordVariantDto&&(identical(other.id, id) || other.id == id)&&(identical(other.form, form) || other.form == form)&&(identical(other.variantType, variantType) || other.variantType == variantType)&&(identical(other.affixType, affixType) || other.affixType == affixType)&&(identical(other.affixValue, affixValue) || other.affixValue == affixValue)&&(identical(other.dialectId, dialectId) || other.dialectId == dialectId)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,form,variantType,affixType,affixValue,dialectId,notes);

@override
String toString() {
  return 'WordVariantDto(id: $id, form: $form, variantType: $variantType, affixType: $affixType, affixValue: $affixValue, dialectId: $dialectId, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$WordVariantDtoCopyWith<$Res> implements $WordVariantDtoCopyWith<$Res> {
  factory _$WordVariantDtoCopyWith(_WordVariantDto value, $Res Function(_WordVariantDto) _then) = __$WordVariantDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String form,@JsonKey(name: 'variant_type') String variantType,@JsonKey(name: 'affix_type') String? affixType,@JsonKey(name: 'affix_value') String? affixValue,@JsonKey(name: 'dialect_id') String? dialectId, String? notes
});




}
/// @nodoc
class __$WordVariantDtoCopyWithImpl<$Res>
    implements _$WordVariantDtoCopyWith<$Res> {
  __$WordVariantDtoCopyWithImpl(this._self, this._then);

  final _WordVariantDto _self;
  final $Res Function(_WordVariantDto) _then;

/// Create a copy of WordVariantDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? form = null,Object? variantType = null,Object? affixType = freezed,Object? affixValue = freezed,Object? dialectId = freezed,Object? notes = freezed,}) {
  return _then(_WordVariantDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,form: null == form ? _self.form : form // ignore: cast_nullable_to_non_nullable
as String,variantType: null == variantType ? _self.variantType : variantType // ignore: cast_nullable_to_non_nullable
as String,affixType: freezed == affixType ? _self.affixType : affixType // ignore: cast_nullable_to_non_nullable
as String?,affixValue: freezed == affixValue ? _self.affixValue : affixValue // ignore: cast_nullable_to_non_nullable
as String?,dialectId: freezed == dialectId ? _self.dialectId : dialectId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
