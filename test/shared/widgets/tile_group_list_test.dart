import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'package:sambasku_mobile/shared/widgets/tile_group_list.dart';

class _Item {
  const _Item(this.id);
  final String id;
}

Widget _host({
  required List<_Item> items,
  required bool hasMore,
  required Future<void> Function() onLoadMore,
}) {
  return FTheme(
    data: FThemes.zinc.light.touch,
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 400,
          child: TileGroupList<_Item>(
            items: items,
            hasMore: hasMore,
            onLoadMore: onLoadMore,
            tileBuilder: (context, item) =>
                FTile(title: Text('item ${item.id}')),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('merender semua tile dan tidak memuat saat hasMore false',
      (tester) async {
    var loadMoreCalls = 0;
    await tester.pumpWidget(
      _host(
        items: const [_Item('a'), _Item('b'), _Item('c')],
        hasMore: false,
        onLoadMore: () async => loadMoreCalls++,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('item a'), findsOneWidget);
    expect(find.text('item b'), findsOneWidget);
    expect(find.text('item c'), findsOneWidget);
    expect(loadMoreCalls, 0);
  });

  testWidgets('memanggil onLoadMore saat list pendek (fill-check)',
      (tester) async {
    var loadMoreCalls = 0;
    await tester.pumpWidget(
      _host(
        items: const [_Item('a')],
        hasMore: true,
        onLoadMore: () async => loadMoreCalls++,
      ),
    );
    await tester.pumpAndSettle();

    // List 1 item lebih pendek dari viewport 400px -> autoload terpanggil.
    expect(loadMoreCalls, greaterThanOrEqualTo(1));
  });

  testWidgets('tidak loop request saat halaman kosong tanpa progress item',
      (tester) async {
    var loadMoreCalls = 0;
    await tester.pumpWidget(
      _host(
        items: const [_Item('a')],
        hasMore: true,
        onLoadMore: () async => loadMoreCalls++,
      ),
    );
    await tester.pumpAndSettle();

    final callsAfterFirst = loadMoreCalls;
    // items tidak bertambah (halaman kosong) -> fill-check berikutnya
    // tidak boleh memicu request lagi.
    await tester.pump(const Duration(seconds: 1));
    expect(loadMoreCalls, callsAfterFirst);
  });
}
