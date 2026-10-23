import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_view.dart';
import 'package:sambasku_mobile/features/vote/domain/failures/vote_failure.dart';
import 'package:sambasku_mobile/features/vote/presentation/providers/meaning_vote_providers.dart';
import 'package:sambasku_mobile/features/vote/presentation/widgets/meaning_vote_row.dart';

/// Vote per baris makna: angka dari state batch, tombol hanya upvote.
void main() {
  Future<void> pumpRow(
    WidgetTester tester,
    MeaningVotesState state, {
    void Function(int value)? onVote,
  }) async {
    final container = ProviderContainer(
      overrides: [
        authStatusProvider.overrideWith(
          () => _FakeAuth(const AuthStatusState(isAuth: true, role: 'user')),
        ),
        meaningVotesControllerProvider.overrideWith(
          () => _StubMeaningVotes(state, onVote),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Auth provider async - tunggu resolved biar `ref.read(...).value` tidak
    // null (guard login di widget akan menolak vote kalau belum tahu status).
    await container.read(authStatusProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: FTheme(
            data: foruiPalettes['zinc']!.light.touch,
            child: Scaffold(
              body: MeaningVoteRow(meaningId: 'm1'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('angka vote per makna tampil dari state batch', (tester) async {
    await pumpRow(
      tester,
      const MeaningVotesState(
        counts: {'meaning:m1': VoteCounts(upvotes: 7, downvotes: 2)},
      ),
    );

    expect(find.text('7'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('makna tanpa vote = 0/0, bukan angka kosong', (tester) async {
    await pumpRow(tester, const MeaningVotesState());

    expect(find.text('0'), findsNWidgets(2));
  });

  testWidgets('tap upvote meneruskan arah ke controller', (tester) async {
    int? clicked;
    await pumpRow(
      tester,
      const MeaningVotesState(
        counts: {'meaning:m1': VoteCounts(upvotes: 1, downvotes: 0)},
      ),
      onVote: (value) => clicked = value,
    );

    await tester.tap(find.byIcon(FLucideIcons.arrowBigUp));
    await tester.pump();

    expect(clicked, 1);
  });

  testWidgets('vote aktif ditandai (myVote = 1)', (tester) async {
    await pumpRow(
      tester,
      const MeaningVotesState(
        counts: {'meaning:m1': VoteCounts(upvotes: 1, downvotes: 0)},
        myVotes: {'meaning:m1': 1},
      ),
    );

    // Panah upvote aktif = ikon di dalam badge foreground, bukan warna saja.
    expect(find.byIcon(FLucideIcons.arrowBigUp), findsOneWidget);
    expect(find.byIcon(FLucideIcons.arrowBigDown), findsOneWidget);
  });
}

class _FakeAuth extends AuthStatusNotifier {
  _FakeAuth(this.authState);

  final AuthStatusState authState;

  @override
  Future<AuthStatusState> build() async => authState;
}

class _StubMeaningVotes extends MeaningVotesController {
  _StubMeaningVotes(this.state, this.onVote);

  @override
  final MeaningVotesState state;
  final void Function(int value)? onVote;

  @override
  MeaningVotesState build() => state;

  @override
  Future<VoteFailure?> toggle(String meaningId, int value) async {
    onVote?.call(value);
    return null;
  }
}
