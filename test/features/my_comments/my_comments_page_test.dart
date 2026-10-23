import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/my_comments/data/providers/my_comment_data_providers.dart';
import 'package:sambasku_mobile/features/my_comments/domain/failures/my_comment_failure.dart';
import 'package:sambasku_mobile/features/my_comments/domain/entities/my_comment_item.dart';
import 'package:sambasku_mobile/features/my_comments/domain/entities/my_comment_page.dart';
import 'package:sambasku_mobile/features/my_comments/domain/repositories/my_comment_repository.dart';
import 'package:sambasku_mobile/features/my_comments/presentation/pages/my_comments_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';

class _FakeComments implements MyCommentRepository {
  final statuses = <String?>[];

  @override
  Future<Either<MyCommentFailure, MyCommentPage>> listMine({
    int limit = 20,
    String? cursor,
    String? status,
  }) async {
    statuses.add(status);
    return Either.right(
      MyCommentPage(
        items: [
          MyCommentItem(
            id: '01CMT00000000000000000001',
            wordId: '01WORD0000000000000000001',
            wordLemma: status == 'taken_down' ? null : 'makatn',
            body: 'sering saya dengar di Sambas',
            status: status ?? 'published',
            createdAt: '2026-09-21T10:00:00.000Z',
            reviewedAt: null,
          ),
        ],
        nextCursor: null,
        hasMore: false,
      ),
    );
  }
}

void main() {
  testWidgets('chip Tayang mengirim status; lemma null tidak navigasi', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'isAuth': true,
      'sessionUsername': 'budi',
      'sessionRole': 'contributor',
    });
    FlutterSecureStorage.setMockInitialValues({
      'accessToken': 'test-access',
      'refreshToken': 'test-refresh',
    });
    final repo = _FakeComments();
    final router = GoRouter(
      initialLocation: '/comments',
      routes: [
        GoRoute(
          path: '/comments',
          builder: (context, state) => const MyCommentsPage(),
        ),
        GoRoute(
          path: '/words/:id',
          builder: (context, state) => Text('kata ${state.pathParameters['id']}'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
          myCommentRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp.router(
          theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) => FTheme(
            data: foruiPalettes['zinc']!.light.touch,
            child: child!,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Tayang'), findsWidgets);
    expect(repo.statuses, [null]);

    await tester.tap(find.text('Diturunkan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(repo.statuses.last, 'taken_down');
    expect(find.text('Kata tidak tersedia'), findsOneWidget);

    await tester.tap(find.text('Kata tidak tersedia'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(router.routeInformationProvider.value.uri.path, '/comments');
  });
}
