/// Kategori usulan perubahan. [code] = `reason_code` API, kecuali
/// [addExample] yang lewat POST /api/v1/meanings/:id/examples.
enum SuggestCategory {
  changeMeaning('change_meaning'),
  changeWordClass('change_word_class'),
  changeWordType('change_word_type'),
  addMeaning('add_meaning'),
  addExample('add_example'),
  addPhoto('add_photo'),
  changePhoto('change_photo'),
  /// #244: ubah contoh published (moderasi usulan, bukan POST examples).
  changeExample('change_example'),
  /// Ubah notasi pelafalan published (moderasi usulan, bukan POST pronunciations).
  changePronunciation('change_pronunciation'),
  synonym('synonym'),
  antonym('antonym'),
  // PRD relasi-lemma: relasi bentuk + akar/turunan + kelompok makna.
  variantOf('variant_of'),
  nonstandardOf('nonstandard_of'),
  derivedFrom('derived_from'),
  meaningGroup('meaning_group'),
  spellingVariant('spelling_variant'),
  lemmaNotes('lemma_notes');

  const SuggestCategory(this.code);

  /// `reason_code` API - stabil, bukan teks tampilan.
  final String code;

  bool get needsMeaning =>
      this == changeMeaning || this == changeWordClass || this == addExample;
}

/// Sembunyikan kategori yang tidak punya sasaran di kata ini.
List<SuggestCategory> availableSuggestCategories({
  required bool hasMeaning,
  required bool hasImage,
  bool hasExample = false,
  bool hasPronunciation = false,
}) => SuggestCategory.values
    .where((c) {
      if (c.needsMeaning) return hasMeaning;
      if (c == SuggestCategory.changePhoto) return hasImage;
      if (c == SuggestCategory.changeExample) return hasExample;
      if (c == SuggestCategory.changePronunciation) return hasPronunciation;
      return true;
    })
    .toList(growable: false);

/// Ubah pelafalan: value baru (raw tanpa slash). `null` = tidak ada perubahan.
Map<String, dynamic>? buildChangePronunciation({
  required String pronunciationId,
  required String originalValue,
  required String value,
}) {
  final next = value.trim();
  final orig = originalValue.trim();
  if (next.isEmpty || next == orig) return null;
  return {
    'pronunciations': [
      {
        'pronunciation_id': pronunciationId,
        'action': 'update',
        'value': next,
      },
    ],
  };
}

/// #244: usulan ubah contoh published. `null` = tidak ada perubahan.
Map<String, dynamic>? buildChangeExample({
  required String exampleId,
  required String originalSourceSentence,
  required String sourceSentence,
  required String? originalTargetSentence,
  required String targetSentence,
}) {
  final src = sourceSentence.trim();
  final tgt = targetSentence.trim();
  final origSrc = originalSourceSentence.trim();
  final origTgt = (originalTargetSentence ?? '').trim();
  final srcChanged = src.isNotEmpty && src != origSrc;
  final tgtChanged = tgt != origTgt;
  if (!srcChanged && !tgtChanged) return null;
  if (src.isEmpty) return null;
  return {
    'examples': [
      {
        'example_id': exampleId,
        'action': 'update',
        if (srcChanged) 'source_sentence': src,
        if (tgtChanged) 'target_sentence': tgt.isEmpty ? null : tgt,
      },
    ],
  };
}

/// Ubah makna: definisi dan/atau padanan. `null` = tidak ada yang berubah.
/// Padanan dikosongkan tidak dikirim (usulan tidak menghapus padanan).
/// #230: support multiple meanings.
Map<String, dynamic>? buildChangeMeaning({
  required List<({
    String meaningId,
    String originalDefinition,
    String definition,
    String originalPadanan,
    String padanan,
  })> meanings,
  required String? padananLanguageId,
}) {
  final rows = <Map<String, dynamic>>[];
  for (final m in meanings) {
    final def = m.definition.trim();
    final pad = m.padanan.trim();
    final defChanged = def != m.originalDefinition.trim();
    final padChanged = pad.isNotEmpty && pad != m.originalPadanan.trim();
    if (!defChanged && !padChanged) continue;
    if (padChanged && padananLanguageId == null) {
      throw StateError('Bahasa terjemahan belum diketahui');
    }
    rows.add({
      'meaning_id': m.meaningId,
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
    });
  }
  return rows.isEmpty ? null : {'meanings': rows};
}

Map<String, dynamic>? buildChangeWordClass({
  required String meaningId,
  required String? originalWordClassId,
  required String? wordClassId,
}) {
  if (wordClassId == null || wordClassId == originalWordClassId) return null;
  return {
    'meanings': [
      {
        'meaning_id': meaningId,
        'action': 'update',
        'word_class_id': wordClassId,
      },
    ],
  };
}

/// Jenis entri (kata / idiom / peribahasa / ungkapan). Bukan kelas kata.
Map<String, dynamic>? buildChangeWordType({
  required String originalWordType,
  required String wordType,
}) {
  final next = wordType.trim();
  if (next.isEmpty || next == originalWordType.trim()) return null;
  return {'word_type': next};
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

/// Sinonim/antonim: tambah + hapus yang sudah ada. `addLemmas` = lemma bebas;
/// API resolve sendiri (lemma yang belum ada dibuat sebagai kata baru saat
/// usulan disetujui verifikator).
Map<String, dynamic>? buildRelations({
  required String relationType,
  required List<String> addLemmas,
  required Iterable<String> removeWordIds,
}) {
  final rows = [
    for (final lemma in addLemmas.map((e) => e.trim()).toSet())
      if (lemma.isNotEmpty)
        {'action': 'add', 'relation_type': relationType, 'lemma': lemma},
    for (final id in removeWordIds)
      {'action': 'remove', 'relation_type': relationType, 'word_id': id},
  ];
  return rows.isEmpty ? null : {'relations': rows};
}

// PRD relasi-lemma: kelompok makna - gabung grup yang ada / usul grup baru
// / keluar dari grup. `null` = tidak ada perubahan.
Map<String, dynamic>? buildGroups({
  String? joinGroupId,
  String? newGroupName,
  String? newGroupDescription,
  List<String> newGroupLemmas = const [],
  Iterable<String> leaveGroupIds = const [],
}) {
  final rows = <Map<String, dynamic>>[
    if (joinGroupId != null && joinGroupId.isNotEmpty)
      {'action': 'add', 'group_id': joinGroupId},
    if (newGroupName != null && newGroupName.trim().isNotEmpty)
      {
        'action': 'add',
        'name': newGroupName.trim(),
        if (newGroupDescription != null &&
            newGroupDescription.trim().isNotEmpty)
          'description': newGroupDescription.trim(),
        if (newGroupLemmas.isNotEmpty) 'lemmas': newGroupLemmas,
      },
    for (final id in leaveGroupIds) {'action': 'remove', 'group_id': id},
  ];
  return rows.isEmpty ? null : {'groups': rows};
}

/// Variasi penulisan: bentuk baru (tanpa lemma/duplikat) + hapus yang ada.
Map<String, dynamic>? buildVariants({
  required String lemma,
  required Iterable<String> existingForms,
  required List<String> addForms,
  required Map<String, String> removeFormTypes,
}) {
  final seen = {
    lemma.trim().toLowerCase(),
    ...existingForms.map((f) => f.trim().toLowerCase()),
  };
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
  if (apiField.contains('translation_text') ||
      apiField.endsWith('translations')) {
    return 'padanan';
  }
  if (apiField.contains('word_class')) return 'word_class';
  if (apiField.startsWith('relations.')) return 'relation_lemma';
  if (apiField.startsWith('groups.')) {
    if (apiField.endsWith('.name')) return 'name';
    if (apiField.endsWith('.lemmas')) return 'group_lemma';
    return null;
  }
  if (apiField.contains('source_sentence')) return 'sentence';
  if (apiField.contains('target_sentence')) return 'sentence_translation';
  if (apiField.startsWith('pronunciations')) return 'pronunciation';
  return switch (apiField) {
    'lemma' => 'lemma',
    'notes' => 'notes',
    'word_type' => 'word_type',
    'reason_text' => 'reason',
    'examples' => 'sentence',
    'pronunciations' => 'pronunciation',
    _ => null,
  };
}
