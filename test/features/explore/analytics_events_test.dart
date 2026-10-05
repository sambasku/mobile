import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/services/analytics_service.dart';

void main() {
  test('event analytics eksplorasi terdaftar sebagai konstanta', () {
    // Guard: nama event tidak boleh typo/berubah tanpa sadar.
    expect(AnalyticsEvents.exploreCategoryTap, 'explore_category_tap');
    expect(AnalyticsEvents.poiOpen, 'poi_open');
    expect(AnalyticsEvents.wilayahKecSelect, 'wilayah_kec_select');
    expect(AnalyticsEvents.wilayahDesaSelect, 'wilayah_desa_select');
    expect(AnalyticsEvents.cuisineOpen, 'cuisine_open');
  });
}
