import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/suggest_edit/domain/suggest_category.dart';

void main() {
  test('kategori tanpa sasaran disembunyikan', () {
    final none = availableSuggestCategories(hasMeaning: false, hasImage: false);
    expect(none, isNot(contains(SuggestCategory.changeMeaning)));
    expect(none, isNot(contains(SuggestCategory.changeWordClass)));
    expect(none, isNot(contains(SuggestCategory.addExample)));
    expect(none, isNot(contains(SuggestCategory.changePhoto)));
    expect(none, contains(SuggestCategory.addMeaning));
    expect(availableSuggestCategories(hasMeaning: true, hasImage: true), SuggestCategory.values);
  });

  test('ubah makna: tanpa perubahan = null, padanan saja tidak bawa definisi', () {
    Map<String, dynamic>? build(String def, String pad) => buildChangeMeaning(
          meaningId: 'm1',
          originalDefinition: 'lama',
          definition: def,
          originalPadanan: 'makan',
          padanan: pad,
          padananLanguageId: 'idn',
        );
    expect(build(' lama ', 'makan'), isNull);
    expect(build('lama', ''), isNull);
    final m = (build('lama', 'santap')!['meanings'] as List).single as Map;
    expect(m.containsKey('definition'), isFalse);
    expect(m.containsKey('word_class_id'), isFalse);
    expect((m['translations'] as List).single['translation_text'], 'santap');
  });

  test('ubah kelas kata: sama = null', () {
    expect(
      buildChangeWordClass(meaningId: 'm1', originalWordClassId: 'n', wordClassId: 'n'),
      isNull,
    );
  });

  test('variasi: lemma dan duplikat dibuang, hapus membawa tipe asli', () {
    final out = buildVariants(
      lemma: 'kete',
      existingForms: ['kate'],
      addForms: ['Kete', 'kate', 'katee', 'katee'],
      removeFormTypes: {'kate': 'alternative'},
    )!['variants'] as List;
    expect(out, [
      {'action': 'add', 'form': 'katee', 'variant_type': 'alternative'},
      {'action': 'remove', 'form': 'kate', 'variant_type': 'alternative'},
    ]);
  });

  test('field API dipetakan ke field form', () {
    expect(suggestFieldKey('meanings.0.definition'), 'definition');
    expect(suggestFieldKey('meanings.0.translations.0.translation_text'), 'padanan');
    expect(suggestFieldKey('proposed_changes'), isNull);
  });
}
