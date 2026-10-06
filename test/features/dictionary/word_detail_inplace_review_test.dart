import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/core/widgets/pending_review_badge_icon.dart';
import 'package:sambasku_mobile/core/widgets/verified_badge_icon.dart';
import 'package:sambasku_mobile/features/dictionary/data/providers/dictionary_data_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/domain/failures/dictionary_failure.dart';
import 'package:sambasku_mobile/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/pages/word_detail_page.dart';
import 'package:sambasku_mobile/features/review/domain/entities/review_contribution.dart';
import 'package:sambasku_mobile/features/review/domain/failures/review_failure.dart';
import 'package:sambasku_mobile/features/review/domain/repositories/review_repository.dart';
import 'package:sambasku_mobile/features/review/presentation/providers/review_providers.dart';

const _wordId = '01AAAAAAAAAAAAAAAAAAAAAAAA';

WordDetail _pendingDetail() => WordDetail(
  id: _wordId,
  lemma: 'apam',
  languageId: 'lang-1',
  wordType: 'word',
  status: 'published',
  isVerified: false,
  isCorrected: false,
  createdBy: const WordVerifier(
    username: 'budi',
    displayName: 'Budi',
    role: 'contributor',
  ),
  images: const [],
  meanings: const [],
);

WordDetail _verifiedDetail() => WordDetail(
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
  images: const [],
  meanings: const [],
);

class _FakeAuthStatus extends AuthStatusNotifier {
  _FakeAuthStatus(this.role);

  final String? role;

  @override
  Future<AuthStatusState> build() async =>
      AuthStatusState(isAuth: role != null, username: 'tester', role: role);
}

class _StubRepo implements DictionaryRepository {
  _StubRepo() : called = 0;
  int called;

  bool approved = false;

  WordDetail get _detail =>
      approved ? _verifiedDetail() : _pendingDetail();

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordById(
    String id, {
    bool forceRefresh = false,
  }) async => Either.right(_detail);

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordByLemma(
    String lemma, {
    bool forceRefresh = false,
  }) async => Either.right(_detail);

  @override
  Future<Either<DictionaryFailure, WordOfDay?>> getWordOfDay({
    bool forceRefresh = false,
  }) async => Either.right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _ReviewRepo implements ReviewRepository {
  _ReviewRepo(this.stub);

  final _StubRepo stub;
  int approved = 0;
  int rejected = 0;
  String? lastComment;

  @override
  Future<Either<ReviewFailure, ReviewListPage>> list({
    String? status,
    String? entityType,
    String? wordId,
    bool mine = false,
    bool hideSkipped = false,
    int limit = 20,
    String? cursor,
  }) async {
    return Either.right(
      ReviewListPage(
        items: [
          ReviewItem(
            id: _wordId,
            contributorUsername: 'budi',
            entityType: 'word',
            entityId: _wordId,
            action: 'create',
            status: 'pending',
            createdAt: '2026-10-06T00:00:00Z',
          ),
        ],
      ),
    );
  }

  @override
  Future<Either<ReviewFailure, ReviewDetail>> detail(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> approve(
    String id, {
    String? comment,
  }) async {
    approved++;
    stub.approved = true;
    return Either.right(ReviewDecisionResult(status: 'approved'));
  }

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> reject(
    String id, {
    required String comment,
  }) async {
    rejected++;
    lastComment = comment;
    return Either.right(ReviewDecisionResult(status: 'approved'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<void> _pump(
  WidgetTester tester,
  _StubRepo stub,
  _ReviewRepo reviewRepo,
) async {
  final router = GoRouter(
    initialLocation: '/words/$_wordId',
    routes: [
      GoRoute(
        path: '/words/:id',
        builder: (context, state) =>
            WordDetailPage(wordId: state.pathParameters['id']!),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dictionaryRepositoryProvider.overrideWithValue(stub),
        reviewRepositoryProvider.overrideWithValue(reviewRepo),
        authStatusProvider.overrideWith(() => _FakeAuthStatus('reviewer')),
      ],
      child: MaterialApp.router(
        theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: FLocalizations.localizationsDelegates,
        supportedLocales: FLocalizations.supportedLocales,
        routerConfig: router,
        builder: (context, child) => FTheme(
          data: FThemes.zinc.light.touch,
          child: FToaster(child: child!),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('verifikator bisa approve langsung dari detail kata', (
    tester,
  ) async {
    final stub = _StubRepo();
    final reviewRepo = _ReviewRepo(stub);
    await _pump(tester, stub, reviewRepo);

    // Badge pending tampil untuk verifikator
    expect(find.text('apam'), findsWidgets);

    // Tap badge pending → bottom sheet muncul
    await tester.tap(find.byType(PendingReviewBadgeIcon));
    await tester.pumpAndSettle();
    expect(find.text('Menunggu pengecekan'), findsOneWidget);

    // Tombol Setujui ditekan → approve jalan → state terbaru (verified) di-refresh
    await tester.tap(find.text('Setujui'));
    await tester.pumpAndSettle();
    expect(reviewRepo.approved, 1);
    expect(find.byType(VerifiedBadgeIcon), findsOneWidget);
    expect(find.byType(PendingReviewBadgeIcon), findsNothing);
  });
}