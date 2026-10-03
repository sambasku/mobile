import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_word_variant_dto.freezed.dart';
part 'create_word_variant_dto.g.dart';

/// Item `variants[]` body usul kata - Form mobile hanya
/// mengirim ejaan alternatif - `variant_type` selalu 'alternative'.
@freezed
abstract class CreateWordVariantDto with _$CreateWordVariantDto {
  const factory CreateWordVariantDto({
    required String form,
    @JsonKey(name: 'variant_type') @Default('alternative') String variantType,
  }) = _CreateWordVariantDto;

  factory CreateWordVariantDto.fromJson(Map<String, dynamic> json) =>
      _$CreateWordVariantDtoFromJson(json);
}
