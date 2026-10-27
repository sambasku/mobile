import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/features/activity/presentation/widgets/activity_feed_tile.dart';
import 'package:sambasku_mobile/features/user_profile/domain/entities/public_profile.dart';
import 'package:sambasku_mobile/features/user_profile/presentation/pages/public_profile_page.dart';
import 'package:sambasku_mobile/features/user_profile/presentation/models/public_activity_category_state.dart';
import 'package:sambasku_mobile/features/user_profile/presentation/providers/user_profile_providers.dart';
import 'package:sambasku_mobile/shared/widgets/small_button.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

class _FakeAuthStatus extends AuthStatusNotifier {
  _FakeAuthStatus(this.username);

  final String? username;

  @override
  Future<AuthStatusState> build() async =>
      AuthStatusState(isAuth: username != null, username: username);
}

const _profile = PublicProfile(
  username: 'budi',
  displayName: 'Budi',
  role: 'contributor',
  isVerifier: false,
  joinedAt: '2026-08-01T00:00:00.000Z',
  contributionsApproved: 2,
  wordsApproved: 1,
  correctionsApproved: 1,
  verificationsDone: 0,
  commentsPublished: 0,
);

final _activity = [
  const PublicActivityItem(
    id: '01ACT0000000000000000001',
    kind: 'contribution',
    occurredAt: '2026-09-30T10:00:00.000Z',
    summary: 'menambahkan "kumis"',
    wordId: 'w1',
    lemma: 'kumis',
  ),
  const PublicActivityItem(
    id: '01ACT0000000000000000002',
    kind: 'comment',
    occurredAt: '2026-09-29T10:00:00.000Z',
    summary: 'bagus nih',
  ),
];

final _categoryPage = PublicActivityCategoryState(items: _activity);

Future<void> _pump(WidgetTester tester, {String? sessionUsername}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStatusProvider.overrideWith(() => _FakeAuthStatus(sessionUsername)),
        publicProfileProvider('budi').overrideWith((ref) async => _profile),
        publicActivityProvider('budi').overrideWith((ref) async => _activity),
        // Chip Perbaikan/Komentar baca family kind - override dua kind aktif.
        for (final kind in ['contribution', 'comment'])
          publicActivityByKindProvider(
            'budi',
            kind,
          ).overrideWith((ref) async => _categoryPage),
      ],
      child: MaterialApp(
        localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        ...FLocalizations.localizationsDelegates,
      ],
        supportedLocales: const [Locale('id')],
      locale: const Locale('id'),
        builder: (context, child) =>
            FTheme(data: foruiPalettes['zinc']!.light.touch, child: child!),
        home: const PublicProfilePage(username: 'budi'),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('aktivitas terbaru dirender sebagai ActivityFeedTile', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byType(ActivityFeedTile), findsNWidgets(2));
    expect(find.byType(FTileGroup), findsNothing);
    // Body dirender sebagai Text.rich (splitQuotedLemma), bukan Text polos.
    expect(find.textContaining('bagus nih'), findsOneWidget);
  });

  testWidgets('stat profil dirender inline, bukan kartu', (tester) async {
    await _pump(tester);

    expect(find.textContaining('usul kata'), findsOneWidget);
    expect(find.textContaining('perbaikan'), findsOneWidget);
  });

  testWidgets('chips kategori aktivitas tampil dan filter per kind', (
    tester,
  ) async {
    await _pump(tester);

    // Semua kategori ada, "Semua" terpilih default. Cari khusus chips:
    // label kind yang sama juga muncul di tile feed.
    final chips = find.byKey(const ValueKey('profile_activity_chips'));
    // #193: selaras feed beranda - hanya Semua | Perbaikan | Komentar.
    for (final label in ['Semua', 'Perbaikan', 'Komentar']) {
      expect(
        find.descendant(of: chips, matching: find.text(label)),
        findsOneWidget,
        reason: 'chip $label hilang',
      );
    }
    for (final gone in ['Kontribusi', 'Verifikasi', 'Penilaian']) {
      expect(
        find.descendant(of: chips, matching: find.text(gone)),
        findsNothing,
        reason: 'chip $gone harus dihapus (tidak ada di feed utama)',
      );
    }
    final allChip = tester.widget<FButton>(
      find.ancestor(
        of: find.descendant(of: chips, matching: find.text('Semua')),
        matching: find.byType(FButton),
      ),
    );
    expect(allChip.variant, FButtonVariant.primary);

    // Tap "Komentar" -> provider kind comment dipanggil, chip ikut terpilih.
    await tester.tap(
      find.descendant(of: chips, matching: find.text('Komentar')),
    );
    await tester.pump();

    final commentChip = tester.widget<FButton>(
      find.ancestor(
        of: find.descendant(of: chips, matching: find.text('Komentar')),
        matching: find.byType(FButton),
      ),
    );
    expect(
      commentChip.variant,
      FButtonVariant.primary,
      reason: 'chip yang di-tap harus tampil terpilih, bukan balik ke Semua',
    );
    // Chips tetap ada selama kategori baru memuat (pelajaran bug #193).
    expect(chips, findsOneWidget);
    expect(
      find.descendant(of: chips, matching: find.text('Semua')),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
  });

  testWidgets('chips full-bleed: tepi kiri viewport, bukan digeser childPad', (
    tester,
  ) async {
    await _pump(tester);

    // Selaras feed beranda (#193): baris chip menempel ke tepi layar.
    // Regresi: FScaffold childPad:true menggeser SELURUH scroll view 12px,
    // jadi chip tampak double-pad (24 dari tepi) dan garis bawahnya tidak
    // sampai ke tepi.
    final chipsFinder = find.byKey(const ValueKey('profile_activity_chips'));
    final chipsRect = tester.getRect(chipsFinder);
    expect(
      chipsRect.left,
      0,
      reason: 'baris chip harus full-bleed dari tepi kiri layar',
    );
    expect(
      MediaQuery.sizeOf(tester.element(chipsFinder)).width - chipsRect.right,
      closeTo(0, 0.5),
      reason: 'baris chip harus full-bleed sampai tepi kanan layar',
    );
  });

  testWidgets('profil orang lain: tanpa tombol Edit, CTA tile tampil', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.bySemanticsLabel('Edit profil'), findsNothing);
    expect(find.byIcon(FLucideIcons.chevronRight), findsOneWidget);
    expect(find.text('Lihat arti'), findsOneWidget);
  });

  testWidgets(
    'profil sendiri: tombol Edit kecil di body, CTA tile disembunyikan',
    (tester) async {
      await _pump(tester, sessionUsername: 'budi');

      // Layout publik tetap lama: tombol Edit kecil di sisi kanan identitas.
      // Ikon edit di app bar hanya milik tab Profil.
      expect(find.byType(SmallButton), findsOneWidget);
      expect(find.bySemanticsLabel('Edit profil'), findsNothing);
      expect(find.byIcon(FLucideIcons.chevronRight), findsNothing);
      expect(find.text('Lihat arti'), findsNothing);
      // Body tetap dirender (header identitas + cover membuat aktivitas
      // berada di bawah fold, jadi gulir dulu).
      await tester.scrollUntilVisible(
        find.textContaining('bagus nih'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('bagus nih'), findsOneWidget);
    },
  );
}
