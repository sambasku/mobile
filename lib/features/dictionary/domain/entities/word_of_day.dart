import 'word_detail.dart';

/// Kata hari ini: detail reuse + tanggal WIB seed + chip mingguan.
class WordOfDay {
  const WordOfDay({
    required this.word,
    required this.date,
    required this.isNewThisWeek,
  });

  final WordDetail word;
  final String date;
  final bool isNewThisWeek;

  /// Definisi makna pertama. Treats '-' (API placeholder) as empty.
  String get firstDefinition {
    if (word.meanings.isEmpty) return '';
    return _nonEmpty(word.meanings.first.definition) ?? '';
  }

  /// Terjemahan pertama dari makna pertama. Treats '-' as empty.
  String get firstTranslation {
    if (word.meanings.isEmpty) return '';
    final translations = word.meanings.first.translations;
    if (translations.isEmpty) return '';
    return _nonEmpty(translations.first.text) ?? '';
  }

  /// Arti pertama (definition), fallback terjemahan pertama.
  /// Treats '-' (API placeholder for empty) as empty.
  String get firstSense {
    final definition = firstDefinition;
    if (definition.isNotEmpty) return definition;
    return firstTranslation;
  }
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty || trimmed == '-') return null;
  return trimmed;
}
