import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/explore/domain/entities/place.dart';
import 'package:sambasku_mobile/features/explore/presentation/pages/pins_page.dart';
import 'package:sambasku_mobile/features/explore/presentation/providers/places_providers.dart';

Widget _app(Future<List<Place>?> Function() load) => ProviderScope(
  overrides: [placesProvider.overrideWith((ref) => load())],
  child: MaterialApp(
    home: FTheme(data: FThemes.zinc.light.touch, child: const PinsPage()),
  ),
);

void main() {
  testWidgets('no header; back button floats while loading', (tester) async {
    await tester.pumpWidget(_app(() => Completer<List<Place>?>().future));
    await tester.pump();

    expect(find.byType(FHeader), findsNothing);
    expect(find.byTooltip('Kembali'), findsOneWidget);
  });

  testWidgets('theme toggle flips the map page only', (tester) async {
    await tester.pumpWidget(_app(() => Completer<List<Place>?>().future));
    await tester.pump();
    final appContext = tester.element(find.byType(PinsPage));

    await tester.tap(find.byTooltip('Peta mode gelap'));
    await tester.pump();

    expect(find.byTooltip('Peta mode terang'), findsOneWidget);
    final pageContext = tester.element(find.byType(FScaffold));
    expect(Theme.of(pageContext).brightness, Brightness.dark);
    expect(Theme.of(appContext).brightness, Brightness.light);
  });

  testWidgets('back button stays on error state', (tester) async {
    await tester.pumpWidget(_app(() async => throw Exception('offline')));
    await tester.pumpAndSettle();

    expect(find.text('Peta tidak bisa dimuat'), findsOneWidget);
    expect(find.byTooltip('Kembali'), findsOneWidget);
  });
}
