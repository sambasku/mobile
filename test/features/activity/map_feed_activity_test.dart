import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/activity/data/map_feed_activity.dart';
import 'package:sambasku_mobile/features/activity/domain/entities/feed_activity_item.dart';

void main() {
  group('mapFeedActivityItem', () {
    test('map comment dengan actor', () {
      final item = mapFeedActivityItem({
        'id': 'comment:01',
        'kind': 'comment',
        'created_at': '2026-09-28T12:00:00.000Z',
        'actor': {
          'username': 'budi',
          'display_name': 'Budi',
          'avatar_url': null,
        },
        'body': 'halo',
        'subtitle': 'lading',
        'target': {'type': 'word', 'id': '01w'},
      });
      expect(item, isNotNull);
      expect(item!.kind, FeedActivityKind.comment);
      expect(item.actor?.username, 'budi');
      expect(item.target?.id, '01w');
    });

    test('search_miss actor null', () {
      final item = mapFeedActivityItem({
        'id': 'search_miss:01',
        'kind': 'search_miss',
        'created_at': '2026-09-28T12:00:00.000Z',
        'actor': null,
        'body': 'Mencari "kalintiak" - belum ada di kamus.',
        'subtitle': null,
        'target': {'type': 'search_miss', 'id': '01'},
      });
      expect(item, isNotNull);
      expect(item!.actor, isNull);
      expect(item.kind, FeedActivityKind.searchMiss);
    });

    test('card_share dan suggestion dikenali', () {
      expect(parseFeedActivityKind('card_share'), FeedActivityKind.cardShare);
      expect(parseFeedActivityKind('suggestion'), FeedActivityKind.suggestion);
    });

    test('kind tidak dikenal diabaikan', () {
      expect(
        mapFeedActivityItem({
          'id': 'x:1',
          'kind': 'unknown',
          'created_at': '',
          'body': '',
        }),
        isNull,
      );
    });

    test(
      'created_at mustahil (epoch ms) dibuang, bukan dirender "baru" (#47)',
      () {
        // Bentuk yang sempat ada di produksi: kolom `mode: 'timestamp'` diisi
        // epoch milidetik lalu dibaca sebagai detik -> tahun 50.000-an.
        final corrupt = mapFeedActivityItem({
          'id': 'word:01',
          'kind': 'word',
          'created_at': '+058716-09-15T00:00:00.000Z',
          'actor': {'username': 'a', 'display_name': 'A', 'avatar_url': null},
          'body': 'pengimpor_data_csv',
          'subtitle': 'Kata baru',
          'target': {'type': 'word', 'id': '01'},
        });
        expect(corrupt, isNull);

        // created_at tidak bisa diparse / kosong juga dibuang.
        expect(
          mapFeedActivityItem({
            'id': 'word:02',
            'kind': 'word',
            'created_at': 'bukan-tanggal',
            'body': 'x',
          }),
          isNull,
        );
        expect(
          mapFeedActivityItem({'id': 'word:03', 'kind': 'word', 'body': 'x'}),
          isNull,
        );
      },
    );

    test('map list membuang hanya baris korup, sisanya tetap urut', () {
      final items = mapFeedActivityList([
        {
          'id': 'word:1',
          'kind': 'word',
          'created_at': '2026-09-28T12:00:00.000Z',
          'actor': {'username': 'a', 'display_name': 'A', 'avatar_url': null},
          'body': 'sah',
          'subtitle': null,
          'target': {'type': 'word', 'id': '1'},
        },
        {
          'id': 'word:2',
          'kind': 'word',
          'created_at': '+058716-09-15T00:00:00.000Z',
          'actor': {'username': 'b', 'display_name': 'B', 'avatar_url': null},
          'body': 'korup',
          'subtitle': null,
          'target': {'type': 'word', 'id': '2'},
        },
        {
          'id': 'word:3',
          'kind': 'word',
          'created_at': '2026-09-27T12:00:00.000Z',
          'actor': {'username': 'c', 'display_name': 'C', 'avatar_url': null},
          'body': 'sah juga',
          'subtitle': null,
          'target': {'type': 'word', 'id': '3'},
        },
      ]);

      expect(items.map((i) => i.id), ['word:1', 'word:3']);
    });

    test('map list', () {
      final items = mapFeedActivityList([
        {
          'id': 'vote:1',
          'kind': 'vote',
          'created_at': '2026-09-28T12:00:00.000Z',
          'actor': {'username': 'a', 'display_name': 'A', 'avatar_url': null},
          'body': 'Vote naik · x',
          'subtitle': 'word',
          'target': {'type': 'word', 'id': 'w'},
        },
        {'id': 'bad', 'kind': 'nope', 'body': ''},
      ]);
      expect(items, hasLength(1));
      expect(items.first.kind, FeedActivityKind.vote);
    });

    test('parse kind verification (#99: verifikasi != vote)', () {
      final item = mapFeedActivityItem({
        'id': 'verification:01ACTVER000000000000000001',
        'kind': 'verification',
        'created_at': '2026-10-07T10:00:00.000Z',
        'body': 'Memverifikasi kata',
        'actor': {
          'username': 'reviewer1',
          'display_name': 'Reviewer Satu',
          'avatar_url': null,
        },
      });
      expect(item, isNotNull);
      expect(item!.kind, FeedActivityKind.verification);
      expect(item.body, 'Memverifikasi kata');
    });

    test('parse kind vote_up / vote_down (#99: arah vote terpisah)', () {
      final up = mapFeedActivityItem({
        'id': 'vote_up:01ACTVUP00000000000000001',
        'kind': 'vote_up',
        'created_at': '2026-10-07T11:00:00.000Z',
        'body': '"kumis" sudah pas',
        'actor': {'username': 'a', 'display_name': 'A', 'avatar_url': null},
      });
      expect(up!.kind, FeedActivityKind.voteUp);

      final down = mapFeedActivityItem({
        'id': 'vote_down:01ACTVDN00000000000000001',
        'kind': 'vote_down',
        'created_at': '2026-10-07T11:00:00.000Z',
        'body': '"kumis" perlu dicek ulang',
        'actor': {'username': 'a', 'display_name': 'A', 'avatar_url': null},
      });
      expect(down!.kind, FeedActivityKind.voteDown);
    });
  });

  group('mapFeedActivityItem announcement (#102)', () {
    test('payload announcement terparse penuh', () {
      final item = mapFeedActivityItem({
        'id': 'announcement:01ANNC0000000000000000001',
        'kind': 'announcement',
        'created_at': '2026-10-07T11:00:00.000Z',
        'actor': {
          'username': 'admin',
          'display_name': 'Admin SambasKu',
          'avatar_url': null,
        },
        'body': 'Pengumuman',
        'subtitle': null,
        'target': {'type': 'announcement', 'id': '01ANNC0000000000000000001'},
        'announcement': {
          'id': '01ANNC0000000000000000001',
          'title': 'Kamus baru rilis',
          'body': 'Update v0.3 minggu ini.',
          'action_url': 'https://sambasku.com/blog/rilis',
          'action_label': 'Baca rilis',
          'expired': false,
        },
      });
      expect(item, isNotNull);
      expect(item!.kind, FeedActivityKind.announcement);
      expect(item.target?.type, 'announcement');
      expect(item.announcement, isNotNull);
      expect(item.announcement!.title, 'Kamus baru rilis');
      expect(item.announcement!.actionUrl, 'https://sambasku.com/blog/rilis');
      expect(item.announcement!.actionLabel, 'Baca rilis');
      expect(item.announcement!.expired, isFalse);
    });

    test('expired true + action kosong', () {
      final item = mapFeedActivityItem({
        'id': 'announcement:01ANNC0000000000000000002',
        'kind': 'announcement',
        'created_at': '2026-10-07T11:00:00.000Z',
        'actor': null,
        'body': 'Pengumuman',
        'target': {'type': 'announcement', 'id': '01ANNC0000000000000000002'},
        'announcement': {
          'id': '01ANNC0000000000000000002',
          'title': 'Maintenance',
          'body': 'Server maintenance besok.',
          'action_url': null,
          'action_label': null,
          'expired': true,
        },
      });
      expect(item, isNotNull);
      expect(item!.announcement!.expired, isTrue);
      expect(item.announcement!.actionUrl, isNull);
      expect(item.announcement!.actionLabel, isNull);
    });

    test('kind lain abaikan field announcement', () {
      final item = mapFeedActivityItem({
        'id': 'word:01WORD00000000000000000001',
        'kind': 'word',
        'created_at': '2026-10-07T11:00:00.000Z',
        'actor': null,
        'body': '"kumis"',
        'target': {'type': 'word', 'id': '01WORD00000000000000000001'},
        'announcement': {
          'id': '01ANNC0000000000000000003',
          'title': 'Hantu',
          'body': 'Tidak boleh nempel.',
          'expired': false,
        },
      });
      expect(item, isNotNull);
      expect(item!.announcement, isNull);
    });

    test('announcement tanpa payload tetap tayang tanpa crash', () {
      final item = mapFeedActivityItem({
        'id': 'announcement:01ANNC0000000000000000004',
        'kind': 'announcement',
        'created_at': '2026-10-07T11:00:00.000Z',
        'actor': null,
        'body': 'Pengumuman',
        'target': {'type': 'announcement', 'id': '01ANNC0000000000000000004'},
      });
      expect(item, isNotNull);
      expect(item!.announcement, isNull);
    });
  });
}
