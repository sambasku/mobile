import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../flavors.dart';

/// Sisipkan identitas build di setiap request API supaya backend bisa
/// log / filter / gate per versi tanpa ubah body.
///
/// Header (self-asserted, seperti `X-Device-Id`):
/// - `X-App-Version` - `version` dari pubspec / store (mis. `1.2.3`)
/// - `X-App-Build` - `buildNumber` (mis. `45`)
/// - `X-App-Flavor` - `staging` \| `production`
///
/// Backend boleh mengabaikan sementara; kontrak opt-in (pola
/// `Accept-Language`). Jangan pakai untuk auth/keputusan keamanan.
class AppVersionInterceptor extends Interceptor {
  AppVersionInterceptor({
    Future<PackageInfo> Function()? packageInfoLoader,
  }) : _loader = packageInfoLoader ?? PackageInfo.fromPlatform;

  final Future<PackageInfo> Function() _loader;

  String? _version;
  String? _build;
  Future<void>? _loading;

  Future<void> _ensureCached() {
    if (_version != null) return Future<void>.value();
    return _loading ??= () async {
      final info = await _loader();
      _version = info.version.trim();
      _build = info.buildNumber.trim();
    }();
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      await _ensureCached();
      final version = _version;
      if (version != null && version.isNotEmpty) {
        options.headers['X-App-Version'] = version;
      }
      final build = _build;
      if (build != null && build.isNotEmpty) {
        options.headers['X-App-Build'] = build;
      }
      options.headers['X-App-Flavor'] = F.appFlavor.name;
    } catch (_) {
      // Gagal baca PackageInfo: request tetap jalan tanpa header versi.
    }
    handler.next(options);
  }
}
