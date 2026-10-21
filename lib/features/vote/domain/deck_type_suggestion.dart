import '../../../shared/domain/word_type_options.dart';

export '../../../shared/domain/word_type_options.dart';

/// Alias lama supaya pemanggil deck tetap pendek.
const deckWordTypeOptions = wordTypeOptions;

String deckWordTypeLabel(String? code) => wordTypeOptionLabel(code);

/// Satu makna yang kelasnya masih Umum, plus kelas yang dipilih user.
class DeckClassPick {
  const DeckClassPick({
    required this.meaningId,
    required this.currentClassId,
    required this.nextClassId,
    required this.isUmum,
  });

  final String meaningId;
  final String? currentClassId;
  final String? nextClassId;
  final bool isUmum;
}

/// Body `proposed_changes` hanya berisi field yang beda.
/// Null bila tidak ada perubahan.
Map<String, dynamic>? buildDeckTypeProposal({
  required String currentWordType,
  required String nextWordType,
  required List<DeckClassPick> classes,
}) {
  final changes = <String, dynamic>{};
  if (nextWordType != currentWordType &&
      deckWordTypeOptions.any((option) => option.value == nextWordType)) {
    changes['word_type'] = nextWordType;
  }

  final meanings = <Map<String, dynamic>>[];
  for (final pick in classes) {
    final next = pick.nextClassId?.trim() ?? '';
    final current = pick.currentClassId?.trim() ?? '';
    if (next.isEmpty || next == current) continue;
    meanings.add({
      'action': 'update',
      'meaning_id': pick.meaningId,
      'word_class_id': next,
    });
  }
  if (meanings.isNotEmpty) changes['meanings'] = meanings;
  if (changes.isEmpty) return null;
  return changes;
}
