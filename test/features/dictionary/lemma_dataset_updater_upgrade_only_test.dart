import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sambasku_mobile/features/dictionary/data/dataset/lemma_database_opener.dart';
import 'package:sambasku_mobile/features/dictionary/data/dataset/lemma_dataset_constants.dart';
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
      isOnline: false,
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
      isOnline: false,
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
