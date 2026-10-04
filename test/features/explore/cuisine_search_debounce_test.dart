import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/explore/domain/entities/cuisine.dart';
import 'package:sambasku_mobile/features/explore/presentation/pages/cuisine_list_page.dart';
import 'package:sambasku_mobile/features/explore/presentation/providers/cuisine_providers.dart';

const _cuisine = Cuisine(
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

/// Regresi: search box ter-debounce 300ms. Ketikan cepat tidak memicu
/// setState per karakter; filter baru jalan setelah user berhenti mengetik.
void main() {
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cuisineProvider.overrideWith((ref) async => const [_cuisine]),
        ],
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

  testWidgets('ketikan cepat: list belum terfilter sebelum 300ms', (
    tester,
  ) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField).first, 'zzz');
    await tester.pump(const Duration(milliseconds: 100));

    // Masih dalam jeda debounce: list belum bereaksi.
    expect(find.text('Bubur Pedas Sambas'), findsOneWidget);
  });

  testWidgets('setelah 300ms: list terfilter', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField).first, 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('Bubur Pedas Sambas'), findsNothing);
    expect(find.text('Belum ada cuisine yang cocok.'), findsOneWidget);
  });
}
