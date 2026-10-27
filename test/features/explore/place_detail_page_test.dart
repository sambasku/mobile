import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_delegates.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/explore/domain/entities/place.dart';
import 'package:sambasku_mobile/features/explore/explore_router.dart';
import 'package:sambasku_mobile/features/explore/presentation/pages/place_detail_page.dart';
import 'package:sambasku_mobile/features/explore/presentation/pages/place_photos_page.dart';
import 'package:sambasku_mobile/features/explore/presentation/providers/places_providers.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';

Place _place(
  String id,
  String name,
  List<PlaceRelated> related, {
  String? regionId,
  PlaceCategory category = PlaceCategory.wisata,
}) => Place(
  id: id,
  slug: id,
  name: name,
  category: category,
  type: PlaceType.sejarah,
  regionId: regionId,
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
      _place('istana', 'Istana Alwatzikoebillah', const [], regionId: 'sambas'),
      _place('masjid', 'Masjid Jami', const [], regionId: 'sambas'),
      _place('pantai-jauh', 'Pantai Jauh', const [], regionId: 'paloh'),
      _place(
        'bubur',
        'Bubur Pedas',
        const [],
        regionId: 'sambas',
        category: PlaceCategory.kuliner,
      ),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [placesProvider.overrideWith((ref) async => places)],
        child: MaterialApp(
      localizationsDelegates: appLocalizationDelegates,
      locale: appTestLocale,
      supportedLocales: appTestSupportedLocales,
          home: FTheme(
            data: foruiPalettes['zinc']!.light.touch,
            child: const FToaster(child: PlaceDetailPage(slug: 'istana')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Istana Alwatzikoebillah'), findsOneWidget);
    expect(find.text('Wisata'), findsOneWidget);
    expect(find.text('Sejarah'), findsOneWidget);
    expect(find.text('08.00 - 17.00'), findsOneWidget);
    expect(find.text('Baca Selengkapnya'), findsNothing);
    expect(find.text('[object Object]'), findsNothing);
    expect(find.byTooltip('Bagikan'), findsOneWidget);
    // Section "Sumber" dan "Wisata lain" ada di bawah fold ListView lazy -
    // wajib scroll dulu. Ada 2 scrollable (carousel + list), pilih vertikal.
    await tester.scrollUntilVisible(
      find.text('Sumber'),
      400,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axis == Axis.vertical,
          )
          .first,
    );
    expect(find.text('Sumber'), findsWidgets);
    expect(find.text('Wisata lain di kecamatan ini'), findsOneWidget);
    expect(find.text('Masjid Jami'), findsOneWidget);
    expect(find.text('Pantai Jauh'), findsNothing);
    expect(find.text('Bubur Pedas'), findsNothing);

    final source = find.textContaining('sengaja panjang').first;
    await tester.ensureVisible(source);
    expect(tester.getSize(source).height, lessThan(14 * 2));
    expect(find.text('CC BY-SA 3.0').first, findsOneWidget);

    await tester.tap(find.byTooltip('Bookmark'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Bookmark tempat belum bisa dipakai'), findsOneWidget);
  });

  testWidgets('tap gambar hero membuka preview fullscreen', (tester) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final places = [
      Place(
        id: 'istana',
        slug: 'istana',
        name: 'Istana',
        category: PlaceCategory.wisata,
        type: PlaceType.sejarah,
        lat: 1.36,
        lng: 109.31,
        shortDescription: 'Deskripsi',
        images: const [
          PlaceImage(url: 'https://img.example/a.jpg', isMain: true),
          PlaceImage(url: 'https://img.example/b.jpg', isMain: false),
        ],
        hours: null,
        contact: null,
        related: const [],
        sources: const [],
      ),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [placesProvider.overrideWith((ref) async => places)],
        child: MaterialApp(
      localizationsDelegates: appLocalizationDelegates,
      locale: appTestLocale,
      supportedLocales: appTestSupportedLocales,
          home: FTheme(
            data: foruiPalettes['zinc']!.light.touch,
            child: const FToaster(child: PlaceDetailPage(slug: 'istana')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PageView).first);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Tutup'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
  });

  testWidgets('kontak nomor dan email tampil, teks rusak disembunyikan', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final places = [
      Place(
        id: 'pantai',
        slug: 'pantai',
        name: 'Pantai Camar Bulan',
        category: PlaceCategory.wisata,
        type: PlaceType.pantai,
        shortDescription: 'Pantai',
        images: const [
          PlaceImage(url: 'https://img.example/a.jpg', isMain: true),
          PlaceImage(url: 'https://img.example/b.jpg', isMain: false),
          PlaceImage(url: 'https://img.example/c.jpg', isMain: false),
          PlaceImage(url: 'https://img.example/d.jpg', isMain: false),
        ],
        hours: null,
        contact: const PlaceContact(
          phone: '085229186159',
          email: 'budiprasetiya@rocketmail.com',
        ),
        related: const [],
        sources: const [],
      ),
    ];
    final router = GoRouter(
      initialLocation: '/pantai',
      routes: [
        GoRoute(
          path: '/pantai',
          builder: (_, _) => const PlaceDetailPage(slug: 'pantai'),
        ),
        GoRoute(
          path: ExploreRouter.placePhotos.path,
          builder: (_, state) =>
              PlacePhotosPage(slug: state.pathParameters['slug'] ?? ''),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [placesProvider.overrideWith((ref) async => places)],
        child: MaterialApp.router(
          localizationsDelegates: appLocalizationDelegates,
          locale: appTestLocale,
          supportedLocales: appTestSupportedLocales,
          routerConfig: router,
          builder: (context, child) => FTheme(
            data: foruiPalettes['zinc']!.light.touch,
            child: FToaster(child: child ?? const SizedBox()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('085229186159'), findsOneWidget);
    expect(find.text('Telepon'), findsOneWidget);
    expect(find.text('budiprasetiya@rocketmail.com'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('[object Object]'), findsNothing);
    expect(find.text('Foto'), findsOneWidget);
    expect(find.text('Lihat 1 foto lainnya'), findsOneWidget);
    await tester.tap(find.text('Lihat 1 foto lainnya'));
    await tester.pumpAndSettle();
    expect(find.text('Unggah foto'), findsOneWidget);
    expect(find.text('Lihat 1 foto lainnya'), findsNothing);
    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 3);
  });
}
