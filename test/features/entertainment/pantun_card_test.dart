import 'package:flutter/material.dart'
    show FontWeight, Icon, Locale, MaterialApp, Scaffold, Text, Widget;
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/core/widgets/verified_badge_icon.dart';
import 'package:sambasku_mobile/features/entertainment/domain/pantun_models.dart';
import 'package:sambasku_mobile/features/entertainment/presentation/widgets/pantun_card.dart';
import 'package:sambasku_mobile/features/entertainment/presentation/widgets/pantun_vote_bar.dart';

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
      child: MaterialApp(
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          ...FLocalizations.localizationsDelegates,
        ],
        supportedLocales: const [Locale('id')],
        locale: const Locale('id'),
        home: Scaffold(body: child),
      ),
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
    await pump(tester, PantunCard(pantun: _pantun(displayName: null)));

    expect(find.text('bujang_sambas'), findsOneWidget);
    expect(find.text('@bujang_sambas'), findsNothing);
  });

  testWidgets('penulis verifikator: centang tampil', (tester) async {
    await pump(tester, PantunCard(pantun: _pantun(isVerifier: true)));

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

  testWidgets('badge pola rima tidak ditampilkan', (tester) async {
    await pump(tester, PantunCard(pantun: _pantun(scheme: 'ABAB')));

    expect(find.text('ABAB'), findsNothing);
  });

  testWidgets('baris pembayang redup, baris isi tegas', (tester) async {
    await pump(tester, PantunCard(pantun: _pantun()));

    final pembayang = tester.widget<Text>(
      find.text('Pagi hari ke pasar sambas'),
    );
    final isi = tester.widget<Text>(find.text('Kalau memang nak berbalas'));

    expect(pembayang.style?.fontWeight, FontWeight.w400);
    expect(isi.style?.fontWeight, FontWeight.w600);
    expect(pembayang.style?.color, isNot(isi.style?.color));
  });

  testWidgets('panah vote tidak menyusut walau kartu punya footer hapus', (
    tester,
  ) async {
    Future<double> voteWidth({required bool withFooter}) async {
      await pump(
        tester,
        PantunCard(
          pantun: _pantun().copyWith(upvotes: 3, downvotes: 1),
          onVoteToggle: _noop,
          footer: withFooter ? PantunActionRow.delete(onDelete: () {}) : null,
        ),
      );
      return tester.getSize(find.byType(PantunVoteBar)).width;
    }

    final without = await voteWidth(withFooter: false);
    final withFooter = await voteWidth(withFooter: true);

        // Vote dan footer berbagi satu baris (gaya ThreadMessageRow), tapi
        // Align memberi constraint longgar - lebar vote tetap natural,
        // tidak disusutkan Spacer/Flexible seperti versi lama.
    expect(withFooter, without);
    expect(tester.widget<Icon>(find.byIcon(FLucideIcons.arrowBigUp)).size, 14);
  });

  testWidgets('footer hapus: ikon trash saja, label lewat Semantics', (
    tester,
  ) async {
    await pump(
      tester,
      PantunCard(
        pantun: _pantun(),
        footer: PantunActionRow.delete(onDelete: () {}),
      ),
    );
    expect(find.text('Hapus'), findsNothing);
    expect(find.byIcon(FLucideIcons.trash), findsOneWidget);
    expect(find.byIcon(FLucideIcons.flag), findsNothing);
    expect(
      tester.getSemantics(find.byIcon(FLucideIcons.trash)),
      matchesSemantics(
        label: 'Hapus',
        isButton: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
  });

  testWidgets('footer lapor: ikon flag saja, label lewat Semantics', (
    tester,
  ) async {
    await pump(
      tester,
      PantunCard(
        pantun: _pantun(),
        footer: PantunActionRow.report(onReport: () {}),
      ),
    );
    expect(find.text('Laporkan'), findsNothing);
    expect(find.byIcon(FLucideIcons.flag), findsOneWidget);
    expect(find.byIcon(FLucideIcons.trash), findsNothing);
    expect(
      tester.getSemantics(find.byIcon(FLucideIcons.flag)),
      matchesSemantics(
        label: 'Laporkan',
        isButton: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
  });
}
