// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_word_variant_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateWordVariantDto {

 String get form;@JsonKey(name: 'variant_type') String get variantType;
/// Create a copy of CreateWordVariantDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateWordVariantDtoCopyWith<CreateWordVariantDto> get copyWith => _$CreateWordVariantDtoCopyWithImpl<CreateWordVariantDto>(this as CreateWordVariantDto, _$identity);

  /// Serializes this CreateWordVariantDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateWordVariantDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateWordVariantDto&&(identical(other.form, _this.form) || other.form == _this.form)&&(identical(other.variantType, _this.variantType) || other.variantType == _this.variantType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateWordVariantDto;
  return Object.hash(runtimeType,_this.form,_this.variantType);
}

@override
String toString() {
  final _this = this as CreateWordVariantDto;
  return 'CreateWordVariantDto(form: ${_this.form}, variantType: ${_this.variantType})';
}


}

/// @nodoc
abstract mixin class $CreateWordVariantDtoCopyWith<$Res>  {
  factory $CreateWordVariantDtoCopyWith(CreateWordVariantDto value, $Res Function(CreateWordVariantDto) _then) = _$CreateWordVariantDtoCopyWithImpl;
@useResult
$Res call({
 String form,@JsonKey(name: 'variant_type') String variantType
});




}
/// @nodoc
class _$CreateWordVariantDtoCopyWithImpl<$Res>
    implements $CreateWordVariantDtoCopyWith<$Res> {
  _$CreateWordVariantDtoCopyWithImpl(this._self, this._then);

  final CreateWordVariantDto _self;
  final $Res Function(CreateWordVariantDto) _then;

/// Create a copy of CreateWordVariantDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? form = null,Object? variantType = null,}) {
  return _then(CreateWordVariantDto(
form: null == form ? _self.form : form // ignore: cast_nullable_to_non_nullable
as String,variantType: null == variantType ? _self.variantType : variantType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateWordVariantDto].
extension CreateWordVariantDtoPatterns on CreateWordVariantDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateWordVariantDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateWordVariantDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateWordVariantDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateWordVariantDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateWordVariantDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateWordVariantDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String form, @JsonKey(name: 'variant_type')  String variantType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateWordVariantDto() when $default != null:
return $default(_that.form,_that.variantType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String form, @JsonKey(name: 'variant_type')  String variantType)  $default,) {final _that = this;
switch (_that) {
case _CreateWordVariantDto():
return $default(_that.form,_that.variantType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String form, @JsonKey(name: 'variant_type')  String variantType)?  $default,) {final _that = this;
switch (_that) {
case _CreateWordVariantDto() when $default != null:
return $default(_that.form,_that.variantType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateWordVariantDto implements CreateWordVariantDto {
  const _CreateWordVariantDto({required this.form, @JsonKey(name: 'variant_type') this.variantType = 'alternative'});
  factory _CreateWordVariantDto.fromJson(Map<String, dynamic> json) => _$CreateWordVariantDtoFromJson(json);

@override final  String form;
@override@JsonKey(name: 'variant_type') final  String variantType;

/// Create a copy of CreateWordVariantDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateWordVariantDtoCopyWith<_CreateWordVariantDto> get copyWith => __$CreateWordVariantDtoCopyWithImpl<_CreateWordVariantDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateWordVariantDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateWordVariantDto&&(identical(other.form, form) || other.form == form)&&(identical(other.variantType, variantType) || other.variantType == variantType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,form,variantType);
}

@override
String toString() {
    return 'CreateWordVariantDto(form: $form, variantType: $variantType)';
}


}

/// @nodoc
abstract mixin class _$CreateWordVariantDtoCopyWith<$Res> implements $CreateWordVariantDtoCopyWith<$Res> {
  factory _$CreateWordVariantDtoCopyWith(_CreateWordVariantDto value, $Res Function(_CreateWordVariantDto) _then) = __$CreateWordVariantDtoCopyWithImpl;
@override @useResult
$Res call({
 String form,@JsonKey(name: 'variant_type') String variantType
});




}
/// @nodoc
class __$CreateWordVariantDtoCopyWithImpl<$Res>
    implements _$CreateWordVariantDtoCopyWith<$Res> {
  __$CreateWordVariantDtoCopyWithImpl(this._self, this._then);

  final _CreateWordVariantDto _self;
  final $Res Function(_CreateWordVariantDto) _then;

/// Create a copy of CreateWordVariantDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? form = null,Object? variantType = null,}) {
  return _then(_CreateWordVariantDto(
form: null == form ? _self.form : form // ignore: cast_nullable_to_non_nullable
as String,variantType: null == variantType ? _self.variantType : variantType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
