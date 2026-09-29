import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sambasku_mobile/app.dart';
import 'package:sambasku_mobile/core/services/analytics_service.dart';
import 'package:sambasku_mobile/core/theme/forui_palette_controller.dart';
import 'package:sambasku_mobile/core/theme/theme_mode_controller.dart';
import 'package:sambasku_mobile/features/onboarding/data/onboarding_prefs.dart';
import 'package:sambasku_mobile/features/search_miss/domain/entities/search_miss.dart';
import 'package:sambasku_mobile/features/search_miss/domain/failures/search_miss_failure.dart';
import 'package:sambasku_mobile/features/dictionary/domain/providers/dictionary_domain_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/usecases/list_latest_words_use_case.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_summary.dart';
import 'package:sambasku_mobile/features/dictionary/domain/failures/dictionary_failure.dart';
import 'package:sambasku_mobile/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/word_of_day_providers.dart';
import 'package:sambasku_mobile/features/search_miss/domain/providers/search_miss_domain_providers.dart';
import 'package:sambasku_mobile/features/search_miss/domain/usecases/list_search_misses_use_case.dart';
import 'package:sambasku_mobile/flavors.dart';

class _FakeListSearchMissesUseCase implements ListSearchMissesUseCase {
  const _FakeListSearchMissesUseCase();

  @override
  Future<Either<SearchMissFailure, List<SearchMiss>>> call(
    ListSearchMissesParams params,
  ) async =>
      Either.right(<SearchMiss>[]);
}

class _EmptyLatestUseCase extends ListLatestWordsUseCase {
  _EmptyLatestUseCase() : super(const _EmptyLatestRepository());

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> call(
    ListLatestWordsParams params,
  ) async =>
      const Right(
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
  }) async =>
      const Right(
        WordSearchPage(items: [], nextCursor: null, hasMore: false),
      );

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> listWords({
    required String q,
    required int limit,
    String? cursor,
    String? letter,
    bool? isVerified,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordById(
    String id, {
    bool forceRefresh = false,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordByLemma(
    String lemma, {
    bool forceRefresh = false,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<DictionaryFailure, WordOfDay?>> getWordOfDay({
    bool forceRefresh = false,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> searchWords({
    required String query,
    required int limit,
    String? cursor,
    String searchIn = 'lemma',
  }) async =>
      throw UnimplementedError();
}

void main() {
  // test tidak melewati main() - flavor + onboarding wajib di-init manual
  setUpAll(() {
    F.appFlavor = Flavor.staging;
    OnboardingPrefs.done = true;
  });

  setUp(() {
    AnalyticsService.debugReset();
    FlutterSecureStorage.setMockInitialValues({});
  });

  tearDown(AnalyticsService.debugReset);

  testWidgets('App bootstrap - HOME tab terender tanpa error', (
    WidgetTester tester,
  ) async {
    // plugin SharedPreferences tidak tersedia di test env - mock values
    SharedPreferences.setMockInitialValues({});
    await ThemeModeController.preload();
    await ForuiPaletteController.preload();
    // banner search-miss memakai jaringan; override usecase supaya test
    // deterministik tanpa pending Timer (dio timeout) di fake-async zone.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          listSearchMissesUseCaseProvider
              .overrideWithValue(const _FakeListSearchMissesUseCase()),
          // Kata hari ini juga hit Dio; tanpa stub, connectTimeout
          // menyisakan pending Timer di fake-async.
          wordOfDayProvider.overrideWith((ref) async => null),
          listLatestWordsUseCaseProvider.overrideWithValue(
            _EmptyLatestUseCase(),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pump();
    // redirect GoRouter (getIsAuth) selesai di frame berikutnya
    await tester.pump();

    // cold start langsung HOME (FScaffold shell + header SambasKu)
    expect(find.byType(FScaffold), findsWidgets);
    expect(find.text('SambasKu'), findsOneWidget);
  });
}