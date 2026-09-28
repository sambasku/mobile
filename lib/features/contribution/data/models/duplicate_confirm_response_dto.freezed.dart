// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'duplicate_confirm_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DuplicateConfirmResponseDto {

@JsonKey(name: 'word_id') String get wordId;@JsonKey(name: 'meaning_id') String get meaningId; String get lemma;@JsonKey(name: 'my_vote') int? get myVote; int get upvotes; int get downvotes; String get message;
/// Create a copy of DuplicateConfirmResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DuplicateConfirmResponseDtoCopyWith<DuplicateConfirmResponseDto> get copyWith => _$DuplicateConfirmResponseDtoCopyWithImpl<DuplicateConfirmResponseDto>(this as DuplicateConfirmResponseDto, _$identity);

  /// Serializes this DuplicateConfirmResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DuplicateConfirmResponseDto&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.meaningId, meaningId) || other.meaningId == meaningId)&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.myVote, myVote) || other.myVote == myVote)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wordId,meaningId,lemma,myVote,upvotes,downvotes,message);

@override
String toString() {
  return 'DuplicateConfirmResponseDto(wordId: $wordId, meaningId: $meaningId, lemma: $lemma, myVote: $myVote, upvotes: $upvotes, downvotes: $downvotes, message: $message)';
}


}

/// @nodoc
abstract mixin class $DuplicateConfirmResponseDtoCopyWith<$Res>  {
  factory $DuplicateConfirmResponseDtoCopyWith(DuplicateConfirmResponseDto value, $Res Function(DuplicateConfirmResponseDto) _then) = _$DuplicateConfirmResponseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'word_id') String wordId,@JsonKey(name: 'meaning_id') String meaningId, String lemma,@JsonKey(name: 'my_vote') int? myVote, int upvotes, int downvotes, String message
});




}
/// @nodoc
class _$DuplicateConfirmResponseDtoCopyWithImpl<$Res>
    implements $DuplicateConfirmResponseDtoCopyWith<$Res> {
  _$DuplicateConfirmResponseDtoCopyWithImpl(this._self, this._then);

  final DuplicateConfirmResponseDto _self;
  final $Res Function(DuplicateConfirmResponseDto) _then;

/// Create a copy of DuplicateConfirmResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wordId = null,Object? meaningId = null,Object? lemma = null,Object? myVote = freezed,Object? upvotes = null,Object? downvotes = null,Object? message = null,}) {
  return _then(_self.copyWith(
wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,meaningId: null == meaningId ? _self.meaningId : meaningId // ignore: cast_nullable_to_non_nullable
as String,lemma: null == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String,myVote: freezed == myVote ? _self.myVote : myVote // ignore: cast_nullable_to_non_nullable
as int?,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DuplicateConfirmResponseDto].
extension DuplicateConfirmResponseDtoPatterns on DuplicateConfirmResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DuplicateConfirmResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DuplicateConfirmResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DuplicateConfirmResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _DuplicateConfirmResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DuplicateConfirmResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _DuplicateConfirmResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'word_id')  String wordId, @JsonKey(name: 'meaning_id')  String meaningId,  String lemma, @JsonKey(name: 'my_vote')  int? myVote,  int upvotes,  int downvotes,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DuplicateConfirmResponseDto() when $default != null:
return $default(_that.wordId,_that.meaningId,_that.lemma,_that.myVote,_that.upvotes,_that.downvotes,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'word_id')  String wordId, @JsonKey(name: 'meaning_id')  String meaningId,  String lemma, @JsonKey(name: 'my_vote')  int? myVote,  int upvotes,  int downvotes,  String message)  $default,) {final _that = this;
switch (_that) {
case _DuplicateConfirmResponseDto():
return $default(_that.wordId,_that.meaningId,_that.lemma,_that.myVote,_that.upvotes,_that.downvotes,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'word_id')  String wordId, @JsonKey(name: 'meaning_id')  String meaningId,  String lemma, @JsonKey(name: 'my_vote')  int? myVote,  int upvotes,  int downvotes,  String message)?  $default,) {final _that = this;
switch (_that) {
case _DuplicateConfirmResponseDto() when $default != null:
return $default(_that.wordId,_that.meaningId,_that.lemma,_that.myVote,_that.upvotes,_that.downvotes,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DuplicateConfirmResponseDto implements DuplicateConfirmResponseDto {
  const _DuplicateConfirmResponseDto({@JsonKey(name: 'word_id') required this.wordId, @JsonKey(name: 'meaning_id') required this.meaningId, required this.lemma, @JsonKey(name: 'my_vote') this.myVote, this.upvotes = 0, this.downvotes = 0, required this.message});
  factory _DuplicateConfirmResponseDto.fromJson(Map<String, dynamic> json) => _$DuplicateConfirmResponseDtoFromJson(json);

@override@JsonKey(name: 'word_id') final  String wordId;
@override@JsonKey(name: 'meaning_id') final  String meaningId;
@override final  String lemma;
@override@JsonKey(name: 'my_vote') final  int? myVote;
@override@JsonKey() final  int upvotes;
@override@JsonKey() final  int downvotes;
@override final  String message;

/// Create a copy of DuplicateConfirmResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DuplicateConfirmResponseDtoCopyWith<_DuplicateConfirmResponseDto> get copyWith => __$DuplicateConfirmResponseDtoCopyWithImpl<_DuplicateConfirmResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DuplicateConfirmResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DuplicateConfirmResponseDto&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.meaningId, meaningId) || other.meaningId == meaningId)&&(identical(other.lemma, lemma) || other.lemma == lemma)&&(identical(other.myVote, myVote) || other.myVote == myVote)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wordId,meaningId,lemma,myVote,upvotes,downvotes,message);

@override
String toString() {
  return 'DuplicateConfirmResponseDto(wordId: $wordId, meaningId: $meaningId, lemma: $lemma, myVote: $myVote, upvotes: $upvotes, downvotes: $downvotes, message: $message)';
}


}

/// @nodoc
abstract mixin class _$DuplicateConfirmResponseDtoCopyWith<$Res> implements $DuplicateConfirmResponseDtoCopyWith<$Res> {
  factory _$DuplicateConfirmResponseDtoCopyWith(_DuplicateConfirmResponseDto value, $Res Function(_DuplicateConfirmResponseDto) _then) = __$DuplicateConfirmResponseDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'word_id') String wordId,@JsonKey(name: 'meaning_id') String meaningId, String lemma,@JsonKey(name: 'my_vote') int? myVote, int upvotes, int downvotes, String message
});




}
/// @nodoc
class __$DuplicateConfirmResponseDtoCopyWithImpl<$Res>
    implements _$DuplicateConfirmResponseDtoCopyWith<$Res> {
  __$DuplicateConfirmResponseDtoCopyWithImpl(this._self, this._then);

  final _DuplicateConfirmResponseDto _self;
  final $Res Function(_DuplicateConfirmResponseDto) _then;

/// Create a copy of DuplicateConfirmResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wordId = null,Object? meaningId = null,Object? lemma = null,Object? myVote = freezed,Object? upvotes = null,Object? downvotes = null,Object? message = null,}) {
  return _then(_DuplicateConfirmResponseDto(
wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,meaningId: null == meaningId ? _self.meaningId : meaningId // ignore: cast_nullable_to_non_nullable
as String,lemma: null == lemma ? _self.lemma : lemma // ignore: cast_nullable_to_non_nullable
as String,myVote: freezed == myVote ? _self.myVote : myVote // ignore: cast_nullable_to_non_nullable
as int?,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
