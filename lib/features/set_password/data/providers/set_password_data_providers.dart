import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/set_password_repository.dart';
import '../datasources/set_password_remote_datasource.dart';
import '../repositories/set_password_repository_impl.dart';

part 'set_password_data_providers.g.dart';

@riverpod
SetPasswordRemoteDatasource setPasswordRemoteDatasource(Ref ref) =>
    SetPasswordRemoteDatasource(ref.watch(dioProvider));

@riverpod
SetPasswordRepository setPasswordRepository(Ref ref) =>
    SetPasswordRepositoryImpl(ref.watch(setPasswordRemoteDatasourceProvider));
