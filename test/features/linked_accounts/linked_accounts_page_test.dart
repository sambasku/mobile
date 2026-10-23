import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'package:sambasku_mobile/features/auth/presentation/providers/auth_login_providers.dart';
import 'package:sambasku_mobile/features/linked_accounts/presentation/models/linked_accounts_state.dart';
import 'package:sambasku_mobile/features/linked_accounts/presentation/pages/linked_accounts_page.dart';
import 'package:sambasku_mobile/features/linked_accounts/presentation/providers/linked_accounts_providers.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';

class _FakeNotifier extends LinkedAccountsNotifier {
  _FakeNotifier(this.initial);

  final LinkedAccountsState initial;

  @override
  LinkedAccountsState build() => initial;
}

Widget _host(LinkedAccountsState state, {bool githubEnabled = true}) {
  return ProviderScope(
    overrides: [
      linkedAccountsProvider.overrideWith(() => _FakeNotifier(state)),
      githubAuthEnabledProvider.overrideWithValue(githubEnabled),
    ],
    child: FTheme(
      data: foruiPalettes['zinc']!.light.touch,
      child: const MaterialApp(home: LinkedAccountsPage()),
    ),
  );
}

void main() {
  test('formatLinkedDate: ISO -> "12 Sep 2026", rusak -> "Terhubung"', () {
    expect(formatLinkedDate('2026-09-12T10:00:00.000Z'), '12 Sep 2026');
    expect(formatLinkedDate('2026-01-05T00:00:00.000Z'), '5 Jan 2026');
    expect(formatLinkedDate('bukan tanggal'), 'Terhubung');
  });

  testWidgets('satu grup, tile Google+GitHub, status ikut linked', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const LinkedAccountsState(
          isLoading: false,
          googleLinked: true,
          googleLinkedAt: '2026-09-12T10:00:00.000Z',
          githubLinked: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Google'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('Terhubung sejak 12 Sep 2026'), findsOneWidget);
    expect(find.text('Belum terhubung'), findsOneWidget);
    // Gaya profil: satu FTileGroup saja, tanpa tombol lebar di luar tile.
    expect(find.byType(FTileGroup), findsOneWidget);
    expect(find.byType(FButton), findsNothing);
  });

  testWidgets('GitHub disembunyikan bila tidak dikonfigurasi', (tester) async {
    await tester.pumpWidget(
      _host(const LinkedAccountsState(isLoading: false), githubEnabled: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Google'), findsOneWidget);
    expect(find.text('GitHub'), findsNothing);
  });

  testWidgets('tap tile terhubung membuka sheet konfirmasi lepas', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const LinkedAccountsState(isLoading: false, googleLinked: true)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Google'));
    await tester.pumpAndSettle();

    expect(find.text('Lepas Google?'), findsOneWidget);
    expect(find.text('Lepas'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);
  });
}
