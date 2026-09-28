import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/contribution/domain/meaning_source.dart';

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
    expect(meaningSourceReviewLabel('kbbi'), 'Dari KBBI');
    expect(meaningSourceReviewLabel('kbbi_edited'), 'Dari KBBI (diubah)');
    expect(meaningSourceReviewLabel(null), 'Ketik manual');
  });
}
