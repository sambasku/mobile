import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/activity/presentation/pages/pinned_announcements_page.dart';
import 'package:sambasku_mobile/features/activity/presentation/providers/announcement_detail_provider.dart';

/// Widget test halaman pinned: empty / single / carousel / error.
/// Dio di-stub via HttpClientAdapter (pola announcement_detail_provider_test).
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

Widget _app(ProviderContainer container) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp.router(
    routerConfig: GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const PinnedAnnouncementsPage()),
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
  testWidgets('empty: shrink, teks tidak ada yang dipin', (tester) async {
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(_dio(200, '{"success":true,"data":[]}')),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();
    expect(find.text('Tidak ada pengumuman yang dipin'), findsOneWidget);
  });

  testWidgets('single: satu card, tanpa carousel dots', (tester) async {
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(
          _dio(200, '{"success":true,"data":[{${_ann('01A', 'Satu')}}]}'),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();
    expect(find.text('Satu'), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
  });

  testWidgets('carousel: 3 item, PageView + indicator semantics', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(
          _dio(
            200,
            '{"success":true,"data":[{${_ann('01A', 'Satu')}},'
            '{${_ann('01B', 'Dua')}},{${_ann('01C', 'Tiga')}}]}',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();
    expect(find.byType(PageView), findsOneWidget);
    expect(find.text('Satu'), findsOneWidget);
    // Item ke-2/3 belum dibangun (lazy PageView.builder).
    expect(find.text('Dua', skipOffstage: false), findsNothing);
    // Indikator aksesibel.
    expect(
      find.bySemanticsLabel(RegExp('Indikator halaman carousel, 1 dari 3')),
      findsOneWidget,
    );
  });

  testWidgets('error: pesan gagal + tombol Coba lagi', (tester) async {
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(
          _dio(500, '{"success":false,"error":{"code":"INTERNAL"}}'),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();
    expect(find.text('Gagal memuat pengumuman'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  test('provider: item tanpa id/title/body dibuang (hardening)', () async {
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(
          _dio(
            200,
            '{"success":true,"data":['
            '{${_ann('01A', "Valid")}},'
            '{"title":"Tanpa id","body":"x"},'
            '{"id":"01C","body":"tanpa title"}]}',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final items = await container.read(
      pinnedAnnouncementsProvider(null).future,
    );
    expect(items, hasLength(1));
    expect(items.first.title, 'Valid');
  });
}
