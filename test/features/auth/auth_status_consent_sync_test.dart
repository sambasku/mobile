import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/features/edit_profile/domain/entities/my_profile.dart';
import 'package:sambasku_mobile/features/edit_profile/domain/failures/edit_profile_failure.dart';
import 'package:sambasku_mobile/features/edit_profile/domain/providers/edit_profile_domain_providers.dart';
import 'package:sambasku_mobile/features/edit_profile/domain/repositories/edit_profile_repository.dart';
import 'package:sambasku_mobile/features/edit_profile/domain/usecases/edit_profile_use_cases.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regresi consent sync: `requires_consent` dari GET /users/me harus
/// tercermin di AuthStatusState WALAU identitas (username, display, avatar)
/// tidak berubah. Tanpa ini, naiknya versi legal tidak pernah memunculkan
/// sheet karena early-return "sudah sinkron" mempertahankan false.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> boot({required bool requiresConsent}) async {
    FlutterSecureStorage.setMockInitialValues({
      'accessToken': 'at',
      'refreshToken': 'rt',
    });
    // Identitas tersimpan == identitas server (tidak ada diff).
    SharedPreferences.setMockInitialValues({
      'isAuth': true,
      'session.username': 'budi',
      'session.displayName': 'Budi',
    });
    final storage = AuthTokenStorage();
    await storage.setIsAuth(true);

    final profile = MyProfile(
      username: 'budi',
      displayName: 'Budi',
      hasReadContributionGuide: false,
      requiresConsent: requiresConsent,
    );
    final container = ProviderContainer(
      overrides: [
        authTokenStorageProvider.overrideWithValue(storage),
        getMyProfileUseCaseProvider.overrideWithValue(
          GetMyProfileUseCase(_FakeEditProfileRepository(profile)),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('identitas sama + requires_consent true -> state di-update', () async {
    final container = await boot(requiresConsent: true);

    await container.read(authStatusProvider.notifier).future;

    expect(
      container.read(authStatusProvider).value?.requiresLegalConsent,
      isTrue,
      reason:
          'versi legal naik tidak mengubah identitas. Tanpa fix, '
          'early-return mempertahankan false dan sheet tidak muncul.',
    );
  });

  test(
    'identitas sama + requires_consent false -> state tidak di-emit ulang',
    () async {
      final container = await boot(requiresConsent: false);

      final first = await container.read(authStatusProvider.notifier).future;
      final after = container.read(authStatusProvider).value;

      expect(after?.requiresLegalConsent, isFalse);
      expect(
        identical(first, after),
        isTrue,
        reason:
            'tidak ada perubahan -> objek state dipertahankan (hindari jank)',
      );
    },
  );
}

class _FakeEditProfileRepository implements EditProfileRepository {
  _FakeEditProfileRepository(this.profile);

  final MyProfile profile;

  @override
  Future<Either<EditProfileFailure, MyProfile>> getMyProfile() async =>
      Either.right(profile);

  @override
  Future<Either<EditProfileFailure, MyProfile>> updateMyProfile({
    String? username,
    String? displayName,
    String? bio,
    String? regionId,
    String? villageId,
    bool? hasReadContributionGuide,
  }) async => Either.right(profile);
}
