import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/cache/cache_entry.dart';
import 'package:sambasku_mobile/core/cache/cache_key.dart';
import 'package:sambasku_mobile/core/cache/cache_policy.dart';
import 'package:sambasku_mobile/core/cache/cache_providers.dart';
import 'package:sambasku_mobile/core/cache/response_cache_store.dart';
import 'package:sambasku_mobile/core/models/api_response.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/core/services/analytics_service.dart';
import 'package:sambasku_mobile/features/contribution/domain/entities/submit_word_result.dart';
import 'package:sambasku_mobile/features/contribution/domain/failures/contribution_failure.dart';
import 'package:sambasku_mobile/features/contribution/domain/providers/contribution_domain_providers.dart';
import 'package:sambasku_mobile/features/contribution/domain/usecases/submit_anon_word_use_case.dart';
import 'package:sambasku_mobile/features/contribution/presentation/pages/contribute_page.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/word_detail_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Adapter Dio yang selalu gagal - reference (bahasa/kelas kata/dialek)
/// masuk kondisi error tanpa menunggu timer jaringan.
class _ThrowingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => throw DioException.connectionError(
    requestOptions: options,
    reason: 'mock offline',
  );

  @override
  void close({bool force = false}) {}
}

class _CapturingSubmit implements SubmitAnonWordUseCase {
  _CapturingSubmit({this.result});

  /// Kalau tidak null, submit dianggap sukses dan mengembalikan result ini.
  final SubmitWordResult? result;

  SubmitAnonWordParams? params;

  @override
  Future<Either<ContributionFailure, SubmitWordResult>> call(
    SubmitAnonWordParams params,
  ) async {
    this.params = params;
    final r = result;
    if (r != null) return Either.right(r);
    return Either.left(
      const ContributionFailure('berhenti', errorCode: 'RATE_LIMITED'),
    );
  }
}

class _ReferenceAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path;
    final Object body;
    if (path.endsWith('/word-classes')) {
      body = {
        'data': [
          {'id': 'wc-umum', 'name': 'Umum', 'code': 'umum'},
        ],
      };
    } else if (path.endsWith('/languages')) {
      body = {
        'data': [
          {'id': 'lang-sbs', 'name': 'Sambas', 'code': 'SBS'},
          {'id': 'lang-idn', 'name': 'Indonesia', 'code': 'IDN'},
        ],
      };
    } else if (path.endsWith('/dialects')) {
      body = {
        'data': [
          {'id': 'd-umum', 'name': 'Umum', 'code': 'umum', 'is_default': true},
        ],
      };
    } else {
      body = {'data': []};
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeSubmitUsecase implements SubmitAnonWordUseCase {
  _FakeSubmitUsecase(this.failure);

  final ContributionFailure failure;

  @override
  Future<Either<ContributionFailure, SubmitWordResult>> call(
    SubmitAnonWordParams params,
  ) async => Either.left(failure);
}

/// Widget test form kontribusi (mobile-base-stack Section 10): error 4xx
/// selalu muncul sebagai toast FToaster, VALIDATION_ERROR tetap menampilkan
/// error inline per field.
void main() {
  setUp(() {
    AnalyticsService.debugReset();
    FlutterSecureStorage.setMockInitialValues({});
  });

  tearDown(AnalyticsService.debugReset);

  Future<void> pumpContribute(
    WidgetTester tester, {
    required ContributionFailure failure,
  }) async {
    SharedPreferences.setMockInitialValues({});

    final throwingDio = Dio()..httpClientAdapter = _ThrowingAdapter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(throwingDio),
          submitAnonWordUseCaseProvider.overrideWithValue(
            _FakeSubmitUsecase(failure),
          ),
        ],
        child: MaterialApp(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: const FToaster(child: ContributePage()),
          ),
        ),
      ),
    );
    // initState prefill + loading reference provider
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> submitForm(WidgetTester tester) async {
    final fields = find.byType(EditableText);
    expect(fields, findsAtLeastNWidgets(2));
    await tester.enterText(fields.at(1), 'aktivitas makan');
    await tester.pump();
    await tester.tap(find.text('Kirim Usulan'));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('4xx RATE_LIMITED - toast error ditampilkan', (tester) async {
    await pumpContribute(
      tester,
      failure: const ContributionFailure(
        'Terlalu banyak usulan dikirim. Coba lagi nanti.',
        errorCode: 'RATE_LIMITED',
      ),
    );

    await submitForm(tester);

    expect(
      find.descendant(
        of: find.byType(FToast),
        matching: find.text('Terlalu banyak usulan dikirim. Coba lagi nanti.'),
      ),
      findsOneWidget,
    );

    // biarkan toast auto-dismiss supaya tidak ada pending timer di teardown
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('400 VALIDATION_ERROR - toast panduan + error inline per field', (
    tester,
  ) async {
    await pumpContribute(
      tester,
      failure: const ContributionFailure(
        'Gagal validasi',
        errorCode: 'VALIDATION_ERROR',
        details: [ApiErrorDetail(field: 'lemma', message: 'Kata wajib diisi')],
      ),
    );

    await submitForm(tester);

    expect(
      find.descendant(
        of: find.byType(FToast),
        matching: find.text('Periksa kembali isian yang ditandai merah'),
      ),
      findsOneWidget,
    );

    // scroll kembali ke atas untuk melihat error inline di bawah field lemma
    // (ListView bersifat lazy - elemen di luar layar tidak di-build)
    await tester.scrollUntilVisible(
      find.text('Kata wajib diisi'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Kata wajib diisi'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('mode standar mengirim lemma dan terjemahan', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final usecase = _CapturingSubmit();
    final dio = Dio()..httpClientAdapter = _ReferenceAdapter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(dio),
          submitAnonWordUseCaseProvider.overrideWithValue(usecase),
        ],
        child: MaterialApp(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: const FToaster(child: ContributePage()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('Kata / ungkapan Sambas *'), findsOneWidget);
    expect(find.text('Terjemahan Indonesia *'), findsOneWidget);
    expect(find.text('Jenis'), findsNothing);
    expect(find.text('Dialek'), findsNothing);
    expect(find.text('Contoh'), findsNothing);

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'makatn');
    await tester.enterText(fields.at(1), 'makan');
    await tester.tap(find.text('Kirim Usulan'));
    await tester.pump(const Duration(milliseconds: 400));

    final params = usecase.params;
    expect(params, isNotNull);
    expect(params!.lemma, 'makatn');
    expect(params.wordType, 'word');
    // Mode Dasar tetap kirim dialek umum (API menolak dialect_id: null).
    expect(params.dialectId, 'd-umum');
    expect(params.meanings, hasLength(1));
    expect(params.meanings.first.definition, '-');
    expect(params.meanings.first.isHaveDefinition, isFalse);
    expect(params.meanings.first.isHaveTranslation, isTrue);
    expect(params.meanings.first.translationTexts, ['makan']);
    expect(params.meanings.first.wordClassId, 'wc-umum');
    expect(params.meanings.first.exampleSentences, isEmpty);

    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('submit sukses menghapus cache L1 + invalidate detail (issue #28)', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    const wordId = '01JWORD0000000000000000000';
    const lemma = 'makatn';
    final usecase = _CapturingSubmit(
      result: const SubmitWordResult(wordId: wordId, status: 'pending_review'),
    );
    final dio = Dio()..httpClientAdapter = _ReferenceAdapter();

    const detail = WordDetail(
      id: wordId,
      lemma: lemma,
      languageId: 'lang-sbs',
      wordType: 'word',
      status: 'published',
      isVerified: true,
      isCorrected: false,
    );
    var detailBuilds = 0;

    final store = _InMemoryCacheStore();
    final byIdKey = buildCacheKey(method: 'GET', path: '/api/v1/words/$wordId');
    final byLemmaKey = buildCacheKey(
      method: 'GET',
      path: '/api/v1/words/lemma/$lemma',
    );
    await store.put(key: byIdKey, body: '{"data":{"id":"$wordId"}}');
    await store.put(key: byLemmaKey, body: '{"data":{"id":"$wordId"}}');

    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(dio),
        submitAnonWordUseCaseProvider.overrideWithValue(usecase),
        responseCacheStoreProvider.overrideWithValue(store),
        wordDetailProvider(lemma).overrideWith((ref) async {
          detailBuilds++;
          return detail;
        }),
        wordDetailProvider(wordId).overrideWith((ref) async {
          detailBuilds++;
          return detail;
        }),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: const FToaster(child: ContributePage()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Panaskan kedua kunci detail (lemma + ULID) supaya ada state lama.
    await container.read(wordDetailProvider(lemma).future);
    await container.read(wordDetailProvider(wordId).future);
    expect(detailBuilds, 2);
    expect(store.peek(byIdKey), isNotNull);
    expect(store.peek(byLemmaKey), isNotNull);

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), lemma);
    await tester.enterText(fields.at(1), 'makan');
    await tester.tap(find.text('Kirim Usulan'));
    await tester.pump(const Duration(milliseconds: 400));

    // Dialog sukses muncul, tutup lewat "Tambah lagi" (tanpa navigasi).
    expect(find.text('Usulan terkirim'), findsOneWidget);
    await tester.tap(find.text('Tambah lagi'));
    await tester.pump(const Duration(milliseconds: 400));

    // Riverpod: kedua kunci ter-invalidate → builder jalan lagi.
    await container.read(wordDetailProvider(lemma).future);
    await container.read(wordDetailProvider(wordId).future);
    expect(detailBuilds, 4);

    // L1: entry by-id dan by-lemma terhapus.
    expect(store.peek(byIdKey), isNull);
    expect(store.peek(byLemmaKey), isNull);

    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 300));
  });
}

/// Fake L1 store in-memory: cukup put/get/delete untuk assert invalidasi.
class _InMemoryCacheStore implements ResponseCacheStore {
  final Map<String, CacheEntry> _entries = {};

  @override
  Future<void> open() async {}

  @override
  Future<CacheEntry?> get(String key) async => _entries[key];

  @override
  Future<void> put({
    required String key,
    required String body,
    CacheScope scope = CacheScope.public,
  }) async {
    final now = DateTime.now().toUtc();
    _entries[key] = CacheEntry(
      key: key,
      body: body,
      cachedAt: now,
      lastAccess: now,
      sizeBytes: body.length,
      scope: scope,
      schemaVersion: CachePolicy.schemaVersion,
    );
  }

  @override
  Future<void> delete(String key) async {
    _entries.remove(key);
  }

  @override
  Future<void> deleteByPrefix(String prefix) async {
    _entries.removeWhere((k, _) => k.startsWith(prefix));
  }

  @override
  Future<void> wipeScope(CacheScope scope) async {
    _entries.removeWhere((_, e) => e.scope == scope);
  }

  @override
  Future<void> wipeAll() async {
    _entries.clear();
  }

  @override
  List<CacheEntryMeta> listMeta() => _entries.values
      .map((e) => e.meta)
      .toList(growable: false);

  @override
  CacheEntry? peek(String key) => _entries[key];

  @override
  int get entryCount => _entries.length;

  @override
  int get totalBytes =>
      _entries.values.fold(0, (sum, e) => sum + e.sizeBytes);
}

