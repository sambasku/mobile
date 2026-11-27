import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:sambasku_mobile/shared/change_history/change_history_models.dart';
import 'package:sambasku_mobile/shared/change_history/change_history_timeline.dart';

/// Adapter stub: halaman 1 tanpa cursor, halaman 2 dengan cursor.
class _PagedAdapter implements HttpClientAdapter {
  _PagedAdapter(this.firstPage, this.secondPage, {this.status = 200});

  final Map<String, dynamic> firstPage;
  final Map<String, dynamic>? secondPage;
  final int status;
  final requests = <RequestOptions>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final hasCursor = options.queryParameters.containsKey('cursor');
    final body = hasCursor ? secondPage : firstPage;
    return ResponseBody.fromString(
      jsonEncode(body ?? {}),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

Map<String, dynamic> _entry(
  String id, {
  String actionLabel = 'Data diperbarui',
  String action = 'update',
  List<Map<String, dynamic>> changes = const [],
  Map<String, dynamic>? source,
  String type = '',
}) => {
  'id': id,
  'timestamp': DateTime.now()
      .subtract(const Duration(hours: 2))
      .toUtc()
      .toIso8601String(),
  'actor': {'user_id': 'u1', 'username': 'budiaja', 'display_name': 'Budi'},
  'action': action,
  'action_label': actionLabel,
  'entity': 'place',
  'type': ?(type.isEmpty ? null : type),
  'changes': changes,
  'source': source,
};

Map<String, dynamic> _page(
  List<Map<String, dynamic>> items, {
  bool hasMore = false,
  String? next,
}) => {
  'success': true,
  'data': items,
  'meta': {'limit': 20, 'next_cursor': next, 'has_more': hasMore},
};

Widget _app(ProviderContainer container) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp(
    localizationsDelegates: [
      ...AppLocalizations.localizationsDelegates,
      ...FLocalizations.localizationsDelegates,
    ],
    supportedLocales: const [Locale('id')],
    locale: const Locale('id'),
    builder: (context, child) =>
        FTheme(data: foruiPalettes[defaultPalette]!.light.touch, child: child!),
    home: const Scaffold(
      body: SingleChildScrollView(
        child: ChangeHistoryTimeline(
          path: '/api/v1/places/pantai/change-history',
          notFoundTitle: 'Data tidak ditemukan',
          emptyHint: 'Belum ada perubahan.',
        ),
      ),
    ),
  ),
);

ProviderContainer _container(_PagedAdapter adapter) => ProviderContainer(
  overrides: [
    dioProvider.overrideWithValue(Dio()..httpClientAdapter = adapter),
  ],
);

void main() {
  group('ChangeHistoryEntry.fromJson', () {
    test('bentuk kata: type, source usulan, label field kosong', () {
      final e = ChangeHistoryEntry.fromJson({
        'id': 'a',
        'timestamp': '2026-11-27T10:00:00.000Z',
        'actor': {'user_id': 'u', 'username': 'budiaja', 'display_name': ' '},
        'type': 'suggest_edit',
        'entity': 'meaning',
        'action': 'create',
        'action_label': 'Arti ditambahkan',
        'changes': [
          {'entity': 'meaning', 'field': 'definition', 'display_old': '-', 'display_new': 'makan'},
        ],
        'source': {
          'suggested_by': {'username': 'sariaja', 'display_name': 'Sari'},
          'reason': 'Perbaikan',
          'review_comment': null,
        },
      });
      expect(e.actorLabel, 'budiaja'); // display_name kosong -> username
      expect(e.fromSuggestion, isTrue);
      expect(e.suggestedByLabel, 'Sari');
      expect(e.reason, 'Perbaikan');
      expect(e.reviewComment, isNull);
      expect(e.fields.single.label, isNull);
    });

    test('bentuk eksplorasi: source contribution_id, label dari server', () {
      final e = ChangeHistoryEntry.fromJson(
        _entry(
          'b',
          source: {'contribution_id': 'c1'},
          changes: [
            {
              'field': 'name',
              'label': 'Nama',
              'display_old': 'A',
              'display_new': 'B',
            },
          ],
        ),
      );
      expect(e.fromSuggestion, isTrue);
      expect(e.suggestedByLabel, isNull);
      expect(e.fields.single.label, 'Nama');
    });
  });

  testWidgets('tampil judul aksi, pelaku, dan diff Sebelum/Sesudah', (
    tester,
  ) async {
    final adapter = _PagedAdapter(
      _page([
        _entry(
          'e1',
          actionLabel: 'Data diperbarui',
          changes: [
            {
              'field': 'name',
              'label': 'Nama',
              'display_old': 'Pantai Lama',
              'display_new': 'Pantai Baru',
            },
          ],
        ),
        _entry('e2', actionLabel: 'Wisata ditambahkan', action: 'create'),
      ]),
      null,
    );
    final container = _container(adapter);
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    expect(find.text('Data diperbarui'), findsOneWidget);
    expect(find.text('Wisata ditambahkan'), findsOneWidget);
    expect(find.text('Oleh Budi · 2 jam lalu'), findsNWidgets(2));
    expect(find.text('Nama'), findsOneWidget);
    expect(find.text('Sebelum: Pantai Lama'), findsOneWidget);
    expect(find.text('Sesudah: Pantai Baru'), findsOneWidget);
    expect(find.text('Muat lebih banyak'), findsNothing);
  });

  testWidgets('data baru (old "-") tampil nilai saja, usulan tampil lencana', (
    tester,
  ) async {
    final adapter = _PagedAdapter(
      _page([
        _entry(
          'e1',
          source: {'contribution_id': 'c1'},
          changes: [
            {
              'field': 'hours',
              'label': 'Jam buka',
              'display_old': '-',
              'display_new': '08.00-17.00',
            },
          ],
        ),
      ]),
      null,
    );
    final container = _container(adapter);
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    expect(find.text('08.00-17.00'), findsOneWidget);
    expect(find.textContaining('Sebelum'), findsNothing);
    expect(find.text('Dari usulan'), findsOneWidget);
  });

  testWidgets('lebih dari 3 field: ringkas, bisa dibuka', (tester) async {
    List<Map<String, dynamic>> fields = [
      for (var i = 1; i <= 5; i++)
        {
          'field': 'f$i',
          'label': 'Field $i',
          'display_old': 'lama $i',
          'display_new': 'baru $i',
        },
    ];
    final adapter = _PagedAdapter(
      _page([_entry('e1', changes: fields)]),
      null,
    );
    final container = _container(adapter);
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    expect(find.text('Field 3'), findsOneWidget);
    expect(find.text('Field 4'), findsNothing);
    await tester.tap(find.text('Lihat 2 perubahan lain'));
    await tester.pumpAndSettle();
    expect(find.text('Field 5'), findsOneWidget);
    expect(find.text('Tampilkan lebih sedikit'), findsOneWidget);
  });

  testWidgets('muat lebih: kirim cursor dan tambahkan baris', (tester) async {
    final adapter = _PagedAdapter(
      _page([_entry('e1', actionLabel: 'Satu')], hasMore: true, next: 'CUR1'),
      _page([_entry('e2', actionLabel: 'Dua')]),
    );
    final container = _container(adapter);
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    expect(find.text('Satu'), findsOneWidget);
    expect(find.text('Dua'), findsNothing);
    await tester.tap(find.text('Muat lebih banyak'));
    await tester.pumpAndSettle();

    expect(find.text('Satu'), findsOneWidget);
    expect(find.text('Dua'), findsOneWidget);
    expect(find.text('Muat lebih banyak'), findsNothing);
    expect(adapter.requests.last.queryParameters['cursor'], 'CUR1');
  });

  testWidgets('kosong: pesan + petunjuk dari pemanggil', (tester) async {
    final container = _container(_PagedAdapter(_page(const []), null));
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada riwayat'), findsOneWidget);
    expect(find.text('Belum ada perubahan.'), findsOneWidget);
  });

  testWidgets('404: tampil judul tidak ditemukan', (tester) async {
    final container = _container(
      _PagedAdapter({'success': false}, null, status: 404),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    expect(find.text('Data tidak ditemukan'), findsOneWidget);
  });
}
