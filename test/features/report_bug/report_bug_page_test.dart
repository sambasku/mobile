import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/features/report_bug/data/bug_report_providers.dart';
import 'package:sambasku_mobile/features/report_bug/data/bug_report_repository.dart';
import 'package:sambasku_mobile/features/report_bug/domain/bug_report_models.dart';
import 'package:sambasku_mobile/features/report_bug/presentation/report_bug_page.dart';

import '../../helpers/l10n_delegates.dart';

class _GuestAuthStatusNotifier extends AuthStatusNotifier {
  @override
  Future<AuthStatusState> build() async => const AuthStatusState(isAuth: false);
}

class _FakeBugReportRepository extends BugReportRepository {
  _FakeBugReportRepository() : super(Dio());

  String? lastDescription;
  int submitCalls = 0;

  @override
  Future<BugReportSubmitResult> submit({
    required String description,
    required List<BugReportImageRef> images,
    required String? appVersion,
    required String? platform,
  }) async {
    submitCalls++;
    lastDescription = description;
    return const BugReportSubmitResult(
      id: 'rep_1',
      status: 'open',
      submittedAt: '2026-11-27T00:00:00Z',
      isAnonymous: true,
    );
  }
}

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'SambasKu',
      packageName: 'com.sambasku.mobile',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    required ReportBugMode mode,
    required _FakeBugReportRepository repo,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/form',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/form',
          builder: (_, _) => ReportBugPage(mode: mode),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStatusProvider.overrideWith(_GuestAuthStatusNotifier.new),
          bugReportRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: appLocalizationDelegates,
          locale: appTestLocale,
          supportedLocales: appTestSupportedLocales,
          builder: (context, child) => FTheme(
            data: foruiPalettes['zinc']!.light.touch,
            child: FToaster(child: child!),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('mode bug menampilkan copy laporan masalah tanpa ilustrasi', (
    tester,
  ) async {
    final repo = _FakeBugReportRepository();
    await pumpPage(tester, mode: ReportBugMode.bug, repo: repo);

    expect(find.text('Laporkan Masalah'), findsOneWidget);
    expect(find.text('Keterangan'), findsOneWidget);
    expect(find.text('Kirim'), findsOneWidget);
    expect(find.text('Kritik & Saran'), findsNothing);
    expect(
      find.bySemanticsLabel('Ilustrasi kirim kritik dan saran untuk SambasKu'),
      findsNothing,
    );
  });

  testWidgets(
    'mode feedback menampilkan ilustrasi, copy kritik/saran, dan submit via BugReportRepository',
    (tester) async {
      final repo = _FakeBugReportRepository();
      await pumpPage(tester, mode: ReportBugMode.feedback, repo: repo);

      expect(find.text('Kritik & Saran'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Ilustrasi kirim kritik dan saran untuk SambasKu'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Punya ide fitur, masukan, atau hal yang kurang pas? Ceritakan di sini ya.',
        ),
        findsOneWidget,
      );
      expect(find.text('Kritik atau saran'), findsOneWidget);
      expect(find.text('Kirim Masukan'), findsOneWidget);
      expect(find.text('Laporkan Masalah'), findsNothing);

      await tester.enterText(
        find.byType(EditableText),
        'Tambahkan fitur pencarian cepat di halaman eksplorasi ya',
      );
      await tester.pump();

      await tester.tap(find.text('Kirim Masukan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo.submitCalls, 1);
      expect(
        repo.lastDescription,
        'Tambahkan fitur pencarian cepat di halaman eksplorasi ya',
      );
      expect(
        find.text('Terima kasih, masukan kamu sudah kami terima'),
        findsOneWidget,
      );
      // Biarkan timer auto-dismiss toast selesai sebelum teardown.
      await tester.pump(const Duration(seconds: 6));
    },
  );
}
