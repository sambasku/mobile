import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';

void main() {
  test('firstSense pakai definition, fallback terjemahan', () {
    final withDef = WordOfDay(
      date: '2026-09-21',
      isNewThisWeek: false,
      word: WordDetail(
        id: 'A' * 26,
        lemma: 'makatn',
        languageId: 'L' * 26,
        wordType: 'word',
        status: 'published',
        isVerified: true,
        isCorrected: false,
        meanings: [
          WordMeaning(
            id: 'M' * 26,
            orderIndex: 1,
            definition: 'Aktivitas memasukkan makanan ke mulut',
            translations: [WordTranslation(text: 'makan', type: 'direct')],
          ),
        ],
      ),
    );
    expect(withDef.firstSense, 'Aktivitas memasukkan makanan ke mulut');
    expect(withDef.firstDefinition, 'Aktivitas memasukkan makanan ke mulut');
    expect(withDef.firstTranslation, 'makan');

    final fallback = WordOfDay(
      date: '2026-09-21',
      isNewThisWeek: true,
      word: WordDetail(
        id: 'A' * 26,
        lemma: 'makatn',
        languageId: 'L' * 26,
        wordType: 'word',
        status: 'published',
        isVerified: true,
        isCorrected: false,
        meanings: [
          WordMeaning(
            id: 'M' * 26,
            orderIndex: 1,
            translations: [WordTranslation(text: 'makan', type: 'direct')],
          ),
        ],
      ),
    );
    expect(fallback.firstSense, 'makan');
    expect(fallback.firstDefinition, '');
    expect(fallback.firstTranslation, 'makan');
    expect(fallback.isNewThisWeek, isTrue);
  });
}
