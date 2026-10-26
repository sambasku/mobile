import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/explore/domain/explore_category.dart';

void main() {
  test('kategori permainan (hiburan) aktif (bukan coming soon)', () {
    final hiburan = ExploreCategory.byId('hiburan');
    expect(hiburan, isNotNull);
    expect(hiburan!.comingSoon, isFalse,
        reason: 'Permainan harus aktif setelah pantun tayang');
    expect(hiburan.title, 'Permainan');
  });

  test('semua kategori tetap terdaftar', () {
    for (final c in ExploreCategory.all) {
      expect(ExploreCategory.byId(c.id), isNotNull);
    }
  });
}
