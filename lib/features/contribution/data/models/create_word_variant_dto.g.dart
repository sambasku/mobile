// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_word_variant_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateWordVariantDto _$CreateWordVariantDtoFromJson(
  Map<String, dynamic> json,
) => _CreateWordVariantDto(
  form: json['form'] as String,
  variantType: json['variant_type'] as String? ?? 'alternative',
);

Map<String, dynamic> _$CreateWordVariantDtoToJson(
  _CreateWordVariantDto instance,
) => <String, dynamic>{
  'form': instance.form,
  'variant_type': instance.variantType,
};
