import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_providers.dart';
import '../domain/encyclopedia_repository.dart';
import 'encyclopedia_remote_datasource.dart';

final encyclopediaRemoteDatasourceProvider =
    Provider<EncyclopediaRemoteDatasource>(
  (ref) => EncyclopediaRemoteDatasource(ref.watch(dioProvider)),
);

final encyclopediaRepositoryProvider = Provider<EncyclopediaRepository>(
  (ref) => EncyclopediaRepositoryImpl(
    ref.watch(encyclopediaRemoteDatasourceProvider),
  ),
);