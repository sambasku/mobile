import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/auth/data/providers/auth_data_providers.dart';
import 'package:sambasku_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:sambasku_mobile/features/auth/domain/failures/auth_failure.dart';
import 'package:sambasku_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:sambasku_mobile/features/bookmark/data/providers/bookmark_data_providers.dart';
import 'package:sambasku_mobile/features/bookmark/domain/entities/bookmark_page.dart'
    as ent;
import 'package:sambasku_mobile/features/bookmark/domain/entities/bookmark_status.dart';
import 'package:sambasku_mobile/features/bookmark/domain/failures/bookmark_failure.dart';
import 'package:sambasku_mobile/features/bookmark/domain/repositories/bookmark_repository.dart';
import 'package:sambasku_mobile/features/bookmark/presentation/pages/bookmark_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithGoogle({
    required String idToken,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithFacebook({
    required String accessToken,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, void>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String confirmPassword,
    required List<({String documentType, String documentVersion})> consents,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, void>> logout() async => Either.right(null);

  @override
  Future<Either<AuthFailure, AuthSession>> verifyEmail({
    required String email,
    required String code,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, void>> resendOtp({required String email}) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, String>> forgotPassword({
    required String email,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, String>> resetPassword({
    String? token,
    String? email,
    String? code,
    required String newPassword,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));
}

/// Repository yang selalu gagal (simulasi 4xx) + menghitung panggilan.
class _FailingBookmarkRepository implements BookmarkRepository {
  int myBookmarksCalls = 0;

  @override
  Future<Either<BookmarkFailure, ent.BookmarkPage>> myBookmarks({
    int limit = 20,
    String? cursor,
  }) async {
    myBookmarksCalls++;
    return Either.left(
      BookmarkFailure('Sesi berakhir, silakan masuk kembali',
          errorCode: 'UNAUTHORIZED'),
    );
  }

  @override
  Future<Either<BookmarkFailure, BookmarkStatus>> toggle(String wordId) async =>
      Either.left(BookmarkFailure('gagal'));

  @override
  Future<Either<BookmarkFailure, Map<String, BookmarkStatus>>> statuses(
    List<String> wordIds,
  ) async =>
      Either.left(BookmarkFailure('gagal'));
}

/// Reproduksi laporan bug: 4xx pada halaman Bookmark harus menampilkan
/// pesan error + tombol coba lagi, TIDAK infinite loop (rebuild tanpa henti
/// yang menempel spinner / spam request).
void main() {
  testWidgets('4xx dari API - pesan error tampil sekali, tanpa loop', (
    tester,
  ) async {
    final repo = _FailingBookmarkRepository();
    SharedPreferences.setMockInitialValues({
      'isAuth': true,
      'sessionUsername': 'budi',
      'sessionRole': 'contributor',
    });
    FlutterSecureStorage.setMockInitialValues({
      'accessToken': 'test-access',
      'refreshToken': 'test-refresh',
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          bookmarkRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: const BookmarkPage(),
          ),
        ),
      ),
    );

    // Majukan beberapa frame - kalau ada loop rebuild, jumlah panggilan
    // repository terus bertambah di tiap frame.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(repo.myBookmarksCalls, 1,
        reason: 'repository harus dipanggil tepat sekali, bukan berulang');
    expect(find.text('Sesi berakhir, silakan masuk kembali'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(find.byType(FCircularProgress), findsNothing);
  });
}
