import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sambasku_mobile/features/activity/presentation/providers/contribution_guide_providers.dart';
import 'package:sambasku_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/edit_profile/domain/entities/my_profile.dart';
import 'package:sambasku_mobile/features/edit_profile/domain/failures/edit_profile_failure.dart';
import 'package:sambasku_mobile/features/edit_profile/domain/providers/edit_profile_domain_providers.dart';
import 'package:sambasku_mobile/features/edit_profile/domain/repositories/edit_profile_repository.dart';
import 'package:sambasku_mobile/features/edit_profile/domain/usecases/edit_profile_use_cases.dart';

/// Fake repo profil: flag server selalu hasRead=false supaya sinyal yang
/// diuji murni flag lokal per-user.
class _FakeProfileRepo implements EditProfileRepository {
  const _FakeProfileRepo();

  @override
  Future<Either<EditProfileFailure, MyProfile>> getMyProfile() async =>
      Either.right(
        MyProfile(
          username: 'u',
          displayName: 'U',
          hasReadContributionGuide: false,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Flag guide Kontribusi per-user: dua akun di HP yang sama tidak saling
/// menimpa "sudah baca". User A baca -> user B login -> guide tampil lagi.
void main() {
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer(
      overrides: [
        getMyProfileUseCaseProvider.overrideWith(
          (ref) => GetMyProfileUseCase(const _FakeProfileRepo()),
        ),
        authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<bool> unread() =>
      container.read(contributionGuideUnreadProvider.future);

  Future<void> markRead(String? userId) async {
    final prefs = await container.read(contributionGuidePrefsProvider.future);
    final key = userId != null
        ? '$kContribGuideReadPrefsKeyPrefix$userId'
        : kContribGuideReadPrefsKey;
    await prefs.setString(key, DateTime.now().toIso8601String());
    container.invalidate(contributionGuideUnreadProvider);
  }

  /// markLoggedIn set state sinkron, tapi build() awal authStatusProvider
  /// (keepAlive, async) bisa masih in-flight dan menimpa state balik jadi
  /// tamu setelahnya. Tunggu build awal selesai dulu sebelum set state.
  Future<void> login(String userId) async {
    await container.read(authStatusProvider.future);
    container.read(authStatusProvider.notifier).markLoggedIn(_session(userId));
    // Invalidasi guide supaya watch authStatus jalan
    container.invalidate(contributionGuideUnreadProvider);
  }

  test('user A read, login user B -> unread lagi', () async {
    await login('user-a');
    expect(await unread(), isTrue);

    await markRead('user-a');
    expect(await unread(), isFalse, reason: 'user A sudah tap Mengerti');

    // Login akun lain di HP yang sama.
    await login('user-b');
    expect(
      await unread(),
      isTrue,
      reason: 'user B belum pernah baca guide - harus muncul lagi',
    );
  });

  test('user A bolak-balik login tetap read, tidak ditanya ulang', () async {
    await login('user-a');
    await markRead('user-a');

    await login('user-b');
    await login('user-a');
    expect(await unread(), isFalse);
  });

  test('tamu baca -> login user baru tetap ditanya', () async {
    await markRead(null);
    expect(await unread(), isFalse);

    await login('user-a');
    expect(await unread(), isTrue);
  });
}

AuthSession _session(String userId) =>
    AuthSession(userId: userId, username: 'u-$userId', role: 'user');
