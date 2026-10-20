// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_summary_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WordSummaryDto {

 String get id; String get lemma;@JsonKey(name: 'language_id') String get languageId;@JsonKey(name: 'language_code') String get languageCode;@JsonKey(name: 'word_type') String get wordType; String get status;@JsonKey(name: 'is_verified') bool get isVerified;/// Hanya terisi saat search_in=translation (Indonesia→Sambas).
@JsonKey(name: 'matched_translation') String? get matchedTranslation;/// Form variasi yang cocok (doc 11, search_in=lemma via variasi).
@JsonKey(name: 'matched_variant') String? get matchedVariant;/// PRD relasi-lemma: 'related_group' = hasil perluasan kelompok makna
/// (bukan cocok langsung). Null = hasil langsung.
@JsonKey(name: 'match_type') String? get matchType;/// Satu baris arti.
/// - GET /words/latest: definisi atau terjemahan pertama.
/// - GET /words (A-Z): gloss `[n] makan,[v] santap`.
 String? get sense;/// Waktu persetujuan ISO. Hanya GET /api/v1/words/latest.
@JsonKey(name: 'approved_at') String? get approvedAt;@JsonKey(name: 'usage_labels') List<String> get usageLabels;
/// Create a copy of WordSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordSummaryDtoCopyWith<WordSummaryDto> get copyWith => _$WordSummaryDtoCopyWithImpl<WordSummaryDto>(this as WordSummaryDto, _$identity);

  /// Serializes this WordSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordSummaryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.languageId, languageId) || other.languageId == languageId)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.wordType, wordType) || other.wordType == wordType)&&(identical(other.status, status) || other.status == status)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.matchedTranslation, matchedTranslation) || other.matchedTranslation == matchedTranslation)&&(identical(other.matchedVariant, matchedVariant) || other.matchedVariant == matchedVariant)&&(identical(other.matchType, matchType) || other.matchType == matchType)&&(identical(other.sense, sense) || other.sense == sense)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&const DeepCollectionEquality().equals(other.usageLabels, usageLabels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,lemma,languageId,languageCode,wordType,status,isVerified,matchedTranslation,matchedVariant,matchType,sense,approvedAt,const DeepCollectionEquality().hash(usageLabels));

@override
String toString() {
  return 'WordSummaryDto(id: $id, lemma: $lemma, languageId: $languageId, languageCode: $languageCode, wordType: $wordType, status: $status, isVerified: $isVerified, matchedTranslation: $matchedTranslation, matchedVariant: $matchedVariant, matchType: $matchType, sense: $sense, approvedAt: $approvedAt, usageLabels: $usageLabels)';
}


}

/// @nodoc
abstract mixin class $WordSummaryDtoCopyWith<$Res>  {
  factory $WordSummaryDtoCopyWith(WordSummaryDto value, $Res Function(WordSummaryDto) _then) = _$WordSummaryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String lemma,@JsonKey(name: 'language_id') String languageId,@JsonKey(name: 'language_code') String languageCode,@JsonKey(name: 'word_type') String wordType, String status,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'matched_translation') String? matchedTranslation,@JsonKey(name: 'matched_variant') String? matchedVariant,@JsonKey(name: 'match_type') String? matchType, String? sense,@JsonKey(name: 'approved_at') String? approvedAt,@JsonKey(name: 'usage_labels') List<String> usageLabels
});




}
/// @nodoc
class _$WordSummaryDtoCopyWithImpl<$Res>
    implements $WordSummaryDtoCopyWith<$Res> {
  _$WordSummaryDtoCopyWithImpl(this._self, this._then);

  final WordSummaryDto _self;
  final $Res Function(WordSummaryDto) _then;

/// Create a copy of WordSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lemma = null,Object? languageId = null,Object? languageCode = null,Object? wordType = null,Object? status = null,Object? isVerified = null,Object? matchedTranslation = freezed,Object? matchedVariant = freezed,Object? matchType = freezed,Object? sense = freezed,Object? approvedAt = freezed,Object? usageLabels = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lemma: null == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String,languageId: null == languageId ? _self.languageId : languageId // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,wordType: null == wordType ? _self.wordType : wordType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,matchedTranslation: freezed == matchedTranslation ? _self.matchedTranslation : matchedTranslation // ignore: cast_nullable_to_non_nullable
as String?,matchedVariant: freezed == matchedVariant ? _self.matchedVariant : matchedVariant // ignore: cast_nullable_to_non_nullable
as String?,matchType: freezed == matchType ? _self.matchType : matchType // ignore: cast_nullable_to_non_nullable
as String?,sense: freezed == sense ? _self.sense : sense // ignore: cast_nullable_to_non_nullable
as String?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as String?,usageLabels: null == usageLabels ? _self.usageLabels : usageLabels // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [WordSummaryDto].
extension WordSummaryDtoPatterns on WordSummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordSummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordSummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordSummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _WordSummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordSummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _WordSummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String lemma, @JsonKey(name: 'language_id')  String languageId, @JsonKey(name: 'language_code')  String languageCode, @JsonKey(name: 'word_type')  String wordType,  String status, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'matched_translation')  String? matchedTranslation, @JsonKey(name: 'matched_variant')  String? matchedVariant, @JsonKey(name: 'match_type')  String? matchType,  String? sense, @JsonKey(name: 'approved_at')  String? approvedAt, @JsonKey(name: 'usage_labels')  List<String> usageLabels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordSummaryDto() when $default != null:
return $default(_that.id,_that.lemma,_that.languageId,_that.languageCode,_that.wordType,_that.status,_that.isVerified,_that.matchedTranslation,_that.matchedVariant,_that.matchType,_that.sense,_that.approvedAt,_that.usageLabels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String lemma, @JsonKey(name: 'language_id')  String languageId, @JsonKey(name: 'language_code')  String languageCode, @JsonKey(name: 'word_type')  String wordType,  String status, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'matched_translation')  String? matchedTranslation, @JsonKey(name: 'matched_variant')  String? matchedVariant, @JsonKey(name: 'match_type')  String? matchType,  String? sense, @JsonKey(name: 'approved_at')  String? approvedAt, @JsonKey(name: 'usage_labels')  List<String> usageLabels)  $default,) {final _that = this;
switch (_that) {
case _WordSummaryDto():
return $default(_that.id,_that.lemma,_that.languageId,_that.languageCode,_that.wordType,_that.status,_that.isVerified,_that.matchedTranslation,_that.matchedVariant,_that.matchType,_that.sense,_that.approvedAt,_that.usageLabels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String lemma, @JsonKey(name: 'language_id')  String languageId, @JsonKey(name: 'language_code')  String languageCode, @JsonKey(name: 'word_type')  String wordType,  String status, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'matched_translation')  String? matchedTranslation, @JsonKey(name: 'matched_variant')  String? matchedVariant, @JsonKey(name: 'match_type')  String? matchType,  String? sense, @JsonKey(name: 'approved_at')  String? approvedAt, @JsonKey(name: 'usage_labels')  List<String> usageLabels)?  $default,) {final _that = this;
switch (_that) {
case _WordSummaryDto() when $default != null:
return $default(_that.id,_that.lemma,_that.languageId,_that.languageCode,_that.wordType,_that.status,_that.isVerified,_that.matchedTranslation,_that.matchedVariant,_that.matchType,_that.sense,_that.approvedAt,_that.usageLabels);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WordSummaryDto implements WordSummaryDto {
  const _WordSummaryDto({required this.id, required this.lemma, @JsonKey(name: 'language_id') required this.languageId, @JsonKey(name: 'language_code') required this.languageCode, @JsonKey(name: 'word_type') required this.wordType, required this.status, @JsonKey(name: 'is_verified') required this.isVerified, @JsonKey(name: 'matched_translation') this.matchedTranslation, @JsonKey(name: 'matched_variant') this.matchedVariant, @JsonKey(name: 'match_type') this.matchType, this.sense, @JsonKey(name: 'approved_at') this.approvedAt, @JsonKey(name: 'usage_labels') final  List<String> usageLabels = const []}): _usageLabels = usageLabels;
  factory _WordSummaryDto.fromJson(Map<String, dynamic> json) => _$WordSummaryDtoFromJson(json);

@override final  String id;
@override final  String lemma;
@override@JsonKey(name: 'language_id') final  String languageId;
@override@JsonKey(name: 'language_code') final  String languageCode;
@override@JsonKey(name: 'word_type') final  String wordType;
@override final  String status;
@override@JsonKey(name: 'is_verified') final  bool isVerified;
/// Hanya terisi saat search_in=translation (Indonesia→Sambas).
@override@JsonKey(name: 'matched_translation') final  String? matchedTranslation;
/// Form variasi yang cocok (doc 11, search_in=lemma via variasi).
@override@JsonKey(name: 'matched_variant') final  String? matchedVariant;
/// PRD relasi-lemma: 'related_group' = hasil perluasan kelompok makna
/// (bukan cocok langsung). Null = hasil langsung.
@override@JsonKey(name: 'match_type') final  String? matchType;
/// Satu baris arti.
/// - GET /words/latest: definisi atau terjemahan pertama.
/// - GET /words (A-Z): gloss `[n] makan,[v] santap`.
@override final  String? sense;
/// Waktu persetujuan ISO. Hanya GET /api/v1/words/latest.
@override@JsonKey(name: 'approved_at') final  String? approvedAt;
 final  List<String> _usageLabels;
@override@JsonKey(name: 'usage_labels') List<String> get usageLabels {
  if (_usageLabels is EqualUnmodifiableListView) return _usageLabels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_usageLabels);
}


/// Create a copy of WordSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordSummaryDtoCopyWith<_WordSummaryDto> get copyWith => __$WordSummaryDtoCopyWithImpl<_WordSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WordSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordSummaryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.languageId, languageId) || other.languageId == languageId)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.wordType, wordType) || other.wordType == wordType)&&(identical(other.status, status) || other.status == status)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.matchedTranslation, matchedTranslation) || other.matchedTranslation == matchedTranslation)&&(identical(other.matchedVariant, matchedVariant) || other.matchedVariant == matchedVariant)&&(identical(other.matchType, matchType) || other.matchType == matchType)&&(identical(other.sense, sense) || other.sense == sense)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&const DeepCollectionEquality().equals(other._usageLabels, _usageLabels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,lemma,languageId,languageCode,wordType,status,isVerified,matchedTranslation,matchedVariant,matchType,sense,approvedAt,const DeepCollectionEquality().hash(_usageLabels));

@override
String toString() {
  return 'WordSummaryDto(id: $id, lemma: $lemma, languageId: $languageId, languageCode: $languageCode, wordType: $wordType, status: $status, isVerified: $isVerified, matchedTranslation: $matchedTranslation, matchedVariant: $matchedVariant, matchType: $matchType, sense: $sense, approvedAt: $approvedAt, usageLabels: $usageLabels)';
}


}

/// @nodoc
abstract mixin class _$WordSummaryDtoCopyWith<$Res> implements $WordSummaryDtoCopyWith<$Res> {
  factory _$WordSummaryDtoCopyWith(_WordSummaryDto value, $Res Function(_WordSummaryDto) _then) = __$WordSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String lemma,@JsonKey(name: 'language_id') String languageId,@JsonKey(name: 'language_code') String languageCode,@JsonKey(name: 'word_type') String wordType, String status,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'matched_translation') String? matchedTranslation,@JsonKey(name: 'matched_variant') String? matchedVariant,@JsonKey(name: 'match_type') String? matchType, String? sense,@JsonKey(name: 'approved_at') String? approvedAt,@JsonKey(name: 'usage_labels') List<String> usageLabels
});




}
/// @nodoc
class __$WordSummaryDtoCopyWithImpl<$Res>
    implements _$WordSummaryDtoCopyWith<$Res> {
  __$WordSummaryDtoCopyWithImpl(this._self, this._then);

  final _WordSummaryDto _self;
  final $Res Function(_WordSummaryDto) _then;

/// Create a copy of WordSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lemma = null,Object? languageId = null,Object? languageCode = null,Object? wordType = null,Object? status = null,Object? isVerified = null,Object? matchedTranslation = freezed,Object? matchedVariant = freezed,Object? matchType = freezed,Object? sense = freezed,Object? approvedAt = freezed,Object? usageLabels = null,}) {
  return _then(_WordSummaryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lemma: null == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String,languageId: null == languageId ? _self.languageId : languageId // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,wordType: null == wordType ? _self.wordType : wordType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,matchedTranslation: freezed == matchedTranslation ? _self.matchedTranslation : matchedTranslation // ignore: cast_nullable_to_non_nullable
as String?,matchedVariant: freezed == matchedVariant ? _self.matchedVariant : matchedVariant // ignore: cast_nullable_to_non_nullable
as String?,matchType: freezed == matchType ? _self.matchType : matchType // ignore: cast_nullable_to_non_nullable
as String?,sense: freezed == sense ? _self.sense : sense // ignore: cast_nullable_to_non_nullable
as String?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as String?,usageLabels: null == usageLabels ? _self._usageLabels : usageLabels // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
