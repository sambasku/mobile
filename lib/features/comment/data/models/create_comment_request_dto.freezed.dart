// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_comment_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateCommentRequestDto {

 String get body;
/// Create a copy of CreateCommentRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateCommentRequestDtoCopyWith<CreateCommentRequestDto> get copyWith => _$CreateCommentRequestDtoCopyWithImpl<CreateCommentRequestDto>(this as CreateCommentRequestDto, _$identity);

  /// Serializes this CreateCommentRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateCommentRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateCommentRequestDto&&(identical(other.body, _this.body) || other.body == _this.body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateCommentRequestDto;
  return Object.hash(runtimeType,_this.body);
}

@override
String toString() {
  final _this = this as CreateCommentRequestDto;
  return 'CreateCommentRequestDto(body: ${_this.body})';
}


}

/// @nodoc
abstract mixin class $CreateCommentRequestDtoCopyWith<$Res>  {
  factory $CreateCommentRequestDtoCopyWith(CreateCommentRequestDto value, $Res Function(CreateCommentRequestDto) _then) = _$CreateCommentRequestDtoCopyWithImpl;
@useResult
$Res call({
 String body
});




}
/// @nodoc
class _$CreateCommentRequestDtoCopyWithImpl<$Res>
    implements $CreateCommentRequestDtoCopyWith<$Res> {
  _$CreateCommentRequestDtoCopyWithImpl(this._self, this._then);

  final CreateCommentRequestDto _self;
  final $Res Function(CreateCommentRequestDto) _then;

/// Create a copy of CreateCommentRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? body = null,}) {
  return _then(CreateCommentRequestDto(
body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateCommentRequestDto].
extension CreateCommentRequestDtoPatterns on CreateCommentRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateCommentRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateCommentRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateCommentRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateCommentRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateCommentRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateCommentRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String body)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateCommentRequestDto() when $default != null:
return $default(_that.body);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String body)  $default,) {final _that = this;
switch (_that) {
case _CreateCommentRequestDto():
return $default(_that.body);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String body)?  $default,) {final _that = this;
switch (_that) {
case _CreateCommentRequestDto() when $default != null:
return $default(_that.body);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateCommentRequestDto implements CreateCommentRequestDto {
  const _CreateCommentRequestDto({required this.body});
  factory _CreateCommentRequestDto.fromJson(Map<String, dynamic> json) => _$CreateCommentRequestDtoFromJson(json);

@override final  String body;

/// Create a copy of CreateCommentRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateCommentRequestDtoCopyWith<_CreateCommentRequestDto> get copyWith => __$CreateCommentRequestDtoCopyWithImpl<_CreateCommentRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateCommentRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateCommentRequestDto&&(identical(other.body, body) || other.body == body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,body);
}

@override
String toString() {
    return 'CreateCommentRequestDto(body: $body)';
}


}

/// @nodoc
abstract mixin class _$CreateCommentRequestDtoCopyWith<$Res> implements $CreateCommentRequestDtoCopyWith<$Res> {
  factory _$CreateCommentRequestDtoCopyWith(_CreateCommentRequestDto value, $Res Function(_CreateCommentRequestDto) _then) = __$CreateCommentRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String body
});




}
/// @nodoc
class __$CreateCommentRequestDtoCopyWithImpl<$Res>
    implements _$CreateCommentRequestDtoCopyWith<$Res> {
  __$CreateCommentRequestDtoCopyWithImpl(this._self, this._then);

  final _CreateCommentRequestDto _self;
  final $Res Function(_CreateCommentRequestDto) _then;

/// Create a copy of CreateCommentRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? body = null,}) {
  return _then(_CreateCommentRequestDto(
body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
