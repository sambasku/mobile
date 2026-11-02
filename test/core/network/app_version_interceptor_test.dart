import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sambasku_mobile/core/network/interceptors/app_version_interceptor.dart';
import 'package:sambasku_mobile/flavors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    F.appFlavor = Flavor.staging;
    PackageInfo.setMockInitialValues(
      appName: 'SambasKu',
      packageName: 'com.sambasku.app',
      version: '1.2.3',
      buildNumber: '45',
      buildSignature: '',
    );
  });

  test('menyisipkan X-App-Version, X-App-Build, X-App-Flavor', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    late RequestOptions captured;
    dio.interceptors.add(AppVersionInterceptor());
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: {}),
          );
        },
      ),
    );

    await dio.get('/ping');

    expect(captured.headers['X-App-Version'], '1.2.3');
    expect(captured.headers['X-App-Build'], '45');
    expect(captured.headers['X-App-Flavor'], 'staging');
  });

  test('flavor production ikut header', () async {
    F.appFlavor = Flavor.production;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    late RequestOptions captured;
    dio.interceptors.add(AppVersionInterceptor());
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: {}),
          );
        },
      ),
    );

    await dio.get('/ping');

    expect(captured.headers['X-App-Flavor'], 'production');
  });
}
