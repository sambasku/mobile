import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/dictionary/application/word_clipboard.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';

void main() {
  const meaning1 = WordMeaning(
    id: 'm1',
    orderIndex: 1,
    wordClassCode: 'n',
    definition: 'bulu di atas bibir',
    translations: [WordTranslation(text: 'kumis', type: 'direct')],
    examples: [
      WordExample(
        id: 'e1',
        sourceSentence: 'sometmu yo cukor',
        targetSentence: 'kumismu itu cukur',
      ),
    ],
  );

  test('buildWordClipboardText menyusun lemma, makna, dan contoh', () {
    const detail = WordDetail(
      id: 'w1',
      lemma: 'somet',
      languageId: 'sbs',
      wordType: 'word',
      status: 'published',
      isVerified: true,
      isCorrected: false,
      meanings: [
        meaning1,
        WordMeaning(
          id: 'm2',
          orderIndex: 2,
          wordClassCode: 'v',
          definition: 'dimarahi',
        ),
      ],
      variants: [WordVariant(form: 'sumet', variantType: 'alternative')],
    );

    final text = buildWordClipboardText(detail);
    expect(text, startsWith('somet\nsumet'));
    expect(text, contains('1 [n] → kumis'));
    expect(text, contains('bulu di atas bibir'));
    expect(text, contains('"sometmu yo cukor"'));
    expect(text, contains('2 [v]\ndimarahi'));
    expect(text, endsWith('#SambasKu'));
  });

  test('buildWordMeaningClipboardText hanya satu makna + lemma', () {
    final text = buildWordMeaningClipboardText(
      lemma: 'somet',
      meaning: meaning1,
    );
    expect(text, startsWith('somet\n[n] → kumis'));
    expect(text, contains('bulu di atas bibir'));
    expect(text, contains('"sometmu yo cukor"'));
    expect(text, isNot(contains('dimarahi')));
    expect(text, endsWith('#SambasKu'));
  });
}
