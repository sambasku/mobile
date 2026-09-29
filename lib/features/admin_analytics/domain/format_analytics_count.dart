/// Format angka analitik untuk UI mobile yang sempit.
///
/// - `< 1000` → `999`
/// - `1000` → `1k`
/// - `1500` → `1.5k`
/// - `15000` → `15k`
String formatAnalyticsCount(int value) {
  final sign = value < 0 ? '-' : '';
  final n = value.abs();
  if (n < 1000) return '$sign$n';

  if (n < 10000) {
    final tenths = (n / 100).round(); // 1500 → 15 → 1.5
    if (tenths % 10 == 0) return '$sign${tenths ~/ 10}k';
    return '$sign${tenths ~/ 10}.${tenths % 10}k';
  }

  if (n < 1000000) {
    final k = (n / 1000).round();
    return '$sign${k}k';
  }

  final millions = n / 1000000;
  if ((millions * 10).round() % 10 == 0) {
    return '$sign${millions.round()}jt';
  }
  return '$sign${millions.toStringAsFixed(1)}jt';
}
