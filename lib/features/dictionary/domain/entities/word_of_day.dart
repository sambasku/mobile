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

/// Arti pertama (definition), fallback terjemahan pertama.
/// Treats '-' (API placeholder for empty) as empty.
String get firstSense {
if (word.meanings.isEmpty) return '';
final meaning = word.meanings.first;
final definition = meaning.definition?.trim();
if (definition != null && definition.isNotEmpty && definition != '-') {
return definition;
}
if (meaning.translations.isEmpty) return '';
final translation = meaning.translations.first.text.trim();
if (translation.isEmpty || translation == '-') return '';
return translation;
}
}
