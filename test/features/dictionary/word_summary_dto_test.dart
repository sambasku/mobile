import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/dictionary/data/models/word_summary_dto.dart';

/// Snapshot fixture lokal.
void main() {
  Map<String, dynamic> loadFixture(String name) {
    final file = File('test/fixtures/json/word/$name');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  test('search-words.200.json → WordSummaryDto (lemma)', () {
    final json = loadFixture('search-words.200.json');
    final items = (json['data'] as List).cast<Map<String, dynamic>>();
    final dto = WordSummaryDto.fromJson(items.first);

    expect(dto.lemma, 'makatn');
    expect(dto.languageCode, 'SBS');
    expect(dto.wordType, 'word');
    expect(dto.status, 'published');
    expect(dto.isVerified, isTrue);
    expect(dto.matchedTranslation, isNull);
  });

  test('search-reverse.200.json → WordSummaryDto (translation relation)', () {
    final json = loadFixture('search-reverse.200.json');
    final items = (json['data'] as List).cast<Map<String, dynamic>>();
    final dto = WordSummaryDto.fromJson(items.first);

    expect(dto.lemma, 'makatn');
    expect(dto.matchedTranslation, 'makan');
    // label UI: "makan → makatn"
    expect('${dto.matchedTranslation} → ${dto.lemma}', 'makan → makatn');
  });

  // PRD relasi-lemma: penanda hasil perluasan kelompok makna.
  test('WordSummaryDto mem-parse match_type + matched_variant', () {
    final dto = WordSummaryDto.fromJson({
      'id': '01AAAAAAAAAAAAAAAAAAAAAAAA',
      'lemma': 'misai',
      'language_id': 'lang-1',
      'language_code': 'SBS',
      'word_type': 'word',
      'status': 'published',
      'is_verified': true,
      'match_type': 'related_group',
      'matched_variant': 'misay',
    });

    expect(dto.matchType, 'related_group');
    expect(dto.matchedVariant, 'misay');
  });

  test('payload lama tanpa match_type = null (hasil langsung)', () {
    final dto = WordSummaryDto.fromJson({
      'id': '01AAAAAAAAAAAAAAAAAAAAAAAA',
      'lemma': 'makatn',
      'language_id': 'lang-1',
      'language_code': 'SBS',
      'word_type': 'word',
      'status': 'published',
      'is_verified': true,
    });

    expect(dto.matchType, isNull);
    expect(dto.matchedVariant, isNull);
  });
}
