import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/shared/widgets/profile_identity_header.dart';
import 'package:sambasku_mobile/shared/widgets/profile_stat_inline.dart';
import 'package:sambasku_mobile/shared/widgets/user_avatar.dart';

import '../helpers/l10n_delegates.dart';

/// Stat ringkas 2 angka - bentuk data yang dikirim API profil publik.
const _stats = ProfileStatRow(words: 3, corrections: 2);

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    FTheme(
      data: foruiPalettes['zinc']!.light.touch,
      child: MaterialApp(
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: appTestSupportedLocales,
        locale: appTestLocale,
        home: FScaffold(child: SingleChildScrollView(child: child)),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('hero: avatar 104, stat ringkas, cover placeholder', (
    tester,
  ) async {
    const surfaceWidth = 800.0;
    await _pump(
      tester,
      const MediaQuery(
        // Lebar 800: tinggi cover = lebar / rasio asset hero (1032×400).
        // Status bar overlay di atas cover (tidak menambah tinggi art).
        data: MediaQueryData(
          size: Size(surfaceWidth, 600),
          padding: EdgeInsets.only(top: 24),
        ),
        child: ProfileIdentityHeader(
          variant: ProfileHeaderVariant.hero,
          displayName: 'Budi Santoso',
          username: 'budi',
          bio: 'Suka berkontribusi',
          stats: _stats,
          joinedLabel: 'Bergabung 1 Agustus 2026',
        ),
      ),
    );

    final avatar = find.byType(UserAvatar);
    expect(avatar, findsOneWidget);
    expect(tester.getSize(avatar).width, 104);

    // Tinggi art = cover (rasio asset) + separuh frame avatar.
    // Foto di tengah frame (bukan nempel bawah) supaya selaras saat ada border.
    final headerTop = tester
        .getTopLeft(find.byType(ProfileIdentityHeader))
        .dy;
    final coverH = ProfileIdentityHeader.coverHeightOf(
      ProfileHeaderVariant.hero,
      surfaceWidth,
    );
    const avatarSize = 104.0;
    final extent = avatarSize * 1.32;
    expect(
      tester.getBottomLeft(avatar).dy - headerTop,
      closeTo(coverH + extent / 2 - (extent - avatarSize) / 2, 0.5),
    );

    // Dua angka yang dicari orang; sisanya sengaja tidak ditampilkan.
    for (final label in ['usul kata', 'perbaikan']) {
      expect(
        find.textContaining(label),
        findsOneWidget,
        reason: 'label $label',
      );
    }
    expect(
      find.text('usul kata'),
      findsNothing,
      reason: 'satu baris, bukan grid',
    );
    for (final label in ['verifikasi', 'komentar', 'kontribusi']) {
      expect(find.text(label), findsNothing, reason: 'noise: $label');
    }

    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('@budi'), findsOneWidget);
    expect(find.textContaining('Bergabung'), findsOneWidget);

    // Tanpa coverUrl: asset default tab Profil (bukan NetworkImage).
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName ==
                ProfileIdentityHeader.defaultCoverAsset(
                  ProfileHeaderVariant.hero,
                ),
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((w) => w is Image && w.image is NetworkImage),
      findsNothing,
    );
  });

  testWidgets('compact: stats null -> blok stat disembunyikan', (tester) async {
    await _pump(
      tester,
      const ProfileIdentityHeader(
        variant: ProfileHeaderVariant.compact,
        displayName: 'Budi',
      ),
    );

    expect(tester.getSize(find.byType(UserAvatar)).width, 72);
    expect(find.byType(ProfileStatRow), findsNothing);
    expect(find.text('usul kata'), findsNothing);
    // Tanpa username -> baris handle tidak dirender.
    expect(find.textContaining('@'), findsNothing);
  });

  testWidgets('coverUrl diisi -> Image cover muncul', (tester) async {
    await _pump(
      tester,
      const ProfileIdentityHeader(
        variant: ProfileHeaderVariant.compact,
        displayName: 'Budi',
        coverUrl: 'https://example.com/cover.jpg',
      ),
    );

    // Harness test memblokir HTTP (400); errorBuilder bisa menambah
    // Image.asset fallback. Kontrak yang diuji: NetworkImage cover ada.
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is NetworkImage &&
            (w.image as NetworkImage).url.contains('cover.jpg'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('actions + footer dirender', (tester) async {
    await _pump(
      tester,
      ProfileIdentityHeader(
        variant: ProfileHeaderVariant.hero,
        displayName: 'Budi',
        actions: [
          FButton(
            size: .xs,
            onPress: () {},
            child: const Text('Lihat profil publik'),
          ),
        ],
        footer: const Text('Lencana'),
      ),
    );

    expect(find.text('Lihat profil publik'), findsOneWidget);
    expect(find.text('Lencana'), findsOneWidget);
  });

  testWidgets(
    'avatarOverlay di kanan avatar tetap bisa di-tap (hit-test overflow)',
    (tester) async {
      var taps = 0;
      await _pump(
        tester,
        ProfileIdentityHeader(
          variant: ProfileHeaderVariant.compact,
          displayName: 'Budi',
          avatarOverlay: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => taps++,
            child: const SizedBox(
              width: 180,
              height: 36,
              child: Text('bubble-preview'),
            ),
          ),
        ),
      );

      final bubble = find.text('bubble-preview');
      expect(bubble, findsOneWidget);

      // Tap di ujung kanan bubble (di luar kotak avatar) - dulu miss.
      final box = tester.getRect(bubble);
      await tester.tapAt(Offset(box.right - 8, box.center.dy));
      await tester.pump();
      expect(taps, 1);
    },
  );
}
