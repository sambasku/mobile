// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_audio_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WordAudioDto {

 String get id; String get url;@JsonKey(name: 'dialect_id') String? get dialectId;@JsonKey(name: 'speaker_name') String? get speakerName;@JsonKey(name: 'duration_ms') int? get durationMs;@JsonKey(name: 'is_primary') bool get isPrimary;@JsonKey(name: 'mime_type') String? get mimeType;/// Default true: payload lama tanpa field tetap dianggap terverifikasi.
@JsonKey(name: 'is_verified') bool get isVerified;
/// Create a copy of WordAudioDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordAudioDtoCopyWith<WordAudioDto> get copyWith => _$WordAudioDtoCopyWithImpl<WordAudioDto>(this as WordAudioDto, _$identity);

  /// Serializes this WordAudioDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordAudioDto&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.dialectId, dialectId) || other.dialectId == dialectId)&&(identical(other.speakerName, speakerName) || other.speakerName == speakerName)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,dialectId,speakerName,durationMs,isPrimary,mimeType,isVerified);

@override
String toString() {
  return 'WordAudioDto(id: $id, url: $url, dialectId: $dialectId, speakerName: $speakerName, durationMs: $durationMs, isPrimary: $isPrimary, mimeType: $mimeType, isVerified: $isVerified)';
}


}

/// @nodoc
abstract mixin class $WordAudioDtoCopyWith<$Res>  {
  factory $WordAudioDtoCopyWith(WordAudioDto value, $Res Function(WordAudioDto) _then) = _$WordAudioDtoCopyWithImpl;
@useResult
$Res call({
 String id, String url,@JsonKey(name: 'dialect_id') String? dialectId,@JsonKey(name: 'speaker_name') String? speakerName,@JsonKey(name: 'duration_ms') int? durationMs,@JsonKey(name: 'is_primary') bool isPrimary,@JsonKey(name: 'mime_type') String? mimeType,@JsonKey(name: 'is_verified') bool isVerified
});




}
/// @nodoc
class _$WordAudioDtoCopyWithImpl<$Res>
    implements $WordAudioDtoCopyWith<$Res> {
  _$WordAudioDtoCopyWithImpl(this._self, this._then);

  final WordAudioDto _self;
  final $Res Function(WordAudioDto) _then;

/// Create a copy of WordAudioDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? dialectId = freezed,Object? speakerName = freezed,Object? durationMs = freezed,Object? isPrimary = null,Object? mimeType = freezed,Object? isVerified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,dialectId: freezed == dialectId ? _self.dialectId : dialectId // ignore: cast_nullable_to_non_nullable
as String?,speakerName: freezed == speakerName ? _self.speakerName : speakerName // ignore: cast_nullable_to_non_nullable
as String?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WordAudioDto].
extension WordAudioDtoPatterns on WordAudioDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordAudioDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordAudioDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordAudioDto value)  $default,){
final _that = this;
switch (_that) {
case _WordAudioDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordAudioDto value)?  $default,){
final _that = this;
switch (_that) {
case _WordAudioDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url, @JsonKey(name: 'dialect_id')  String? dialectId, @JsonKey(name: 'speaker_name')  String? speakerName, @JsonKey(name: 'duration_ms')  int? durationMs, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'mime_type')  String? mimeType, @JsonKey(name: 'is_verified')  bool isVerified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordAudioDto() when $default != null:
return $default(_that.id,_that.url,_that.dialectId,_that.speakerName,_that.durationMs,_that.isPrimary,_that.mimeType,_that.isVerified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url, @JsonKey(name: 'dialect_id')  String? dialectId, @JsonKey(name: 'speaker_name')  String? speakerName, @JsonKey(name: 'duration_ms')  int? durationMs, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'mime_type')  String? mimeType, @JsonKey(name: 'is_verified')  bool isVerified)  $default,) {final _that = this;
switch (_that) {
case _WordAudioDto():
return $default(_that.id,_that.url,_that.dialectId,_that.speakerName,_that.durationMs,_that.isPrimary,_that.mimeType,_that.isVerified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url, @JsonKey(name: 'dialect_id')  String? dialectId, @JsonKey(name: 'speaker_name')  String? speakerName, @JsonKey(name: 'duration_ms')  int? durationMs, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'mime_type')  String? mimeType, @JsonKey(name: 'is_verified')  bool isVerified)?  $default,) {final _that = this;
switch (_that) {
case _WordAudioDto() when $default != null:
return $default(_that.id,_that.url,_that.dialectId,_that.speakerName,_that.durationMs,_that.isPrimary,_that.mimeType,_that.isVerified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WordAudioDto implements WordAudioDto {
  const _WordAudioDto({required this.id, required this.url, @JsonKey(name: 'dialect_id') this.dialectId, @JsonKey(name: 'speaker_name') this.speakerName, @JsonKey(name: 'duration_ms') this.durationMs, @JsonKey(name: 'is_primary') this.isPrimary = false, @JsonKey(name: 'mime_type') this.mimeType, @JsonKey(name: 'is_verified') this.isVerified = true});
  factory _WordAudioDto.fromJson(Map<String, dynamic> json) => _$WordAudioDtoFromJson(json);

@override final  String id;
@override final  String url;
@override@JsonKey(name: 'dialect_id') final  String? dialectId;
@override@JsonKey(name: 'speaker_name') final  String? speakerName;
@override@JsonKey(name: 'duration_ms') final  int? durationMs;
@override@JsonKey(name: 'is_primary') final  bool isPrimary;
@override@JsonKey(name: 'mime_type') final  String? mimeType;
/// Default true: payload lama tanpa field tetap dianggap terverifikasi.
@override@JsonKey(name: 'is_verified') final  bool isVerified;

/// Create a copy of WordAudioDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordAudioDtoCopyWith<_WordAudioDto> get copyWith => __$WordAudioDtoCopyWithImpl<_WordAudioDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WordAudioDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordAudioDto&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.dialectId, dialectId) || other.dialectId == dialectId)&&(identical(other.speakerName, speakerName) || other.speakerName == speakerName)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,dialectId,speakerName,durationMs,isPrimary,mimeType,isVerified);

@override
String toString() {
  return 'WordAudioDto(id: $id, url: $url, dialectId: $dialectId, speakerName: $speakerName, durationMs: $durationMs, isPrimary: $isPrimary, mimeType: $mimeType, isVerified: $isVerified)';
}


}

/// @nodoc
abstract mixin class _$WordAudioDtoCopyWith<$Res> implements $WordAudioDtoCopyWith<$Res> {
  factory _$WordAudioDtoCopyWith(_WordAudioDto value, $Res Function(_WordAudioDto) _then) = __$WordAudioDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String url,@JsonKey(name: 'dialect_id') String? dialectId,@JsonKey(name: 'speaker_name') String? speakerName,@JsonKey(name: 'duration_ms') int? durationMs,@JsonKey(name: 'is_primary') bool isPrimary,@JsonKey(name: 'mime_type') String? mimeType,@JsonKey(name: 'is_verified') bool isVerified
});




}
/// @nodoc
class __$WordAudioDtoCopyWithImpl<$Res>
    implements _$WordAudioDtoCopyWith<$Res> {
  __$WordAudioDtoCopyWithImpl(this._self, this._then);

  final _WordAudioDto _self;
  final $Res Function(_WordAudioDto) _then;

/// Create a copy of WordAudioDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? dialectId = freezed,Object? speakerName = freezed,Object? durationMs = freezed,Object? isPrimary = null,Object? mimeType = freezed,Object? isVerified = null,}) {
  return _then(_WordAudioDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,dialectId: freezed == dialectId ? _self.dialectId : dialectId // ignore: cast_nullable_to_non_nullable
as String?,speakerName: freezed == speakerName ? _self.speakerName : speakerName // ignore: cast_nullable_to_non_nullable
as String?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
