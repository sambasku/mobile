// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'toggle_bookmark_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ToggleBookmarkResponseDto {

@JsonKey(name: 'word_id') String get wordId;@JsonKey(name: 'is_bookmarked') bool get isBookmarked;@JsonKey(name: 'bookmarked_at') String? get bookmarkedAt;
/// Create a copy of ToggleBookmarkResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToggleBookmarkResponseDtoCopyWith<ToggleBookmarkResponseDto> get copyWith => _$ToggleBookmarkResponseDtoCopyWithImpl<ToggleBookmarkResponseDto>(this as ToggleBookmarkResponseDto, _$identity);

  /// Serializes this ToggleBookmarkResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ToggleBookmarkResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToggleBookmarkResponseDto&&(identical(other.wordId, _this.wordId) || other.wordId == _this.wordId)&&(identical(other.isBookmarked, _this.isBookmarked) || other.isBookmarked == _this.isBookmarked)&&(identical(other.bookmarkedAt, _this.bookmarkedAt) || other.bookmarkedAt == _this.bookmarkedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ToggleBookmarkResponseDto;
  return Object.hash(runtimeType,_this.wordId,_this.isBookmarked,_this.bookmarkedAt);
}

@override
String toString() {
  final _this = this as ToggleBookmarkResponseDto;
  return 'ToggleBookmarkResponseDto(wordId: ${_this.wordId}, isBookmarked: ${_this.isBookmarked}, bookmarkedAt: ${_this.bookmarkedAt})';
}


}

/// @nodoc
abstract mixin class $ToggleBookmarkResponseDtoCopyWith<$Res>  {
  factory $ToggleBookmarkResponseDtoCopyWith(ToggleBookmarkResponseDto value, $Res Function(ToggleBookmarkResponseDto) _then) = _$ToggleBookmarkResponseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'word_id') String wordId,@JsonKey(name: 'is_bookmarked') bool isBookmarked,@JsonKey(name: 'bookmarked_at') String? bookmarkedAt
});




}
/// @nodoc
class _$ToggleBookmarkResponseDtoCopyWithImpl<$Res>
    implements $ToggleBookmarkResponseDtoCopyWith<$Res> {
  _$ToggleBookmarkResponseDtoCopyWithImpl(this._self, this._then);

  final ToggleBookmarkResponseDto _self;
  final $Res Function(ToggleBookmarkResponseDto) _then;

/// Create a copy of ToggleBookmarkResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wordId = null,Object? isBookmarked = null,Object? bookmarkedAt = freezed,}) {
  return _then(ToggleBookmarkResponseDto(
wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,isBookmarked: null == isBookmarked ? _self.isBookmarked : isBookmarked // ignore: cast_nullable_to_non_nullable
as bool,bookmarkedAt: freezed == bookmarkedAt ? _self.bookmarkedAt : bookmarkedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ToggleBookmarkResponseDto].
extension ToggleBookmarkResponseDtoPatterns on ToggleBookmarkResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ToggleBookmarkResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToggleBookmarkResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ToggleBookmarkResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _ToggleBookmarkResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ToggleBookmarkResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _ToggleBookmarkResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'word_id')  String wordId, @JsonKey(name: 'is_bookmarked')  bool isBookmarked, @JsonKey(name: 'bookmarked_at')  String? bookmarkedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToggleBookmarkResponseDto() when $default != null:
return $default(_that.wordId,_that.isBookmarked,_that.bookmarkedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'word_id')  String wordId, @JsonKey(name: 'is_bookmarked')  bool isBookmarked, @JsonKey(name: 'bookmarked_at')  String? bookmarkedAt)  $default,) {final _that = this;
switch (_that) {
case _ToggleBookmarkResponseDto():
return $default(_that.wordId,_that.isBookmarked,_that.bookmarkedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'word_id')  String wordId, @JsonKey(name: 'is_bookmarked')  bool isBookmarked, @JsonKey(name: 'bookmarked_at')  String? bookmarkedAt)?  $default,) {final _that = this;
switch (_that) {
case _ToggleBookmarkResponseDto() when $default != null:
return $default(_that.wordId,_that.isBookmarked,_that.bookmarkedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ToggleBookmarkResponseDto implements ToggleBookmarkResponseDto {
  const _ToggleBookmarkResponseDto({@JsonKey(name: 'word_id') required this.wordId, @JsonKey(name: 'is_bookmarked') this.isBookmarked = false, @JsonKey(name: 'bookmarked_at') this.bookmarkedAt});
  factory _ToggleBookmarkResponseDto.fromJson(Map<String, dynamic> json) => _$ToggleBookmarkResponseDtoFromJson(json);

@override@JsonKey(name: 'word_id') final  String wordId;
@override@JsonKey(name: 'is_bookmarked') final  bool isBookmarked;
@override@JsonKey(name: 'bookmarked_at') final  String? bookmarkedAt;

/// Create a copy of ToggleBookmarkResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToggleBookmarkResponseDtoCopyWith<_ToggleBookmarkResponseDto> get copyWith => __$ToggleBookmarkResponseDtoCopyWithImpl<_ToggleBookmarkResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ToggleBookmarkResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToggleBookmarkResponseDto&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.isBookmarked, isBookmarked) || other.isBookmarked == isBookmarked)&&(identical(other.bookmarkedAt, bookmarkedAt) || other.bookmarkedAt == bookmarkedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,wordId,isBookmarked,bookmarkedAt);
}

@override
String toString() {
    return 'ToggleBookmarkResponseDto(wordId: $wordId, isBookmarked: $isBookmarked, bookmarkedAt: $bookmarkedAt)';
}


}

/// @nodoc
abstract mixin class _$ToggleBookmarkResponseDtoCopyWith<$Res> implements $ToggleBookmarkResponseDtoCopyWith<$Res> {
  factory _$ToggleBookmarkResponseDtoCopyWith(_ToggleBookmarkResponseDto value, $Res Function(_ToggleBookmarkResponseDto) _then) = __$ToggleBookmarkResponseDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'word_id') String wordId,@JsonKey(name: 'is_bookmarked') bool isBookmarked,@JsonKey(name: 'bookmarked_at') String? bookmarkedAt
});




}
/// @nodoc
class __$ToggleBookmarkResponseDtoCopyWithImpl<$Res>
    implements _$ToggleBookmarkResponseDtoCopyWith<$Res> {
  __$ToggleBookmarkResponseDtoCopyWithImpl(this._self, this._then);

  final _ToggleBookmarkResponseDto _self;
  final $Res Function(_ToggleBookmarkResponseDto) _then;

/// Create a copy of ToggleBookmarkResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wordId = null,Object? isBookmarked = null,Object? bookmarkedAt = freezed,}) {
  return _then(_ToggleBookmarkResponseDto(
wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,isBookmarked: null == isBookmarked ? _self.isBookmarked : isBookmarked // ignore: cast_nullable_to_non_nullable
as bool,bookmarkedAt: freezed == bookmarkedAt ? _self.bookmarkedAt : bookmarkedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
