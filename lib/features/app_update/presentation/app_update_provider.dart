import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/network/network_providers.dart';
import '../domain/latest_release.dart';

/// Hasil cek versi: null = sudah terbaru / skip, selain itu = tampilkan banner.
class AppUpdateState {
  const AppUpdateState({required this.release});

  final LatestRelease release;
}

final appUpdateProvider = FutureProvider.autoDispose<AppUpdateState?>((ref) async {
  final dio = ref.watch(dioProvider);
  final info = await PackageInfo.fromPlatform();
  final platform = Platform.isIOS ? 'ios' : 'android';

  final res = await dio.get<Map<String, dynamic>>(
    '/api/v1/mobile-release/latest',
    queryParameters: {'platform': platform},
  );

  final data = res.data?['data'];
  if (data is! Map<String, dynamic>) return null;

  final release = LatestRelease.fromJson(data);
  // store_url kosong (mis. iOS belum listing): tidak ada tujuan CTA, skip.
  if (release.storeUrl == null) return null;
  if (!isNewerRelease(release.version, info.version)) return null;

  return AppUpdateState(release: release);
});
