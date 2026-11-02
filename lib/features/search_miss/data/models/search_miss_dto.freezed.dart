// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_miss_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchMissDto {

 String get id; String get term;/// Wire API: `direction` (bukan `search_in`). Field Dart tetap searchIn
/// supaya UI/router lama tidak pecah.
@JsonKey(name: 'direction') String get searchIn;@JsonKey(name: 'hit_count') int get hitCount;@JsonKey(name: 'last_searched_at') DateTime? get lastSearchedAt;
/// Create a copy of SearchMissDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchMissDtoCopyWith<SearchMissDto> get copyWith => _$SearchMissDtoCopyWithImpl<SearchMissDto>(this as SearchMissDto, _$identity);

  /// Serializes this SearchMissDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SearchMissDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchMissDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.term, _this.term) || other.term == _this.term)&&(identical(other.searchIn, _this.searchIn) || other.searchIn == _this.searchIn)&&(identical(other.hitCount, _this.hitCount) || other.hitCount == _this.hitCount)&&(identical(other.lastSearchedAt, _this.lastSearchedAt) || other.lastSearchedAt == _this.lastSearchedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SearchMissDto;
  return Object.hash(runtimeType,_this.id,_this.term,_this.searchIn,_this.hitCount,_this.lastSearchedAt);
}

@override
String toString() {
  final _this = this as SearchMissDto;
  return 'SearchMissDto(id: ${_this.id}, term: ${_this.term}, searchIn: ${_this.searchIn}, hitCount: ${_this.hitCount}, lastSearchedAt: ${_this.lastSearchedAt})';
}


}

/// @nodoc
abstract mixin class $SearchMissDtoCopyWith<$Res>  {
  factory $SearchMissDtoCopyWith(SearchMissDto value, $Res Function(SearchMissDto) _then) = _$SearchMissDtoCopyWithImpl;
@useResult
$Res call({
 String id, String term,@JsonKey(name: 'direction') String searchIn,@JsonKey(name: 'hit_count') int hitCount,@JsonKey(name: 'last_searched_at') DateTime? lastSearchedAt
});




}
/// @nodoc
class _$SearchMissDtoCopyWithImpl<$Res>
    implements $SearchMissDtoCopyWith<$Res> {
  _$SearchMissDtoCopyWithImpl(this._self, this._then);

  final SearchMissDto _self;
  final $Res Function(SearchMissDto) _then;

/// Create a copy of SearchMissDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? term = null,Object? searchIn = null,Object? hitCount = null,Object? lastSearchedAt = freezed,}) {
  return _then(SearchMissDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,searchIn: null == searchIn ? _self.searchIn : searchIn // ignore: cast_nullable_to_non_nullable
as String,hitCount: null == hitCount ? _self.hitCount : hitCount // ignore: cast_nullable_to_non_nullable
as int,lastSearchedAt: freezed == lastSearchedAt ? _self.lastSearchedAt : lastSearchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchMissDto].
extension SearchMissDtoPatterns on SearchMissDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchMissDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchMissDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchMissDto value)  $default,){
final _that = this;
switch (_that) {
case _SearchMissDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchMissDto value)?  $default,){
final _that = this;
switch (_that) {
case _SearchMissDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String term, @JsonKey(name: 'direction')  String searchIn, @JsonKey(name: 'hit_count')  int hitCount, @JsonKey(name: 'last_searched_at')  DateTime? lastSearchedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchMissDto() when $default != null:
return $default(_that.id,_that.term,_that.searchIn,_that.hitCount,_that.lastSearchedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String term, @JsonKey(name: 'direction')  String searchIn, @JsonKey(name: 'hit_count')  int hitCount, @JsonKey(name: 'last_searched_at')  DateTime? lastSearchedAt)  $default,) {final _that = this;
switch (_that) {
case _SearchMissDto():
return $default(_that.id,_that.term,_that.searchIn,_that.hitCount,_that.lastSearchedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String term, @JsonKey(name: 'direction')  String searchIn, @JsonKey(name: 'hit_count')  int hitCount, @JsonKey(name: 'last_searched_at')  DateTime? lastSearchedAt)?  $default,) {final _that = this;
switch (_that) {
case _SearchMissDto() when $default != null:
return $default(_that.id,_that.term,_that.searchIn,_that.hitCount,_that.lastSearchedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchMissDto implements SearchMissDto {
  const _SearchMissDto({required this.id, required this.term, @JsonKey(name: 'direction') required this.searchIn, @JsonKey(name: 'hit_count') required this.hitCount, @JsonKey(name: 'last_searched_at') this.lastSearchedAt});
  factory _SearchMissDto.fromJson(Map<String, dynamic> json) => _$SearchMissDtoFromJson(json);

@override final  String id;
@override final  String term;
/// Wire API: `direction` (bukan `search_in`). Field Dart tetap searchIn
/// supaya UI/router lama tidak pecah.
@override@JsonKey(name: 'direction') final  String searchIn;
@override@JsonKey(name: 'hit_count') final  int hitCount;
@override@JsonKey(name: 'last_searched_at') final  DateTime? lastSearchedAt;

/// Create a copy of SearchMissDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchMissDtoCopyWith<_SearchMissDto> get copyWith => __$SearchMissDtoCopyWithImpl<_SearchMissDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchMissDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchMissDto&&(identical(other.id, id) || other.id == id)&&(identical(other.term, term) || other.term == term)&&(identical(other.searchIn, searchIn) || other.searchIn == searchIn)&&(identical(other.hitCount, hitCount) || other.hitCount == hitCount)&&(identical(other.lastSearchedAt, lastSearchedAt) || other.lastSearchedAt == lastSearchedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,term,searchIn,hitCount,lastSearchedAt);
}

@override
String toString() {
    return 'SearchMissDto(id: $id, term: $term, searchIn: $searchIn, hitCount: $hitCount, lastSearchedAt: $lastSearchedAt)';
}


}

/// @nodoc
abstract mixin class _$SearchMissDtoCopyWith<$Res> implements $SearchMissDtoCopyWith<$Res> {
  factory _$SearchMissDtoCopyWith(_SearchMissDto value, $Res Function(_SearchMissDto) _then) = __$SearchMissDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String term,@JsonKey(name: 'direction') String searchIn,@JsonKey(name: 'hit_count') int hitCount,@JsonKey(name: 'last_searched_at') DateTime? lastSearchedAt
});




}
/// @nodoc
class __$SearchMissDtoCopyWithImpl<$Res>
    implements _$SearchMissDtoCopyWith<$Res> {
  __$SearchMissDtoCopyWithImpl(this._self, this._then);

  final _SearchMissDto _self;
  final $Res Function(_SearchMissDto) _then;

/// Create a copy of SearchMissDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? term = null,Object? searchIn = null,Object? hitCount = null,Object? lastSearchedAt = freezed,}) {
  return _then(_SearchMissDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,searchIn: null == searchIn ? _self.searchIn : searchIn // ignore: cast_nullable_to_non_nullable
as String,hitCount: null == hitCount ? _self.hitCount : hitCount // ignore: cast_nullable_to_non_nullable
as int,lastSearchedAt: freezed == lastSearchedAt ? _self.lastSearchedAt : lastSearchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
