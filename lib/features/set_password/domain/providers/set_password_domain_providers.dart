import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/set_password_data_providers.dart';
import '../usecases/set_password_use_case.dart';

part 'set_password_domain_providers.g.dart';

@riverpod
SetPasswordUseCase setPasswordUseCase(Ref ref) =>
    SetPasswordUseCase(ref.watch(setPasswordRepositoryProvider));
