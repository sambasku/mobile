import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/models/image_attribution.dart';
import '../../domain/entities/word_detail.dart';
import '../../domain/entities/word_summary.dart';
import '../dataset/lemma_fts_sanitize.dart';

/// Baca korpus lemma dari SQLite publik (offline / fallback).
class DictionaryLocalDatasource {
  DictionaryLocalDatasource(this._db);

  final Database _db;

  Future<WordSearchPage> searchWords({
    required String query,
    required int limit,
    String? cursor,
    String searchIn = 'lemma',
  }) async {
    final tokens = sanitizeFtsMatchQuery(query);
    if (tokens.isEmpty) {
      return const WordSearchPage(items: [], hasMore: false);
    }

    // FTS5: batasi kolom - lemma/variants vs translations.
    final match = searchIn == 'translation'
        ? 'translations : $tokens'
        : '{lemma variants} : $tokens';

    final rows = await _db.rawQuery(
      '''
      SELECT w.id, w.lemma, w.word_type, w.status, w.is_verified, w.usage_labels,
             lang.code AS language_code
      FROM words_fts
      JOIN words w ON w.id = words_fts.word_id
      JOIN languages lang ON lang.id = w.language_id
      WHERE words_fts MATCH ?
        AND w.status = 'published'
        ${cursor != null && cursor.isNotEmpty ? 'AND w.id > ?' : ''}
      ORDER BY w.id ASC
      LIMIT ?
      ''',
      [
        match,
        if (cursor != null && cursor.isNotEmpty) cursor,
        limit + 1,
      ],
    );

    final items = <WordSummary>[];
    for (final row in rows.take(limit)) {
      final id = row['id']!.toString();
      items.add(
        WordSummary(
          id: id,
          lemma: row['lemma']!.toString(),
          languageCode: row['language_code']?.toString() ?? 'sbs',
          wordType: row['word_type']?.toString() ?? 'word',
          status: row['status']?.toString() ?? 'published',
          isVerified: (row['is_verified'] as int? ?? 0) == 1,
          sense: await _senseForWord(id),
          usageLabels: _parseUsageLabels(row['usage_labels']),
        ),
      );
    }

    final hasMore = rows.length > limit;
    return WordSearchPage(
      items: items,
      nextCursor: hasMore && items.isNotEmpty ? items.last.id : null,
      hasMore: hasMore,
    );
  }

  Future<WordSearchPage> listWords({
    required String q,
    required int limit,
    String? cursor,
    String? letter,
    bool? isVerified,
    String? category,
  }) async {
    final where = <String>["w.status = 'published'"];
    final args = <Object?>[];

    final trimmed = q.trim();
    if (trimmed.isNotEmpty) {
      where.add('lower(w.lemma) LIKE ?');
      args.add('%${trimmed.toLowerCase()}%');
    }
    if (letter != null && letter.isNotEmpty) {
      where.add('lower(substr(w.lemma, 1, 1)) = ?');
      args.add(letter.toLowerCase());
    }
    if (isVerified != null) {
      where.add('w.is_verified = ?');
      args.add(isVerified ? 1 : 0);
    }
    if (category != null && category.isNotEmpty) {
      where.add('''
        EXISTS (
          SELECT 1 FROM word_categories wc
          WHERE wc.word_id = w.id AND wc.category_id = ?
        )
      ''');
      args.add(category);
    }
    if (cursor != null && cursor.isNotEmpty) {
      where.add(
        '(lower(w.lemma) > (SELECT lower(lemma) FROM words WHERE id = ?) '
        'OR (lower(w.lemma) = (SELECT lower(lemma) FROM words WHERE id = ?) '
        'AND w.id > ?))',
      );
      args.addAll([cursor, cursor, cursor]);
    }

    args.add(limit + 1);
    final rows = await _db.rawQuery(
      '''
      SELECT w.id, w.lemma, w.word_type, w.status, w.is_verified, w.usage_labels,
             lang.code AS language_code
      FROM words w
      JOIN languages lang ON lang.id = w.language_id
      WHERE ${where.join(' AND ')}
      ORDER BY lower(w.lemma) ASC, w.id ASC
      LIMIT ?
      ''',
      args,
    );

    final items = <WordSummary>[];
    for (final row in rows.take(limit)) {
      final id = row['id']!.toString();
      items.add(
        WordSummary(
          id: id,
          lemma: row['lemma']!.toString(),
          languageCode: row['language_code']?.toString() ?? 'sbs',
          wordType: row['word_type']?.toString() ?? 'word',
          status: row['status']?.toString() ?? 'published',
          isVerified: (row['is_verified'] as int? ?? 0) == 1,
          sense: await _senseForWord(id),
          usageLabels: _parseUsageLabels(row['usage_labels']),
        ),
      );
    }
    final hasMore = rows.length > limit;
    return WordSearchPage(
      items: items,
      nextCursor: hasMore && items.isNotEmpty ? items.last.id : null,
      hasMore: hasMore,
    );
  }

  Future<WordSearchPage> listLatest({
    required int limit,
    String? cursor,
  }) async {
    final args = <Object?>[];
    var cursorSql = '';
    if (cursor != null && cursor.isNotEmpty) {
      cursorSql = '''
        AND (
          COALESCE(w.verified_at, w.created_at) < (
            SELECT COALESCE(verified_at, created_at) FROM words WHERE id = ?
          )
          OR (
            COALESCE(w.verified_at, w.created_at) = (
              SELECT COALESCE(verified_at, created_at) FROM words WHERE id = ?
            )
            AND w.id < ?
          )
        )
      ''';
      args.addAll([cursor, cursor, cursor]);
    }
    args.add(limit + 1);

    final rows = await _db.rawQuery(
      '''
      SELECT w.id, w.lemma, w.word_type, w.status, w.is_verified, w.usage_labels,
             w.verified_at, w.created_at,
             lang.code AS language_code
      FROM words w
      JOIN languages lang ON lang.id = w.language_id
      WHERE w.status = 'published'
        $cursorSql
      ORDER BY COALESCE(w.verified_at, w.created_at) DESC, w.id DESC
      LIMIT ?
      ''',
      args,
    );

    final items = <WordSummary>[];
    for (final row in rows.take(limit)) {
      final id = row['id']!.toString();
      final epoch = (row['verified_at'] as int?) ?? (row['created_at'] as int?);
      items.add(
        WordSummary(
          id: id,
          lemma: row['lemma']!.toString(),
          languageCode: row['language_code']?.toString() ?? 'sbs',
          wordType: row['word_type']?.toString() ?? 'word',
          status: row['status']?.toString() ?? 'published',
          isVerified: (row['is_verified'] as int? ?? 0) == 1,
          sense: await _senseForWord(id),
          approvedAt: epoch == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(epoch * 1000, isUtc: true),
          usageLabels: _parseUsageLabels(row['usage_labels']),
        ),
      );
    }
    final hasMore = rows.length > limit;
    return WordSearchPage(
      items: items,
      nextCursor: hasMore && items.isNotEmpty ? items.last.id : null,
      hasMore: hasMore,
    );
  }

  Future<List<WordCategory>> listCategories() async {
    final rows = await _db.query('categories', orderBy: 'name ASC');
    return [
      for (final row in rows)
        WordCategory(
          id: row['id']!.toString(),
          name: row['name']!.toString(),
        ),
    ];
  }

  Future<WordDetail?> getWordById(String id) async {
    final rows = await _db.rawQuery(
      '''
      SELECT w.*
      FROM words w
      WHERE w.id = ? AND w.status = 'published'
      LIMIT 1
      ''',
      [id],
    );
    if (rows.isEmpty) return null;
    return _mapDetail(rows.first);
  }

  Future<WordDetail?> getWordByLemma(String lemma) async {
    final rows = await _db.rawQuery(
      '''
      SELECT w.*
      FROM words w
      WHERE lower(w.lemma) = lower(?) AND w.status = 'published'
      LIMIT 1
      ''',
      [lemma.trim()],
    );
    if (rows.isEmpty) return null;
    return _mapDetail(rows.first);
  }

  Future<WordDetail> _mapDetail(Map<String, Object?> w) async {
    final id = w['id']!.toString();
    final meanings = await _loadMeanings(id);
    final categories = await _loadCategories(id);
    final pronunciations = await _loadPronunciations(id);
    final audios = await _loadAudios(id);
    final images = await _loadImages(id);
    final variants = await _loadVariants(id);
    final related = await _loadRelated(id);
    final appears = await _loadAppearsIn(id);

    final verifiedAtEpoch = w['verified_at'] as int?;
    return WordDetail(
      id: id,
      lemma: w['lemma']!.toString(),
      languageId: w['language_id']!.toString(),
      notes: w['notes']?.toString(),
      wordType: w['word_type']?.toString() ?? 'word',
      status: w['status']?.toString() ?? 'published',
      isVerified: (w['is_verified'] as int? ?? 0) == 1,
      isCorrected: (w['is_corrected'] as int? ?? 0) == 1,
      verifiedAt: verifiedAtEpoch == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              verifiedAtEpoch * 1000,
              isUtc: true,
            ).toIso8601String(),
      meanings: meanings,
      categories: categories,
      usageLabels: _parseUsageLabels(w['usage_labels']),
      pronunciations: pronunciations,
      audios: sortWordAudios(audios),
      images: images,
      relatedWords: related,
      appearsIn: appears,
      variants: variants,
    );
  }

  Future<List<WordMeaning>> _loadMeanings(String wordId) async {
    final rows = await _db.rawQuery(
      '''
      SELECT m.*, wc.code AS wc_code, wc.name AS wc_name, wc.alias AS wc_alias
      FROM meanings m
      LEFT JOIN word_classes wc ON wc.id = m.word_class_id
      WHERE m.word_id = ? AND m.status = 'published'
      ORDER BY m.order_index ASC, m.id ASC
      ''',
      [wordId],
    );
    final out = <WordMeaning>[];
    for (final m in rows) {
      final mid = m['id']!.toString();
      final translations = await _db.query(
        'meaning_translations',
        where: 'meaning_id = ?',
        whereArgs: [mid],
      );
      final examples = await _db.query(
        'examples',
        where: "meaning_id = ? AND status = 'published'",
        whereArgs: [mid],
      );
      final alias = m['wc_alias']?.toString();
      final wcName = m['wc_name']?.toString();
      final wordClassName = wcName == null
          ? null
          : (alias == null || alias.isEmpty)
          ? wcName
          : '$wcName ($alias)';
      out.add(
        WordMeaning(
          id: mid,
          wordClassId: m['word_class_id']?.toString(),
          wordClassCode: m['wc_code']?.toString(),
          wordClassName: wordClassName,
          definition: m['definition']?.toString(),
          orderIndex: (m['order_index'] as int?) ?? 0,
          translations: [
            for (final t in translations)
              WordTranslation(
                text: t['translation_text']!.toString(),
                type: t['translation_type']?.toString() ?? 'direct',
                languageId: t['language_id']?.toString(),
              ),
          ],
          examples: [
            for (final e in examples)
              WordExample(
                id: e['id']!.toString(),
                sourceSentence: e['source_sentence']!.toString(),
                targetSentence: e['target_sentence']?.toString(),
                audios: await _loadAudiosForExample(e['id']!.toString()),
              ),
          ],
        ),
      );
    }
    return out;
  }

  Future<List<WordCategory>> _loadCategories(String wordId) async {
    final rows = await _db.rawQuery(
      '''
      SELECT c.id, c.name
      FROM word_categories wc
      JOIN categories c ON c.id = wc.category_id
      WHERE wc.word_id = ?
      ORDER BY c.name ASC
      ''',
      [wordId],
    );
    return [
      for (final r in rows)
        WordCategory(id: r['id']!.toString(), name: r['name']!.toString()),
    ];
  }

  Future<List<WordPronunciation>> _loadPronunciations(String wordId) async {
    final rows = await _db.query(
      'pronunciations',
      where: "word_id = ? AND status = 'published'",
      whereArgs: [wordId],
    );
    return [
      for (final r in rows)
        WordPronunciation(
          notation: r['notation']?.toString() ?? 'ipa',
          value: r['value']!.toString(),
        ),
    ];
  }

  Future<List<WordAudio>> _loadAudios(String wordId) async {
    final rows = await _db.query(
      'word_audios',
      where: "word_id = ? AND status = 'published' AND example_id IS NULL",
      whereArgs: [wordId],
    );
    return _mapAudioRows(rows);
  }

  Future<List<WordAudio>> _loadAudiosForExample(String exampleId) async {
    final rows = await _db.query(
      'word_audios',
      where: "example_id = ? AND status = 'published'",
      whereArgs: [exampleId],
    );
    return _mapAudioRows(rows);
  }

  List<WordAudio> _mapAudioRows(List<Map<String, Object?>> rows) => [
        for (final r in rows)
          WordAudio(
            id: r['id']!.toString(),
            url: r['url']!.toString(),
            dialectId: r['dialect_id']?.toString(),
            speakerName: r['speaker_name']?.toString(),
            durationMs: r['duration_ms'] as int?,
            isPrimary: (r['is_primary'] as int? ?? 0) == 1,
            mimeType: r['mime_type']?.toString(),
            isVerified: (r['is_verified'] as int? ?? 0) == 1,
          ),
      ];

  Future<List<WordImage>> _loadImages(String wordId) async {
    final rows = await _db.query(
      'word_images',
      where: "word_id = ? AND status = 'published'",
      whereArgs: [wordId],
    );
    return [
      for (final r in rows)
        WordImage(
          id: r['id']!.toString(),
          url: r['url']!.toString(),
          altText: r['alt_text']?.toString(),
          isPrimary: (r['is_primary'] as int? ?? 0) == 1,
          isVerified: (r['is_verified'] as int? ?? 0) == 1,
          contentWarnings: _parseStringList(r['content_warnings']),
          attribution: ImageAttribution.fromJson(
            _tryJsonMap(r['attribution']),
          ),
        ),
    ];
  }

  Future<List<WordVariant>> _loadVariants(String wordId) async {
    final rows = await _db.query(
      'word_variants',
      where: 'word_id = ?',
      whereArgs: [wordId],
    );
    return [
      for (final r in rows)
        WordVariant(
          form: r['form']!.toString(),
          variantType: r['variant_type']?.toString() ?? 'alternative',
          affixType: r['affix_type']?.toString(),
          affixValue: r['affix_value']?.toString(),
          notes: r['notes']?.toString(),
        ),
    ];
  }

  Future<List<RelatedWord>> _loadRelated(String wordId) async {
    final rows = await _db.rawQuery(
      '''
      SELECT lr.relation_type, tw.id AS word_id, tw.lemma
      FROM lexical_relations lr
      JOIN words tw ON tw.id = lr.target_word_id
      WHERE lr.source_word_id = ?
        AND lr.status = 'published'
        AND tw.status = 'published'
      ''',
      [wordId],
    );
    return [
      for (final r in rows)
        RelatedWord(
          wordId: r['word_id']!.toString(),
          lemma: r['lemma']!.toString(),
          relationType: r['relation_type']!.toString(),
        ),
    ];
  }

  Future<List<RelatedWord>> _loadAppearsIn(String wordId) async {
    final rows = await _db.rawQuery(
      '''
      SELECT lr.relation_type, sw.id AS word_id, sw.lemma
      FROM lexical_relations lr
      JOIN words sw ON sw.id = lr.source_word_id
      WHERE lr.target_word_id = ?
        AND lr.status = 'published'
        AND sw.status = 'published'
      ''',
      [wordId],
    );
    return [
      for (final r in rows)
        RelatedWord(
          wordId: r['word_id']!.toString(),
          lemma: r['lemma']!.toString(),
          relationType: r['relation_type']!.toString(),
        ),
    ];
  }

  Future<String?> _senseForWord(String wordId) async {
    final rows = await _db.rawQuery(
      '''
      SELECT m.definition, mt.translation_text, wc.code AS wc_code
      FROM meanings m
      LEFT JOIN meaning_translations mt ON mt.meaning_id = m.id
      LEFT JOIN word_classes wc ON wc.id = m.word_class_id
      WHERE m.word_id = ? AND m.status = 'published'
      ORDER BY m.order_index ASC, m.id ASC
      LIMIT 6
      ''',
      [wordId],
    );
    if (rows.isEmpty) return null;
    final parts = <String>[];
    for (final r in rows) {
      final code = r['wc_code']?.toString();
      final gloss =
          (r['translation_text']?.toString().trim().isNotEmpty == true)
          ? r['translation_text']!.toString()
          : r['definition']?.toString();
      if (gloss == null || gloss.isEmpty) continue;
      parts.add(
        code == null || code.isEmpty ? gloss : '[${code.toLowerCase()}] $gloss',
      );
    }
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  List<String> _parseUsageLabels(Object? raw) {
    if (raw == null) return const [];
    if (raw is List) return knownUsageLabels(raw);
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        return knownUsageLabels(decoded);
      } catch (_) {
        return const [];
      }
    }
    return const [];
  }

  List<String> _parseStringList(Object? raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return [for (final e in raw) e.toString()];
    }
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return [for (final e in decoded) e.toString()];
        }
      } catch (_) {}
    }
    return const [];
  }

  Map<String, dynamic>? _tryJsonMap(Object? raw) {
    if (raw == null) return null;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return null;
  }
}
