import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_summary_dto.freezed.dart';
part 'word_summary_dto.g.dart';

/// Item hasil GET /api/v1/words/search.
@freezed
abstract class WordSummaryDto with _$WordSummaryDto {
  const factory WordSummaryDto({
    required String id,
    required String lemma,
    @JsonKey(name: 'language_id') required String languageId,
    @JsonKey(name: 'language_code') required String languageCode,
    @JsonKey(name: 'word_type') required String wordType,
    required String status,
    @JsonKey(name: 'is_verified') required bool isVerified,
    /// Hanya terisi saat search_in=translation (Indonesia→Sambas).
    @JsonKey(name: 'matched_translation') String? matchedTranslation,
    /// Satu baris arti.
    /// - GET /words/latest: definisi atau terjemahan pertama.
    /// - GET /words (A-Z): gloss `[n] makan,[v] santap`.
    String? sense,
    /// Waktu persetujuan ISO. Hanya GET /api/v1/words/latest.
    @JsonKey(name: 'approved_at') String? approvedAt,
    @JsonKey(name: 'usage_labels') @Default([]) List<String> usageLabels,
  }) = _WordSummaryDto;

  factory WordSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$WordSummaryDtoFromJson(json);
}
