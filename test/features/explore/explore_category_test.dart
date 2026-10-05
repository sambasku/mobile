import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/explore/domain/explore_category.dart';

void main() {
  test('kategori aktif: wisata + kuliner selalu ada', () {
    final active = ExploreCategory.all.where((c) => !c.comingSoon);
    expect(active.map((c) => c.id), containsAll(['wisata', 'kuliner']));
  });

  test('comingSoon mayoritas: filter memang mengurangi jumlah kartu', () {
    final active = ExploreCategory.all.where((c) => !c.comingSoon).length;
    final coming = ExploreCategory.all.where((c) => c.comingSoon).length;
    expect(active, lessThan(ExploreCategory.all.length));
    expect(active + coming, ExploreCategory.all.length);
    // Kesan pertama tab: kartu aktif dominan tampil, stub tersembunyi.
    expect(active, greaterThanOrEqualTo(2));
  });
}
