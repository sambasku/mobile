import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_deck_item.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_target.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_view.dart';
import 'package:sambasku_mobile/features/vote/domain/failures/vote_failure.dart';
import 'package:sambasku_mobile/features/vote/domain/providers/vote_domain_providers.dart';
import 'package:sambasku_mobile/features/vote/domain/repositories/vote_repository.dart';
import 'package:sambasku_mobile/features/vote/domain/usecases/get_vote_deck_use_case.dart';
import 'package:sambasku_mobile/features/vote/domain/usecases/toggle_vote_use_case.dart';
import 'package:sambasku_mobile/features/vote/presentation/providers/vote_deck_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

VoteDeckItem _item(String id) => VoteDeckItem(
      id: id,
      lemma: 'kata-$id',
      languageId: 'lang',
      languageCode: 'id',
      wordType: 'noun',
      status: 'published',
      isVerified: true,
      approvedAt: '2026-01-01T00:00:00.000Z',
      sense: 'arti $id',
    );

class _FakeAuthStatus extends AuthStatusNotifier {
  @override
  Future<AuthStatusState> build() async =>
      const AuthStatusState(isAuth: true, username: 'tester');
}

class _FakeDeckRepo implements VoteRepository {
  _FakeDeckRepo(this.deckItems);

  List<VoteDeckItem> deckItems;
  final List<({VoteTarget target, int value})> toggles = [];

  @override
  Future<Either<VoteFailure, Map<String, VoteCounts>>> countMany(
    List<VoteTarget> targets,
  ) async =>
      Either.right({});

  @override
  Future<Either<VoteFailure, Map<String, int>>> myVotes(
    List<VoteTarget> targets,
  ) async =>
      Either.right({});

  @override
  Future<Either<VoteFailure, VoteView>> toggle(
    VoteTarget target,
    int value,
  ) async {
    toggles.add((target: target, value: value));
    return Either.right(VoteView(target: target, myVote: value));
  }

  @override
  Future<Either<VoteFailure, VoteDeckPage>> getDeck({
    int limit = 10,
    String? cursor,
  }) async {
    return Either.right(
      VoteDeckPage(items: List.of(deckItems), hasMore: false),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeDeckRepo repo;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = _FakeDeckRepo([_item('a'), _item('b'), _item('c')]);
    container = ProviderContainer(
      overrides: [
        authStatusProvider.overrideWith(_FakeAuthStatus.new),
        getVoteDeckUseCaseProvider.overrideWithValue(
          GetVoteDeckUseCase(repo),
        ),
        toggleVoteUseCaseProvider.overrideWithValue(
          ToggleVoteUseCase(repo),
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<VoteDeckState> ready() async {
    // Auth harus siap dulu: watch AsyncNotifier lain sebelum auth settle
    // bisa membuat .future deck menggantung.
    await container.read(authStatusProvider.future);
    return container.read(voteDeckControllerProvider.future);
  }

  test('skipAndAdvance menghapus kartu dan menyimpan rewind', () async {
    final initial = await ready();
    expect(initial.items.map((i) => i.id), ['a', 'b', 'c']);

    container
        .read(voteDeckControllerProvider.notifier)
        .skipAndAdvance(initial.items.first);

    final state = container.read(voteDeckControllerProvider).value!;
    expect(state.items.map((i) => i.id), ['b', 'c']);
    expect(state.canRewind, isTrue);
    expect(state.rewindEntry?.item.id, 'a');
    expect(state.rewindEntry?.kind, VoteDeckRewindKind.skip);
  });

  test('rewind skip mengembalikan kartu ke depan antrean', () async {
    final initial = await ready();
    container
        .read(voteDeckControllerProvider.notifier)
        .skipAndAdvance(initial.items.first);

    final failure =
        await container.read(voteDeckControllerProvider.notifier).rewind();

    expect(failure, isNull);
    final state = container.read(voteDeckControllerProvider).value!;
    expect(state.items.map((i) => i.id), ['a', 'b', 'c']);
    expect(state.canRewind, isFalse);
    expect(repo.toggles, isEmpty);
  });

  test('castAndAdvance + rewind memanggil toggle dua kali (vote lalu off)',
      () async {
    final initial = await ready();
    final first = initial.items.first;

    final castFailure = await container
        .read(voteDeckControllerProvider.notifier)
        .castAndAdvance(item: first, value: 1);
    expect(castFailure, isNull);
    expect(repo.toggles.length, 1);
    expect(repo.toggles.first.value, 1);

    var state = container.read(voteDeckControllerProvider).value!;
    expect(state.items.map((i) => i.id), ['b', 'c']);
    expect(state.rewindEntry?.kind, VoteDeckRewindKind.upvote);

    final rewindFailure =
        await container.read(voteDeckControllerProvider.notifier).rewind();
    expect(rewindFailure, isNull);
    expect(repo.toggles.length, 2);
    expect(repo.toggles.last.value, 1);

    state = container.read(voteDeckControllerProvider).value!;
    expect(state.items.map((i) => i.id), ['a', 'b', 'c']);
    expect(state.canRewind, isFalse);
  });
}
