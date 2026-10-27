import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gap/gap.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/activity/presentation/widgets/pinned_home_banner.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

/// Widget test banner pinned beranda: shrink saat kosong/error, tampil saat
/// ada pinned, tap navigasi ke /pinned, suffix multi-pinned.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.status, this.body);

  final int status;
  final Object? body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final payload = body == null ? '{}' : body.toString();
    return ResponseBody.fromString(
      payload,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

Dio _dio(int status, Object? body) =>
    Dio()..httpClientAdapter = _StubAdapter(status, body);

/// Adapter tak pernah menjawab -> provider tetap loading.
class _HangAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      Completer<ResponseBody>().future;
}

Widget _app(ProviderContainer container) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp.router(
    localizationsDelegates: [
      ...AppLocalizations.localizationsDelegates,
      ...FLocalizations.localizationsDelegates,
    ],
    supportedLocales: const [Locale('id')],
    locale: const Locale('id'),
    routerConfig: GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Scaffold(body: PinnedHomeBanner())),
        GoRoute(
          path: '/announcements/:id',
          name: 'ActivityRouter.announcementDetail',
          builder: (_, _) => const Scaffold(body: Text('HALAMAN DETAIL')),
        ),
      ],
    ),
  ),
);

String _ann(String id, String title) =>
    '"id":"$id","title":"$title","body":"Isi $title",'
    '"body_type":"plain","action_url":null,"action_label":null,'
    '"expires_at":null,"pinned_at":1799946600,"expired":false,'
    '"created_by":"01U","created_at":1799946600,"updated_at":null';

void main() {
  testWidgets('kosong: banner shrink total', (tester) async {
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(_dio(200, '{"success":true,"data":[]}')),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();
    expect(find.byType(PinnedHomeBanner), findsOneWidget);
    expect(find.text('Pengumuman prioritas'), findsNothing);
  });

  testWidgets('loading: skeleton tampil (#134), bukan muncul mendadak', (
    tester,
  ) async {
    // Adapter menggantung -> provider loading selamanya di frame test.
    final dio = Dio()..httpClientAdapter = _HangAdapter();
    final container = ProviderContainer(
      overrides: [dioProvider.overrideWithValue(dio)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    // pump 1 frame: provider AsyncLoading -> skeleton terpasang. Shimmer
    // jalan terus, jadi pumpAndSettle tidak pernah settle - jangan pakai.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    // Skeleton punya text dummy "Judul pengumuman prioritas" + Container.
    expect(find.text('Judul pengumuman prioritas'), findsOneWidget);
    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('error: banner shrink total', (tester) async {
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(
          _dio(500, '{"success":false,"error":{"code":"INTERNAL"}}'),
        ),
      ],
    );
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();
    expect(find.text('Pengumuman prioritas'), findsNothing);
    // Riverpod 3 menjadwalkan timer retry saat error; dispose eksplisit
    // membatalkan timer itu supaya tidak "Timer is still pending".
    container.dispose();
  });

  testWidgets('1 pinned: banner tampil, tap LANGSUNG ke detail (#134)', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(
          _dio(200, '{"success":true,"data":[{${_ann('01A', 'Jadwal Mudik')}}]}'),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();
    expect(find.text('Jadwal Mudik'), findsOneWidget);
    expect(find.text('Isi Jadwal Mudik'), findsOneWidget);
    // 1 item: tanpa dots.
    expect(find.byType(AnimatedContainer), findsNothing);

    await tester.tap(find.text('Jadwal Mudik'));
    await tester.pumpAndSettle();
    expect(find.text('HALAMAN DETAIL'), findsOneWidget);
  });

  testWidgets('2+ pinned: carousel full-bleed, snap + jarak antar kartu', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(
          _dio(
            200,
            '{"success":true,"data":[{${_ann('01A', 'Jadwal Mudik')}},'
            '{${_ann('01B', 'Lomba Kuis')}},{${_ann('01C', 'Rapat')}}]}',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();
    // Bukan lagi PageView: geser bebas via ListView horizontal + snap.
    expect(find.byType(PageView), findsNothing);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Jadwal Mudik'), findsOneWidget);
    // Indikator titik: satu per kartu.
    expect(find.byKey(const ValueKey('pinned_dot_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('pinned_dot_1')), findsOneWidget);
    expect(find.byKey(const ValueKey('pinned_dot_2')), findsOneWidget);

    // Jarak antar kartu = Gap murni; ukur saat tengah geseran supaya dua
    // kartu sama-sama hidup.
    await tester.drag(find.byType(ListView), const Offset(-200, 0));
    await tester.pump();
    expect(find.byType(Gap), findsWidgets);
    final r1 = tester.getRect(find.text('Jadwal Mudik'));
    final r2 = tester.getRect(find.text('Lomba Kuis'));
    expect(r2.left - r1.right, greaterThan(24));

    // Snap presisi: stride (kartu + Gap) = lebar viewport → mendarat pas
    // di batas halaman (pixels = 1x viewport).
    await tester.fling(find.byType(ListView), const Offset(-500, 0), 2000);
    await tester.pumpAndSettle();
    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(
      scrollable.position.pixels,
      closeTo(scrollable.position.viewportDimension, 0.5),
    );
    expect(find.text('Lomba Kuis'), findsWidgets);
    // Dot aktif ikut pindah ke halaman kedua (warna beda dari dot pertama).
    Color dotColor(int i) =>
        (tester.widget<Container>(find.byKey(ValueKey('pinned_dot_$i')))
                .decoration! as BoxDecoration)
            .color!;
    expect(dotColor(1), isNot(dotColor(0)));
  });

  testWidgets('geometri kartu: tinggi 82, gutter 12 full-bleed', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(
          _dio(200, '{"success":true,"data":[{${_ann('01A', 'Jadwal Mudik')}}]}'),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            ...FLocalizations.localizationsDelegates,
          ],
          supportedLocales: const [Locale('id')],
          locale: const Locale('id'),
          home: FTheme(
            data: foruiPalettes['zinc']!.dark.touch,
            child: FScaffold(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 16),
                children: const [PinnedHomeBanner()],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final list = tester.getRect(find.byType(ListView).first);
    final pin = tester.getRect(
      find
          .descendant(
            of: find.byType(PinnedHomeBanner),
            matching: find.byType(Container),
          )
          .first,
    );
    // Full-bleed: banner memasang gutter 12 sendiri (shell tak mempad).
    expect(pin.left - list.left, closeTo(12, 0.5));
    expect(list.right - pin.right, closeTo(12, 0.5));
    expect(pin.height, 82);
  });
}
