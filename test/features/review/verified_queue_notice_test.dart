import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/review/presentation/pages/review_session_page.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

void main() {
  testWidgets('ikon info sejajar puncak teks, bukan tengah vertikal', (
    tester,
  ) async {
    const message =
        'Sudah terverifikasi oleh @ibnulmutaki. Menyetujui hanya menutup antrean.';

    await tester.pumpWidget(
      MaterialApp(
        theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          ...FLocalizations.localizationsDelegates,
        ],
        supportedLocales: const [Locale('id')],
        locale: const Locale('id'),
        builder: (context, child) =>
            FTheme(data: foruiPalettes['zinc']!.light.touch, child: child!),
        home: const Scaffold(
          body: SizedBox(
            width: 280,
            child: VerifiedQueueNotice(message: message),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final icon = tester.getRect(find.byIcon(FLucideIcons.circleAlert));
    final text = tester.getRect(find.text(message));

    expect(text.height, greaterThan(icon.height * 2));
    expect((icon.top - text.top).abs(), lessThanOrEqualTo(4));
    expect(icon.center.dy, lessThan(text.top + text.height / 2));
  });
}
