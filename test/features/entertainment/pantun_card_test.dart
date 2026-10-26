import 'package:flutter/material.dart' show MaterialApp, Scaffold, Widget;
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/core/widgets/verified_badge_icon.dart';
import 'package:sambasku_mobile/features/entertainment/domain/pantun_models.dart';
import 'package:sambasku_mobile/features/entertainment/presentation/widgets/pantun_card.dart';

Future<String?> _noop(Pantun pantun, int value) async => null;

Pantun _pantun({
  String? displayName = 'Bujang Sambas',
  String? username = 'bujang_sambas',
  bool isVerifier = false,
  String? parentId,
  String scheme = 'ABAB',
}) => Pantun(
  id: 'p1',
  userId: 'u1',
  username: username,
  displayName: displayName,
  avatarUrl: null,
  parentId: parentId,
  language: 'id',
  themeId: null,
  rhymeScheme: scheme,
  lines: const [
    'Pagi hari ke pasar sambas',
    'Beli ikan sama terasi',
    'Kalau memang nak berbalas',
    'Balas pantun jangan tangisi',
  ],
  status: 'published',
  createdAt: DateTime(2026, 10, 25),
  updatedAt: null,
  isVerifier: isVerifier,
);

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    FTheme(
      data: foruiPalettes['zinc']!.light.touch,
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );

  testWidgets('handle @username tampil di baris bawah nama', (tester) async {
    await pump(tester, PantunCard(pantun: _pantun()));

    expect(find.text('Bujang Sambas'), findsOneWidget);
    expect(find.text('@bujang_sambas'), findsOneWidget);
    // Handle tidak sebaris dengan nama: nama di atas handle.
    final nameY = tester.getTopLeft(find.text('Bujang Sambas')).dy;
    final handleY = tester.getTopLeft(find.text('@bujang_sambas')).dy;
    expect(handleY, greaterThan(nameY));
  });

  testWidgets('tanpa display name: label = username, handle disembunyikan', (
    tester,
  ) async {
    await pump(
      tester,
      PantunCard(pantun: _pantun(displayName: null)),
    );

    expect(find.text('bujang_sambas'), findsOneWidget);
    expect(find.text('@bujang_sambas'), findsNothing);
  });

  testWidgets('penulis verifikator: centang tampil', (tester) async {
    await pump(
      tester,
      PantunCard(pantun: _pantun(isVerifier: true)),
    );

    expect(find.byType(VerifiedBadgeIcon), findsOneWidget);
  });

  testWidgets('tanpa onVoteToggle: bar vote tidak dirender', (tester) async {
    await pump(tester, PantunCard(pantun: _pantun()));

    expect(find.text('0'), findsNothing);
  });

  testWidgets('dengan onVoteToggle: count vote dirender', (tester) async {
    await pump(
      tester,
      PantunCard(
        pantun: _pantun().copyWith(upvotes: 3, downvotes: 1),
        onVoteToggle: _noop,
      ),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });
}
