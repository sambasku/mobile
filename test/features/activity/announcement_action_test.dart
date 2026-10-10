import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/activity/domain/entities/feed_activity_item.dart';
import 'package:sambasku_mobile/features/activity/presentation/pages/announcement_detail_page.dart';

void main() {
  test('#124: actionUrl host sambasku -> isSambaskuDeepLink true', () {
    final page = AnnouncementDetailPage(
      announcement: FeedAnnouncement(
        id: 'a1',
        title: 'T',
        body: 'B',
        actionUrl: 'https://sambasku.com/blog/rilis',
        actionLabel: null,
        expired: false,
      ),
    );
    expect(page.isInAppDeepLink, isTrue);
  });

  test('#124: actionUrl host eksternal -> isInAppDeepLink false', () {
    final page = AnnouncementDetailPage(
      announcement: FeedAnnouncement(
        id: 'a2',
        title: 'T',
        body: 'B',
        actionUrl: 'https://example.com/x',
        actionLabel: null,
        expired: false,
      ),
    );
    expect(page.isInAppDeepLink, isFalse);
  });

  test('#124: tanpa actionUrl -> isInAppDeepLink false', () {
    final page = AnnouncementDetailPage(
      announcement: FeedAnnouncement(
        id: 'a3',
        title: 'T',
        body: 'B',
        actionUrl: null,
        actionLabel: null,
        expired: false,
      ),
    );
    expect(page.isInAppDeepLink, isFalse);
  });
}
