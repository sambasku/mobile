import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/explore/domain/entities/place.dart';
import 'package:sambasku_mobile/features/explore/presentation/pages/place_detail_page.dart';
import 'package:sambasku_mobile/features/explore/presentation/providers/places_providers.dart';

Place _place(String id, String name, List<PlaceRelated> related) => Place(
  id: id,
  slug: id,
  name: name,
  category: PlaceCategory.wisata,
  type: PlaceType.sejarah,
  lat: 1.36,
  lng: 109.31,
  shortDescription: 'Deskripsi $name',
  images: const [],
  hours: '08.00 - 17.00',
  contact: null,
  related: related,
  sources: const [
    PlaceSource(
      name: 'Wikipedia - Istana Alwatzikoebillah yang namanya sengaja panjang',
      type: 'web',
      address: 'https://id.wikipedia.org/wiki/Istana_Alwatzikoebillah',
      license: 'CC BY-SA 3.0',
    ),
  ],
);

void main() {
  testWidgets('detail shows hero actions, info, related; bookmark toasts', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final places = [
      _place('istana', 'Istana Alwatzikoebillah', const [
        PlaceRelated(kind: PlaceRelatedKind.place, id: 'masjid'),
      ]),
      _place('masjid', 'Masjid Jami', const []),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [placesProvider.overrideWith((ref) async => places)],
        child: MaterialApp(
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: const FToaster(child: PlaceDetailPage(slug: 'istana')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Istana Alwatzikoebillah'), findsOneWidget);
    expect(find.text('Wisata'), findsOneWidget);
    expect(find.text('Sejarah'), findsNWidgets(2)); // badge + kartu terkait
    expect(find.text('08.00 - 17.00'), findsOneWidget);
    expect(find.byTooltip('Bagikan'), findsOneWidget);
    expect(find.text('Masjid Jami'), findsOneWidget);

    final source = find.textContaining('sengaja panjang').first;
    await tester.ensureVisible(source);
    expect(tester.getSize(source).height, lessThan(14 * 2));
    expect(find.text('CC BY-SA 3.0').first, findsOneWidget);

    await tester.tap(find.byTooltip('Bookmark'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Bookmark tempat belum bisa dipakai'), findsOneWidget);
  });
}
