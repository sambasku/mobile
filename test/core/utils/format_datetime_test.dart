import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/utils/format_datetime.dart';

void main() {
  test('formatDateYmd: YYYY-MM-DD tanpa geser zona', () {
    expect(formatDateYmd('2026-09-21'), '21 Sep 2026');
    expect(formatDateYmd('2026-08-02'), '2 Agu 2026');
    expect(formatDateYmd(null), '');
    expect(formatDateYmd('bukan-tanggal'), '');
  });

  test('formatRelativeAgo: singkat bahasa Indonesia', () {
    final now = DateTime(2026, 9, 28, 17, 0);
    expect(formatRelativeAgo(null, now: now), '');
    expect(
      formatRelativeAgo(now.subtract(const Duration(seconds: 20)), now: now),
      'baru saja',
    );
    expect(
      formatRelativeAgo(now.subtract(const Duration(minutes: 5)), now: now),
      '5 mnt lalu',
    );
    expect(
      formatRelativeAgo(now.subtract(const Duration(hours: 2)), now: now),
      '2 jam lalu',
    );
    expect(
      formatRelativeAgo(now.subtract(const Duration(days: 3)), now: now),
      '3 hari lalu',
    );
    expect(
      formatRelativeAgo(now.subtract(const Duration(days: 10)), now: now),
      '18 Sep 2026',
    );
  });

  test('formatRelativeCompact: humanize singkat', () {
    final now = DateTime(2026, 9, 28, 17, 0);
    expect(formatRelativeCompact(null, now: now), '');
    expect(
      formatRelativeCompact(now.subtract(const Duration(seconds: 20)), now: now),
      'baru',
    );
    expect(
      formatRelativeCompact(now.subtract(const Duration(minutes: 12)), now: now),
      '12m',
    );
    expect(
      formatRelativeCompact(now.subtract(const Duration(hours: 2)), now: now),
      '2h',
    );
    expect(
      formatRelativeCompact(now.subtract(const Duration(days: 3)), now: now),
      '3d',
    );
    expect(
      formatRelativeCompact(now.subtract(const Duration(days: 10)), now: now),
      '18 Sep',
    );
  });
}
