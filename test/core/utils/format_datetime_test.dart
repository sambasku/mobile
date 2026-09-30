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

  test('isPlausibleInstant: tolak tanggal jauh di masa depan (#47)', () {
    final now = DateTime(2026, 9, 28, 17, 0);
    expect(isPlausibleInstant(now.subtract(const Duration(hours: 3)), now: now), isTrue);
    expect(isPlausibleInstant(now, now: now), isTrue);
    // Kemiringan jam sedikit masih wajar.
    expect(isPlausibleInstant(now.add(const Duration(hours: 2)), now: now), isTrue);
    // Epoch ms terbaca sebagai detik -> tahun 50.000-an.
    expect(
      isPlausibleInstant(DateTime.parse('+058716-09-15T00:00:00.000Z'), now: now),
      isFalse,
    );
    expect(isPlausibleInstant(null, now: now), isFalse);
  });

  test('formatRelative* tidak merender "baru" untuk timestamp mustahil (#47)', () {
    final now = DateTime(2026, 9, 28, 17, 0);
    final corrupt = DateTime.parse('+058716-09-15T00:00:00.000Z');

    // Tanpa guard, selisih negatif di-clamp jadi nol -> "baru saja"/"baru".
    expect(formatRelative(corrupt, now: now), '');
    expect(formatRelativeAgo(corrupt, now: now), '');
    expect(formatRelativeCompact(corrupt, now: now), '');

    // Nilai yang sah tetap berfungsi.
    expect(
      formatRelativeCompact(now.subtract(const Duration(minutes: 5)), now: now),
      '5m',
    );
  });
}
