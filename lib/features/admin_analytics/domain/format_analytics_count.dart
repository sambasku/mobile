import '../../../core/utils/format_number.dart';

/// Angka analitik dengan pemisah ribuan Indonesia: `1500` → `1.500`.
String formatAnalyticsCount(int value) => formatRibuan(value);
