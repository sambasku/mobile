import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/search_history_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pump({
    Map<String, Object> values = const {},
  }) async {
    SharedPreferences.setMockInitialValues(values);
    await SearchHistoryController.preload();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  test('record: simpan query, terbaru di atas', () async {
    final c = await pump();
    await c.read(searchHistoryControllerProvider.notifier).record('ange');
    await c.read(searchHistoryControllerProvider.notifier).record('sabak');
    expect(c.read(searchHistoryControllerProvider), ['sabak', 'ange']);
  });

  test('record: dedup case-insensitive, digeser ke atas', () async {
    final c = await pump();
    await c.read(searchHistoryControllerProvider.notifier).record('ange');
    await c.read(searchHistoryControllerProvider.notifier).record('ANGE');
    expect(c.read(searchHistoryControllerProvider), ['ANGE']);
  });

  test('record: query pendek (<2 char) diabaikan', () async {
    final c = await pump();
    await c.read(searchHistoryControllerProvider.notifier).record('a');
    expect(c.read(searchHistoryControllerProvider), isEmpty);
  });

  test('record: cap 10 entri, yang tertua dibuang', () async {
    final c = await pump();
    final n = c.read(searchHistoryControllerProvider.notifier);
    for (var i = 0; i < 12; i++) {
      await n.record('kata$i');
    }
    final list = c.read(searchHistoryControllerProvider);
    expect(list.length, 10);
    expect(list.first, 'kata11');
    expect(list.contains('kata0'), isFalse);
  });

  test('remove: hapus satu entri', () async {
    final c = await pump(
      values: {
        SearchHistoryController.prefKey: ['ange', 'sabak'],
      },
    );
    await c.read(searchHistoryControllerProvider.notifier).remove('sabak');
    expect(c.read(searchHistoryControllerProvider), ['ange']);
  });

  test('clear: kosongkan semua', () async {
    final c = await pump(
      values: {
        SearchHistoryController.prefKey: ['ange', 'sabak'],
      },
    );
    await c.read(searchHistoryControllerProvider.notifier).clear();
    expect(c.read(searchHistoryControllerProvider), isEmpty);
  });

  test('preload: seed dari SharedPreferences', () async {
    final c = await pump(
      values: {
        SearchHistoryController.prefKey: ['ange', 'sabak'],
      },
    );
    expect(c.read(searchHistoryControllerProvider), ['ange', 'sabak']);
  });
}
