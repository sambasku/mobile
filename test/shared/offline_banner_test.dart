import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/network/connectivity_provider.dart';
import 'package:sambasku_mobile/shared/widgets/offline_banner.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

void main() {
  test('connectivity: semua none = offline, ada wifi = online', () {
    expect(connectivityResultsAreOffline([ConnectivityResult.none]), isTrue);
    expect(
      connectivityResultsAreOffline([
        ConnectivityResult.wifi,
        ConnectivityResult.none,
      ]),
      isFalse,
    );
    expect(connectivityResultsAreOffline(const []), isTrue);
  });

  testWidgets('banner: tampil saat offline, hilang saat online', (tester) async {
    final controller = StreamController<List<ConnectivityResult>>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityProvider.overrideWith((ref) => controller.stream),
        ],
        child: FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: MaterialApp(
            localizationsDelegates: const [
              ...AppLocalizations.localizationsDelegates,
              ...FLocalizations.localizationsDelegates,
            ],
            supportedLocales: const [Locale('id')],
            locale: const Locale('id'),
            home: const Scaffold(body: OfflineBanner()),
          ),
        ),
      ),
    );

    const offlineCopy =
        'Kamu lagi offline. Kamus tetap bisa dipakai dari data lokal.';

    // Frame pertama: belum ada event, dianggap online (banner hilang).
    expect(find.text(offlineCopy), findsNothing);

    // Offline event -> banner muncul (setelah debounce 2s).
    controller.add([ConnectivityResult.none]);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(find.text(offlineCopy), findsOneWidget);

    // Online lagi -> banner hilang tanpa debounce.
    controller.add([ConnectivityResult.wifi]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(offlineCopy), findsNothing);

    await controller.close();
  });

  testWidgets('banner: loading/null connectivity tidak stuck offline', (
    tester,
  ) async {
    final controller = StreamController<List<ConnectivityResult>>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityProvider.overrideWith((ref) => controller.stream),
        ],
        child: FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: MaterialApp(
            localizationsDelegates: const [
              ...AppLocalizations.localizationsDelegates,
              ...FLocalizations.localizationsDelegates,
            ],
            supportedLocales: const [Locale('id')],
            locale: const Locale('id'),
            home: const Scaffold(body: OfflineBanner()),
          ),
        ),
      ),
    );

    const offlineCopy =
        'Kamu lagi offline. Kamus tetap bisa dipakai dari data lokal.';

    controller.add([ConnectivityResult.none]);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(find.text(offlineCopy), findsOneWidget);

    // Emulasi stream reconnect tanpa event data baru: provider loading
    // tidak boleh mempertahankan/memicu offline palsu setelah online.
    controller.add([ConnectivityResult.wifi]);
    await tester.pump();
    expect(find.text(offlineCopy), findsNothing);

    await controller.close();
  });
}
