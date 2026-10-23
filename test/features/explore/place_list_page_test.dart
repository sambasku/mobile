import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/explore/domain/entities/place.dart';
import 'package:sambasku_mobile/features/explore/presentation/pages/place_list_page.dart';
import 'package:sambasku_mobile/features/explore/presentation/providers/places_browse_providers.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';

Place _place(String name, PlaceCategory category, PlaceType? type) => Place(
  id: name,
  slug: name.toLowerCase().replaceAll(' ', '-'),
  name: name,
  category: category,
  type: type,
  lat: 0,
  lng: 0,
  shortDescription: 'Deskripsi $name',
  images: const [],
  hours: null,
  contact: null,
  related: const [],
  sources: const [],
);

final _places = [
  _place('Pantai Temajuk', PlaceCategory.wisata, PlaceType.pantai),
  _place('Istana Alwatzikoebillah', PlaceCategory.wisata, PlaceType.sejarah),
  _place('Bubur Pedas', PlaceCategory.kuliner, null),
];

List<Place> _visible(PlacesBrowseQuery query) {
  final q = query.q.toLowerCase();
  return [
    for (final place in _places)
      if (place.category == query.category &&
          (query.type == null || place.type == query.type) &&
          (q.isEmpty || place.name.toLowerCase().contains(q)))
        place,
  ];
}

class _StaticBrowse extends PlacesBrowse {
  _StaticBrowse(super.query);

  @override
  Future<PlacesBrowseState> build() async =>
      PlacesBrowseState(items: _visible(query));
}

class _HangBrowse extends PlacesBrowse {
  _HangBrowse(super.query);

  @override
  Future<PlacesBrowseState> build() async {
    await Completer<void>().future;
    return const PlacesBrowseState();
  }
}

class _RefreshBrowse extends PlacesBrowse {
  _RefreshBrowse(super.query, this.onReload, this.gate);

  final void Function() onReload;
  final Future<void> gate;

  @override
  Future<PlacesBrowseState> build() async =>
      PlacesBrowseState(items: _visible(query));

  @override
  Future<void> reload({bool keepItems = false}) async {
    onReload();
    await gate;
  }
}

class _PageBrowse extends PlacesBrowse {
  _PageBrowse(super.query, this.onLoad);

  final void Function() onLoad;

  @override
  Future<PlacesBrowseState> build() async => PlacesBrowseState(
    items: [_places.first],
    nextCursor: 'cursor-1',
    hasMore: true,
  );

  @override
  Future<void> loadMore() async {
    onLoad();
    final current = state.value!;
    state = AsyncData(
      current.copyWith(
        items: [...current.items, _places[1]],
        hasMore: false,
        clearCursor: true,
        isLoadingMore: false,
      ),
    );
  }
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        placesBrowseProvider.overrideWith2((query) => _StaticBrowse(query)),
      ],
      child: MaterialApp(
        home: FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: const FToaster(
            child: PlaceListPage(mode: PlacePageMode.wisata),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mode wisata loading memakai grid 3 kolom', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placesBrowseProvider.overrideWith2((query) => _HangBrowse(query)),
        ],
        child: MaterialApp(
          home: FTheme(
            data: foruiPalettes['zinc']!.light.touch,
            child: const FToaster(
              child: PlaceListPage(mode: PlacePageMode.wisata),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tap bookmark shows coming-soon toast', (tester) async {
    await _pump(tester);

    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(
      tester.getTopLeft(find.byIcon(FLucideIcons.bookmark).first).dy,
      lessThan(tester.getTopLeft(find.text('Pantai Temajuk')).dy),
      reason: 'ikon bookmark menempel di foto, di atas nama',
    );

    await tester.tap(find.byTooltip('Bookmark').first);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Bookmark tempat belum bisa dipakai'), findsOneWidget);
  });

  testWidgets('chip and search filter the list', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(EditableText), 'istana');
    await tester.pumpAndSettle();
    expect(find.text('Istana Alwatzikoebillah'), findsOneWidget);
    expect(find.text('Pantai Temajuk'), findsNothing);

    await tester.enterText(find.byType(EditableText), '');
    await tester.pumpAndSettle();
    final kulinerChip = find
        .descendant(of: find.byType(FBadge), matching: find.text('Kuliner'))
        .first;
    await tester.ensureVisible(kulinerChip);
    await tester.pumpAndSettle();
    await tester.tap(kulinerChip);
    await tester.pumpAndSettle();
    expect(find.text('Bubur Pedas'), findsOneWidget);
    expect(find.text('Pantai Temajuk'), findsNothing);
  });

  testWidgets('mode kuliner: tanpa chip, hanya entri kuliner', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placesBrowseProvider.overrideWith2((query) => _StaticBrowse(query)),
        ],
        child: MaterialApp(
          home: FTheme(
            data: foruiPalettes['zinc']!.light.touch,
            child: const FToaster(
              child: PlaceListPage(mode: PlacePageMode.kuliner),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kuliner'), findsWidgets);
    expect(find.text('Bubur Pedas'), findsOneWidget);
    expect(find.text('Pantai Temajuk'), findsNothing);
    expect(find.text('Istana Alwatzikoebillah'), findsNothing);
    expect(find.text('Semua'), findsNothing);
  });

  testWidgets('scroll pendek memuat halaman cursor berikutnya', (tester) async {
    var loads = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placesBrowseProvider.overrideWith2(
            (query) => _PageBrowse(query, () => loads++),
          ),
        ],
        child: MaterialApp(
          home: FTheme(
            data: foruiPalettes['zinc']!.light.touch,
            child: const FToaster(
              child: PlaceListPage(mode: PlacePageMode.wisata),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loads, 1);
    expect(find.text('Istana Alwatzikoebillah'), findsOneWidget);
  });

  testWidgets('pull-to-refresh memuat ulang halaman pertama', (tester) async {
    var refreshCalls = 0;
    final refreshCompleter = Completer<void>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placesBrowseProvider.overrideWith2(
            (query) => _RefreshBrowse(
              query,
              () => refreshCalls++,
              refreshCompleter.future,
            ),
          ),
        ],
        child: MaterialApp(
          home: FTheme(
            data: foruiPalettes['zinc']!.light.touch,
            child: const FToaster(
              child: PlaceListPage(mode: PlacePageMode.wisata),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(refreshCalls, 0, reason: 'refresh tidak dipanggil sebelum pull');

    await tester.drag(find.byType(RefreshIndicator), const Offset(0, 320));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(refreshCalls, 1, reason: 'pull-to-refresh memuat ulang halaman');
    expect(find.byType(RefreshIndicator), findsOneWidget);
    refreshCompleter.complete();
    await tester.pumpAndSettle();
    expect(find.text('Pantai Temajuk'), findsOneWidget);
  });
}
