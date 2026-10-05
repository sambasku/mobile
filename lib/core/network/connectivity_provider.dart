import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

/// Status koneksi: offline ketika tidak ada interface jaringan sama
/// sekali (wifi + mobile kosong). WiFi/cellular/ethernet dianggap online -
/// portal captive tidak terdeteksi, itu tanggung jawaban layer fetch.
@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> connectivity(Ref ref) {
  return Connectivity().onConnectivityChanged;
}

/// Stream bisa emmit kosong sesaat saat switching - debounce supaya banner
/// tidak kedip. Offline hanya bila hasil kosong bertahan > 2 detik.
@Riverpod(keepAlive: true)
Stream<bool> isOffline(Ref ref) {
  final controller = StreamController<bool>();
  Timer? debounce;

  final sub = ref.listen(connectivityProvider, (_, next) {
    final results = next.value ?? const <ConnectivityResult>[];
    final offline = results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none);
    debounce?.cancel();
    if (!offline) {
      debounce = null;
      controller.add(false);
      return;
    }
    debounce = Timer(const Duration(seconds: 2), () {
      controller.add(true);
    });
  });

  ref.onDispose(() {
    debounce?.cancel();
    unawaited(controller.close());
    sub.close();
  });

  return controller.stream;
}
