// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_detail_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WordDetailDto {

 String get id; String get lemma;@JsonKey(name: 'language_id') String get languageId; String? get notes;@JsonKey(name: 'word_type') String get wordType; String get status;@JsonKey(name: 'is_verified') bool get isVerified;@JsonKey(name: 'is_corrected') bool get isCorrected;@JsonKey(name: 'self_verified') bool get selfVerified;@JsonKey(name: 'verified_at') String? get verifiedAt;@JsonKey(name: 'verified_by') WordVerifierDto? get verifiedBy;@JsonKey(name: 'created_by') WordVerifierDto? get createdBy; List<MeaningDto> get meanings; List<CategoryDto> get categories;@JsonKey(name: 'usage_labels') List<String> get usageLabels; List<PronunciationDto> get pronunciations; List<WordAudioDto> get audios; List<WordImageDto> get images;@JsonKey(name: 'related_words') List<RelatedWordDto> get relatedWords;@JsonKey(name: 'appears_in') List<RelatedWordDto> get appearsIn;/// PRD relasi-lemma: kelompok makna (published saja).
@JsonKey(name: 'meaning_groups') List<MeaningGroupDto> get meaningGroups; List<WordVariantDto> get variants;/// Hanya diisi GET /words/today; detail biasa mengabaikan (null/false).
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
  final _this = this as WordDetailDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordDetailDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.lemma, _this.lemma) || other.lemma == _this.lemma)&&(identical(other.languageId, _this.languageId) || other.languageId == _this.languageId)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.wordType, _this.wordType) || other.wordType == _this.wordType)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.isVerified, _this.isVerified) || other.isVerified == _this.isVerified)&&(identical(other.isCorrected, _this.isCorrected) || other.isCorrected == _this.isCorrected)&&(identical(other.selfVerified, _this.selfVerified) || other.selfVerified == _this.selfVerified)&&(identical(other.verifiedAt, _this.verifiedAt) || other.verifiedAt == _this.verifiedAt)&&(identical(other.verifiedBy, _this.verifiedBy) || other.verifiedBy == _this.verifiedBy)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&const DeepCollectionEquality().equals(other.meanings, _this.meanings)&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&const DeepCollectionEquality().equals(other.usageLabels, _this.usageLabels)&&const DeepCollectionEquality().equals(other.pronunciations, _this.pronunciations)&&const DeepCollectionEquality().equals(other.audios, _this.audios)&&const DeepCollectionEquality().equals(other.images, _this.images)&&const DeepCollectionEquality().equals(other.relatedWords, _this.relatedWords)&&const DeepCollectionEquality().equals(other.appearsIn, _this.appearsIn)&&const DeepCollectionEquality().equals(other.meaningGroups, _this.meaningGroups)&&const DeepCollectionEquality().equals(other.variants, _this.variants)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.isNewThisWeek, _this.isNewThisWeek) || other.isNewThisWeek == _this.isNewThisWeek));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WordDetailDto;
  return Object.hashAll([runtimeType,_this.id,_this.lemma,_this.languageId,_this.notes,_this.wordType,_this.status,_this.isVerified,_this.isCorrected,_this.selfVerified,_this.verifiedAt,_this.verifiedBy,_this.createdBy,const DeepCollectionEquality().hash(_this.meanings),const DeepCollectionEquality().hash(_this.categories),const DeepCollectionEquality().hash(_this.usageLabels),const DeepCollectionEquality().hash(_this.pronunciations),const DeepCollectionEquality().hash(_this.audios),const DeepCollectionEquality().hash(_this.images),const DeepCollectionEquality().hash(_this.relatedWords),const DeepCollectionEquality().hash(_this.appearsIn),const DeepCollectionEquality().hash(_this.meaningGroups),const DeepCollectionEquality().hash(_this.variants),_this.date,_this.isNewThisWeek]);
}

@override
String toString() {
  final _this = this as WordDetailDto;
  return 'WordDetailDto(id: ${_this.id}, lemma: ${_this.lemma}, languageId: ${_this.languageId}, notes: ${_this.notes}, wordType: ${_this.wordType}, status: ${_this.status}, isVerified: ${_this.isVerified}, isCorrected: ${_this.isCorrected}, selfVerified: ${_this.selfVerified}, verifiedAt: ${_this.verifiedAt}, verifiedBy: ${_this.verifiedBy}, createdBy: ${_this.createdBy}, meanings: ${_this.meanings}, categories: ${_this.categories}, usageLabels: ${_this.usageLabels}, pronunciations: ${_this.pronunciations}, audios: ${_this.audios}, images: ${_this.images}, relatedWords: ${_this.relatedWords}, appearsIn: ${_this.appearsIn}, meaningGroups: ${_this.meaningGroups}, variants: ${_this.variants}, date: ${_this.date}, isNewThisWeek: ${_this.isNewThisWeek})';
}


}

/// @nodoc
abstract mixin class $WordDetailDtoCopyWith<$Res>  {
  factory $WordDetailDtoCopyWith(WordDetailDto value, $Res Function(WordDetailDto) _then) = _$WordDetailDtoCopyWithImpl;
@useResult
$Res call({
 String id, String lemma,@JsonKey(name: 'language_id') String languageId, String? notes,@JsonKey(name: 'word_type') String wordType, String status,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'is_corrected') bool isCorrected,@JsonKey(name: 'self_verified') bool selfVerified,@JsonKey(name: 'verified_at') String? verifiedAt,@JsonKey(name: 'verified_by') WordVerifierDto? verifiedBy,@JsonKey(name: 'created_by') WordVerifierDto? createdBy, List<MeaningDto> meanings, List<CategoryDto> categories,@JsonKey(name: 'usage_labels') List<String> usageLabels, List<PronunciationDto> pronunciations, List<WordAudioDto> audios, List<WordImageDto> images,@JsonKey(name: 'related_words') List<RelatedWordDto> relatedWords,@JsonKey(name: 'appears_in') List<RelatedWordDto> appearsIn,@JsonKey(name: 'meaning_groups') List<MeaningGroupDto> meaningGroups, List<WordVariantDto> variants, String? date,@JsonKey(name: 'is_new_this_week') bool isNewThisWeek
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lemma = null,Object? languageId = null,Object? notes = freezed,Object? wordType = null,Object? status = null,Object? isVerified = null,Object? isCorrected = null,Object? selfVerified = null,Object? verifiedAt = freezed,Object? verifiedBy = freezed,Object? createdBy = freezed,Object? meanings = null,Object? categories = null,Object? usageLabels = null,Object? pronunciations = null,Object? audios = null,Object? images = null,Object? relatedWords = null,Object? appearsIn = null,Object? meaningGroups = null,Object? variants = null,Object? date = freezed,Object? isNewThisWeek = null,}) {
  return _then(WordDetailDto(
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
as List<RelatedWordDto>,meaningGroups: null == meaningGroups ? _self.meaningGroups : meaningGroups // ignore: cast_nullable_to_non_nullable
as List<MeaningGroupDto>,variants: null == variants ? _self.variants : variants // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String lemma, @JsonKey(name: 'language_id')  String languageId,  String? notes, @JsonKey(name: 'word_type')  String wordType,  String status, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'is_corrected')  bool isCorrected, @JsonKey(name: 'self_verified')  bool selfVerified, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'verified_by')  WordVerifierDto? verifiedBy, @JsonKey(name: 'created_by')  WordVerifierDto? createdBy,  List<MeaningDto> meanings,  List<CategoryDto> categories, @JsonKey(name: 'usage_labels')  List<String> usageLabels,  List<PronunciationDto> pronunciations,  List<WordAudioDto> audios,  List<WordImageDto> images, @JsonKey(name: 'related_words')  List<RelatedWordDto> relatedWords, @JsonKey(name: 'appears_in')  List<RelatedWordDto> appearsIn, @JsonKey(name: 'meaning_groups')  List<MeaningGroupDto> meaningGroups,  List<WordVariantDto> variants,  String? date, @JsonKey(name: 'is_new_this_week')  bool isNewThisWeek)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordDetailDto() when $default != null:
return $default(_that.id,_that.lemma,_that.languageId,_that.notes,_that.wordType,_that.status,_that.isVerified,_that.isCorrected,_that.selfVerified,_that.verifiedAt,_that.verifiedBy,_that.createdBy,_that.meanings,_that.categories,_that.usageLabels,_that.pronunciations,_that.audios,_that.images,_that.relatedWords,_that.appearsIn,_that.meaningGroups,_that.variants,_that.date,_that.isNewThisWeek);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String lemma, @JsonKey(name: 'language_id')  String languageId,  String? notes, @JsonKey(name: 'word_type')  String wordType,  String status, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'is_corrected')  bool isCorrected, @JsonKey(name: 'self_verified')  bool selfVerified, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'verified_by')  WordVerifierDto? verifiedBy, @JsonKey(name: 'created_by')  WordVerifierDto? createdBy,  List<MeaningDto> meanings,  List<CategoryDto> categories, @JsonKey(name: 'usage_labels')  List<String> usageLabels,  List<PronunciationDto> pronunciations,  List<WordAudioDto> audios,  List<WordImageDto> images, @JsonKey(name: 'related_words')  List<RelatedWordDto> relatedWords, @JsonKey(name: 'appears_in')  List<RelatedWordDto> appearsIn, @JsonKey(name: 'meaning_groups')  List<MeaningGroupDto> meaningGroups,  List<WordVariantDto> variants,  String? date, @JsonKey(name: 'is_new_this_week')  bool isNewThisWeek)  $default,) {final _that = this;
switch (_that) {
case _WordDetailDto():
return $default(_that.id,_that.lemma,_that.languageId,_that.notes,_that.wordType,_that.status,_that.isVerified,_that.isCorrected,_that.selfVerified,_that.verifiedAt,_that.verifiedBy,_that.createdBy,_that.meanings,_that.categories,_that.usageLabels,_that.pronunciations,_that.audios,_that.images,_that.relatedWords,_that.appearsIn,_that.meaningGroups,_that.variants,_that.date,_that.isNewThisWeek);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String lemma, @JsonKey(name: 'language_id')  String languageId,  String? notes, @JsonKey(name: 'word_type')  String wordType,  String status, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'is_corrected')  bool isCorrected, @JsonKey(name: 'self_verified')  bool selfVerified, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'verified_by')  WordVerifierDto? verifiedBy, @JsonKey(name: 'created_by')  WordVerifierDto? createdBy,  List<MeaningDto> meanings,  List<CategoryDto> categories, @JsonKey(name: 'usage_labels')  List<String> usageLabels,  List<PronunciationDto> pronunciations,  List<WordAudioDto> audios,  List<WordImageDto> images, @JsonKey(name: 'related_words')  List<RelatedWordDto> relatedWords, @JsonKey(name: 'appears_in')  List<RelatedWordDto> appearsIn, @JsonKey(name: 'meaning_groups')  List<MeaningGroupDto> meaningGroups,  List<WordVariantDto> variants,  String? date, @JsonKey(name: 'is_new_this_week')  bool isNewThisWeek)?  $default,) {final _that = this;
switch (_that) {
case _WordDetailDto() when $default != null:
return $default(_that.id,_that.lemma,_that.languageId,_that.notes,_that.wordType,_that.status,_that.isVerified,_that.isCorrected,_that.selfVerified,_that.verifiedAt,_that.verifiedBy,_that.createdBy,_that.meanings,_that.categories,_that.usageLabels,_that.pronunciations,_that.audios,_that.images,_that.relatedWords,_that.appearsIn,_that.meaningGroups,_that.variants,_that.date,_that.isNewThisWeek);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WordDetailDto implements WordDetailDto {
  const _WordDetailDto({required this.id, required this.lemma, @JsonKey(name: 'language_id') required this.languageId, this.notes, @JsonKey(name: 'word_type') required this.wordType, required this.status, @JsonKey(name: 'is_verified') required this.isVerified, @JsonKey(name: 'is_corrected') this.isCorrected = false, @JsonKey(name: 'self_verified') this.selfVerified = false, @JsonKey(name: 'verified_at') this.verifiedAt, @JsonKey(name: 'verified_by') this.verifiedBy, @JsonKey(name: 'created_by') this.createdBy,  List<MeaningDto> meanings = const [],  List<CategoryDto> categories = const [], @JsonKey(name: 'usage_labels')  List<String> usageLabels = const [],  List<PronunciationDto> pronunciations = const [],  List<WordAudioDto> audios = const [],  List<WordImageDto> images = const [], @JsonKey(name: 'related_words')  List<RelatedWordDto> relatedWords = const [], @JsonKey(name: 'appears_in')  List<RelatedWordDto> appearsIn = const [], @JsonKey(name: 'meaning_groups')  List<MeaningGroupDto> meaningGroups = const [],  List<WordVariantDto> variants = const [], this.date, @JsonKey(name: 'is_new_this_week') this.isNewThisWeek = false}): _meanings = meanings,_categories = categories,_usageLabels = usageLabels,_pronunciations = pronunciations,_audios = audios,_images = images,_relatedWords = relatedWords,_appearsIn = appearsIn,_meaningGroups = meaningGroups,_variants = variants;
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

/// PRD relasi-lemma: kelompok makna (published saja).
 final  List<MeaningGroupDto> _meaningGroups;
/// PRD relasi-lemma: kelompok makna (published saja).
@override@JsonKey(name: 'meaning_groups') List<MeaningGroupDto> get meaningGroups {
  if (_meaningGroups is EqualUnmodifiableListView) return _meaningGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_meaningGroups);
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.languageId, languageId) || other.languageId == languageId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.wordType, wordType) || other.wordType == wordType)&&(identical(other.status, status) || other.status == status)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isCorrected, isCorrected) || other.isCorrected == isCorrected)&&(identical(other.selfVerified, selfVerified) || other.selfVerified == selfVerified)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&const DeepCollectionEquality().equals(other.meanings, _meanings)&&const DeepCollectionEquality().equals(other.categories, _categories)&&const DeepCollectionEquality().equals(other.usageLabels, _usageLabels)&&const DeepCollectionEquality().equals(other.pronunciations, _pronunciations)&&const DeepCollectionEquality().equals(other.audios, _audios)&&const DeepCollectionEquality().equals(other.images, _images)&&const DeepCollectionEquality().equals(other.relatedWords, _relatedWords)&&const DeepCollectionEquality().equals(other.appearsIn, _appearsIn)&&const DeepCollectionEquality().equals(other.meaningGroups, _meaningGroups)&&const DeepCollectionEquality().equals(other.variants, _variants)&&(identical(other.date, date) || other.date == date)&&(identical(other.isNewThisWeek, isNewThisWeek) || other.isNewThisWeek == isNewThisWeek));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,lemma,languageId,notes,wordType,status,isVerified,isCorrected,selfVerified,verifiedAt,verifiedBy,createdBy,const DeepCollectionEquality().hash(_meanings),const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_usageLabels),const DeepCollectionEquality().hash(_pronunciations),const DeepCollectionEquality().hash(_audios),const DeepCollectionEquality().hash(_images),const DeepCollectionEquality().hash(_relatedWords),const DeepCollectionEquality().hash(_appearsIn),const DeepCollectionEquality().hash(_meaningGroups),const DeepCollectionEquality().hash(_variants),date,isNewThisWeek]);
}

@override
String toString() {
    return 'WordDetailDto(id: $id, lemma: $lemma, languageId: $languageId, notes: $notes, wordType: $wordType, status: $status, isVerified: $isVerified, isCorrected: $isCorrected, selfVerified: $selfVerified, verifiedAt: $verifiedAt, verifiedBy: $verifiedBy, createdBy: $createdBy, meanings: $meanings, categories: $categories, usageLabels: $usageLabels, pronunciations: $pronunciations, audios: $audios, images: $images, relatedWords: $relatedWords, appearsIn: $appearsIn, meaningGroups: $meaningGroups, variants: $variants, date: $date, isNewThisWeek: $isNewThisWeek)';
}


}

/// @nodoc
abstract mixin class _$WordDetailDtoCopyWith<$Res> implements $WordDetailDtoCopyWith<$Res> {
  factory _$WordDetailDtoCopyWith(_WordDetailDto value, $Res Function(_WordDetailDto) _then) = __$WordDetailDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String lemma,@JsonKey(name: 'language_id') String languageId, String? notes,@JsonKey(name: 'word_type') String wordType, String status,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'is_corrected') bool isCorrected,@JsonKey(name: 'self_verified') bool selfVerified,@JsonKey(name: 'verified_at') String? verifiedAt,@JsonKey(name: 'verified_by') WordVerifierDto? verifiedBy,@JsonKey(name: 'created_by') WordVerifierDto? createdBy, List<MeaningDto> meanings, List<CategoryDto> categories,@JsonKey(name: 'usage_labels') List<String> usageLabels, List<PronunciationDto> pronunciations, List<WordAudioDto> audios, List<WordImageDto> images,@JsonKey(name: 'related_words') List<RelatedWordDto> relatedWords,@JsonKey(name: 'appears_in') List<RelatedWordDto> appearsIn,@JsonKey(name: 'meaning_groups') List<MeaningGroupDto> meaningGroups, List<WordVariantDto> variants, String? date,@JsonKey(name: 'is_new_this_week') bool isNewThisWeek
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lemma = null,Object? languageId = null,Object? notes = freezed,Object? wordType = null,Object? status = null,Object? isVerified = null,Object? isCorrected = null,Object? selfVerified = null,Object? verifiedAt = freezed,Object? verifiedBy = freezed,Object? createdBy = freezed,Object? meanings = null,Object? categories = null,Object? usageLabels = null,Object? pronunciations = null,Object? audios = null,Object? images = null,Object? relatedWords = null,Object? appearsIn = null,Object? meaningGroups = null,Object? variants = null,Object? date = freezed,Object? isNewThisWeek = null,}) {
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
as List<RelatedWordDto>,meaningGroups: null == meaningGroups ? _self._meaningGroups : meaningGroups // ignore: cast_nullable_to_non_nullable
as List<MeaningGroupDto>,variants: null == variants ? _self._variants : variants // ignore: cast_nullable_to_non_nullable
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
  final _this = this as WordVerifierDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordVerifierDto&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.role, _this.role) || other.role == _this.role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WordVerifierDto;
  return Object.hash(runtimeType,_this.username,_this.displayName,_this.role);
}

@override
String toString() {
  final _this = this as WordVerifierDto;
  return 'WordVerifierDto(username: ${_this.username}, displayName: ${_this.displayName}, role: ${_this.role})';
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
  return _then(WordVerifierDto(
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
int get hashCode {
    return Object.hash(runtimeType,username,displayName,role);
}

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

 String get id;@JsonKey(name: 'word_class') WordClassDto? get wordClass;@JsonKey(name: 'inherited_from_meaning_id') String? get inheritedFromMeaningId; String? get definition;@JsonKey(name: 'order_index') int get orderIndex;@JsonKey(name: 'created_by') WordVerifierDto? get createdBy; List<TranslationDto> get translations; List<ExampleDto> get examples;
/// Create a copy of MeaningDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeaningDtoCopyWith<MeaningDto> get copyWith => _$MeaningDtoCopyWithImpl<MeaningDto>(this as MeaningDto, _$identity);

  /// Serializes this MeaningDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MeaningDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeaningDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.wordClass, _this.wordClass) || other.wordClass == _this.wordClass)&&(identical(other.inheritedFromMeaningId, _this.inheritedFromMeaningId) || other.inheritedFromMeaningId == _this.inheritedFromMeaningId)&&(identical(other.definition, _this.definition) || other.definition == _this.definition)&&(identical(other.orderIndex, _this.orderIndex) || other.orderIndex == _this.orderIndex)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&const DeepCollectionEquality().equals(other.translations, _this.translations)&&const DeepCollectionEquality().equals(other.examples, _this.examples));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MeaningDto;
  return Object.hash(runtimeType,_this.id,_this.wordClass,_this.inheritedFromMeaningId,_this.definition,_this.orderIndex,_this.createdBy,const DeepCollectionEquality().hash(_this.translations),const DeepCollectionEquality().hash(_this.examples));
}

@override
String toString() {
  final _this = this as MeaningDto;
  return 'MeaningDto(id: ${_this.id}, wordClass: ${_this.wordClass}, inheritedFromMeaningId: ${_this.inheritedFromMeaningId}, definition: ${_this.definition}, orderIndex: ${_this.orderIndex}, createdBy: ${_this.createdBy}, translations: ${_this.translations}, examples: ${_this.examples})';
}


}

/// @nodoc
abstract mixin class $MeaningDtoCopyWith<$Res>  {
  factory $MeaningDtoCopyWith(MeaningDto value, $Res Function(MeaningDto) _then) = _$MeaningDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'word_class') WordClassDto? wordClass,@JsonKey(name: 'inherited_from_meaning_id') String? inheritedFromMeaningId, String? definition,@JsonKey(name: 'order_index') int orderIndex,@JsonKey(name: 'created_by') WordVerifierDto? createdBy, List<TranslationDto> translations, List<ExampleDto> examples
});


$WordClassDtoCopyWith<$Res>? get wordClass;$WordVerifierDtoCopyWith<$Res>? get createdBy;

}
/// @nodoc
class _$MeaningDtoCopyWithImpl<$Res>
    implements $MeaningDtoCopyWith<$Res> {
  _$MeaningDtoCopyWithImpl(this._self, this._then);

  final MeaningDto _self;
  final $Res Function(MeaningDto) _then;

/// Create a copy of MeaningDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? wordClass = freezed,Object? inheritedFromMeaningId = freezed,Object? definition = freezed,Object? orderIndex = null,Object? createdBy = freezed,Object? translations = null,Object? examples = null,}) {
  return _then(MeaningDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,wordClass: freezed == wordClass ? _self.wordClass : wordClass // ignore: cast_nullable_to_non_nullable
as WordClassDto?,inheritedFromMeaningId: freezed == inheritedFromMeaningId ? _self.inheritedFromMeaningId : inheritedFromMeaningId // ignore: cast_nullable_to_non_nullable
as String?,definition: freezed == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String?,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as WordVerifierDto?,translations: null == translations ? _self.translations : translations // ignore: cast_nullable_to_non_nullable
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
}/// Create a copy of MeaningDto
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'word_class')  WordClassDto? wordClass, @JsonKey(name: 'inherited_from_meaning_id')  String? inheritedFromMeaningId,  String? definition, @JsonKey(name: 'order_index')  int orderIndex, @JsonKey(name: 'created_by')  WordVerifierDto? createdBy,  List<TranslationDto> translations,  List<ExampleDto> examples)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeaningDto() when $default != null:
return $default(_that.id,_that.wordClass,_that.inheritedFromMeaningId,_that.definition,_that.orderIndex,_that.createdBy,_that.translations,_that.examples);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'word_class')  WordClassDto? wordClass, @JsonKey(name: 'inherited_from_meaning_id')  String? inheritedFromMeaningId,  String? definition, @JsonKey(name: 'order_index')  int orderIndex, @JsonKey(name: 'created_by')  WordVerifierDto? createdBy,  List<TranslationDto> translations,  List<ExampleDto> examples)  $default,) {final _that = this;
switch (_that) {
case _MeaningDto():
return $default(_that.id,_that.wordClass,_that.inheritedFromMeaningId,_that.definition,_that.orderIndex,_that.createdBy,_that.translations,_that.examples);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'word_class')  WordClassDto? wordClass, @JsonKey(name: 'inherited_from_meaning_id')  String? inheritedFromMeaningId,  String? definition, @JsonKey(name: 'order_index')  int orderIndex, @JsonKey(name: 'created_by')  WordVerifierDto? createdBy,  List<TranslationDto> translations,  List<ExampleDto> examples)?  $default,) {final _that = this;
switch (_that) {
case _MeaningDto() when $default != null:
return $default(_that.id,_that.wordClass,_that.inheritedFromMeaningId,_that.definition,_that.orderIndex,_that.createdBy,_that.translations,_that.examples);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeaningDto implements MeaningDto {
  const _MeaningDto({required this.id, @JsonKey(name: 'word_class') this.wordClass, @JsonKey(name: 'inherited_from_meaning_id') this.inheritedFromMeaningId, this.definition, @JsonKey(name: 'order_index') this.orderIndex = 0, @JsonKey(name: 'created_by') this.createdBy,  List<TranslationDto> translations = const [],  List<ExampleDto> examples = const []}): _translations = translations,_examples = examples;
  factory _MeaningDto.fromJson(Map<String, dynamic> json) => _$MeaningDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'word_class') final  WordClassDto? wordClass;
@override@JsonKey(name: 'inherited_from_meaning_id') final  String? inheritedFromMeaningId;
@override final  String? definition;
@override@JsonKey(name: 'order_index') final  int orderIndex;
@override@JsonKey(name: 'created_by') final  WordVerifierDto? createdBy;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeaningDto&&(identical(other.id, id) || other.id == id)&&(identical(other.wordClass, wordClass) || other.wordClass == wordClass)&&(identical(other.inheritedFromMeaningId, inheritedFromMeaningId) || other.inheritedFromMeaningId == inheritedFromMeaningId)&&(identical(other.definition, definition) || other.definition == definition)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&const DeepCollectionEquality().equals(other.translations, _translations)&&const DeepCollectionEquality().equals(other.examples, _examples));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,wordClass,inheritedFromMeaningId,definition,orderIndex,createdBy,const DeepCollectionEquality().hash(_translations),const DeepCollectionEquality().hash(_examples));
}

@override
String toString() {
    return 'MeaningDto(id: $id, wordClass: $wordClass, inheritedFromMeaningId: $inheritedFromMeaningId, definition: $definition, orderIndex: $orderIndex, createdBy: $createdBy, translations: $translations, examples: $examples)';
}


}

/// @nodoc
abstract mixin class _$MeaningDtoCopyWith<$Res> implements $MeaningDtoCopyWith<$Res> {
  factory _$MeaningDtoCopyWith(_MeaningDto value, $Res Function(_MeaningDto) _then) = __$MeaningDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'word_class') WordClassDto? wordClass,@JsonKey(name: 'inherited_from_meaning_id') String? inheritedFromMeaningId, String? definition,@JsonKey(name: 'order_index') int orderIndex,@JsonKey(name: 'created_by') WordVerifierDto? createdBy, List<TranslationDto> translations, List<ExampleDto> examples
});


@override $WordClassDtoCopyWith<$Res>? get wordClass;@override $WordVerifierDtoCopyWith<$Res>? get createdBy;

}
/// @nodoc
class __$MeaningDtoCopyWithImpl<$Res>
    implements _$MeaningDtoCopyWith<$Res> {
  __$MeaningDtoCopyWithImpl(this._self, this._then);

  final _MeaningDto _self;
  final $Res Function(_MeaningDto) _then;

/// Create a copy of MeaningDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? wordClass = freezed,Object? inheritedFromMeaningId = freezed,Object? definition = freezed,Object? orderIndex = null,Object? createdBy = freezed,Object? translations = null,Object? examples = null,}) {
  return _then(_MeaningDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,wordClass: freezed == wordClass ? _self.wordClass : wordClass // ignore: cast_nullable_to_non_nullable
as WordClassDto?,inheritedFromMeaningId: freezed == inheritedFromMeaningId ? _self.inheritedFromMeaningId : inheritedFromMeaningId // ignore: cast_nullable_to_non_nullable
as String?,definition: freezed == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String?,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as WordVerifierDto?,translations: null == translations ? _self._translations : translations // ignore: cast_nullable_to_non_nullable
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
}/// Create a copy of MeaningDto
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
  final _this = this as WordClassDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordClassDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.alias, _this.alias) || other.alias == _this.alias)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WordClassDto;
  return Object.hash(runtimeType,_this.id,_this.code,_this.name,_this.alias,_this.parentId);
}

@override
String toString() {
  final _this = this as WordClassDto;
  return 'WordClassDto(id: ${_this.id}, code: ${_this.code}, name: ${_this.name}, alias: ${_this.alias}, parentId: ${_this.parentId})';
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
  return _then(WordClassDto(
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
int get hashCode {
    return Object.hash(runtimeType,id,code,name,alias,parentId);
}

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
  final _this = this as TranslationDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslationDto&&(identical(other.languageId, _this.languageId) || other.languageId == _this.languageId)&&(identical(other.translationText, _this.translationText) || other.translationText == _this.translationText)&&(identical(other.translationType, _this.translationType) || other.translationType == _this.translationType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TranslationDto;
  return Object.hash(runtimeType,_this.languageId,_this.translationText,_this.translationType);
}

@override
String toString() {
  final _this = this as TranslationDto;
  return 'TranslationDto(languageId: ${_this.languageId}, translationText: ${_this.translationText}, translationType: ${_this.translationType})';
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
  return _then(TranslationDto(
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
int get hashCode {
    return Object.hash(runtimeType,languageId,translationText,translationType);
}

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
  final _this = this as ExampleDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExampleDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sourceLanguageId, _this.sourceLanguageId) || other.sourceLanguageId == _this.sourceLanguageId)&&(identical(other.sourceSentence, _this.sourceSentence) || other.sourceSentence == _this.sourceSentence)&&(identical(other.targetLanguageId, _this.targetLanguageId) || other.targetLanguageId == _this.targetLanguageId)&&(identical(other.targetSentence, _this.targetSentence) || other.targetSentence == _this.targetSentence)&&(identical(other.sourceType, _this.sourceType) || other.sourceType == _this.sourceType)&&const DeepCollectionEquality().equals(other.audios, _this.audios));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExampleDto;
  return Object.hash(runtimeType,_this.id,_this.sourceLanguageId,_this.sourceSentence,_this.targetLanguageId,_this.targetSentence,_this.sourceType,const DeepCollectionEquality().hash(_this.audios));
}

@override
String toString() {
  final _this = this as ExampleDto;
  return 'ExampleDto(id: ${_this.id}, sourceLanguageId: ${_this.sourceLanguageId}, sourceSentence: ${_this.sourceSentence}, targetLanguageId: ${_this.targetLanguageId}, targetSentence: ${_this.targetSentence}, sourceType: ${_this.sourceType}, audios: ${_this.audios})';
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
  return _then(ExampleDto(
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
  const _ExampleDto({required this.id, @JsonKey(name: 'source_language_id') required this.sourceLanguageId, @JsonKey(name: 'source_sentence') required this.sourceSentence, @JsonKey(name: 'target_language_id', fromJson: nullableStringFromJson) this.targetLanguageId, @JsonKey(name: 'target_sentence', fromJson: nullableStringFromJson) this.targetSentence, @JsonKey(name: 'source_type', fromJson: nullableStringFromJson) this.sourceType,  List<WordAudioDto> audios = const []}): _audios = audios;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExampleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceLanguageId, sourceLanguageId) || other.sourceLanguageId == sourceLanguageId)&&(identical(other.sourceSentence, sourceSentence) || other.sourceSentence == sourceSentence)&&(identical(other.targetLanguageId, targetLanguageId) || other.targetLanguageId == targetLanguageId)&&(identical(other.targetSentence, targetSentence) || other.targetSentence == targetSentence)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&const DeepCollectionEquality().equals(other.audios, _audios));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,sourceLanguageId,sourceSentence,targetLanguageId,targetSentence,sourceType,const DeepCollectionEquality().hash(_audios));
}

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
  final _this = this as CategoryDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CategoryDto;
  return Object.hash(runtimeType,_this.id,_this.name);
}

@override
String toString() {
  final _this = this as CategoryDto;
  return 'CategoryDto(id: ${_this.id}, name: ${_this.name})';
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
  return _then(CategoryDto(
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
int get hashCode {
    return Object.hash(runtimeType,id,name);
}

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
  final _this = this as PronunciationDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PronunciationDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.notation, _this.notation) || other.notation == _this.notation)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.dialectId, _this.dialectId) || other.dialectId == _this.dialectId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PronunciationDto;
  return Object.hash(runtimeType,_this.id,_this.notation,_this.value,_this.dialectId);
}

@override
String toString() {
  final _this = this as PronunciationDto;
  return 'PronunciationDto(id: ${_this.id}, notation: ${_this.notation}, value: ${_this.value}, dialectId: ${_this.dialectId})';
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
  return _then(PronunciationDto(
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
int get hashCode {
    return Object.hash(runtimeType,id,notation,value,dialectId);
}

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
  final _this = this as WordImageDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordImageDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.altText, _this.altText) || other.altText == _this.altText)&&(identical(other.isPrimary, _this.isPrimary) || other.isPrimary == _this.isPrimary)&&(identical(other.isVerified, _this.isVerified) || other.isVerified == _this.isVerified)&&const DeepCollectionEquality().equals(other.contentWarnings, _this.contentWarnings)&&const DeepCollectionEquality().equals(other.attribution, _this.attribution));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WordImageDto;
  return Object.hash(runtimeType,_this.id,_this.url,_this.altText,_this.isPrimary,_this.isVerified,const DeepCollectionEquality().hash(_this.contentWarnings),const DeepCollectionEquality().hash(_this.attribution));
}

@override
String toString() {
  final _this = this as WordImageDto;
  return 'WordImageDto(id: ${_this.id}, url: ${_this.url}, altText: ${_this.altText}, isPrimary: ${_this.isPrimary}, isVerified: ${_this.isVerified}, contentWarnings: ${_this.contentWarnings}, attribution: ${_this.attribution})';
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
  return _then(WordImageDto(
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
  const _WordImageDto({required this.id, required this.url, @JsonKey(name: 'alt_text') this.altText, @JsonKey(name: 'is_primary') this.isPrimary = false, @JsonKey(name: 'is_verified') this.isVerified = true, @JsonKey(name: 'content_warnings')  List<String> contentWarnings = const [],  Map<String, dynamic>? attribution}): _contentWarnings = contentWarnings,_attribution = attribution;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordImageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.altText, altText) || other.altText == altText)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&const DeepCollectionEquality().equals(other.contentWarnings, _contentWarnings)&&const DeepCollectionEquality().equals(other.attribution, _attribution));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,url,altText,isPrimary,isVerified,const DeepCollectionEquality().hash(_contentWarnings),const DeepCollectionEquality().hash(_attribution));
}

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
  final _this = this as RelatedWordDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RelatedWordDto&&(identical(other.wordId, _this.wordId) || other.wordId == _this.wordId)&&(identical(other.lemma, _this.lemma) || other.lemma == _this.lemma)&&(identical(other.relationType, _this.relationType) || other.relationType == _this.relationType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RelatedWordDto;
  return Object.hash(runtimeType,_this.wordId,_this.lemma,_this.relationType);
}

@override
String toString() {
  final _this = this as RelatedWordDto;
  return 'RelatedWordDto(wordId: ${_this.wordId}, lemma: ${_this.lemma}, relationType: ${_this.relationType})';
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
  return _then(RelatedWordDto(
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
int get hashCode {
    return Object.hash(runtimeType,wordId,lemma,relationType);
}

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
mixin _$MeaningGroupMemberDto {

@JsonKey(name: 'word_id') String get wordId; String get lemma; String? get notes;
/// Create a copy of MeaningGroupMemberDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeaningGroupMemberDtoCopyWith<MeaningGroupMemberDto> get copyWith => _$MeaningGroupMemberDtoCopyWithImpl<MeaningGroupMemberDto>(this as MeaningGroupMemberDto, _$identity);

  /// Serializes this MeaningGroupMemberDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MeaningGroupMemberDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeaningGroupMemberDto&&(identical(other.wordId, _this.wordId) || other.wordId == _this.wordId)&&(identical(other.lemma, _this.lemma) || other.lemma == _this.lemma)&&(identical(other.notes, _this.notes) || other.notes == _this.notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MeaningGroupMemberDto;
  return Object.hash(runtimeType,_this.wordId,_this.lemma,_this.notes);
}

@override
String toString() {
  final _this = this as MeaningGroupMemberDto;
  return 'MeaningGroupMemberDto(wordId: ${_this.wordId}, lemma: ${_this.lemma}, notes: ${_this.notes})';
}


}

/// @nodoc
abstract mixin class $MeaningGroupMemberDtoCopyWith<$Res>  {
  factory $MeaningGroupMemberDtoCopyWith(MeaningGroupMemberDto value, $Res Function(MeaningGroupMemberDto) _then) = _$MeaningGroupMemberDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'word_id') String wordId, String lemma, String? notes
});




}
/// @nodoc
class _$MeaningGroupMemberDtoCopyWithImpl<$Res>
    implements $MeaningGroupMemberDtoCopyWith<$Res> {
  _$MeaningGroupMemberDtoCopyWithImpl(this._self, this._then);

  final MeaningGroupMemberDto _self;
  final $Res Function(MeaningGroupMemberDto) _then;

/// Create a copy of MeaningGroupMemberDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wordId = null,Object? lemma = null,Object? notes = freezed,}) {
  return _then(MeaningGroupMemberDto(
wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,lemma: null == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MeaningGroupMemberDto].
extension MeaningGroupMemberDtoPatterns on MeaningGroupMemberDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeaningGroupMemberDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeaningGroupMemberDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeaningGroupMemberDto value)  $default,){
final _that = this;
switch (_that) {
case _MeaningGroupMemberDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeaningGroupMemberDto value)?  $default,){
final _that = this;
switch (_that) {
case _MeaningGroupMemberDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'word_id')  String wordId,  String lemma,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeaningGroupMemberDto() when $default != null:
return $default(_that.wordId,_that.lemma,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'word_id')  String wordId,  String lemma,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _MeaningGroupMemberDto():
return $default(_that.wordId,_that.lemma,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'word_id')  String wordId,  String lemma,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _MeaningGroupMemberDto() when $default != null:
return $default(_that.wordId,_that.lemma,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeaningGroupMemberDto implements MeaningGroupMemberDto {
  const _MeaningGroupMemberDto({@JsonKey(name: 'word_id') required this.wordId, required this.lemma, this.notes});
  factory _MeaningGroupMemberDto.fromJson(Map<String, dynamic> json) => _$MeaningGroupMemberDtoFromJson(json);

@override@JsonKey(name: 'word_id') final  String wordId;
@override final  String lemma;
@override final  String? notes;

/// Create a copy of MeaningGroupMemberDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeaningGroupMemberDtoCopyWith<_MeaningGroupMemberDto> get copyWith => __$MeaningGroupMemberDtoCopyWithImpl<_MeaningGroupMemberDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeaningGroupMemberDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeaningGroupMemberDto&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,wordId,lemma,notes);
}

@override
String toString() {
    return 'MeaningGroupMemberDto(wordId: $wordId, lemma: $lemma, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$MeaningGroupMemberDtoCopyWith<$Res> implements $MeaningGroupMemberDtoCopyWith<$Res> {
  factory _$MeaningGroupMemberDtoCopyWith(_MeaningGroupMemberDto value, $Res Function(_MeaningGroupMemberDto) _then) = __$MeaningGroupMemberDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'word_id') String wordId, String lemma, String? notes
});




}
/// @nodoc
class __$MeaningGroupMemberDtoCopyWithImpl<$Res>
    implements _$MeaningGroupMemberDtoCopyWith<$Res> {
  __$MeaningGroupMemberDtoCopyWithImpl(this._self, this._then);

  final _MeaningGroupMemberDto _self;
  final $Res Function(_MeaningGroupMemberDto) _then;

/// Create a copy of MeaningGroupMemberDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wordId = null,Object? lemma = null,Object? notes = freezed,}) {
  return _then(_MeaningGroupMemberDto(
wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,lemma: null == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MeaningGroupDto {

@JsonKey(name: 'group_id') String get groupId; String get name; String? get description; List<MeaningGroupMemberDto> get members;
/// Create a copy of MeaningGroupDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeaningGroupDtoCopyWith<MeaningGroupDto> get copyWith => _$MeaningGroupDtoCopyWithImpl<MeaningGroupDto>(this as MeaningGroupDto, _$identity);

  /// Serializes this MeaningGroupDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MeaningGroupDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeaningGroupDto&&(identical(other.groupId, _this.groupId) || other.groupId == _this.groupId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&const DeepCollectionEquality().equals(other.members, _this.members));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MeaningGroupDto;
  return Object.hash(runtimeType,_this.groupId,_this.name,_this.description,const DeepCollectionEquality().hash(_this.members));
}

@override
String toString() {
  final _this = this as MeaningGroupDto;
  return 'MeaningGroupDto(groupId: ${_this.groupId}, name: ${_this.name}, description: ${_this.description}, members: ${_this.members})';
}


}

/// @nodoc
abstract mixin class $MeaningGroupDtoCopyWith<$Res>  {
  factory $MeaningGroupDtoCopyWith(MeaningGroupDto value, $Res Function(MeaningGroupDto) _then) = _$MeaningGroupDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'group_id') String groupId, String name, String? description, List<MeaningGroupMemberDto> members
});




}
/// @nodoc
class _$MeaningGroupDtoCopyWithImpl<$Res>
    implements $MeaningGroupDtoCopyWith<$Res> {
  _$MeaningGroupDtoCopyWithImpl(this._self, this._then);

  final MeaningGroupDto _self;
  final $Res Function(MeaningGroupDto) _then;

/// Create a copy of MeaningGroupDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupId = null,Object? name = null,Object? description = freezed,Object? members = null,}) {
  return _then(MeaningGroupDto(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<MeaningGroupMemberDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [MeaningGroupDto].
extension MeaningGroupDtoPatterns on MeaningGroupDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeaningGroupDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeaningGroupDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeaningGroupDto value)  $default,){
final _that = this;
switch (_that) {
case _MeaningGroupDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeaningGroupDto value)?  $default,){
final _that = this;
switch (_that) {
case _MeaningGroupDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'group_id')  String groupId,  String name,  String? description,  List<MeaningGroupMemberDto> members)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeaningGroupDto() when $default != null:
return $default(_that.groupId,_that.name,_that.description,_that.members);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'group_id')  String groupId,  String name,  String? description,  List<MeaningGroupMemberDto> members)  $default,) {final _that = this;
switch (_that) {
case _MeaningGroupDto():
return $default(_that.groupId,_that.name,_that.description,_that.members);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'group_id')  String groupId,  String name,  String? description,  List<MeaningGroupMemberDto> members)?  $default,) {final _that = this;
switch (_that) {
case _MeaningGroupDto() when $default != null:
return $default(_that.groupId,_that.name,_that.description,_that.members);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeaningGroupDto implements MeaningGroupDto {
  const _MeaningGroupDto({@JsonKey(name: 'group_id') required this.groupId, required this.name, this.description,  List<MeaningGroupMemberDto> members = const []}): _members = members;
  factory _MeaningGroupDto.fromJson(Map<String, dynamic> json) => _$MeaningGroupDtoFromJson(json);

@override@JsonKey(name: 'group_id') final  String groupId;
@override final  String name;
@override final  String? description;
 final  List<MeaningGroupMemberDto> _members;
@override@JsonKey() List<MeaningGroupMemberDto> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}


/// Create a copy of MeaningGroupDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeaningGroupDtoCopyWith<_MeaningGroupDto> get copyWith => __$MeaningGroupDtoCopyWithImpl<_MeaningGroupDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeaningGroupDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeaningGroupDto&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.members, _members));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,groupId,name,description,const DeepCollectionEquality().hash(_members));
}

@override
String toString() {
    return 'MeaningGroupDto(groupId: $groupId, name: $name, description: $description, members: $members)';
}


}

/// @nodoc
abstract mixin class _$MeaningGroupDtoCopyWith<$Res> implements $MeaningGroupDtoCopyWith<$Res> {
  factory _$MeaningGroupDtoCopyWith(_MeaningGroupDto value, $Res Function(_MeaningGroupDto) _then) = __$MeaningGroupDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'group_id') String groupId, String name, String? description, List<MeaningGroupMemberDto> members
});




}
/// @nodoc
class __$MeaningGroupDtoCopyWithImpl<$Res>
    implements _$MeaningGroupDtoCopyWith<$Res> {
  __$MeaningGroupDtoCopyWithImpl(this._self, this._then);

  final _MeaningGroupDto _self;
  final $Res Function(_MeaningGroupDto) _then;

/// Create a copy of MeaningGroupDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupId = null,Object? name = null,Object? description = freezed,Object? members = null,}) {
  return _then(_MeaningGroupDto(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<MeaningGroupMemberDto>,
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
  final _this = this as WordVariantDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordVariantDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.form, _this.form) || other.form == _this.form)&&(identical(other.variantType, _this.variantType) || other.variantType == _this.variantType)&&(identical(other.affixType, _this.affixType) || other.affixType == _this.affixType)&&(identical(other.affixValue, _this.affixValue) || other.affixValue == _this.affixValue)&&(identical(other.dialectId, _this.dialectId) || other.dialectId == _this.dialectId)&&(identical(other.notes, _this.notes) || other.notes == _this.notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WordVariantDto;
  return Object.hash(runtimeType,_this.id,_this.form,_this.variantType,_this.affixType,_this.affixValue,_this.dialectId,_this.notes);
}

@override
String toString() {
  final _this = this as WordVariantDto;
  return 'WordVariantDto(id: ${_this.id}, form: ${_this.form}, variantType: ${_this.variantType}, affixType: ${_this.affixType}, affixValue: ${_this.affixValue}, dialectId: ${_this.dialectId}, notes: ${_this.notes})';
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
  return _then(WordVariantDto(
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
int get hashCode {
    return Object.hash(runtimeType,id,form,variantType,affixType,affixValue,dialectId,notes);
}

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
