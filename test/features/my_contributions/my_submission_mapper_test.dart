import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/my_contributions/data/repositories/my_contribution_repository_impl.dart';
import 'package:sambasku_mobile/features/my_contributions/domain/entities/my_submission.dart';
import 'package:sambasku_mobile/features/my_contributions/domain/failures/my_contribution_failure.dart';
import 'package:sambasku_mobile/features/my_contributions/presentation/my_contribution_labels.dart';
import 'package:sambasku_mobile/l10n/app_localizations_id.dart';

void main() {
  final l10n = AppLocalizationsId();

  test('parseMySubmission list item contribution', () {
    final item = parseMySubmission({
      'id': '01HCONTRIBUTION00000000001',
      'kind': 'contribution',
      'entity_type': 'word',
      'lemma': 'makatn',
      'status': 'pending',
      'created_at': '2026-09-21T00:00:00.000Z',
      'review_comment': null,
      'word_id': '01HCONTRIBUTION00000000001',
      'action': 'create',
      'reason': null,
      'reason_code': null,
      'reviewed_at': null,
    });

    expect(item.id, '01HCONTRIBUTION00000000001');
    expect(item.kind, 'contribution');
    expect(item.entityType, 'word');
    expect(item.lemma, 'makatn');
    expect(mySubmissionTitle(l10n, item), 'makatn');
    expect(mySubmissionKindLabel(l10n, item.entityType), 'Usul kata baru');
    expect(mySubmissionStatusLabel(l10n, item.status), 'Menunggu pengecekan');
    // Kata logged-in langsung tayang → word_id ada, bisa dibuka meski pending.
    expect(item.canOpenWord, isTrue);
    expect(item.isSuggestion, isFalse);
    expect(
      mySubmissionSubtitle(l10n, item, '21 Sep 2026 07:00'),
      'Usul kata baru · Menunggu pengecekan · 21 Sep 2026 07:00',
    );
  });

  test('parseMySubmission suggestion ditolak + cuplikan catatan', () {
    final item = parseMySubmission({
      'id': '01HSUGGESTION0000000000001',
      'kind': 'suggestion',
      'entity_type': 'word_suggestion',
      'lemma': 'makatn',
      'status': 'rejected',
      'created_at': '2026-09-21T01:00:00.000Z',
      'review_comment':
          'Definisi masih terlalu umum dan tidak menyebut konteks pemakaian di Sambas.',
      'word_id': '01JDWORDMAKATN000000000000',
      'action': null,
      'reason': 'Definisi kurang tepat',
      'reason_code': 'inaccurate_definition',
      'reviewed_at': '2026-09-21T02:00:00.000Z',
    });

    expect(item.isSuggestion, isTrue);
    expect(mySubmissionKindLabel(l10n, item.entityType), 'Usul perubahan');
    expect(mySubmissionStatusLabel(l10n, item.status), 'Ditolak');
    expect(item.canOpenWord, isTrue);
    expect(item.reasonCode, 'inaccurate_definition');
    expect(
      mySubmissionSubtitle(l10n, item, '21 Sep 2026 08:00'),
      'Usul perubahan · Ditolak · 21 Sep 2026 08:00 · '
      'Definisi masih terlalu umum dan tidak menyebut konteks pemak...',
    );
  });

  test('lemma kosong fallback ke label jenis', () {
    const item = MySubmission(
      id: '01H',
      kind: 'contribution',
      entityType: 'meaning',
      status: 'approved',
      createdAt: '2026-09-21T00:00:00.000Z',
      wordId: '01JDWORD',
    );
    expect(mySubmissionTitle(l10n, item), 'Usul makna');
    expect(mySubmissionStatusLabel(l10n, item.status), 'Disetujui');
    expect(item.canOpenWord, isTrue);
  });

  test('ownership 404: CONTRIBUTION_NOT_FOUND dan SUGGESTION_NOT_FOUND', () {
    expect(
      MyContributionFailure(
        'Usulan tidak ditemukan',
        errorCode: 'CONTRIBUTION_NOT_FOUND',
      ).isNotFound,
      isTrue,
    );
    expect(
      MyContributionFailure(
        'Usulan tidak ditemukan',
        errorCode: 'SUGGESTION_NOT_FOUND',
      ).isNotFound,
      isTrue,
    );
    expect(
      MyContributionFailure(
        'Gagal memuat',
        errorCode: 'RATE_LIMITED',
      ).isNotFound,
      isFalse,
    );
  });

  test('halaman kosong: list tanpa item tetap valid', () {
    final page = parseMySubmission({
      'id': '01H',
      'kind': 'contribution',
      'entity_type': 'word',
      'status': 'pending',
      'created_at': '',
    });
    expect(mySubmissionTitle(l10n, page), 'Usul kata baru');
    expect(const <MySubmission>[].isEmpty, isTrue);
  });
}
