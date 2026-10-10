import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/activity/data/map_feed_activity.dart';
import 'package:sambasku_mobile/features/activity/domain/entities/feed_activity_item.dart';

/// pinned_at parsing: valid, null, invalid string (hardening).
void main() {
  FeedAnnouncement mapAnn(Object ann) {
    final item = mapFeedActivityItem({
      'id': 'announcement:e1',
      'kind': 'announcement',
      'created_at': '2026-10-08T10:00:00Z',
      'body': 'Judul',
      'announcement': ann,
    });
    return item!.announcement!;
  }

  test('pinned_at valid terbaca sebagai DateTime', () {
    final ann = mapAnn({
      'id': 'a1',
      'title': 'T',
      'body': 'x',
      'pinned_at': '2026-10-08T09:00:00Z',
    });
    expect(ann.pinnedAt, DateTime.utc(2026, 10, 8, 9));
  });

  test('pinned_at null → null (tidak dipin)', () {
    final ann = mapAnn({
      'id': 'a2',
      'title': 'T',
      'body': 'x',
      'pinned_at': null,
    });
    expect(ann.pinnedAt, isNull);
  });

  test('pinned_at tanpa field → null (data lama)', () {
    final ann = mapAnn({'id': 'a3', 'title': 'T', 'body': 'x'});
    expect(ann.pinnedAt, isNull);
  });

  test('pinned_at string rusak → null, item tetap valid', () {
    final ann = mapAnn({
      'id': 'a4',
      'title': 'T',
      'body': 'x',
      'pinned_at': 'not-a-date',
    });
    expect(ann.pinnedAt, isNull);
    expect(ann.title, 'T');
  });

  test('pinned_at angka (epoch) tetap diparse via toString', () {
    final ann = mapAnn({
      'id': 'a5',
      'title': 'T',
      'body': 'x',
      'pinned_at': 1760000000,
    });
    // Epoch second tanpa satuan = dianggap local-time ISO oleh DateTime.parse.
    // Yang dijamin: tidak crash dan menghasilkan DateTime non-null.
    expect(ann.pinnedAt, isNotNull);
  });
}
