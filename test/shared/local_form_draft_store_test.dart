import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/shared/state/local_form_draft_store.dart';

void main() {
  setUp(() => LocalFormDraftStore.instance.clearAll());

  test('peek mengembalikan nilai yang disimpan, lalu remove mengosongkan', () {
    const key = 'acara:create';
    LocalFormDraftStore.instance.put(key, 'pasar malam');

    expect(LocalFormDraftStore.instance.peek<String>(key), 'pasar malam');
    expect(LocalFormDraftStore.instance.peek<int>(key), isNull);

    LocalFormDraftStore.instance.remove(key);
    expect(LocalFormDraftStore.instance.peek<String>(key), isNull);
  });
}
