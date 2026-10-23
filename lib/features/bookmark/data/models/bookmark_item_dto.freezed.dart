// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bookmark_item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookmarkItemDto {

@JsonKey(name: 'word_id') String get wordId;@JsonKey(name: 'bookmarked_at') String? get bookmarkedAt; BookmarkWordDto get word;
/// Create a copy of BookmarkItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookmarkItemDtoCopyWith<BookmarkItemDto> get copyWith => _$BookmarkItemDtoCopyWithImpl<BookmarkItemDto>(this as BookmarkItemDto, _$identity);

  /// Serializes this BookmarkItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BookmarkItemDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookmarkItemDto&&(identical(other.wordId, _this.wordId) || other.wordId == _this.wordId)&&(identical(other.bookmarkedAt, _this.bookmarkedAt) || other.bookmarkedAt == _this.bookmarkedAt)&&(identical(other.word, _this.word) || other.word == _this.word));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BookmarkItemDto;
  return Object.hash(runtimeType,_this.wordId,_this.bookmarkedAt,_this.word);
}

@override
String toString() {
  final _this = this as BookmarkItemDto;
  return 'BookmarkItemDto(wordId: ${_this.wordId}, bookmarkedAt: ${_this.bookmarkedAt}, word: ${_this.word})';
}


}

/// @nodoc
abstract mixin class $BookmarkItemDtoCopyWith<$Res>  {
  factory $BookmarkItemDtoCopyWith(BookmarkItemDto value, $Res Function(BookmarkItemDto) _then) = _$BookmarkItemDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'word_id') String wordId,@JsonKey(name: 'bookmarked_at') String? bookmarkedAt, BookmarkWordDto word
});


$BookmarkWordDtoCopyWith<$Res> get word;

}
/// @nodoc
class _$BookmarkItemDtoCopyWithImpl<$Res>
    implements $BookmarkItemDtoCopyWith<$Res> {
  _$BookmarkItemDtoCopyWithImpl(this._self, this._then);

  final BookmarkItemDto _self;
  final $Res Function(BookmarkItemDto) _then;

/// Create a copy of BookmarkItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wordId = null,Object? bookmarkedAt = freezed,Object? word = null,}) {
  return _then(BookmarkItemDto(
wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,bookmarkedAt: freezed == bookmarkedAt ? _self.bookmarkedAt : bookmarkedAt // ignore: cast_nullable_to_non_nullable
as String?,word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as BookmarkWordDto,
  ));
}
/// Create a copy of BookmarkItemDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookmarkWordDtoCopyWith<$Res> get word {
  
  return $BookmarkWordDtoCopyWith<$Res>(_self.word, (value) {
    return _then(_self.copyWith(word: value));
  });
}
}


/// Adds pattern-matching-related methods to [BookmarkItemDto].
extension BookmarkItemDtoPatterns on BookmarkItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookmarkItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookmarkItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookmarkItemDto value)  $default,){
final _that = this;
switch (_that) {
case _BookmarkItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookmarkItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _BookmarkItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'word_id')  String wordId, @JsonKey(name: 'bookmarked_at')  String? bookmarkedAt,  BookmarkWordDto word)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookmarkItemDto() when $default != null:
return $default(_that.wordId,_that.bookmarkedAt,_that.word);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'word_id')  String wordId, @JsonKey(name: 'bookmarked_at')  String? bookmarkedAt,  BookmarkWordDto word)  $default,) {final _that = this;
switch (_that) {
case _BookmarkItemDto():
return $default(_that.wordId,_that.bookmarkedAt,_that.word);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'word_id')  String wordId, @JsonKey(name: 'bookmarked_at')  String? bookmarkedAt,  BookmarkWordDto word)?  $default,) {final _that = this;
switch (_that) {
case _BookmarkItemDto() when $default != null:
return $default(_that.wordId,_that.bookmarkedAt,_that.word);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookmarkItemDto implements BookmarkItemDto {
  const _BookmarkItemDto({@JsonKey(name: 'word_id') required this.wordId, @JsonKey(name: 'bookmarked_at') this.bookmarkedAt, required this.word});
  factory _BookmarkItemDto.fromJson(Map<String, dynamic> json) => _$BookmarkItemDtoFromJson(json);

@override@JsonKey(name: 'word_id') final  String wordId;
@override@JsonKey(name: 'bookmarked_at') final  String? bookmarkedAt;
@override final  BookmarkWordDto word;

/// Create a copy of BookmarkItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookmarkItemDtoCopyWith<_BookmarkItemDto> get copyWith => __$BookmarkItemDtoCopyWithImpl<_BookmarkItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookmarkItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookmarkItemDto&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.bookmarkedAt, bookmarkedAt) || other.bookmarkedAt == bookmarkedAt)&&(identical(other.word, word) || other.word == word));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,wordId,bookmarkedAt,word);
}

@override
String toString() {
    return 'BookmarkItemDto(wordId: $wordId, bookmarkedAt: $bookmarkedAt, word: $word)';
}


}

/// @nodoc
abstract mixin class _$BookmarkItemDtoCopyWith<$Res> implements $BookmarkItemDtoCopyWith<$Res> {
  factory _$BookmarkItemDtoCopyWith(_BookmarkItemDto value, $Res Function(_BookmarkItemDto) _then) = __$BookmarkItemDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'word_id') String wordId,@JsonKey(name: 'bookmarked_at') String? bookmarkedAt, BookmarkWordDto word
});


@override $BookmarkWordDtoCopyWith<$Res> get word;

}
/// @nodoc
class __$BookmarkItemDtoCopyWithImpl<$Res>
    implements _$BookmarkItemDtoCopyWith<$Res> {
  __$BookmarkItemDtoCopyWithImpl(this._self, this._then);

  final _BookmarkItemDto _self;
  final $Res Function(_BookmarkItemDto) _then;

/// Create a copy of BookmarkItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wordId = null,Object? bookmarkedAt = freezed,Object? word = null,}) {
  return _then(_BookmarkItemDto(
wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,bookmarkedAt: freezed == bookmarkedAt ? _self.bookmarkedAt : bookmarkedAt // ignore: cast_nullable_to_non_nullable
as String?,word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as BookmarkWordDto,
  ));
}

/// Create a copy of BookmarkItemDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookmarkWordDtoCopyWith<$Res> get word {
  
  return $BookmarkWordDtoCopyWith<$Res>(_self.word, (value) {
    return _then(_self.copyWith(word: value));
  });
}
}


/// @nodoc
mixin _$BookmarkWordDto {

 String get id; String get lemma;@JsonKey(name: 'word_type') String get wordType;@JsonKey(name: 'is_verified') bool get isVerified; bool get available;
/// Create a copy of BookmarkWordDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookmarkWordDtoCopyWith<BookmarkWordDto> get copyWith => _$BookmarkWordDtoCopyWithImpl<BookmarkWordDto>(this as BookmarkWordDto, _$identity);

  /// Serializes this BookmarkWordDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BookmarkWordDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookmarkWordDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.lemma, _this.lemma) || other.lemma == _this.lemma)&&(identical(other.wordType, _this.wordType) || other.wordType == _this.wordType)&&(identical(other.isVerified, _this.isVerified) || other.isVerified == _this.isVerified)&&(identical(other.available, _this.available) || other.available == _this.available));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BookmarkWordDto;
  return Object.hash(runtimeType,_this.id,_this.lemma,_this.wordType,_this.isVerified,_this.available);
}

@override
String toString() {
  final _this = this as BookmarkWordDto;
  return 'BookmarkWordDto(id: ${_this.id}, lemma: ${_this.lemma}, wordType: ${_this.wordType}, isVerified: ${_this.isVerified}, available: ${_this.available})';
}


}

/// @nodoc
abstract mixin class $BookmarkWordDtoCopyWith<$Res>  {
  factory $BookmarkWordDtoCopyWith(BookmarkWordDto value, $Res Function(BookmarkWordDto) _then) = _$BookmarkWordDtoCopyWithImpl;
@useResult
$Res call({
 String id, String lemma,@JsonKey(name: 'word_type') String wordType,@JsonKey(name: 'is_verified') bool isVerified, bool available
});




}
/// @nodoc
class _$BookmarkWordDtoCopyWithImpl<$Res>
    implements $BookmarkWordDtoCopyWith<$Res> {
  _$BookmarkWordDtoCopyWithImpl(this._self, this._then);

  final BookmarkWordDto _self;
  final $Res Function(BookmarkWordDto) _then;

/// Create a copy of BookmarkWordDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lemma = null,Object? wordType = null,Object? isVerified = null,Object? available = null,}) {
  return _then(BookmarkWordDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lemma: null == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String,wordType: null == wordType ? _self.wordType : wordType // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BookmarkWordDto].
extension BookmarkWordDtoPatterns on BookmarkWordDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookmarkWordDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookmarkWordDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookmarkWordDto value)  $default,){
final _that = this;
switch (_that) {
case _BookmarkWordDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookmarkWordDto value)?  $default,){
final _that = this;
switch (_that) {
case _BookmarkWordDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String lemma, @JsonKey(name: 'word_type')  String wordType, @JsonKey(name: 'is_verified')  bool isVerified,  bool available)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookmarkWordDto() when $default != null:
return $default(_that.id,_that.lemma,_that.wordType,_that.isVerified,_that.available);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String lemma, @JsonKey(name: 'word_type')  String wordType, @JsonKey(name: 'is_verified')  bool isVerified,  bool available)  $default,) {final _that = this;
switch (_that) {
case _BookmarkWordDto():
return $default(_that.id,_that.lemma,_that.wordType,_that.isVerified,_that.available);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String lemma, @JsonKey(name: 'word_type')  String wordType, @JsonKey(name: 'is_verified')  bool isVerified,  bool available)?  $default,) {final _that = this;
switch (_that) {
case _BookmarkWordDto() when $default != null:
return $default(_that.id,_that.lemma,_that.wordType,_that.isVerified,_that.available);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookmarkWordDto implements BookmarkWordDto {
  const _BookmarkWordDto({required this.id, required this.lemma, @JsonKey(name: 'word_type') this.wordType = 'word', @JsonKey(name: 'is_verified') this.isVerified = false, this.available = true});
  factory _BookmarkWordDto.fromJson(Map<String, dynamic> json) => _$BookmarkWordDtoFromJson(json);

@override final  String id;
@override final  String lemma;
@override@JsonKey(name: 'word_type') final  String wordType;
@override@JsonKey(name: 'is_verified') final  bool isVerified;
@override@JsonKey() final  bool available;

/// Create a copy of BookmarkWordDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookmarkWordDtoCopyWith<_BookmarkWordDto> get copyWith => __$BookmarkWordDtoCopyWithImpl<_BookmarkWordDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookmarkWordDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookmarkWordDto&&(identical(other.id, id) || other.id == id)&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.wordType, wordType) || other.wordType == wordType)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.available, available) || other.available == available));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,lemma,wordType,isVerified,available);
}

@override
String toString() {
    return 'BookmarkWordDto(id: $id, lemma: $lemma, wordType: $wordType, isVerified: $isVerified, available: $available)';
}


}

/// @nodoc
abstract mixin class _$BookmarkWordDtoCopyWith<$Res> implements $BookmarkWordDtoCopyWith<$Res> {
  factory _$BookmarkWordDtoCopyWith(_BookmarkWordDto value, $Res Function(_BookmarkWordDto) _then) = __$BookmarkWordDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String lemma,@JsonKey(name: 'word_type') String wordType,@JsonKey(name: 'is_verified') bool isVerified, bool available
});




}
/// @nodoc
class __$BookmarkWordDtoCopyWithImpl<$Res>
    implements _$BookmarkWordDtoCopyWith<$Res> {
  __$BookmarkWordDtoCopyWithImpl(this._self, this._then);

  final _BookmarkWordDto _self;
  final $Res Function(_BookmarkWordDto) _then;

/// Create a copy of BookmarkWordDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lemma = null,Object? wordType = null,Object? isVerified = null,Object? available = null,}) {
  return _then(_BookmarkWordDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lemma: null == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String,wordType: null == wordType ? _self.wordType : wordType // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
