import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:sambasku_mobile/core/utils/format_number.dart';

void main() {
  test('formatRibuan memakai titik ribuan dan koma desimal', () {
    expect(formatRibuan(0), '0');
    expect(formatRibuan(999), '999');
    expect(formatRibuan(1234), '1.234');
    expect(formatRibuan(1234.5), '1.234,5');
    expect(formatRibuan(-1500), '-1.500');
    expect(formatRibuan(1250000), '1.250.000');
  });

  test('locale id_SBS jatuh ke pemisah Indonesia', () {
    expect(NumberFormat.decimalPattern('id_SBS').format(1234), '1.234');
  });
}
