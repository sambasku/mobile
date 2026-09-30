import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/shared/dev_tool/exception_log/exception_log.dart';

void main() {
  test('menambah record baru', () {
    final buffer = ExceptionLogBuffer(clock: () => DateTime.utc(2026, 1, 1));
    buffer.add('boom', StackTrace.empty);
    expect(buffer.records.value, hasLength(1));
    expect(buffer.records.value.single.message, 'boom');
    expect(buffer.records.value.single.count, 1);
    expect(buffer.records.value.single.stack, isEmpty);
  });

  test('pesan sama dalam 2 detik menaikkan hitungan', () {
    var now = DateTime.utc(2026, 1, 1);
    final buffer = ExceptionLogBuffer(clock: () => now);
    buffer.add('boom', StackTrace.empty);
    now = now.add(const Duration(seconds: 2));
    buffer.add('boom', StackTrace.empty);
    expect(buffer.records.value, hasLength(1));
    expect(buffer.records.value.single.count, 2);
    expect(buffer.records.value.single.at, now);
    expect(buffer.records.value.single.reportText, 'boom\n(2 kali)');
  });

  test('pesan sama setelah jendela 2 detik jadi baris baru', () {
    var now = DateTime.utc(2026, 1, 1);
    final buffer = ExceptionLogBuffer(clock: () => now);
    buffer.add('boom', StackTrace.empty);
    now = now.add(const Duration(seconds: 2, milliseconds: 1));
    buffer.add('boom', StackTrace.empty);
    expect(buffer.records.value, hasLength(2));
    expect(buffer.records.value.first.count, 1);
    expect(buffer.records.value.last.count, 1);
  });

  test('kapasitas 50 membuang yang terlama', () {
    var tick = 0;
    final buffer = ExceptionLogBuffer(
      clock: () => DateTime.utc(2026).add(Duration(seconds: tick)),
    );
    for (var n = 0; n < 51; n++) {
      tick = n * 3;
      buffer.add('e$n', StackTrace.empty);
    }
    final records = buffer.records.value;
    expect(records, hasLength(50));
    expect(records.first.message, 'e50');
    expect(records.last.message, 'e1');
  });
}
