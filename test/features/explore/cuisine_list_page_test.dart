import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/explore/domain/entities/cuisine.dart';
import 'package:sambasku_mobile/features/explore/presentation/pages/cuisine_list_page.dart';
import 'package:sambasku_mobile/features/explore/presentation/providers/cuisine_providers.dart';

Cuisine _cuisine(String name) => Cuisine(
  id: name,
  slug: name.toLowerCase().replaceAll(' ', '-'),
  name: name,
  description: 'Deskripsi $name',
  images: const [],
  ingredients: ['Beras'],
  region: 'Kota Sambas',
  tags: const [],
  servingSuggestion: null,
  sources: const [],
);

final _items = [_cuisine('Bubur Pedas'), _cuisine('Terubuk Asap')];

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [cuisineProvider.overrideWith((ref) async => _items)],
      child: MaterialApp(
        home: FTheme(
          data: FThemes.zinc.light.touch,
          child: const FToaster(child: CuisineListPage()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('list menampilkan semua cuisine lalu filter via search', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Bubur Pedas'), findsOneWidget);
    expect(find.text('Terubuk Asap'), findsOneWidget);
    expect(find.text('Kota Sambas'), findsNWidgets(2));

    await tester.enterText(find.byType(EditableText), 'terubuk');
    await tester.pumpAndSettle();
    expect(find.text('Terubuk Asap'), findsOneWidget);
    expect(find.text('Bubur Pedas'), findsNothing);
  });

  testWidgets('data null (offline) menampilkan error + retry', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [cuisineProvider.overrideWith((ref) async => null)],
        child: MaterialApp(
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: const FToaster(child: CuisineListPage()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });
}

// Pastikan entity cuisine reuse tipe image dari place.
// ignore: unused_element
void _typeCheck(PlaceImage img) {
  Cuisine(
    id: 'x',
    name: 'x',
    slug: 'x',
    description: 'x',
    images: [img],
    ingredients: const [],
    region: 'x',
    tags: const [],
    sources: const [],
  );
}
