import 'package:intl/intl.dart';

final _ribuan = NumberFormat.decimalPattern('id');

/// Pemisah ribuan Indonesia: `1234` → `1.234`, `1234.5` → `1.234,5`.
String formatRibuan(num value) => _ribuan.format(value);
