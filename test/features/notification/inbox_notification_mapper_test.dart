import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:sambasku_mobile/features/notification/domain/entities/inbox_notification.dart';
import 'package:sambasku_mobile/features/notification/domain/failures/notification_failure.dart';

void main() {
  test('parseInboxNotification unread', () {
    final item = parseInboxNotification({
      'id': '01HNOTIF000000000000000001',
      'type': 'contribution_approved',
      'title': 'Usulan disetujui',
      'body': 'Usulan kata Anda telah disetujui dan dipublikasikan.',
      'target_kind': 'contribution',
      'target_id': '01HCONTRIBUTION00000000001',
      'read_at': null,
      'created_at': '2026-09-21T00:00:00.000Z',
    });

    expect(item.id, '01HNOTIF000000000000000001');
    expect(item.isUnread, isTrue);
    expect(item.typeLabel, 'Disetujui');
    expect(item.targetKind, 'contribution');
  });

  test('parseInboxNotification ditolak sudah dibaca', () {
    final item = parseInboxNotification({
      'id': '01HNOTIF000000000000000002',
      'type': 'suggestion_rejected',
      'title': 'Usulan perubahan ditolak',
      'body': 'Usulan perubahan kata Anda ditolak.',
      'target_kind': 'suggestion',
      'target_id': '01HSUGGESTION0000000000001',
      'read_at': '2026-09-21T02:00:00.000Z',
      'created_at': '2026-09-21T01:00:00.000Z',
    });

    expect(item.isUnread, isFalse);
    expect(item.typeLabel, 'Ditolak');
    expect(item.targetKind, 'suggestion');
  });

  test('typeLabel word_comment', () {
    const item = InboxNotification(
      id: '01H',
      type: 'word_comment',
      title: 'Komentar baru',
      body: 'John juga berkomentar di "rumah": Halo',
      targetKind: 'word',
      targetId: '01W',
      createdAt: '2026-09-21T00:00:00.000Z',
    );
    expect(item.typeLabel, 'Komentar');
  });

  test('typeLabel fallback', () {
    const item = InboxNotification(
      id: '01H',
      type: 'unknown',
      title: 'Judul',
      body: 'Isi',
      targetKind: 'contribution',
      targetId: '01C',
      createdAt: '2026-09-21T00:00:00.000Z',
    );
    expect(item.typeLabel, 'Pembaruan');
    expect(item.isUnread, isTrue);
  });

  test('NOTIFICATION_NOT_FOUND isNotFound', () {
    expect(
      NotificationFailure(
        'Notifikasi dengan id tersebut tidak ditemukan',
        errorCode: 'NOTIFICATION_NOT_FOUND',
      ).isNotFound,
      isTrue,
    );
    expect(
      NotificationFailure('Gagal memuat', errorCode: 'RATE_LIMITED').isNotFound,
      isFalse,
    );
  });
}
