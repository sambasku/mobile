import 'package:flutter/widgets.dart';
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
    await _pump(
      tester,
      const MediaQuery(
        // Status bar 24: cover full-bleed harus ikut menambah tinggi segini.
        data: MediaQueryData(padding: EdgeInsets.only(top: 24)),
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

    // Cover full-bleed: tinggi art = status bar + cover + separuh avatar.
    final headerTop = tester
        .getTopLeft(find.byType(ProfileIdentityHeader))
        .dy;
    expect(
      tester.getBottomLeft(avatar).dy - headerTop,
      closeTo(24 + 160 + 104 * 1.32 / 2, 0.5),
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

    // Cover placeholder = gradien, tanpa Image.network.
    expect(find.byType(Image), findsNothing);
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

    expect(find.byType(Image), findsOneWidget);
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
}
