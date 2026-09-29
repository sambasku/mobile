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
        'body': 'Mencari "kalintiak" - belum ada di kamus. Bantu isi.',
      'subtitle': null,
        'target': {'type': 'search_miss', 'id': '01'},
      });
      expect(item, isNotNull);
      expect(item!.actor, isNull);
      expect(item.kind, FeedActivityKind.searchMiss);
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
