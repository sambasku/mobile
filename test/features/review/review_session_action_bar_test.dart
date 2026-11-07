import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/review/presentation/pages/review_session_page.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

void main() {
  Widget bar({required bool closeQueue}) {
    return MaterialApp(
      theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        ...FLocalizations.localizationsDelegates,
      ],
      supportedLocales: const [Locale('id')],
      locale: const Locale('id'),
      builder: (context, child) =>
          FTheme(data: foruiPalettes['zinc']!.light.touch, child: child!),
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 400,
            child: ReviewSessionActionBar(
              pendingAction: null,
              canCorrect: true,
              canRewind: false,
              closeQueue: closeQueue,
              onApprove: () {},
              onCorrect: () {},
              onReject: () {},
              onSkip: () {},
              onRewind: () {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('kata sudah terverifikasi: tombol Tutup antrean, bukan Setujui', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(bar(closeQueue: true));
    await tester.pumpAndSettle();

    expect(find.text('Tutup'), findsOneWidget);
    expect(find.byIcon(FLucideIcons.check), findsNothing);
    expect(find.byIcon(FLucideIcons.x), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kata belum terverifikasi tetap memakai ikon setuju', (
    tester,
  ) async {
    await tester.pumpWidget(bar(closeQueue: false));
    await tester.pumpAndSettle();

    expect(find.text('Tutup antrean'), findsNothing);
    expect(find.byIcon(FLucideIcons.check), findsOneWidget);
    expect(find.byIcon(FLucideIcons.x), findsOneWidget);
  });
}
