import 'dart:ui' show Size;

import 'package:flutter/material.dart' show debugDumpApp;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as forui;
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/app.dart';
import 'package:sambasku_mobile/core/router/app_router.dart';
import 'package:sambasku_mobile/core/services/analytics_service.dart';
import 'package:sambasku_mobile/core/theme/forui_palette_controller.dart';
import 'package:sambasku_mobile/core/theme/theme_mode_controller.dart';
import 'package:sambasku_mobile/features/onboarding/data/onboarding_prefs.dart';
import 'package:sambasku_mobile/features/search_miss/domain/entities/search_miss.dart';
import 'package:sambasku_mobile/features/search_miss/domain/failures/search_miss_failure.dart';
import 'package:sambasku_mobile/features/search_miss/domain/providers/search_miss_domain_providers.dart';
import 'package:sambasku_mobile/features/search_miss/domain/usecases/list_search_misses_use_case.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_summary.dart';
import 'package:sambasku_mobile/features/dictionary/domain/failures/dictionary_failure.dart';
import 'package:sambasku_mobile/features/dictionary/domain/providers/dictionary_domain_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:sambasku_mobile/features/dictionary/domain/usecases/list_latest_words_use_case.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/word_of_day_providers.dart';
import 'package:sambasku_mobile/flavors.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Integrasi guide Kontribusi + deck: setelah tap "Mengerti", konten deck
/// HARUS kembali. Race tertutup: notifikasi routerDelegate nyasar saat
/// dialog terbuka membuat _VoteDeckHost flip ke stub (canPop=true karena
/// dialog pageless) dan pop dialog tidak men-notify router.
class _FakeListSearchMissesUseCase implements ListSearchMissesUseCase {
  const _FakeListSearchMissesUseCase();

  @override
  Future<Either<SearchMissFailure, List<SearchMiss>>> call(
    ListSearchMissesParams params,
  ) async => Either.right(<SearchMiss>[]);
}

class _EmptyLatestUseCase extends ListLatestWordsUseCase {
  _EmptyLatestUseCase() : super(const _EmptyLatestRepository());

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> call(
    ListLatestWordsParams params,
  ) async =>
      const Right(WordSearchPage(items: [], nextCursor: null, hasMore: false));
}

class _EmptyLatestRepository implements DictionaryRepository {
  const _EmptyLatestRepository();

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listLatest({
    required int limit,
    String? cursor,
    bool forceRefresh = false,
  }) async =>
      const Right(WordSearchPage(items: [], nextCursor: null, hasMore: false));

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listWords({
    required String q,
    required int limit,
    String? cursor,
    String? letter,
    bool? isVerified,
  }) async =>
      const Right(WordSearchPage(items: [], nextCursor: null, hasMore: false));

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordById(
    String id, {
    bool forceRefresh = false,
  }) async => throw UnimplementedError();

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordByLemma(
    String lemma, {
    bool forceRefresh = false,
  }) async => throw UnimplementedError();

  @override
  Future<Either<DictionaryFailure, WordOfDay?>> getWordOfDay({
    bool forceRefresh = false,
  }) async => throw UnimplementedError();

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> searchWords({
    required String query,
    required int limit,
    String? cursor,
    String? letter,
    bool? isVerified,
    String searchIn = 'lemma',
  }) async => throw UnimplementedError();
}

Finder tabItem(String label) => find.descendant(
  of: find.byType(forui.FBottomNavigationBar),
  matching: find.text(label),
);

Future<void> pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await ThemeModeController.preload();
  await ForuiPaletteController.preload();
  // Viewport realistis; default 800x600 membuat sheet overflow palsu.
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        listSearchMissesUseCaseProvider.overrideWithValue(
          const _FakeListSearchMissesUseCase(),
        ),
        wordOfDayProvider.overrideWith((ref) async => null),
        listLatestWordsUseCaseProvider.overrideWithValue(_EmptyLatestUseCase()),
        // Guide unread default (prefs kosong): sengaja TIDAK dioverride.
      ],
      child: const App(),
    ),
  );
  await tester.pump();
}

/// Bukan pumpAndSettle: skeleton guest deck berdenyut terus.
Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 120));
  await tester.pump(const Duration(milliseconds: 120));
}

void main() {
  setUpAll(() {
    F.appFlavor = Flavor.staging;
    OnboardingPrefs.done = true;
  });

  setUp(() {
    AnalyticsService.debugReset();
    FlutterSecureStorage.setMockInitialValues({});
  });

  tearDown(AnalyticsService.debugReset);

  testWidgets('tap Mengerti mengembalikan konten deck tab Kontribusi', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(tabItem('Kontribusi'));
    await settle(tester);

    expect(find.text('Kartu bisa digeser untuk menilai'), findsOneWidget);
    expect(find.text('Masuk dulu untuk menilai kata'), findsOneWidget);

    await tester.tap(find.text('Mengerti'), warnIfMissed: false);
    await settle(tester);
    await settle(tester);

    expect(find.text('Kartu bisa digeser untuk menilai'), findsNothing);
    expect(find.text('Masuk dulu untuk menilai kata'), findsOneWidget);
  });

  testWidgets(
    'notifikasi router nyasar saat guide terbuka tidak membiarkan deck macet stub',
    (tester) async {
      await pumpApp(tester);

      await tester.tap(tabItem('Kontribusi'));
      await settle(tester);
      expect(find.text('Kartu bisa digeser untuk menilai'), findsOneWidget);
      expect(find.text('Masuk dulu untuk menilai kata'), findsOneWidget);

      // Simulasi notifikasi routerDelegate apa pun saat dialog pageless
      // terbuka (goBranch, deep link, dsb): canPop terbaca true.
      AppRouter.router.routerDelegate.notifyListeners();
      await settle(tester);
      // Deck tergantikan stub (alert guest hilang) - kondisi menuju macet.
      expect(
        find.text('Masuk dulu untuk menilai kata'),
        findsNothing,
        reason: 'canPop=true saat dialog terbuka menampilkan stub',
      );

      await tester.tap(find.text('Mengerti'), warnIfMissed: false);
      await settle(tester);
      await settle(tester);
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Kartu bisa digeser untuk menilai'), findsNothing);
      // Regresi inti: konten deck harus kembali, bukan stub kosong selamanya.
      debugDumpApp();
      expect(find.text('Masuk dulu untuk menilai kata'), findsOneWidget);
    },
  );
}
