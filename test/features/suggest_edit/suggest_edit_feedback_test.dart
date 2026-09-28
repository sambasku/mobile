import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/suggest_edit/domain/suggest_edit_feedback.dart';

void main() {
  group('suggestEditEntryTileCopy', () {
    test('verifikator: ubah kata tanpa antrean', () {
      for (final role in ['admin', 'editor', 'root', 'reviewer']) {
        final copy = suggestEditEntryTileCopy(role);
        expect(copy.title, 'Ubah kata');
        expect(copy.subtitle, contains('langsung diterapkan'));
        expect(copy.subtitle, isNot(contains('persetujuan')));
      }
    });

    test('kontributor / null: usulkan + menunggu persetujuan', () {
      for (final role in ['contributor', null]) {
        final copy = suggestEditEntryTileCopy(role);
        expect(copy.title, 'Usulkan perubahan');
        expect(copy.subtitle, contains('menunggu persetujuan'));
      }
    });
  });

  group('suggestEditReasonLabels', () {
    test('verifikator: alasan perubahan', () {
      final labels = suggestEditReasonLabels('admin');
      expect(labels.fieldCaption, 'Alasan perubahan *');
      expect(labels.sheetTitle, 'Pilih alasan perubahan');
    });

    test('kontributor: alasan usulan', () {
      final labels = suggestEditReasonLabels('contributor');
      expect(labels.fieldCaption, 'Alasan usulan *');
      expect(labels.sheetTitle, 'Pilih alasan usulan');
    });
  });

  group('suggestEditPreSubmitCopy', () {
    test('verifikator: banner self-apply + CTA simpan', () {
      for (final role in ['admin', 'editor', 'root', 'reviewer']) {
        final copy = suggestEditPreSubmitCopy(role);
        expect(copy.cta, 'Simpan perubahan');
        expect(copy.ctaBusy, 'Menyimpan...');
        expect(copy.banner, contains('langsung diterapkan'));
        expect(copy.banner, isNot(contains('mereview')));
      }
    });

    test('kontributor: banner antrean + CTA kirim usulan', () {
      final copy = suggestEditPreSubmitCopy('contributor');
      expect(copy.cta, 'Kirim Usulan');
      expect(copy.ctaBusy, 'Mengirim...');
      expect(copy.banner, contains('mereview sebelum tayang'));
    });
  });

  group('suggestEditWasSelfApplied', () {
    test('status approved menang atas role contributor', () {
      expect(
        suggestEditWasSelfApplied(
          responseStatus: 'approved',
          actorRole: 'contributor',
        ),
        isTrue,
      );
    });

    test('status pending menang atas role admin', () {
      expect(
        suggestEditWasSelfApplied(
          responseStatus: 'pending',
          actorRole: 'admin',
        ),
        isFalse,
      );
    });

    test('tanpa status: fallback role verifikator', () {
      expect(
        suggestEditWasSelfApplied(
          responseStatus: null,
          actorRole: 'reviewer',
        ),
        isTrue,
      );
      expect(
        suggestEditWasSelfApplied(
          responseStatus: null,
          actorRole: 'contributor',
        ),
        isFalse,
      );
    });
  });

  group('suggestEditSuccessToast', () {
    test('self-applied', () {
      expect(
        suggestEditSuccessToast(
          selfApplied: true,
          wordVerified: true,
          lemma: 'kete',
        ),
        'Perubahan langsung diterapkan pada "kete".',
      );
    });

    test('pending pada kata verified', () {
      expect(
        suggestEditSuccessToast(
          selfApplied: false,
          wordVerified: true,
          lemma: 'kete',
        ),
        contains('masuk antrean'),
      );
    });

    test('pending pada kata belum verified', () {
      expect(
        suggestEditSuccessToast(
          selfApplied: false,
          wordVerified: false,
          lemma: 'kete',
        ),
        contains('menunggu pengecekan'),
      );
    });
  });

  group('suggestEditStatusFromResponse', () {
    test('ambil status dari envelope', () {
      expect(
        suggestEditStatusFromResponse({
          'success': true,
          'data': {'status': 'approved', 'suggestion_id': '01H'},
        }),
        'approved',
      );
    });

    test('body rusak → null', () {
      expect(suggestEditStatusFromResponse(null), isNull);
      expect(suggestEditStatusFromResponse({'data': 'x'}), isNull);
    });
  });
}
