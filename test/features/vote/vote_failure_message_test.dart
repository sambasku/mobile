import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/features/vote/data/providers/vote_data_providers.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_deck_item.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_view.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_target.dart';
import 'package:sambasku_mobile/features/vote/domain/failures/vote_failure.dart';
import 'package:sambasku_mobile/features/vote/domain/providers/vote_domain_providers.dart';
import 'package:sambasku_mobile/features/vote/domain/repositories/vote_repository.dart';
import 'package:sambasku_mobile/features/vote/domain/usecases/get_vote_deck_use_case.dart';
import 'package:sambasku_mobile/features/vote/presentation/widgets/vote_deck_section.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthStatus extends AuthStatusNotifier {
  @override
  Future<AuthStatusState> build() async =>
      const AuthStatusState(isAuth: true, username: 'tester');
}

class _FailDeckRepo implements VoteRepository {
  _FailDeckRepo(this.failure);

  final VoteFailure failure;

  @override
  Future<Either<VoteFailure, VoteDeckPage>> getDeck({
    int limit = 10,
    String? cursor,
  }) async =>
      Either.left(failure);

  @override
  Future<Either<VoteFailure, Map<String, VoteCounts>>> countMany(
    List<VoteTarget> targets,
  ) async =>
      Either.right(const {});

  @override
  Future<Either<VoteFailure, Map<String, int>>> myVotes(
    List<VoteTarget> targets,
  ) async =>
      Either.right(const {});

  @override
  Future<Either<VoteFailure, VoteView>> toggle(
    VoteTarget target,
    int value,
  ) async =>
      Either.right(VoteView(target: target, upvotes: 0, downvotes: 0));

  @override
  Future<Either<VoteFailure, Unit>> skipWord(String wordId) async =>
      Either.right(unit);

  @override
  Future<Either<VoteFailure, Unit>> unskipWord(String wordId) async =>
      Either.right(unit);
}

void main() {
  // #109: pesan failure harus sampai ke UI (bukan "Instance of 'tTb'"
  // akibat obfuscation tanpa toString override).
  group('VoteFailure.toString', () {
    test('membawa message + errorCode', () {
      expect(
        const VoteFailure('Sesi berakhir', errorCode: 'TOKEN_EXPIRED')
            .toString(),
        'Sesi berakhir (TOKEN_EXPIRED)',
      );
    });

    test('tanpa errorCode hanya message', () {
      expect(
        const VoteFailure('Gagal memuat').toString(),
        'Gagal memuat',
      );
    });
  });

  testWidgets(
      'error state deck menampilkan message failure, bukan Instance of ...',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = _FailDeckRepo(
      const VoteFailure('Sesi berakhir', errorCode: 'TOKEN_EXPIRED'),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStatusProvider.overrideWith(_FakeAuthStatus.new),
          getVoteDeckUseCaseProvider.overrideWithValue(
            GetVoteDeckUseCase(repo),
          ),
          voteRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: const Scaffold(
              body: SizedBox(
              width: 800,
              height: 900,
              child: VoteDeckSection(),
            ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sesi berakhir (TOKEN_EXPIRED)'), findsOneWidget);
    expect(
      find.textContaining('Instance of'),
      findsNothing,
      reason: '#109: toString default tak boleh bocor ke layar',
    );
  });
}
