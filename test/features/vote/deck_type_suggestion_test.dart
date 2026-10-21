import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/vote/domain/deck_type_suggestion.dart';

void main() {
  test('tanpa perubahan mengembalikan null', () {
    final proposal = buildDeckTypeProposal(
      currentWordType: 'word',
      nextWordType: 'word',
      classes: const [
        DeckClassPick(
          meaningId: 'm1',
          currentClassId: 'umum',
          nextClassId: 'umum',
          isUmum: true,
        ),
      ],
    );
    expect(proposal, isNull);
  });

  test('hanya jenis yang berubah', () {
    final proposal = buildDeckTypeProposal(
      currentWordType: 'word',
      nextWordType: 'ungkapan',
      classes: const [
        DeckClassPick(
          meaningId: 'm1',
          currentClassId: 'umum',
          nextClassId: 'umum',
          isUmum: true,
        ),
        DeckClassPick(
          meaningId: 'm2',
          currentClassId: 'n',
          nextClassId: 'v',
          isUmum: false,
        ),
      ],
    );
    expect(proposal, {
      'word_type': 'ungkapan',
      'meanings': [
        {'action': 'update', 'meaning_id': 'm2', 'word_class_id': 'v'},
      ],
    });
  });

  test('hanya kelas Umum yang berubah', () {
    final proposal = buildDeckTypeProposal(
      currentWordType: 'idiom',
      nextWordType: 'idiom',
      classes: const [
        DeckClassPick(
          meaningId: 'm1',
          currentClassId: 'umum',
          nextClassId: 'n',
          isUmum: true,
        ),
      ],
    );
    expect(proposal, {
      'meanings': [
        {'action': 'update', 'meaning_id': 'm1', 'word_class_id': 'n'},
      ],
    });
  });
}
