import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/core/router/app_router.dart';
import 'package:sambasku_mobile/features/dictionary/dictionary_router.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/pages/word_detail_page.dart';

/// "/words/complete" dan "/words/:id" bisa sama-sama match. Kalau urutannya
/// terbalik, go_router memperlakukan "complete" sebagai wordId dan pemilih
/// kata tidak pernah bisa dibuka. Gejalanya subtle (halaman detail gagal
/// dimuat), jadi dijaga di sini.
void main() {
  final routes = DictionaryRouter.routes;

  test('selector kata didaftarkan sebelum route detail', () {
    final completeIndex = routes.indexWhere(
      (r) => r.name == DictionaryRouter.complete.name,
    );
    final detailIndex = routes.indexWhere(
      (r) => r.name == DictionaryRouter.detail.name,
    );

    expect(completeIndex, isNot(-1), reason: 'route complete harus terdaftar');
    expect(detailIndex, isNot(-1), reason: 'route detail harus terdaftar');
    expect(
      completeIndex,
      lessThan(detailIndex),
      reason: 'route parameter harus didaftarkan setelah route static',
    );
  });

  testWidgets('path lengkap membuka pemilih kata, bukan detail kata', (
    tester,
  ) async {
    // Pakai tabel route produksi apa adanya (dengan navigatorKey global),
    // lalu lihat halaman mana yang benar-benar dirender.
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          routerConfig: GoRouter(
            navigatorKey: AppRouter.rootNavigatorKey,
            routes: DictionaryRouter.routes,
            initialLocation: DictionaryRouter.complete.path,
          ),
          builder: (context, child) => FTheme(
            data: FThemes.zinc.light.touch,
            child: child!,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Cari kata Sambas...'), findsOneWidget);
    expect(find.byType(WordDetailPage), findsNothing);
  });
}
