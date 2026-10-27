import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/auth/presentation/widgets/legal_consent_sheet.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

/// Regresi anomali sheet consent:
/// 1. Idempoten: panggil ganda -> hanya SATU sheet (guard _legalSheetVisible).
/// 2. Gagal muat dokumen legal -> ada tombol "Muat ulang" (user tidak
///    terkunci tanpa jalan keluar selain Keluar).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Dio stubDio({int status = 200}) =>
      Dio(BaseOptions())..httpClientAdapter = _Adapter(status: status);

  Widget harness(Dio dio) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const _Trigger()),
      ],
    );
    return ProviderScope(
      overrides: [dioProvider.overrideWithValue(dio)],
      child: MaterialApp.router(
        theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          ...FLocalizations.localizationsDelegates,
        ],
        supportedLocales: const [Locale('id')],
        locale: const Locale('id'),
        routerConfig: router,
        builder: (context, routed) => FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: FToaster(child: routed ?? const SizedBox.shrink()),
        ),
      ),
    );
  }

  testWidgets('panggil ganda -> satu sheet saja (idempoten)', (tester) async {
    await tester.pumpWidget(harness(stubDio()));

    // Dua tap -> dua panggilan showLegalConsentSheet hampir bersamaan
    // (mensimulasikan rebuild shell yang memicu post-frame dua kali).
    await tester.tap(find.byKey(const Key('trigger')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('trigger')));
    await tester.pumpAndSettle();

    expect(find.text('SambasKu perlu izin kamu dulu'), findsOneWidget);

    // Kedua dokumen wajib bisa dibaca - accept-legal menuntut dua-duanya.
    expect(find.text('Syarat dan Ketentuan'), findsOneWidget);
    expect(find.text('Kebijakan Privasi'), findsOneWidget);
    expect(find.text('Baca'), findsNWidgets(2));

    // Tutup sheet supaya guard global terpasang untuk test berikutnya.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator).last);
    navigator.pop();
    await tester.pumpAndSettle();
  });

  testWidgets('gagal muat legal -> tombol Muat ulang muncul', (tester) async {
    await tester.pumpWidget(harness(stubDio(status: 500)));

    await tester.tap(find.byKey(const Key('trigger')));
    await tester.pumpAndSettle();

    expect(find.text('Dokumen belum bisa dimuat'), findsOneWidget);
    expect(find.text('Muat ulang'), findsOneWidget);
  });
}

class _Trigger extends ConsumerWidget {
  const _Trigger();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: FButton(
          key: const Key('trigger'),
          onPress: () => showLegalConsentSheet(context, ref),
          child: const Text('Buka'),
        ),
      ),
    );
  }
}

class _Adapter implements HttpClientAdapter {
  _Adapter({this.status = 200});
  final int status;

  static const _body =
      '{"data":{"terms":{"version":"2026-01-01"},"privacy":{"version":"2026-01-01"}}}';

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.path.endsWith('/legal/current') && status == 200) {
      return ResponseBody.fromString(
        _body,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString('{"message":"stub"}', status);
  }
}
