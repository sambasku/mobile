/// Kategori usulan perubahan. [code] = `reason_code` API, kecuali
/// [addExample] yang lewat POST /api/v1/meanings/:id/examples.
enum SuggestCategory {
  changeMeaning('change_meaning', 'Ubah makna', 'Perbaiki definisi atau padanan'),
  changeWordClass('change_word_class', 'Ubah kelas kata', 'Nomina, verba, adjektiva, dsb.'),
  addMeaning('add_meaning', 'Tambah makna', 'Arti lain dari kata ini'),
  addExample('add_example', 'Tambah contoh', 'Contoh kalimat untuk satu makna'),
  addPhoto('add_photo', 'Tambah foto', 'Foto yang menggambarkan kata ini'),
  changePhoto('change_photo', 'Ubah foto', 'Hapus, ganti, atau pilih foto utama'),
  synonym('synonym', 'Sinonim', 'Kata lain yang artinya sama'),
  antonym('antonym', 'Antonim', 'Kata yang artinya berlawanan'),
  spellingVariant('spelling_variant', 'Variasi penulisan', 'Ejaan lain untuk kata yang sama'),
  lemmaNotes('lemma_notes', 'Lainnya', 'Ejaan lemma atau catatan');

  const SuggestCategory(this.code, this.label, this.description);

  final String code;
  final String label;
  final String description;

  bool get needsMeaning =>
      this == changeMeaning || this == changeWordClass || this == addExample;
}

/// Sembunyikan kategori yang tidak punya sasaran di kata ini.
List<SuggestCategory> availableSuggestCategories({
  required bool hasMeaning,
  required bool hasImage,
}) =>
    SuggestCategory.values
        .where((c) => c.needsMeaning ? hasMeaning : (c != SuggestCategory.changePhoto || hasImage))
        .toList(growable: false);

/// Ubah makna: definisi dan/atau padanan. `null` = tidak ada yang berubah.
/// Padanan dikosongkan tidak dikirim (usulan tidak menghapus padanan).
Map<String, dynamic>? buildChangeMeaning({
  required String meaningId,
  required String originalDefinition,
  required String definition,
  required String originalPadanan,
  required String padanan,
  required String? padananLanguageId,
}) {
  final def = definition.trim();
  final pad = padanan.trim();
  final defChanged = def != originalDefinition.trim();
  final padChanged = pad.isNotEmpty && pad != originalPadanan.trim();
  if (!defChanged && !padChanged) return null;
  if (padChanged && padananLanguageId == null) {
    throw StateError('Bahasa padanan belum diketahui');
  }
  return {
    'meanings': [
      {
        'meaning_id': meaningId,
        'action': 'update',
        if (defChanged) 'definition': def,
        if (padChanged)
          'translations': [
            {
              'language_id': padananLanguageId,
              'translation_text': pad,
              'translation_type': 'direct',
            },
          ],
      },
    ],
  };
}

Map<String, dynamic>? buildChangeWordClass({
  required String meaningId,
  required String? originalWordClassId,
  required String? wordClassId,
}) {
  if (wordClassId == null || wordClassId == originalWordClassId) return null;
  return {
    'meanings': [
      {'meaning_id': meaningId, 'action': 'update', 'word_class_id': wordClassId},
    ],
  };
}

Map<String, dynamic>? buildAddMeaning({
  required String? wordClassId,
  required String definition,
  required String padanan,
  required String? padananLanguageId,
}) {
  final def = definition.trim();
  final pad = padanan.trim();
  if (def.isEmpty && pad.isEmpty) return null;
  return {
    'meanings': [
      {
        'action': 'add',
        'word_class_id': ?wordClassId,
        if (def.isNotEmpty) 'definition': def,
        if (pad.isNotEmpty && padananLanguageId != null)
          'translations': [
            {
              'language_id': padananLanguageId,
              'translation_text': pad,
              'translation_type': 'direct',
            },
          ],
      },
    ],
  };
}

/// Sinonim/antonim: tambah (id hasil cari lemma) + hapus yang sudah ada.
Map<String, dynamic>? buildRelations({
  required String relationType,
  required List<String> addWordIds,
  required Iterable<String> removeWordIds,
}) {
  final rows = [
    for (final id in addWordIds.toSet())
      {'action': 'add', 'relation_type': relationType, 'word_id': id},
    for (final id in removeWordIds)
      {'action': 'remove', 'relation_type': relationType, 'word_id': id},
  ];
  return rows.isEmpty ? null : {'relations': rows};
}

/// Variasi penulisan: bentuk baru (tanpa lemma/duplikat) + hapus yang ada.
Map<String, dynamic>? buildVariants({
  required String lemma,
  required Iterable<String> existingForms,
  required List<String> addForms,
  required Map<String, String> removeFormTypes,
}) {
  final seen = {lemma.trim().toLowerCase(), ...existingForms.map((f) => f.trim().toLowerCase())};
  final rows = <Map<String, dynamic>>[];
  for (final raw in addForms) {
    final form = raw.trim();
    if (form.isEmpty || !seen.add(form.toLowerCase())) continue;
    rows.add({'action': 'add', 'form': form, 'variant_type': 'alternative'});
  }
  removeFormTypes.forEach((form, type) {
    rows.add({'action': 'remove', 'form': form, 'variant_type': type});
  });
  return rows.isEmpty ? null : {'variants': rows};
}

Map<String, dynamic>? buildLemmaNotes({
  required String originalLemma,
  required String lemma,
  required String originalNotes,
  required String notes,
}) {
  final l = lemma.trim();
  final n = notes.trim();
  final out = <String, dynamic>{
    if (l.isNotEmpty && l != originalLemma.trim()) 'lemma': l,
    if (n != originalNotes.trim()) 'notes': n,
  };
  return out.isEmpty ? null : out;
}

List<String> splitCsv(String raw) =>
    raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

/// Petakan `details[].field` API ke kunci field lokal form. `null` = tidak
/// punya field di layar (tampil di sheet error).
String? suggestFieldKey(String apiField) {
  if (apiField.endsWith('definition')) return 'definition';
  if (apiField.contains('translation_text') || apiField.endsWith('translations')) {
    return 'padanan';
  }
  if (apiField.contains('word_class')) return 'word_class';
  return switch (apiField) {
    'lemma' => 'lemma',
    'notes' => 'notes',
    'reason_text' => 'reason',
    'source_sentence' => 'sentence',
    'target_sentence' => 'sentence_translation',
    _ => null,
  };
}
