import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/activity/data/map_feed_activity.dart';
import 'package:sambasku_mobile/features/activity/domain/entities/feed_activity_item.dart';

/// #124: bodyType eksplisit dari API wire announcement.
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

  test('bodyType html/md/webview terbaca dari wire', () {
    expect(
      mapAnn({
        'id': 'a1',
        'title': 'T',
        'body': 'x',
        'bodyType': 'html',
      }).bodyType,
      AnnouncementBodyType.html,
    );
    expect(
      mapAnn({
        'id': 'a2',
        'title': 'T',
        'body': 'x',
        'body_type': 'md',
      }).bodyType,
      AnnouncementBodyType.md,
    );
    expect(
      mapAnn({
        'id': 'a3',
        'title': 'T',
        'body': 'https://x',
        'bodyType': 'webview',
      }).bodyType,
      AnnouncementBodyType.webview,
    );
  });

  test('tanpa bodyType / tak dikenal = plain (data lama)', () {
    expect(
      mapAnn({'id': 'a4', 'title': 'T', 'body': 'x'}).bodyType,
      AnnouncementBodyType.plain,
    );
    expect(
      mapAnn({
        'id': 'a5',
        'title': 'T',
        'body': 'x',
        'bodyType': 'pdf',
      }).bodyType,
      AnnouncementBodyType.plain,
    );
  });
}
