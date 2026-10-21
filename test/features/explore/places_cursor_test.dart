import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/explore/data/datasources/places_remote_datasource.dart';

Map<String, dynamic> _page(List<String> ids, String? cursor) => {
  'success': true,
  'data': {
    'items': [
      for (final id in ids) {'id': id, 'slug': id, 'name': id},
    ],
    'next_cursor': cursor,
  },
};

void main() {
  test('mengikuti next_cursor sampai halaman terakhir', () async {
    final calls = <String?>[];
    final envelope = await walkPlaceCursors(
      fetchPage: (before) async {
        calls.add(before);
        return switch (calls.length) {
          1 => _page(['a', 'b'], 'b'),
          2 => _page(['c'], null),
          _ => _page(const [], null),
        };
      },
    );

    expect(calls, [null, 'b']);
    final places = envelope['places'] as List;
    expect(places.map((p) => (p as Map)['id']), ['a', 'b', 'c']);
  });

  test('cursor yang berulang dihentikan', () async {
    var calls = 0;
    final envelope = await walkPlaceCursors(
      fetchPage: (before) async {
        calls++;
        return _page(['x$calls'], 'stuck');
      },
    );

    expect(calls, 2);
    expect((envelope['places'] as List).length, 2);
  });

  test('berhenti di maxPages', () async {
    var calls = 0;
    await walkPlaceCursors(
      maxPages: 2,
      fetchPage: (before) async {
        calls++;
        return _page(['p$calls'], 'c$calls');
      },
    );

    expect(calls, 2);
  });
}
