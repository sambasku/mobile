// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delete_account_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeleteAccountRequestDto {

@JsonKey(includeIfNull: false) String? get password; String get confirmation;
/// Create a copy of DeleteAccountRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteAccountRequestDtoCopyWith<DeleteAccountRequestDto> get copyWith => _$DeleteAccountRequestDtoCopyWithImpl<DeleteAccountRequestDto>(this as DeleteAccountRequestDto, _$identity);

  /// Serializes this DeleteAccountRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeleteAccountRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteAccountRequestDto&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.confirmation, _this.confirmation) || other.confirmation == _this.confirmation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeleteAccountRequestDto;
  return Object.hash(runtimeType,_this.password,_this.confirmation);
}

@override
String toString() {
  final _this = this as DeleteAccountRequestDto;
  return 'DeleteAccountRequestDto(password: ${_this.password}, confirmation: ${_this.confirmation})';
}


}

/// @nodoc
abstract mixin class $DeleteAccountRequestDtoCopyWith<$Res>  {
  factory $DeleteAccountRequestDtoCopyWith(DeleteAccountRequestDto value, $Res Function(DeleteAccountRequestDto) _then) = _$DeleteAccountRequestDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? password, String confirmation
});




}
/// @nodoc
class _$DeleteAccountRequestDtoCopyWithImpl<$Res>
    implements $DeleteAccountRequestDtoCopyWith<$Res> {
  _$DeleteAccountRequestDtoCopyWithImpl(this._self, this._then);

  final DeleteAccountRequestDto _self;
  final $Res Function(DeleteAccountRequestDto) _then;

/// Create a copy of DeleteAccountRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? password = freezed,Object? confirmation = null,}) {
  return _then(DeleteAccountRequestDto(
password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,confirmation: null == confirmation ? _self.confirmation : confirmation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DeleteAccountRequestDto].
extension DeleteAccountRequestDtoPatterns on DeleteAccountRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeleteAccountRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeleteAccountRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeleteAccountRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _DeleteAccountRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeleteAccountRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _DeleteAccountRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? password,  String confirmation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeleteAccountRequestDto() when $default != null:
return $default(_that.password,_that.confirmation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? password,  String confirmation)  $default,) {final _that = this;
switch (_that) {
case _DeleteAccountRequestDto():
return $default(_that.password,_that.confirmation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? password,  String confirmation)?  $default,) {final _that = this;
switch (_that) {
case _DeleteAccountRequestDto() when $default != null:
return $default(_that.password,_that.confirmation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeleteAccountRequestDto implements DeleteAccountRequestDto {
  const _DeleteAccountRequestDto({@JsonKey(includeIfNull: false) this.password, required this.confirmation});
  factory _DeleteAccountRequestDto.fromJson(Map<String, dynamic> json) => _$DeleteAccountRequestDtoFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? password;
@override final  String confirmation;

/// Create a copy of DeleteAccountRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteAccountRequestDtoCopyWith<_DeleteAccountRequestDto> get copyWith => __$DeleteAccountRequestDtoCopyWithImpl<_DeleteAccountRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeleteAccountRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteAccountRequestDto&&(identical(other.password, password) || other.password == password)&&(identical(other.confirmation, confirmation) || other.confirmation == confirmation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,password,confirmation);
}

@override
String toString() {
    return 'DeleteAccountRequestDto(password: $password, confirmation: $confirmation)';
}


}

/// @nodoc
abstract mixin class _$DeleteAccountRequestDtoCopyWith<$Res> implements $DeleteAccountRequestDtoCopyWith<$Res> {
  factory _$DeleteAccountRequestDtoCopyWith(_DeleteAccountRequestDto value, $Res Function(_DeleteAccountRequestDto) _then) = __$DeleteAccountRequestDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? password, String confirmation
});




}
/// @nodoc
class __$DeleteAccountRequestDtoCopyWithImpl<$Res>
    implements _$DeleteAccountRequestDtoCopyWith<$Res> {
  __$DeleteAccountRequestDtoCopyWithImpl(this._self, this._then);

  final _DeleteAccountRequestDto _self;
  final $Res Function(_DeleteAccountRequestDto) _then;

/// Create a copy of DeleteAccountRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? password = freezed,Object? confirmation = null,}) {
  return _then(_DeleteAccountRequestDto(
password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,confirmation: null == confirmation ? _self.confirmation : confirmation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
