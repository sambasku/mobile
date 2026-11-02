// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_word_translation_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateWordTranslationDto {

@JsonKey(name: 'language_id') String get languageId;@JsonKey(name: 'translation_text') String get translationText;@JsonKey(name: 'translation_type') String get translationType;
/// Create a copy of CreateWordTranslationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateWordTranslationDtoCopyWith<CreateWordTranslationDto> get copyWith => _$CreateWordTranslationDtoCopyWithImpl<CreateWordTranslationDto>(this as CreateWordTranslationDto, _$identity);

  /// Serializes this CreateWordTranslationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateWordTranslationDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateWordTranslationDto&&(identical(other.languageId, _this.languageId) || other.languageId == _this.languageId)&&(identical(other.translationText, _this.translationText) || other.translationText == _this.translationText)&&(identical(other.translationType, _this.translationType) || other.translationType == _this.translationType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateWordTranslationDto;
  return Object.hash(runtimeType,_this.languageId,_this.translationText,_this.translationType);
}

@override
String toString() {
  final _this = this as CreateWordTranslationDto;
  return 'CreateWordTranslationDto(languageId: ${_this.languageId}, translationText: ${_this.translationText}, translationType: ${_this.translationType})';
}


}

/// @nodoc
abstract mixin class $CreateWordTranslationDtoCopyWith<$Res>  {
  factory $CreateWordTranslationDtoCopyWith(CreateWordTranslationDto value, $Res Function(CreateWordTranslationDto) _then) = _$CreateWordTranslationDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'language_id') String languageId,@JsonKey(name: 'translation_text') String translationText,@JsonKey(name: 'translation_type') String translationType
});




}
/// @nodoc
class _$CreateWordTranslationDtoCopyWithImpl<$Res>
    implements $CreateWordTranslationDtoCopyWith<$Res> {
  _$CreateWordTranslationDtoCopyWithImpl(this._self, this._then);

  final CreateWordTranslationDto _self;
  final $Res Function(CreateWordTranslationDto) _then;

/// Create a copy of CreateWordTranslationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? languageId = null,Object? translationText = null,Object? translationType = null,}) {
  return _then(CreateWordTranslationDto(
languageId: null == languageId ? _self.languageId : languageId // ignore: cast_nullable_to_non_nullable
as String,translationText: null == translationText ? _self.translationText : translationText // ignore: cast_nullable_to_non_nullable
as String,translationType: null == translationType ? _self.translationType : translationType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateWordTranslationDto].
extension CreateWordTranslationDtoPatterns on CreateWordTranslationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateWordTranslationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateWordTranslationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateWordTranslationDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateWordTranslationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateWordTranslationDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateWordTranslationDto() when $default != null:
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
case _CreateWordTranslationDto() when $default != null:
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
case _CreateWordTranslationDto():
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
case _CreateWordTranslationDto() when $default != null:
return $default(_that.languageId,_that.translationText,_that.translationType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateWordTranslationDto implements CreateWordTranslationDto {
  const _CreateWordTranslationDto({@JsonKey(name: 'language_id') required this.languageId, @JsonKey(name: 'translation_text') required this.translationText, @JsonKey(name: 'translation_type') this.translationType = 'direct'});
  factory _CreateWordTranslationDto.fromJson(Map<String, dynamic> json) => _$CreateWordTranslationDtoFromJson(json);

@override@JsonKey(name: 'language_id') final  String languageId;
@override@JsonKey(name: 'translation_text') final  String translationText;
@override@JsonKey(name: 'translation_type') final  String translationType;

/// Create a copy of CreateWordTranslationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateWordTranslationDtoCopyWith<_CreateWordTranslationDto> get copyWith => __$CreateWordTranslationDtoCopyWithImpl<_CreateWordTranslationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateWordTranslationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateWordTranslationDto&&(identical(other.languageId, languageId) || other.languageId == languageId)&&(identical(other.translationText, translationText) || other.translationText == translationText)&&(identical(other.translationType, translationType) || other.translationType == translationType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,languageId,translationText,translationType);
}

@override
String toString() {
    return 'CreateWordTranslationDto(languageId: $languageId, translationText: $translationText, translationType: $translationType)';
}


}

/// @nodoc
abstract mixin class _$CreateWordTranslationDtoCopyWith<$Res> implements $CreateWordTranslationDtoCopyWith<$Res> {
  factory _$CreateWordTranslationDtoCopyWith(_CreateWordTranslationDto value, $Res Function(_CreateWordTranslationDto) _then) = __$CreateWordTranslationDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'language_id') String languageId,@JsonKey(name: 'translation_text') String translationText,@JsonKey(name: 'translation_type') String translationType
});




}
/// @nodoc
class __$CreateWordTranslationDtoCopyWithImpl<$Res>
    implements _$CreateWordTranslationDtoCopyWith<$Res> {
  __$CreateWordTranslationDtoCopyWithImpl(this._self, this._then);

  final _CreateWordTranslationDto _self;
  final $Res Function(_CreateWordTranslationDto) _then;

/// Create a copy of CreateWordTranslationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? languageId = null,Object? translationText = null,Object? translationType = null,}) {
  return _then(_CreateWordTranslationDto(
languageId: null == languageId ? _self.languageId : languageId // ignore: cast_nullable_to_non_nullable
as String,translationText: null == translationText ? _self.translationText : translationText // ignore: cast_nullable_to_non_nullable
as String,translationType: null == translationType ? _self.translationType : translationType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
