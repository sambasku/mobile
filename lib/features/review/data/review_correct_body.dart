/// Body POST correct untuk entity kata. Replace semantics di server:
/// field yang tidak dikirim ikut terhapus, jadi gambar, relasi, variasi,
/// dan pelafalan pertama dibawa ulang dari entity detail (camelCase).
Map<String, dynamic> buildWordCorrectBody({
  required Map<String, dynamic> entity,
  required String lemma,
  required String? notes,
  required String wordType,
  required List<
    ({
      String definition,
      String translation,
      String? wordClassId,
      String meaningSource,
    })
  >
  meaningEdits,
  required bool publish,
  String? comment,
}) {
  final meaningsRaw = entity['meanings'];
  final meanings = <Map<String, dynamic>>[];
  if (meaningsRaw is List) {
    for (var i = 0; i < meaningsRaw.length; i++) {
      final meaning = _map(meaningsRaw[i]);
      final edit = i < meaningEdits.length ? meaningEdits[i] : null;
      final definition =
          (edit?.definition ?? meaning['definition']?.toString() ?? '').trim();
      final wordClass = _map(meaning['wordClass']);
      final editedClass = edit?.wordClassId?.trim() ?? '';
      final wordClassId = editedClass.isNotEmpty
          ? editedClass
          : (wordClass['id']?.toString() ?? '');
      final translations = <Map<String, dynamic>>[];
      final existing = meaning['translations'];
      if (existing is List && existing.isNotEmpty) {
        for (var t = 0; t < existing.length; t++) {
          final row = _map(existing[t]);
          final text = t == 0 && edit != null
              ? edit.translation.trim()
              : (row['translationText']?.toString() ?? '').trim();
          if (text.isEmpty) continue;
          final languageId = row['languageId']?.toString();
          if (languageId == null || languageId.isEmpty) continue;
          translations.add({
            'language_id': languageId,
            'translation_text': text,
            'translation_type': row['translationType']?.toString() ?? 'direct',
          });
        }
      }
      final examples = <Map<String, dynamic>>[];
      final exampleRaw = meaning['examples'];
      if (exampleRaw is List) {
        for (final raw in exampleRaw) {
          final example = _map(raw);
          final source = example['sourceSentence']?.toString().trim() ?? '';
          final sourceLanguageId = example['sourceLanguageId']?.toString();
          if (source.isEmpty ||
              sourceLanguageId == null ||
              sourceLanguageId.isEmpty) {
            continue;
          }
          examples.add({
            'source_language_id': sourceLanguageId,
            'source_sentence': source,
            if (example['targetLanguageId'] != null)
              'target_language_id': example['targetLanguageId'],
            if ((example['targetSentence']?.toString().trim().isNotEmpty ??
                false))
              'target_sentence': example['targetSentence'],
            if (example['sourceType'] != null)
              'source_type': example['sourceType'],
          });
        }
      }
      if (wordClassId.isEmpty) continue;
      meanings.add({
        'word_class_id': wordClassId,
        'definition': definition.isEmpty ? '-' : definition,
        'order_index': meaning['orderIndex'] is int ? meaning['orderIndex'] : i,
        'is_have_definition': definition.isNotEmpty && definition != '-',
        'is_have_translation': translations.isNotEmpty,
        'meaning_source':
            edit?.meaningSource ??
            meaning['meaningSource']?.toString() ??
            'manual',
        'translations': translations,
        if (examples.isNotEmpty) 'examples': examples,
      });
    }
  }

  final images = <Map<String, dynamic>>[];
  final imageRaw = entity['images'];
  if (imageRaw is List) {
    for (final raw in imageRaw) {
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
  }

  final related = <Map<String, dynamic>>[];
  final relatedRaw = entity['relatedWords'];
  if (relatedRaw is List) {
    for (final raw in relatedRaw) {
      final row = _map(raw);
      final wordId = row['wordId']?.toString();
      final relation = row['relationType']?.toString();
      if (wordId == null ||
          wordId.isEmpty ||
          relation == null ||
          relation.isEmpty) {
        continue;
      }
      related.add({'word_id': wordId, 'relation_type': relation});
    }
  }

  final variants = <Map<String, dynamic>>[];
  final variantRaw = entity['variants'];
  if (variantRaw is List) {
    for (final raw in variantRaw) {
      final row = _map(raw);
      final form = row['form']?.toString().trim() ?? '';
      final type = row['variantType']?.toString();
      if (form.isEmpty || type == null || type.isEmpty) continue;
      variants.add({
        'form': form,
        'variant_type': type,
        if (row['affixType'] != null) 'affix_type': row['affixType'],
        if ((row['affixValue']?.toString().trim().isNotEmpty ?? false))
          'affix_value': row['affixValue'],
        if (row['dialectId'] != null) 'dialect_id': row['dialectId'],
      });
    }
  }

  final pronunciations = entity['pronunciations'];
  Map<String, dynamic>? pronunciation;
  if (pronunciations is List && pronunciations.isNotEmpty) {
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
  final categoryRaw = entity['categories'];
  if (categoryRaw is List) {
    for (final raw in categoryRaw) {
      final id = _map(raw)['id']?.toString();
      if (id != null && id.isNotEmpty) categories.add(id);
    }
  }

  final trimmedNotes = notes?.trim();
  final dialectId = entity['dialectId']?.toString();
  return {
    'entity_type': 'word',
    'language_id': entity['languageId'],
    if (dialectId != null && dialectId.isNotEmpty) 'dialect_id': dialectId,
    'lemma': lemma.trim(),
    'word_type': wordType,
    if (trimmedNotes != null && trimmedNotes.isNotEmpty) 'notes': trimmedNotes,
    'meanings': meanings,
    'category_ids': categories,
    if (related.isNotEmpty) 'related_words': related,
    if (variants.isNotEmpty) 'variants': variants,
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
