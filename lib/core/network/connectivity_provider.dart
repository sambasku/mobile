import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

bool connectivityResultsAreOffline(List<ConnectivityResult> results) {
  return results.isEmpty ||
      results.every((r) => r == ConnectivityResult.none);
}

/// Status koneksi: seed dari [checkConnectivity] lalu ikut
/// [onConnectivityChanged]. Tanpa seed, subscribe stream saja sering
/// tidak dapat status awal - banner bisa stuck offline walau sudah online.
@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> connectivity(Ref ref) async* {
  final plugin = Connectivity();
  yield await plugin.checkConnectivity();
  yield* plugin.onConnectivityChanged;
}

/// Offline hanya bila hasil offline bertahan > 2 detik (anti kedip saat
/// switching radio). Online langsung clear. Loading/error tidak dianggap
/// offline (bug lama: `next.value ?? []` bikin null = offline permanen).
@Riverpod(keepAlive: true)
class IsOffline extends _$IsOffline {
  Timer? _debounce;
  AppLifecycleListener? _lifecycle;

  @override
  bool build() {
    ref.listen<AsyncValue<List<ConnectivityResult>>>(
      connectivityProvider,
      (_, next) => _onConnectivity(next),
      fireImmediately: true,
    );

    // Saat app kembali ke foreground, re-cek - OEM sering tidak emit
    // onConnectivityChanged kalau restore terjadi di background.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        unawaited(_recheck());
      },
    );

    ref.onDispose(() {
      _debounce?.cancel();
      _lifecycle?.dispose();
    });

    return false;
  }

  void _onConnectivity(AsyncValue<List<ConnectivityResult>> next) {
    final results = next.asData?.value;
    if (results == null) return;

    final offline = connectivityResultsAreOffline(results);
    _debounce?.cancel();
    if (!offline) {
      _debounce = null;
      if (state) state = false;
      return;
    }
    if (state) return;
    _debounce = Timer(const Duration(seconds: 2), () {
      state = true;
    });
  }

  Future<void> _recheck() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (!ref.mounted) return;
      _onConnectivity(AsyncData(results));
    } catch (_) {
      // Diam: tetap pakai state terakhir dari stream.
    }
  }
}
