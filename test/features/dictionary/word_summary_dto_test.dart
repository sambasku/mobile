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
}
