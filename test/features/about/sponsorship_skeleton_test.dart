import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sambasku_mobile/features/about/data/datasources/about_api_datasource.dart';
import 'package:sambasku_mobile/features/about/presentation/pages/about_page.dart';
import 'package:sambasku_mobile/features/about/presentation/providers/about_api_providers.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

const _sponsor = AboutSponsorship(
  id: 'mitra-a',
  name: 'Mitra A',
  since: '2024',
  note: '',
  description: 'Mitra kerja sama',
);

const _contributor = AboutContributorName(
  username: 'budi',
  displayName: 'Budi',
);

final _bones = find.byWidgetPredicate((w) => w is Bone);

/// Regresi: tab Sponsor & Mitra dan Tim Kami wajib tampil skeleton saat
/// loading, bukan kosong lalu lompat (layout shift). FTabs lazy-build,
/// jadi tiap test buka tab-nya dulu.
void main() {
  Future<void> tapTimKami(WidgetTester tester) async {
    await tester.tap(find.text('Tim Kami').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Widget harness(_AboutMode mode) {
    return ProviderScope(
      overrides: [
        aboutSponsorshipsProvider.overrideWith((ref) {
          return switch (mode) {
            _AboutMode.hang => Completer<List<AboutSponsorship>?>().future,
            _AboutMode.ready => Future.value(const [_sponsor]),
            _AboutMode.failed => Future.value(null),
          };
        }),
        aboutTeamProvider.overrideWith((ref) {
          return switch (mode) {
            _AboutMode.hang => Completer<List<AboutTeamMember>?>().future,
            _AboutMode.ready => Future.value(const <AboutTeamMember>[]),
            _AboutMode.failed => Future.value(null),
          };
        }),
        aboutVerifiersProvider.overrideWith((ref) {
          return switch (mode) {
            _AboutMode.hang => Completer<List<AboutVerifier>?>().future,
            _AboutMode.ready => Future.value(const <AboutVerifier>[]),
            _AboutMode.failed => Future.value(null),
          };
        }),
        aboutContributorsProvider.overrideWith(switch (mode) {
          _AboutMode.hang => _HangContributors.new,
          _AboutMode.ready => _ReadyContributors.new,
          _AboutMode.failed => _FailedContributors.new,
        }),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          ...FLocalizations.localizationsDelegates,
        ],
        supportedLocales: const [Locale('id')],
        locale: const Locale('id'),
        home: FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: const FToaster(child: SponsorshipTeamPage()),
        ),
      ),
    );
  }

  testWidgets('tab sponsor: skeleton saat loading, bukan kosong', (
    tester,
  ) async {
    await tester.pumpWidget(harness(_AboutMode.hang));
    await tester.pump();

    expect(_bones, findsWidgets);
  });

  testWidgets('tab tim: skeleton saat loading, bukan kosong', (tester) async {
    await tester.pumpWidget(harness(_AboutMode.hang));
    await tester.pump();
    await tapTimKami(tester);

    expect(_bones, findsWidgets);
  });

  testWidgets('data selesai: konten tampil tanpa skeleton', (tester) async {
    await tester.pumpWidget(harness(_AboutMode.ready));
    await tester.pumpAndSettle();

    expect(_bones, findsNothing);
    expect(find.text('Mitra A'), findsOneWidget);
    await tapTimKami(tester);
    await tester.pumpAndSettle();

    expect(find.text('Kontributor'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Budi'), findsNothing);
  });

  testWidgets('gagal fetch: section hilang, halaman tetap utuh', (
    tester,
  ) async {
    await tester.pumpWidget(harness(_AboutMode.failed));
    await tester.pumpAndSettle();

    expect(_bones, findsNothing);
    expect(find.text('Mitra A'), findsNothing);
    expect(find.text('Ingin ikut mendukung?'), findsOneWidget);
  });
}

enum _AboutMode { hang, ready, failed }

class _HangContributors extends AboutContributors {
  @override
  Future<AboutContributorsState?> build() =>
      Completer<AboutContributorsState?>().future;
}

class _ReadyContributors extends AboutContributors {
  @override
  Future<AboutContributorsState?> build() async =>
      const AboutContributorsState(items: [_contributor], total: 1);
}

class _FailedContributors extends AboutContributors {
  @override
  Future<AboutContributorsState?> build() async => null;
}
