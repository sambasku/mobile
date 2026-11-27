import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cache/cache_providers.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../review/domain/review_access.dart';
import '../../domain/repositories/dictionary_repository.dart';
import '../dataset/lemma_dataset_providers.dart';
import '../datasources/dictionary_remote_datasource.dart';
import '../repositories/dictionary_repository_impl.dart';

part 'dictionary_data_providers.g.dart';

@riverpod
DictionaryRemoteDatasource dictionaryRemoteDatasource(Ref ref) =>
    DictionaryRemoteDatasource(ref.watch(dioProvider));

@riverpod
DictionaryRepository dictionaryRepository(Ref ref) {
  final local = ref.watch(dictionaryLocalDatasourceProvider).asData?.value;
  final sticky = ref.watch(lemmaStickyStoreProvider);
  return DictionaryRepositoryImpl(
    ref.watch(dictionaryRemoteDatasourceProvider),
    dio: ref.watch(dioProvider),
    cache: ref.watch(cachedJsonClientProvider),
    local: local,
    sticky: sticky,
    isOffline: () {
      try {
        return ref.read(isOfflineProvider);
      } catch (_) {
        return false;
      }
    },
    isVerifier: () {
      try {
        return isVerifierRole(ref.read(authStatusProvider).value?.role);
      } catch (_) {
        return false;
      }
    },
    onSource: (kind) {
      try {
        if (!ref.mounted) return;
        ref.read(lemmaDataSourceKindControllerProvider.notifier).setKind(kind);
      } catch (_) {}
    },
  );
}
