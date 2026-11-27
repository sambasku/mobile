import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/theme/f_colors_x.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/vote/presentation/widgets/vote_buttons.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

// #368: upvote aktif hijau, downvote aktif merah, idle abu-abu.
Future<void> _pump(WidgetTester tester, int? myVote) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        ...FLocalizations.localizationsDelegates,
      ],
      supportedLocales: const [Locale('id')],
      locale: const Locale('id'),
      home: FTheme(
        data: foruiPalettes['zinc']!.light.touch,
        child: Scaffold(
          body: Center(
            child: VoteButtons(
              upvotes: 3,
              downvotes: 1,
              myVote: myVote,
              onVote: (_) async {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Color _iconColor(WidgetTester tester, IconData icon) =>
    tester.widget<Icon>(find.byIcon(icon)).color!;

void main() {
  final colors = foruiPalettes['zinc']!.light.touch.colors;

  testWidgets('upvote aktif berwarna hijau, downvote tetap abu-abu', (
    tester,
  ) async {
    await _pump(tester, 1);
    expect(_iconColor(tester, FLucideIcons.arrowBigUp), colors.success);
    expect(
      _iconColor(tester, FLucideIcons.arrowBigDown),
      colors.mutedForeground,
    );
  });

  testWidgets('downvote aktif berwarna merah, upvote tetap abu-abu', (
    tester,
  ) async {
    await _pump(tester, -1);
    expect(
      _iconColor(tester, FLucideIcons.arrowBigDown),
      colors.destructive,
    );
    expect(
      _iconColor(tester, FLucideIcons.arrowBigUp),
      colors.mutedForeground,
    );
  });

  testWidgets('belum vote: keduanya abu-abu', (tester) async {
    await _pump(tester, null);
    expect(
      _iconColor(tester, FLucideIcons.arrowBigUp),
      colors.mutedForeground,
    );
    expect(
      _iconColor(tester, FLucideIcons.arrowBigDown),
      colors.mutedForeground,
    );
  });
}
