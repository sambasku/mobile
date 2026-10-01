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

    test('created_at mustahil (epoch ms) dibuang, bukan dirender "baru" (#47)', () {
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
    });

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
  });
}
