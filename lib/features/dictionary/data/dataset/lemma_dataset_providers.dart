import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/network/interceptors/network_monitor_interceptor.dart';
import '../../../../shared/dev_tool/network_monitor/network_monitor_registry.dart';
import '../datasources/dictionary_local_datasource.dart';
import 'lemma_data_source_kind.dart';
import 'lemma_database_opener.dart';
import 'lemma_dataset_updater.dart';
import 'lemma_release_meta.dart';
import 'lemma_sticky_store.dart';

part 'lemma_dataset_providers.g.dart';

@Riverpod(keepAlive: true)
LemmaDatabaseOpener lemmaDatabaseOpener(Ref ref) => LemmaDatabaseOpener();

@Riverpod(keepAlive: true)
LemmaStickyStore lemmaStickyStore(Ref ref) => LemmaStickyStore();

/// Handle DB lokal. Null = belum siap / gagal open.
@Riverpod(keepAlive: true)
Future<LemmaDatabaseHandle?> lemmaDatabaseHandle(Ref ref) async {
  final opener = ref.watch(lemmaDatabaseOpenerProvider);
  try {
    final handle = await opener.open();
    ref.onDispose(() {
      opener.closeQuietly(handle.db);
    });
    return handle;
  } catch (_) {
    return null;
  }
}

@Riverpod(keepAlive: true)
Future<DictionaryLocalDatasource?> dictionaryLocalDatasource(Ref ref) async {
  final handle = await ref.watch(lemmaDatabaseHandleProvider.future);
  if (handle == null) return null;
  return DictionaryLocalDatasource(handle.db);
}

@Riverpod(keepAlive: true)
class LemmaDataSourceKindController extends _$LemmaDataSourceKindController {
  @override
  LemmaDataSourceKind build() => LemmaDataSourceKind.remote;

  void setKind(LemmaDataSourceKind kind) => state = kind;
}

@Riverpod(keepAlive: true)
Future<LemmaReleaseMeta?> lemmaInstalledMeta(Ref ref) async {
  final handle = await ref.watch(lemmaDatabaseHandleProvider.future);
  return handle?.meta;
}

/// keepAlive + offline dibaca saat update: autoDispose / rebuild akan
/// menutup Dio di tengah fetch (ref.read langsung menjadwalkan dispose).
@Riverpod(keepAlive: true)
LemmaDatasetUpdater lemmaDatasetUpdater(Ref ref) {
  final opener = ref.watch(lemmaDatabaseOpenerProvider);
  // Klien bersih khusus dataset eksternal (GitHub): tanpa AuthInterceptor
  // (raw.githubusercontent.com membalas 404 jika diberi Bearer JWT asing)
  // dan tanpa FailoverInterceptor (jangan timpa receiveTimeout 2 menit).
  final datasetDio = Dio();
  datasetDio.interceptors.add(
    NetworkMonitorInterceptor(repository: NetworkMonitorRegistry.repository),
  );
  ref.onDispose(() => datasetDio.close(force: true));
  return LemmaDatasetUpdater(
    dio: datasetDio,
    opener: opener,
    isOnline: () => !ref.read(isOfflineProvider),
    onBeforeSwap: () async {
      final async = ref.read(lemmaDatabaseHandleProvider);
      final handle = async.asData?.value;
      if (handle != null) {
        await opener.closeQuietly(handle.db);
      }
    },
    onAfterSwap: () async {
      ref.invalidate(lemmaDatabaseHandleProvider);
      await ref.read(lemmaDatabaseHandleProvider.future);
    },
  );
}
