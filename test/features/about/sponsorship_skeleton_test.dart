import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sambasku_mobile/features/about/presentation/pages/about_page.dart';
import 'package:sambasku_mobile/features/about/presentation/providers/contributors_providers.dart';
import 'package:sambasku_mobile/features/about/presentation/providers/sponsors_providers.dart';
import 'package:sambasku_mobile/features/about/data/datasources/contributors_remote_datasource.dart';
import 'package:sambasku_mobile/features/about/data/datasources/sponsors_remote_datasource.dart';

const _contributor = ContributorEntry(
  id: 'budi',
  name: 'Budi',
  roles: ['Kontributor'],
  note: 'Pengusul kata',
  avatarUrl: null,
  since: '2024',
);

const _sponsor = SponsorEntry(
  id: 'mitra-a',
  name: 'Mitra A',
  logoUrl: null,
  description: 'Mitra kerja sama',
  url: null,
  note: '',
  since: '2024',
);

final _bones = find.byWidgetPredicate((w) => w is Bone);

/// Regresi: tab Sponsor & Mitra dan Tim Kami wajib tampil skeleton saat
/// loading, bukan kosong lalu lompat (layout shift). FTabs lazy-build,
/// jadi tiap test buka tab-nya dulu.
void main() {
  Future<void> tapTimKami(WidgetTester tester) async {
    await tester.tap(find.text('Tim Kami').last);
    await tester.pump();
  }

  testWidgets('tab sponsor: skeleton saat loading, bukan kosong', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contributorsProvider.overrideWith(
            (ref) => Completer<List<ContributorEntry>?>().future,
          ),
          sponsorsProvider.overrideWith(
            (ref) => Completer<List<SponsorEntry>?>().future,
          ),
        ],
        child: MaterialApp(
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: const FToaster(child: SponsorshipTeamPage()),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(_bones, findsWidgets);
  });

  testWidgets('tab tim: skeleton saat loading, bukan kosong', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contributorsProvider.overrideWith(
            (ref) => Completer<List<ContributorEntry>?>().future,
          ),
          sponsorsProvider.overrideWith(
            (ref) => Completer<List<SponsorEntry>?>().future,
          ),
        ],
        child: MaterialApp(
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: const FToaster(child: SponsorshipTeamPage()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tapTimKami(tester);
    await tester.pump();

    expect(_bones, findsWidgets);
  });

  testWidgets('data selesai: konten tampil tanpa skeleton', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contributorsProvider.overrideWith((ref) async => [_contributor]),
          sponsorsProvider.overrideWith((ref) async => [_sponsor]),
        ],
        child: MaterialApp(
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: const FToaster(child: SponsorshipTeamPage()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_bones, findsNothing);
    expect(find.text('Mitra A'), findsOneWidget);
    await tapTimKami(tester);
    await tester.pumpAndSettle();

    expect(find.text('Budi'), findsOneWidget);
  });

  testWidgets('gagal fetch: section hilang, halaman tetap utuh', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contributorsProvider.overrideWith((ref) async => null),
          sponsorsProvider.overrideWith((ref) async => null),
        ],
        child: MaterialApp(
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: const FToaster(child: SponsorshipTeamPage()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_bones, findsNothing);
    expect(find.text('Mitra A'), findsNothing);
    // Blok statis tetap tampil.
    expect(find.text('Ingin ikut mendukung?'), findsOneWidget);
  });
}
