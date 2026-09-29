import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_audio_dto.freezed.dart';
part 'word_audio_dto.g.dart';

@freezed
abstract class WordAudioDto with _$WordAudioDto {
  const factory WordAudioDto({
    required String id,
    required String url,
    @JsonKey(name: 'dialect_id') String? dialectId,
    @JsonKey(name: 'speaker_name') String? speakerName,
    @JsonKey(name: 'duration_ms') int? durationMs,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
    @JsonKey(name: 'mime_type') String? mimeType,
    /// Default true: payload lama tanpa field tetap dianggap terverifikasi.
    @JsonKey(name: 'is_verified') @Default(true) bool isVerified,
  }) = _WordAudioDto;

  factory WordAudioDto.fromJson(Map<String, dynamic> json) =>
      _$WordAudioDtoFromJson(json);
}
