import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/activity/presentation/widgets/pinned_home_banner.dart';
import 'package:sambasku_mobile/features/discussion/presentation/widgets/discussion_home_banner.dart';

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

  testWidgets('2+ pinned: carousel swipable + dots, swipe pindah judul', (
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
    expect(find.byType(PageView), findsOneWidget);
    expect(find.text('Jadwal Mudik'), findsOneWidget);
    // Dots 3 (aktif memanjang).
    expect(find.byType(AnimatedContainer), findsNWidgets(3));

    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Lomba Kuis'), findsOneWidget);
    expect(find.text('Jadwal Mudik'), findsNothing);
  });

  testWidgets('geometri kartu seragam dengan banner Ruang Diskusi', (
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
          home: FTheme(
            data: FThemes.zinc.dark.touch,
            child: FScaffold(
              childPad: true,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 16),
                children: const [DiscussionHomeBanner(), PinnedHomeBanner()],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Kartu = Material Diskusi vs Container dalam PinnedHomeBanner.
    final disc = tester.getRect(
      find
          .descendant(
            of: find.byType(DiscussionHomeBanner),
            matching: find.byType(Material),
          )
          .first,
    );
    final pin = tester.getRect(
      find
          .descendant(
            of: find.byType(PinnedHomeBanner),
            matching: find.byType(Container),
          )
          .first,
    );
    // Tepi kiri/kanan & tinggi wajib identik - dua kartu beranda seragam.
    expect(pin.left, disc.left);
    expect(pin.right, disc.right);
    expect(pin.height, disc.height);

    // #134: tanpa spacing atas, dua kartu yang kini bergeometri sama tampak
    // menyatu. Wajib ada jeda vertikal yang jelas antar kartu.
    expect(pin.top - disc.bottom, greaterThanOrEqualTo(16));
  });
}
