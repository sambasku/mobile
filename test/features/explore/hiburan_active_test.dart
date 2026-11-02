import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/explore/domain/explore_category.dart';
import 'package:sambasku_mobile/l10n/app_localizations_id.dart';

void main() {
  test('kategori permainan (hiburan) aktif (bukan coming soon)', () {
    final hiburan = ExploreCategory.byId('hiburan');
    expect(hiburan, isNotNull);
    expect(hiburan!.comingSoon, isFalse,
        reason: 'Permainan harus aktif setelah pantun tayang');
    expect(hiburan.titleOf(AppLocalizationsId()), 'Permainan');
  });

  test('semua kategori tetap terdaftar', () {
    for (final c in ExploreCategory.all) {
      expect(ExploreCategory.byId(c.id), isNotNull);
    }
  });
}
