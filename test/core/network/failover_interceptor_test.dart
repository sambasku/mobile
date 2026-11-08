import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/network/failover/api_host_resolver.dart';
import 'package:sambasku_mobile/core/network/failover/cold_host_gate.dart';
import 'package:sambasku_mobile/core/network/failover/failover_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ApiHostResolver resolver;
  late ColdHostGate gate;
  late _CountingAdapter adapter;
  late Dio dio;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    resolver = ApiHostResolver.instance;
    resolver.onWarmUp = null;
    resolver.pinDuration = kTierPinDuration;
    await resolver.setForcedTier(null);
    resolver.configure(
      primaryHost: 'https://t1.test',
      fallbackHosts: const [
        'https://t2.test',
        'https://render.sambasku.com',
      ],
    );

    gate = ColdHostGate(maxInFlight: 2);
    adapter = _CountingAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://t1.test'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(
      FailoverInterceptor(
        resolver: resolver,
        probeDio: Dio()..httpClientAdapter = _IdleAdapter(),
        coldGate: gate,
      ),
    );
    // Warm-up /health tidak dihitung di tes ini.
    resolver.onWarmUp = null;
  });

  test('tier 1 (CF) tidak menyentuh gate - 6 request paralel langsung jalan',
      () async {
    adapter.holdMs = 20;
    await Future.wait([
      for (var i = 0; i < 6; i++) dio.get<void>('/words/$i'),
    ]);

    expect(gate.inFlight, 0);
    expect(gate.waiting, 0);
    expect(adapter.maxConcurrent, 6);
    expect(adapter.total, 6);
  });

  test('host cold-start membatasi 2 socket bersamaan, request lain mengantri',
      () async {
    resolver.advanceTier();
    resolver.advanceTier();
    expect(resolver.activeHost, 'https://render.sambasku.com');
    expect(resolver.activeTier.timeout, kColdStartTierTimeout);

    adapter.holdMs = 40;
    await Future.wait([
      for (var i = 0; i < 5; i++) dio.get<void>('/words/$i'),
    ]);

    expect(adapter.maxConcurrent, 2);
    expect(adapter.total, 5);
    expect(gate.inFlight, 0);
    expect(gate.waiting, 0);
  });
}

class _IdleAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString('{}', 200);
  }
}

class _CountingAdapter implements HttpClientAdapter {
  int holdMs = 0;
  int _current = 0;
  int maxConcurrent = 0;
  int total = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    total++;
    _current++;
    if (_current > maxConcurrent) maxConcurrent = _current;
    if (holdMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: holdMs));
    }
    _current--;
    return ResponseBody.fromString('{}', 200);
  }
}
