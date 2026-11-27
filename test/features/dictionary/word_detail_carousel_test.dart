import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/core/models/image_attribution.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/features/dictionary/data/providers/dictionary_data_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/domain/failures/dictionary_failure.dart';
import 'package:sambasku_mobile/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/pages/word_detail_page.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

const _wordId = '01AAAAAAAAAAAAAAAAAAAAAAAA';

List<WordImage> _images = const [];

WordImage _img(
  String id, {
  bool primary = false,
  ImageAttribution? attribution,
}) => WordImage(
  id: id,
  url: 'https://images.unsplash.com/photo-$id?w=800',
  isPrimary: primary,
  attribution: attribution,
);

WordDetail _detail() => WordDetail(
  id: _wordId,
  lemma: 'apam',
  languageId: 'lang-1',
  wordType: 'word',
  status: 'published',
  isVerified: true,
  isCorrected: false,
  createdBy: const WordVerifier(
    username: 'budi',
    displayName: 'Budi',
    role: 'contributor',
  ),
  images: _images,
  meanings: const [],
);

class _StubRepo implements DictionaryRepository {
  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordById(
    String id, {
    bool forceRefresh = false,
    String? focusMeaningId,
    bool includeUnverified = false,
  }) async => Either.right(_detail());

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordByLemma(
    String lemma, {
    bool forceRefresh = false,
    String? focusMeaningId,
    bool includeUnverified = false,
  }) async => Either.right(_detail());

  @override
  Future<Either<DictionaryFailure, WordOfDay?>> getWordOfDay({
    bool forceRefresh = false,
  }) async => Either.right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeAuthStatus extends AuthStatusNotifier {
  _FakeAuthStatus(this._isAuth);

  final bool _isAuth;

  @override
  Future<AuthStatusState> build() async => AuthStatusState(
    isAuth: _isAuth,
    username: _isAuth ? 'budi' : null,
    role: _isAuth ? 'user' : null,
    userId: _isAuth ? 'u1' : null,
  );
}

Future<void> _pump(
  WidgetTester tester, {
  bool isAuth = false,
  List<String>? pushedRoutes,
}) async {
  final router = GoRouter(
    initialLocation: '/words/$_wordId',
    routes: [
      GoRoute(
        path: '/words/:id',
        builder: (context, state) =>
            WordDetailPage(wordId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/suggest-edit/:wordId',
        builder: (context, state) {
          pushedRoutes?.add(state.uri.toString());
          return const Scaffold(body: Text('SUGGEST_EDIT_PAGE'));
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          pushedRoutes?.add('/login');
          return const Scaffold(body: Text('LOGIN_PAGE'));
        },
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dictionaryRepositoryProvider.overrideWithValue(_StubRepo()),
        authStatusProvider.overrideWith(() => _FakeAuthStatus(isAuth)),
      ],
      child: MaterialApp.router(
        theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          ...FLocalizations.localizationsDelegates,
        ],
        supportedLocales: const [Locale('id')],
        locale: const Locale('id'),
        routerConfig: router,
        builder: (context, child) => FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: FToaster(child: child!),
        ),
      ),
    ),
  );
  await tester.runAsync(() async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  });
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => _images = const []);

  testWidgets('kredit foto utama tampil di bawah lemma', (tester) async {
    _images = [
      _img(
        'a',
        primary: true,
        attribution: const ImageAttribution(name: 'Ada', provider: 'unsplash'),
      ),
      _img(
        'b',
        attribution: const ImageAttribution(name: 'Bob', provider: 'pixabay'),
      ),
    ];
    await _pump(tester);

    expect(find.text('Foto oleh '), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);
  });

  testWidgets('tanpa kredit: label Foto oleh tidak muncul', (tester) async {
    _images = [_img('a', primary: true)];
    await _pump(tester);
    expect(find.text('Foto oleh '), findsNothing);
  });

  testWidgets('badge jumlah foto tampil bila lebih dari satu', (tester) async {
    _images = [_img('a', primary: true), _img('b')];
    await _pump(tester);
    expect(find.text('2'), findsOneWidget);
    expect(find.byIcon(FLucideIcons.imagePlus), findsNothing);
  });

  testWidgets(
    'tanpa foto: container Tambah foto tampil default dan buka form add_photo',
    (tester) async {
      final pushed = <String>[];
      await _pump(tester, isAuth: true, pushedRoutes: pushed);

      expect(find.byIcon(FLucideIcons.imagePlus), findsOneWidget);
      expect(find.text('Tambah foto'), findsOneWidget);

      await tester.tap(find.text('Tambah foto'));
      await tester.pumpAndSettle();

      expect(pushed, ['/suggest-edit/$_wordId?category=add_photo&autoPick=1']);
    },
  );

  testWidgets(
    'pelafalan kosong tampil dengan format /Tambah pelafalan/ bergaya IPA',
    (tester) async {
      await _pump(tester);

      final textFinder = find.text('/Tambah pelafalan/');
      expect(textFinder, findsOneWidget);
      final widget = tester.widget<Text>(textFinder);
      expect(widget.style?.fontStyle, FontStyle.italic);
    },
  );
}
