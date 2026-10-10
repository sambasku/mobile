import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/activity/presentation/providers/contribution_guide_providers.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:sambasku_mobile/features/dictionary/domain/providers/dictionary_domain_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/usecases/list_latest_words_use_case.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_summary.dart';
import 'package:sambasku_mobile/features/dictionary/domain/failures/dictionary_failure.dart';
import 'package:sambasku_mobile/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/word_of_day_providers.dart';
import 'package:sambasku_mobile/flavors.dart';

/// Stress anti-freeze: hammering tab shell asli (App + AppRouter.router)
/// - rotasi tab 30x termasuk gerbang Profil tamu -> /login -> system back
/// - menu kontribusi 10x pilih tile + system back, selang-seling double-tap
/// - race: pilih tile lalu langsung ketuk tab Home
/// Assert inti tiap siklus: lokasi router berubah (tab tidak beku).
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
  ) async => const Right(
    WordSearchPage(items: [], nextCursor: null, hasMore: false),
  );
}

class _EmptyLatestRepository implements DictionaryRepository {
  const _EmptyLatestRepository();

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listLatest({
    required int limit,
    String? cursor,
    bool forceRefresh = false,
  }) async => const Right(
    WordSearchPage(items: [], nextCursor: null, hasMore: false),
  );

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listWords({
    required String q,
    required int limit,
    String? category,
    String? cursor,
    String? letter,
    bool? isVerified,
  }) async => throw UnimplementedError();

  @override
  Future<Either<DictionaryFailure, List<WordCategory>>> listCategories() async =>
      const Right(<WordCategory>[]);

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

  Finder tabItem(String label) => find.descendant(
        of: find.byType(FBottomNavigationBar),
        matching: find.text(label),
      );

  testWidgets('stress: rotasi tab, menu kontribusi, race - shell tetap hidup', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await ThemeModeController.preload();
    await ForuiPaletteController.preload();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          listSearchMissesUseCaseProvider
              .overrideWithValue(const _FakeListSearchMissesUseCase()),
          wordOfDayProvider.overrideWith((ref) async => null),
          listLatestWordsUseCaseProvider.overrideWithValue(
            _EmptyLatestUseCase(),
          ),
          // Guide sudah dibaca -> overlay tidak blokir tap di stress test.
          contributionGuideUnreadProvider.overrideWith((ref) async => false),
        ],
        child: const App(),
      ),
    );
    await tester.pump();
    await tester.pump();

    String path() =>
        AppRouter.router.routerDelegate.currentConfiguration.uri.path;
    // go_router 17: uri hanya route deklaratif; push imperatif (login,
    // contribute) terlihat di match terakhir.
    String pushedPath() {
      final route = AppRouter
          .router
          .routerDelegate
          .currentConfiguration
          .matches
          .last
          .route;
      return route is GoRoute ? route.path : '?';
    }
    // Bounded pump (bukan pumpAndSettle): skeleton guest deck berdenyut
    // terus saat halaman current.
    Future<void> settle() async {
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 120));
    }

    // 1. Rotasi tab 30x: Home -> (re-tap Home) -> Kontribusi -> Profil(tamu,
    //    lewat gerbang auth redirect) -> system back -> shell.
    //    Eksplorasi sengaja dilewati: MapLibreMap platform view tidak bisa
    //    hidup di widget test (dispose melempar LateError channel) - map
    //    diuji di device.
    for (var i = 0; i < 30; i++) {
      await tester.tap(tabItem('Home'));
      await settle();
      expect(path(), '/', reason: 'iterasi $i');

      // Rapid re-tap branch sama (goBranch idempoten).
      await tester.tap(tabItem('Home'));
      await tester.pump(const Duration(milliseconds: 60));
      await tester.tap(tabItem('Home'));
      await settle();
      expect(path(), '/', reason: 'iterasi $i re-tap');

      await tester.tap(tabItem('Kontribusi'));
      await settle();
      expect(path(), '/action', reason: 'iterasi $i');

      await tester.tap(tabItem('Profil'));
      await settle();
      expect(
        pushedPath(),
        '/login',
        reason: 'iterasi $i: gerbang tamu ke login',
      );
      expect(await tester.binding.handlePopRoute(), isTrue);
      await settle();
      expect(path(), '/action', reason: 'iterasi $i: back ke shell');
    }
    // Animasi exit route terakhir sebelum menyentuh tombol menu.
    await tester.pump(const Duration(milliseconds: 300));

    // 2. Menu kontribusi 10x: pilih tile -> route -> system back.
    //    Iterasi genap double-tap tile (masih hidup saat animasi pop).
    for (var i = 0; i < 10; i++) {
      await tester.tap(find.text('Menu kontribusi'));
      await settle();
      final tile = find.text('Usul kata baru');
      await tester.tap(tile);
      if (i.isEven) {
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(tile, warnIfMissed: false);
      }
      await settle();
      expect(pushedPath(), '/contribute', reason: 'menu iterasi $i');
      expect(await tester.binding.handlePopRoute(), isTrue);
      await settle();
      await tester.pump(const Duration(milliseconds: 300));
      expect(path(), '/action', reason: 'menu iterasi $i: back ke shell');
      expect(find.text('Menu kontribusi'), findsOneWidget);
    }

    // 3. Race: pilih tile lalu langsung ketuk tab Home tanpa menunggu.
    //    Tap saat animasi exit sheet tertelan AbsorbPointer modal route
    //    (perilaku framework, ~250ms) dan shell tertutup route push - yang
    //    diuji anti-freeze: push tidak hilang, back pulih, tab hidup lagi.
    await tester.tap(find.text('Menu kontribusi'));
    await settle();
    await tester.tap(find.text('Ruang diskusi'));
    await tester.pump();
    await tester.tap(tabItem('Home'), warnIfMissed: false);
    await settle();
    await settle();
    expect(pushedPath(), '/discussions', reason: 'push tile tetap jalan');

    expect(await tester.binding.handlePopRoute(), isTrue);
    await settle();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(tabItem('Home'));
    await settle();
    expect(path(), '/');

    // 4. Setelah semua stress, tab tetap responsif.
    await tester.tap(tabItem('Kontribusi'));
    await settle();
    expect(path(), '/action');
  });
}
