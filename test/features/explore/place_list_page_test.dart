import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/explore/domain/entities/place.dart';
import 'package:sambasku_mobile/features/explore/presentation/pages/place_list_page.dart';
import 'package:sambasku_mobile/features/explore/presentation/providers/places_providers.dart';

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

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [placesProvider.overrideWith((ref) async => _places)],
      child: MaterialApp(
        home: FTheme(
          data: FThemes.zinc.light.touch,
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
  testWidgets('tap bookmark shows coming-soon toast', (tester) async {
    await _pump(tester);

    expect(
      tester.getTopLeft(find.byIcon(FLucideIcons.bookmark).first).dy,
      tester.getTopLeft(find.text('Pantai Temajuk')).dy,
      reason: 'ikon bookmark sejajar baris atas nama',
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
    final kulinerChip = find.descendant(
      of: find.byType(FBadge),
      matching: find.text('Kuliner'),
    ).first;
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
        overrides: [placesProvider.overrideWith((ref) async => _places)],
        child: MaterialApp(
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: const FToaster(
              child: PlaceListPage(mode: PlacePageMode.kuliner),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kuliner'), findsWidgets); // judul header + label kartu
    expect(find.text('Bubur Pedas'), findsOneWidget);
    expect(find.text('Pantai Temajuk'), findsNothing);
    expect(find.text('Istana Alwatzikoebillah'), findsNothing);
    // Baris chip filter tidak dirender di mode kuliner.
    expect(find.text('Semua'), findsNothing);
  });

  // #104: pull-to-refresh harus hard-miss L1 (forceRefresh fetch CDN),
  // bukan invalidate yang cuma baca cache fresh lagi + skeleton tampil.
  testWidgets('pull-to-refresh memanggil placesRefreshProvider (forceRefresh) + skeleton', (tester) async {
    var refreshCalls = 0;
    final refreshCompleter = Completer<void>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placesProvider.overrideWith((ref) async => _places),
          placesRefreshProvider.overrideWith((ref) async {
            refreshCalls++;
            await refreshCompleter.future;
            return _places;
          }),
        ],
        child: MaterialApp(
          home: FTheme(
            data: FThemes.zinc.light.touch,
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

    expect(refreshCalls, 1, reason: 'pull-to-refresh memicu fetch forceRefresh');
    expect(find.byType(RefreshIndicator), findsOneWidget);
    refreshCompleter.complete();
    await tester.pumpAndSettle();
    expect(find.text('Pantai Temajuk'), findsOneWidget);
  });
}
