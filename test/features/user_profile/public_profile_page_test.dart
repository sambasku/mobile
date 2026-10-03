import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/features/activity/presentation/widgets/activity_feed_tile.dart';
import 'package:sambasku_mobile/features/user_profile/domain/entities/public_profile.dart';
import 'package:sambasku_mobile/features/user_profile/presentation/pages/public_profile_page.dart';
import 'package:sambasku_mobile/features/user_profile/presentation/providers/user_profile_providers.dart';
import 'package:sambasku_mobile/shared/widgets/small_button.dart';

class _FakeAuthStatus extends AuthStatusNotifier {
  _FakeAuthStatus(this.username);

  final String? username;

  @override
  Future<AuthStatusState> build() async =>
      AuthStatusState(isAuth: username != null, username: username);
}

const _profile = PublicProfile(
  username: 'budi',
  displayName: 'Budi',
  role: 'contributor',
  isVerifier: false,
  joinedAt: '2026-08-01T00:00:00.000Z',
  contributionsApproved: 2,
  verificationsDone: 0,
  commentsPublished: 0,
);

final _activity = [
  const PublicActivityItem(
    id: '01ACT0000000000000000001',
    kind: 'contribution',
    occurredAt: '2026-09-30T10:00:00.000Z',
    summary: 'menambahkan "kumis"',
    wordId: 'w1',
    lemma: 'kumis',
  ),
  const PublicActivityItem(
    id: '01ACT0000000000000000002',
    kind: 'comment',
    occurredAt: '2026-09-29T10:00:00.000Z',
    summary: 'bagus nih',
  ),
];

Future<void> _pump(
  WidgetTester tester, {
  String? sessionUsername,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStatusProvider.overrideWith(
          () => _FakeAuthStatus(sessionUsername),
        ),
        publicProfileProvider('budi').overrideWith((ref) async => _profile),
        publicActivityProvider('budi').overrideWith((ref) async => _activity),
      ],
      child: MaterialApp(
        localizationsDelegates: FLocalizations.localizationsDelegates,
        supportedLocales: FLocalizations.supportedLocales,
        builder: (context, child) =>
            FTheme(data: FThemes.zinc.light.touch, child: child!),
        home: const PublicProfilePage(username: 'budi'),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('aktivitas terbaru dirender sebagai ActivityFeedTile',
      (tester) async {
    await _pump(tester);

    expect(find.byType(ActivityFeedTile), findsNWidgets(2));
    expect(find.byType(FTileGroup), findsNothing);
    // Body dirender sebagai Text.rich (splitQuotedLemma), bukan Text polos.
    expect(find.textContaining('bagus nih'), findsOneWidget);
  });

  testWidgets('stat profil dirender inline, bukan kartu', (tester) async {
    await _pump(tester);

    expect(find.textContaining('kontribusi'), findsOneWidget);
    expect(find.textContaining('verifikasi'), findsOneWidget);
    expect(find.textContaining('komentar'), findsOneWidget);
  });

  testWidgets('profil orang lain: tanpa tombol Edit, CTA tile tampil',
      (tester) async {
    await _pump(tester);

    expect(find.byType(SmallButton), findsNothing);
    expect(find.byIcon(FLucideIcons.chevronRight), findsOneWidget);
    expect(find.text('Lihat arti'), findsOneWidget);
  });

  testWidgets('profil sendiri: tombol Edit kecil tampil, CTA tile disembunyikan',
      (tester) async {
    await _pump(tester, sessionUsername: 'budi');

    final edit = find.byType(SmallButton);
    expect(edit, findsOneWidget);
    expect(find.descendant(of: edit, matching: find.text('Edit')),
        findsOneWidget);
    expect(find.byIcon(FLucideIcons.chevronRight), findsNothing);
    expect(find.text('Lihat arti'), findsNothing);
    // Body tetap dirender.
    expect(find.textContaining('bagus nih'), findsOneWidget);
  });
}
