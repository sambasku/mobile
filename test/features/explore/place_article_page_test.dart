import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/explore/data/place_markdown/place_markdown_repository.dart';
import 'package:sambasku_mobile/features/explore/presentation/pages/place_article_page.dart';

void main() {
  testWidgets('artikel panjang tidak overflow - wajib scrollable (#168)', (
    tester,
  ) async {
    // MarkdownBody = Column tak terbatas; tanpa scroll wrapper artikel panjang
    // bikin "RenderFlex overflowed" di layar kecil. Setelah #168 path sudah
    // benar, tapi halaman harus tetap scrollable kalau isi panjang.
    final longMarkdown = List.generate(
      60,
      (i) => 'Paragraf $i lorem ipsum dolor sit amet consectetur.',
    ).join('\n\n');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placeMarkdownProvider.overrideWith((ref, slug) async => longMarkdown),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: PlaceArticlePage(slug: 'istana'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Setiap exception layout ter-leak ke root widget tree.
    expect(tester.takeException(), isNull);
    // Scroll wrapper wajib ada agar MarkdownBody (Column tak berbatas)
    // tidak overflow.
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}