import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/activity/data/map_feed_activity.dart';
import 'package:sambasku_mobile/features/activity/domain/entities/feed_activity_item.dart';
import 'package:sambasku_mobile/features/activity/presentation/widgets/announcement_body.dart';

/// #124: bodyType eksplisit dari API wire announcement.
/// #134: normalisasi URL webview + preview ringan (strip md/html).
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

  test('#134 stripMarkdownHtml buang markup md/html ringan', () {
    expect(
      stripMarkdownHtml('## Judul\n\n**tebal** dan *miring*'),
      'Judul\ntebal dan miring',
    );
    expect(stripMarkdownHtml('<h1>Halo</h1> <p>dunia</p>'), 'Halo dunia');
    expect(
      stripMarkdownHtml('[tautan](https://x.com) biasa'),
      'tautan biasa',
    );
    // plain text tak tersentuh.
    expect(stripMarkdownHtml('biasa saja'), 'biasa saja');
  });

  test('#134 preview: webview URL -> host, host tanpa skema dinormalisasi', () {
    expect(
      announcementPreviewText(
        'sambasku.com/pengumuman/1',
        AnnouncementBodyType.webview,
      ),
      'sambasku.com',
    );
    expect(
      announcementPreviewText(
        'https://example.com/panjang/sekali/jalan',
        AnnouncementBodyType.webview,
      ),
      'example.com',
    );
    // Body HTML di tipe webview (bukan URL) -> strip markup.
    expect(
      announcementPreviewText('<h1>Halo</h1>', AnnouncementBodyType.webview),
      'Halo',
    );
    // Plain tak tersentuh.
    expect(
      announcementPreviewText('teks biasa', AnnouncementBodyType.plain),
      'teks biasa',
    );
  });
}