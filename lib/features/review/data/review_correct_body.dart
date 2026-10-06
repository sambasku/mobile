/// Contoh kalimat di form koreksi. [sourceIndex] = posisi contoh asal di
/// `meanings[i].examples` entity (null = contoh baru dari verifikator).
typedef CorrectExampleEdit = ({String source, String target, int? sourceIndex});

/// Makna di form koreksi. [sourceIndex] = posisi makna asal di
/// `entity['meanings']` (null = makna baru). Dipakai untuk membawa
/// terjemahan lain dan metadata contoh yang tidak diedit form.
typedef CorrectMeaningEdit = ({
  int? sourceIndex,
  String definition,
  String translation,
  String? translationLanguageId,
  String? wordClassId,
  String meaningSource,
  List<CorrectExampleEdit> examples,
});

typedef CorrectRelationEdit = ({String wordId, String relationType});

/// Body POST correct untuk entity kata. Replace semantics di server: field
/// yang tidak dikirim ikut terhapus, jadi daftar makna, relasi, dan variasi
/// dikirim utuh dari form, sedangkan gambar, kategori, dan pelafalan pertama
/// dibawa ulang dari entity detail (camelCase). `usage_labels` selalu
/// dikirim, termasuk daftar kosong: absen di schema berarti `[]` dan
/// menghapus penanda yang sudah ada.
Map<String, dynamic> buildWordCorrectBody({
  required Map<String, dynamic> entity,
  required String lemma,
  required String? notes,
  required String wordType,
  required List<String> usageLabels,
  required List<CorrectMeaningEdit> meanings,
  required List<CorrectRelationEdit> relatedWords,
  required List<String> variants,
  required bool publish,
  String? comment,
}) {
  final sourceMeanings = _list(entity['meanings']);
  final wordLanguageId = entity['languageId']?.toString();
  final meaningBodies = <Map<String, dynamic>>[];
  for (final edit in meanings) {
    final source = _at(sourceMeanings, edit.sourceIndex);
    final editedClass = edit.wordClassId?.trim() ?? '';
    final wordClassId = editedClass.isNotEmpty
        ? editedClass
        : (_map(source['wordClass'])['id']?.toString() ?? '');
    if (wordClassId.isEmpty) continue;

    final sourceTranslations = _list(source['translations']);
    final firstSource = _at(sourceTranslations, 0);
    final translationLanguageId =
        edit.translationLanguageId ?? firstSource['languageId']?.toString();
    final translations = <Map<String, dynamic>>[];
    final translation = edit.translation.trim();
    if (translation.isNotEmpty &&
        translationLanguageId != null &&
        translationLanguageId.isNotEmpty) {
      translations.add({
        'language_id': translationLanguageId,
        'translation_text': translation,
        'translation_type':
            firstSource['translationType']?.toString() ?? 'direct',
      });
    }
    for (var t = 1; t < sourceTranslations.length; t++) {
      final row = _map(sourceTranslations[t]);
      final text = row['translationText']?.toString().trim() ?? '';
      final languageId = row['languageId']?.toString();
      if (text.isEmpty || languageId == null || languageId.isEmpty) continue;
      translations.add({
        'language_id': languageId,
        'translation_text': text,
        'translation_type': row['translationType']?.toString() ?? 'direct',
      });
    }

    final sourceExamples = _list(source['examples']);
    final examples = <Map<String, dynamic>>[];
    for (final example in edit.examples) {
      final sentence = example.source.trim();
      if (sentence.isEmpty) continue;
      final original = _at(sourceExamples, example.sourceIndex);
      final sourceLanguageId =
          original['sourceLanguageId']?.toString() ?? wordLanguageId;
      if (sourceLanguageId == null || sourceLanguageId.isEmpty) continue;
      final target = example.target.trim();
      final targetLanguageId =
          original['targetLanguageId']?.toString() ?? translationLanguageId;
      examples.add({
        'source_language_id': sourceLanguageId,
        'source_sentence': sentence,
        if (target.isNotEmpty && targetLanguageId != null) ...{
          'target_language_id': targetLanguageId,
          'target_sentence': target,
        },
        if (original['sourceType'] != null)
          'source_type': original['sourceType'],
      });
    }

    final definition = edit.definition.trim();
    meaningBodies.add({
      'word_class_id': wordClassId,
      'definition': definition.isEmpty ? '-' : definition,
      // 1-based, konsisten create-word (kontribusi_repository i+1); skema
      // correct mewarisi order_index min(1) - 0 ditolak (issue #89).
      'order_index': meaningBodies.length + 1,
      'is_have_definition': definition.isNotEmpty && definition != '-',
      'is_have_translation': translations.isNotEmpty,
      'meaning_source': edit.meaningSource,
      'translations': translations,
      if (examples.isNotEmpty) 'examples': examples,
    });
  }

  final images = <Map<String, dynamic>>[];
  for (final raw in _list(entity['images'])) {
    final image = _map(raw);
    final url = image['url']?.toString() ?? '';
    final fileId = image['providerFileId']?.toString() ?? '';
    if (url.isEmpty || fileId.isEmpty) continue;
    images.add({
      'url': url,
      'provider_file_id': fileId,
      if ((image['altText']?.toString().trim().isNotEmpty ?? false))
        'alt_text': image['altText'],
      'is_primary': image['isPrimary'] == true,
    });
  }

  final related = <Map<String, dynamic>>[];
  final seenRelations = <String>{};
  for (final relation in relatedWords) {
    if (relation.wordId.isEmpty || relation.relationType.isEmpty) continue;
    if (!seenRelations.add('${relation.relationType}:${relation.wordId}')) {
      continue;
    }
    related.add({
      'word_id': relation.wordId,
      'relation_type': relation.relationType,
    });
  }

  final sourceVariants = _list(entity['variants']).map(_map).toList();
  final variantBodies = <Map<String, dynamic>>[];
  final seenForms = <String>{};
  for (final raw in variants) {
    final form = raw.trim();
    if (form.isEmpty || !seenForms.add(form.toLowerCase())) continue;
    final row = sourceVariants.firstWhere(
      (v) => v['form']?.toString().trim().toLowerCase() == form.toLowerCase(),
      orElse: () => const {},
    );
    variantBodies.add({
      'form': form,
      'variant_type': row['variantType']?.toString() ?? 'alternative',
      if (row['affixType'] != null) 'affix_type': row['affixType'],
      if ((row['affixValue']?.toString().trim().isNotEmpty ?? false))
        'affix_value': row['affixValue'],
      if (row['dialectId'] != null) 'dialect_id': row['dialectId'],
    });
  }

  final pronunciations = _list(entity['pronunciations']);
  Map<String, dynamic>? pronunciation;
  if (pronunciations.isNotEmpty) {
    final first = _map(pronunciations.first);
    final value = first['value']?.toString().trim() ?? '';
    if (value.isNotEmpty) {
      pronunciation = {
        'notation': first['notation']?.toString() ?? 'ipa',
        'value': value,
      };
    }
  }

  final categories = <String>[];
  for (final raw in _list(entity['categories'])) {
    final id = _map(raw)['id']?.toString();
    if (id != null && id.isNotEmpty) categories.add(id);
  }

  final trimmedNotes = notes?.trim();
  final dialectId = entity['dialectId']?.toString();
  return {
    'entity_type': 'word',
    'language_id': entity['languageId'],
    if (dialectId != null && dialectId.isNotEmpty) 'dialect_id': dialectId,
    'lemma': lemma.trim(),
    'word_type': wordType,
    'usage_labels': usageLabels,
    if (trimmedNotes != null && trimmedNotes.isNotEmpty) 'notes': trimmedNotes,
    'meanings': meaningBodies,
    'category_ids': categories,
    if (related.isNotEmpty) 'related_words': related,
    if (variantBodies.isNotEmpty) 'variants': variantBodies,
    if (images.isNotEmpty) 'images': images,
    'pronunciation': ?pronunciation,
    'publish': publish,
    if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
  };
}

Map<String, dynamic> _map(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return const {};
}

/// Body POST correct untuk entity makna. `word_class_id` nullable di API:
/// string kosong DITOLAK choiceId (min 1), jadi kosong dikirim sebagai null.
/// `meaning_source` tidak ada di skema correct-meaning (server strip) - tidak
/// dikirim; server mempertahankan source yang tersimpan.
Map<String, dynamic> buildMeaningCorrectBody({
  required String definition,
  String? wordClassId,
  required List<Map<String, dynamic>> translations,
  required bool publish,
  String? comment,
}) {
  final trimmedComment = comment?.trim();
  final wordClass = wordClassId?.trim();
  return {
    'entity_type': 'meaning',
    'publish': publish,
    if (trimmedComment != null && trimmedComment.isNotEmpty)
      'comment': trimmedComment,
    'definition': definition.trim(),
    'word_class_id': (wordClass == null || wordClass.isEmpty)
        ? null
        : wordClass,
    'translations': translations,
  };
}

List<Object?> _list(Object? raw) => raw is List ? raw : const [];

Map<String, dynamic> _at(List<Object?> list, int? index) =>
    index != null && index >= 0 && index < list.length
    ? _map(list[index])
    : const {};
