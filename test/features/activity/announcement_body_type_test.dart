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

  test('#134 stripMarkdownHtml: __bold__, _it_, ~~del~~, quote, hr', () {
    expect(stripMarkdownHtml('__tebal__'), 'tebal');
    expect(stripMarkdownHtml('_miring_'), 'miring');
    expect(stripMarkdownHtml('~~hapus~~'), 'hapus');
    expect(
      stripMarkdownHtml('> kutipan\nbiasa'),
      'kutipan\nbiasa',
    );
    expect(stripMarkdownHtml('atas\n---\nbawah'), 'atas\nbawah');
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

  test('wrapImagesInHtml bungkus <img> jadi tautan internal agar tap dicegat', () {
    // Tap gambar -> skema internal, dicegat navigation delegate tanpa JS.
    expect(
      wrapImagesInHtml('<p><img src="https://x.com/a.png"></p>'),
      '<p><a href="sambasku-image:https%3A%2F%2Fx.com%2Fa.png">'
      '<img src="https://x.com/a.png"></a></p>',
    );
    // Atribut lain (width/alt) dipertahankan; src kutip tunggal juga.
    expect(
      wrapImagesInHtml("<img alt='foto' src='https://x.com/b.jpg' width='10'>"),
      "<a href=\"sambasku-image:https%3A%2F%2Fx.com%2Fb.jpg\">"
      "<img alt='foto' src='https://x.com/b.jpg' width='10'></a>",
    );
    // Tanpa <img> -> tak berubah.
    expect(wrapImagesInHtml('<p>halo</p>'), '<p>halo</p>');
    // <img> tanpa src -> dibiarkan (tak bisa di-preview).
    expect(wrapImagesInHtml('<img alt="x">'), '<img alt="x">');
  });
}