import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_word_image_dto.freezed.dart';
part 'create_word_image_dto.g.dart';

/// Item `images[]` body usul kata (docs/api/01 + 03).
@freezed
abstract class CreateWordImageDto with _$CreateWordImageDto {
  const factory CreateWordImageDto({
    required String url,
    @JsonKey(name: 'provider_file_id') required String providerFileId,
    /// Stock Media Explorer; absen = storage aktif (GitHub) di API.
    @JsonKey(includeIfNull: false) String? provider,
    @JsonKey(includeIfNull: false) String? sha,
    @JsonKey(name: 'alt_text', includeIfNull: false) String? altText,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
    /// Peringatan konten dipilih kontributor. V1: 'kekerasan'. Kosong = [].
    @JsonKey(name: 'content_warnings') @Default([]) List<String> contentWarnings,
    /// Kredit foto stock (`ImageAttribution.toJson`); upload: null.
    @JsonKey(includeIfNull: false) Map<String, dynamic>? attribution,
  }) = _CreateWordImageDto;

  factory CreateWordImageDto.fromJson(Map<String, dynamic> json) =>
      _$CreateWordImageDtoFromJson(json);
}
