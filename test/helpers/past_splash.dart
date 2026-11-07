import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:sambasku_mobile/shared/splash/presentation/splash_page.dart';

/// Cold start app kini lewat /splash: _bootstrap() menunggu
/// PackageInfo.fromPlatform() (method channel - wajib mock di test)
/// lalu dwell min 1500ms sebelum go('/'). Pump lewat keduanya supaya
/// shell/tab benar-benar terender, lalu settle redirect GoRouter.
/// Tanpa ini find.byType(FScaffold) = no element.
Future<void> pumpPastSplash(WidgetTester tester) async {
  PackageInfo.setMockInitialValues(
    appName: 'SambasKu',
    packageName: 'com.sambasku.app',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  await tester.pump();
  await tester.pump(SplashPage.minDwell);
  await tester.pump();
  await tester.pump();
}
