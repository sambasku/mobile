import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/contribution/domain/meaning_source.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

void main() {
  group('resolveMeaningSource', () {
    const snap = KbbiMeaningSnapshot(
      padanan: 'makan',
      definition: 'memasukkan makanan ke mulut',
      wordClassId: 'wc1',
    );

    test('tanpa snapshot → manual', () {
      expect(
        resolveMeaningSource(
          snapshot: null,
          padanan: 'makan',
          definition: 'x',
          wordClassId: 'wc1',
        ),
        MeaningSource.manual,
      );
    });

    test('sama dengan snapshot → kbbi', () {
      expect(
        resolveMeaningSource(
          snapshot: snap,
          padanan: 'makan',
          definition: 'memasukkan makanan ke mulut',
          wordClassId: 'wc1',
        ),
        MeaningSource.kbbi,
      );
    });

    test('padanan dikosongkan, definisi tetap → kbbi_edited', () {
      expect(
        resolveMeaningSource(
          snapshot: snap,
          padanan: '',
          definition: 'memasukkan makanan ke mulut',
          wordClassId: 'wc1',
        ),
        MeaningSource.kbbiEdited,
      );
    });

    test('semua dikosongkan → manual', () {
      expect(
        resolveMeaningSource(
          snapshot: snap,
          padanan: '',
          definition: '-',
          wordClassId: null,
        ),
        MeaningSource.manual,
      );
    });

    test('kembalikan teks persis → kbbi', () {
      expect(
        resolveMeaningSource(
          snapshot: snap,
          padanan: ' makan ',
          definition: 'memasukkan makanan ke mulut',
          wordClassId: 'wc1',
        ),
        MeaningSource.kbbi,
      );
    });
  });

  test('meaningSourceReviewLabel', () {
    final l10n = lookupAppLocalizations(const Locale('id'));
    expect(
      meaningSourceReviewLabel(l10n, 'kbbi'),
      l10n.meaningSourceFromKbbi,
    );
    expect(
      meaningSourceReviewLabel(l10n, 'kbbi_edited'),
      l10n.meaningSourceFromKbbiEdited,
    );
    expect(
      meaningSourceReviewLabel(l10n, null),
      l10n.meaningSourceManual,
    );
  });
}
