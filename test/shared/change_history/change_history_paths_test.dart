import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/event/event_router.dart';
import 'package:sambasku_mobile/features/explore/explore_router.dart';
import 'package:sambasku_mobile/features/karya/karya_router.dart';
import 'package:sambasku_mobile/features/layanan/layanan_router.dart';
import 'package:sambasku_mobile/features/usaha/usaha_router.dart';
import 'package:sambasku_mobile/shared/change_history/change_history_controller.dart';

void main() {
  test('endpoint riwayat tiap entitas eksplorasi', () {
    expect(
      usahaChangeHistoryPath('warung a'),
      '/api/v1/usaha/warung%20a/change-history',
    );
    expect(
      eventChangeHistoryPath('pawai'),
      '/api/v1/events/pawai/change-history',
    );
    expect(karyaChangeHistoryPath('lagu'), '/api/v1/karya/lagu/change-history');
    expect(
      layananChangeHistoryPath('amb'),
      '/api/v1/layanan/amb/change-history',
    );
    expect(
      communityChangeHistoryPath('kom'),
      '/api/v1/community/orgs/kom/change-history',
    );
  });

  test('route riwayat tiap entitas eksplorasi', () {
    expect(UsahaRouter.historyPath('a'), '/usaha/a/riwayat');
    expect(EventRouter.historyPath('a'), '/acara/a/riwayat');
    expect(KaryaRouter.historyPath('a'), '/karya/a/riwayat');
    expect(LayananRouter.historyPath('a'), '/layanan/a/riwayat');
    expect(
      ExploreRouter.communityHistoryPath('a'),
      '/explore/komunitas/a/riwayat',
    );
  });
}
