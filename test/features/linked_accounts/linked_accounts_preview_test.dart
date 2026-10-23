import 'dart:io';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'package:sambasku_mobile/app.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_login_providers.dart';
import 'package:sambasku_mobile/features/linked_accounts/presentation/models/linked_accounts_state.dart';
import 'package:sambasku_mobile/features/linked_accounts/presentation/pages/linked_accounts_page.dart';
import 'package:sambasku_mobile/features/linked_accounts/presentation/providers/linked_accounts_providers.dart';

/// Preview driver: render LinkedAccountsPage persis dengan tema app
/// (zinc touch) dalam dark + light, simpan PNG. Bukan test assert -
/// exit code selalu 0 bila render sukses.
class _FakeNotifier extends LinkedAccountsNotifier {
  _FakeNotifier(this.initial);

  final LinkedAccountsState initial;

  @override
  LinkedAccountsState build() => initial;
}

Future<void> _capture(
  WidgetTester tester,
  LinkedAccountsState state,
  String path, {
  required Brightness brightness,
}) async {
  final palette = foruiPalettes[defaultPalette]!;
  final ftheme =
      brightness == Brightness.dark ? palette.dark.touch : palette.light.touch;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        linkedAccountsProvider.overrideWith(() => _FakeNotifier(state)),
        githubAuthEnabledProvider.overrideWithValue(true),
      ],
      child: FTheme(
        data: ftheme,
        child: RepaintBoundary(
          key: const ValueKey('preview'),
          child: MaterialApp(
            theme: App.materialTheme(ftheme),
            darkTheme: App.materialTheme(ftheme),
            themeMode:
                brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
            home: const LinkedAccountsPage(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('preview')),
  );
  // toImage/toByteData adalah async GPU work - harus di dalam runAsync,
  // kalau tidak future-nya tidak pernah selesai di fake async zone test.
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 3.0);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  File(path).writeAsBytesSync(bytes!);
}

void main() {
  testWidgets('preview linked accounts', (tester) async {
    tester.view.physicalSize = const Size(1080, 2372) / 1.5;
    tester.view.devicePixelRatio = 1.0;
    await _capture(
      tester,
      const LinkedAccountsState(
        isLoading: false,
        googleLinked: true,
        googleLinkedAt: '2026-09-12T10:00:00.000Z',
        githubLinked: false,
      ),
      '/tmp/linked_accounts_dark.png',
      brightness: Brightness.dark,
    );
    await _capture(
      tester,
      const LinkedAccountsState(
        isLoading: false,
        googleLinked: true,
        googleLinkedAt: '2026-09-12T10:00:00.000Z',
        githubLinked: false,
      ),
      '/tmp/linked_accounts_light.png',
      brightness: Brightness.light,
    );
  }, timeout: const Timeout(Duration(minutes: 2)));
}
