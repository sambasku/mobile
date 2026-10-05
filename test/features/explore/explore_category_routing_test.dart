import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/explore/domain/entities/cuisine.dart';
import 'package:sambasku_mobile/features/explore/presentation/pages/explore_category_page.dart';
import 'package:sambasku_mobile/features/explore/presentation/providers/cuisine_providers.dart';

const _dummy = Cuisine(
  id: 'x',
  slug: 'bubur-pedas-sambas',
  name: 'Bubur Pedas Sambas',
  description: 'desc',
  images: [],
  ingredients: [],
  region: 'Sambas',
  tags: [],
  servingSuggestion: null,
  sources: [],
);

/// Regresi: kartu kategori 'kuliner' wajib membuka CuisineListPage,
/// bukan fallback "Segera hadir" (bug id mismatch pasca rename).
void main() {
  Future<void> pump(WidgetTester tester, String categoryId) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cuisineProvider.overrideWith((ref) async => const [_dummy]),
        ],
        child: MaterialApp(
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: FToaster(child: ExploreCategoryPage(categoryId: categoryId)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets("kategori kuliner membuka daftar cuisine, bukan coming soon", (
    tester,
  ) async {
    await pump(tester, 'kuliner');

    // Fallback "Segera hadir" tampil kalau routing salah.
    expect(find.text('Segera hadir'), findsNothing);
    expect(find.text('Bubur Pedas Sambas'), findsOneWidget);
  });

  testWidgets('kategori tak dikenal tetap coming soon', (tester) async {
    await pump(tester, 'ngasal');

    expect(find.text('Segera hadir'), findsOneWidget);
  });
}
