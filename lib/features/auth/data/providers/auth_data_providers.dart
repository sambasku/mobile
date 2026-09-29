import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cache/cache_providers.dart';
import '../../../../core/network/network_providers.dart';
import '../../domain/ports/facebook_sign_in_port.dart';
import '../../domain/ports/github_sign_in_port.dart';
import '../../domain/ports/google_sign_in_port.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../facebook_sign_in_adapter.dart';
import '../github_sign_in_adapter.dart';
import '../google_sign_in_adapter.dart';
import '../repositories/auth_repository_impl.dart';

part 'auth_data_providers.g.dart';

@riverpod
AuthRemoteDatasource authRemoteDatasource(Ref ref) =>
    AuthRemoteDatasource(ref.watch(dioProvider));

@riverpod
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  ref.watch(authRemoteDatasourceProvider),
  ref.watch(authTokenStorageProvider),
  responseCache: ref.watch(responseCacheStoreProvider),
);

@Riverpod(keepAlive: true)
GoogleSignInPort googleSignInPort(Ref ref) => GoogleSignInAdapter();

@Riverpod(keepAlive: true)
FacebookSignInPort facebookSignInPort(Ref ref) => FacebookSignInAdapter();

@Riverpod(keepAlive: true)
GithubSignInPort githubSignInPort(Ref ref) => GithubSignInAdapter();
