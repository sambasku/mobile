import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/activity/presentation/providers/contribution_guide_providers.dart';
import 'package:sambasku_mobile/features/activity/presentation/widgets/contribution_guide_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guide swipe tab Kontribusi: hanya tap "Mengerti" yang menulis flag
/// lokal. Full-screen overlay dengan barrierDismissible=false.
void main() {
  late ProviderContainer container;

  Future<void> pump(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    // Lebar layar lebih besar supaya FButton tidak overflow
    tester.view.physicalSize = const Size(480, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return MaterialApp(
              theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
              localizationsDelegates: FLocalizations.localizationsDelegates,
              supportedLocales: FLocalizations.supportedLocales,
              builder: (context, child) =>
                  FTheme(data: FThemes.zinc.light.touch, child: child!),
              home: const Scaffold(body: SizedBox.expand()),
            );
          },
        ),
      ),
    );
    await tester.pump();

    final context = tester.element(find.byType(Scaffold));
    unawaited(showContributionGuideSheet(context));
    await tester.pumpAndSettle();
    expect(find.text('Kartu bisa digeser untuk menilai'), findsOneWidget);
  }

  Future<String?> readFlag() async {
    final prefs = await container.read(contributionGuidePrefsProvider.future);
    return prefs.getString(kContribGuideReadPrefsKey);
  }

  testWidgets('tap Mengerti menulis flag lokal', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Mengerti'));
    await tester.pumpAndSettle();

    expect(await readFlag(), isNotNull);
  });

  testWidgets('barrier tidak bisa di-dismiss (tap di luar / drag)', (tester) async {
    await pump(tester);

    // Coba tap di luar dialog (barrier) - tidak boleh tertutup
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // Dialog masih terbuka
    expect(find.text('Kartu bisa digeser untuk menilai'), findsOneWidget);
    // Flag tidak tertulis
    expect(await readFlag(), isNull);
  });
}