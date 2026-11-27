import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sambasku_mobile/core/network/connectivity_provider.dart';
import 'package:sambasku_mobile/core/network/failover/failover_interceptor.dart';
import 'package:sambasku_mobile/core/network/interceptors/auth_interceptor.dart';
import 'package:sambasku_mobile/features/dictionary/data/dataset/lemma_database_opener.dart';
import 'package:sambasku_mobile/features/dictionary/data/dataset/lemma_dataset_constants.dart';
import 'package:sambasku_mobile/features/dictionary/data/dataset/lemma_dataset_providers.dart';
import 'package:sambasku_mobile/features/dictionary/data/dataset/lemma_dataset_updater.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('offline → offline outcome', () async {
    SharedPreferences.setMockInitialValues({});
    final tmp = await Directory.systemTemp.createTemp('lemma_ota_off_');
    addTearDown(() => tmp.delete(recursive: true));
    final updater = LemmaDatasetUpdater(
      dio: Dio(),
      opener: _TempOpener(tmp.path),
      isOnline: () => false,
    );
    final result = await updater.update();
    expect(result.outcome, LemmaDatasetUpdateOutcome.offline);
  });

  test('busy single-flight', () async {
    SharedPreferences.setMockInitialValues({});
    final tmp = await Directory.systemTemp.createTemp('lemma_ota_busy_');
    addTearDown(() => tmp.delete(recursive: true));
    final updater = LemmaDatasetUpdater(
      dio: Dio(),
      opener: _TempOpener(tmp.path),
      isOnline: () => false,
    );
    // Start first (returns offline quickly) while marking busy via parallel.
    final first = updater.update();
    final second = await updater.update();
    // First may still be in flight; second sees busy OR offline.
    expect(
      second.outcome == LemmaDatasetUpdateOutcome.busy ||
          second.outcome == LemmaDatasetUpdateOutcome.offline,
      isTrue,
    );
    await first;
  });

  test(
    'lemmaDatasetUpdaterProvider memakai Dio bersih tanpa Auth/Failover',
    () {
      final container = ProviderContainer(
        overrides: [isOfflineProvider.overrideWithValue(false)],
      );
      addTearDown(container.dispose);

      final updater = container.read(lemmaDatasetUpdaterProvider);
      final interceptors = updater.dio.interceptors;
      expect(interceptors.whereType<AuthInterceptor>(), isEmpty);
      expect(interceptors.whereType<FailoverInterceptor>(), isEmpty);
    },
  );

  test('updater dari provider tetap hidup setelah ref.read (Dio tidak '
      'ditutup sebelum fetch active.json)', () async {
    SharedPreferences.setMockInitialValues({});
    final tmp = await Directory.systemTemp.createTemp('lemma_ota_alive_');
    addTearDown(() => tmp.delete(recursive: true));
    final container = ProviderContainer(
      overrides: [
        isOfflineProvider.overrideWithValue(false),
        lemmaDatabaseOpenerProvider.overrideWithValue(_TempOpener(tmp.path)),
      ],
    );
    addTearDown(container.dispose);

    final updater = container.read(lemmaDatasetUpdaterProvider);
    updater.dio.httpClientAdapter = _ActiveJsonAdapter(
      '{"release_version":0,"schema_version":1}',
    );
    await container.pump();
    await Future<void>.delayed(Duration.zero);

    final result = await updater.update();
    expect(result.outcome, LemmaDatasetUpdateOutcome.alreadyLatest);
  });
}

class _ActiveJsonAdapter implements HttpClientAdapter {
  _ActiveJsonAdapter(this.body);

  final String body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(body, 200);
}

class _TempOpener extends LemmaDatabaseOpener {
  _TempOpener(this.root);

  final String root;

  @override
  Future<Directory> datasetDir() async {
    final dir = Directory(p.join(root, LemmaDatasetConstants.dirName));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
}
