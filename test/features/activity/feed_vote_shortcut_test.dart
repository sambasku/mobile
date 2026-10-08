import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/activity/presentation/widgets/feed_vote_shortcut.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_target.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_view.dart';
import 'package:sambasku_mobile/features/vote/domain/failures/vote_failure.dart';
import 'package:sambasku_mobile/features/vote/domain/providers/vote_domain_providers.dart';
import 'package:sambasku_mobile/features/vote/domain/repositories/vote_repository.dart';
import 'package:sambasku_mobile/features/vote/domain/usecases/toggle_vote_use_case.dart';
import 'package:sambasku_mobile/features/vote/data/providers/vote_data_providers.dart';

class _FakeRepo implements VoteRepository {
  final List<({VoteTarget target, int value})> toggles = [];
  final VoteTarget testTarget = const VoteTarget(type: 'word', id: 'w1');

  @override
  Future<Either<VoteFailure, VoteView>> toggle(
    VoteTarget target,
    int value,
  ) async {
    toggles.add((target: target, value: value));
    return Either.right(VoteView(target: target, myVote: value));
  }

  @override
  Future<Either<VoteFailure, Map<String, VoteCounts>>> countMany(
    List<VoteTarget> targets,
  ) async {
    return Either.right({
      testTarget.key: const VoteCounts(upvotes: 3, downvotes: 1),
    });
  }

  @override
  Future<Either<VoteFailure, Map<String, int>>> myVotes(
    List<VoteTarget> targets,
  ) async {
    return Either.right({testTarget.key: 1});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    '${invocation.memberName} tidak dipakai di test ini',
  );
}

class _FakeAuth extends AuthStatusNotifier {
  _FakeAuth(this.authState);

  final AuthStatusState authState;

  @override
  Future<AuthStatusState> build() async => authState;
}

Future<GoRouter> _pump(WidgetTester tester, ProviderContainer container) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => FeedVoteShortcut(wordId: 'w1'),
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const Scaffold(body: Text('halaman login')),
      ),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
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
  return router;
}

void main() {
  const target = VoteTarget(type: 'word', id: 'w1');

  testWidgets('render count dari VoteController lalu toggle saat tap', (
    tester,
  ) async {
    final repo = _FakeRepo();
    final container = ProviderContainer(
      overrides: [
        authStatusProvider.overrideWith(
          () => _FakeAuth(const AuthStatusState(isAuth: true, userId: 'u1')),
        ),
        voteRepositoryProvider.overrideWithValue(repo),
        toggleVoteUseCaseProvider.overrideWithValue(ToggleVoteUseCase(repo)),
      ],
    );
    addTearDown(container.dispose);

    await _pump(tester, container);

    // Counts tampil (compact: downvote kiri count 1, upvote kanan count 3).
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();

    expect(repo.toggles, [(target: target, value: 1)]);
  });

  testWidgets('tamu: toast login + push /login, tanpa toggle', (tester) async {
    final repo = _FakeRepo();
    final container = ProviderContainer(
      overrides: [
        authStatusProvider.overrideWith(
          () => _FakeAuth(const AuthStatusState()),
        ),
        voteRepositoryProvider.overrideWithValue(repo),
        toggleVoteUseCaseProvider.overrideWithValue(ToggleVoteUseCase(repo)),
      ],
    );
    addTearDown(container.dispose);

    final router = await _pump(tester, container);

    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();

    expect(repo.toggles, isEmpty);
    expect(find.text('Masuk dulu untuk memberi vote'), findsOneWidget);
    expect(find.text('halaman login'), findsOneWidget);
    expect(
      router.routerDelegate.currentConfiguration.matches.map(
        (m) => m.matchedLocation,
      ),
      contains('/login'),
    );
  });
}
