import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/theme/f_colors_x.dart';
import 'package:sambasku_mobile/features/vote/presentation/widgets/vote_buttons.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

final _zincLight = foruiPalettes['zinc']!.light.touch;

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: [
      ...AppLocalizations.localizationsDelegates,
      ...FLocalizations.localizationsDelegates,
    ],
    supportedLocales: const [Locale('id')],
    locale: const Locale('id'),
    home: FTheme(
      data: _zincLight,
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

/// Parent stateful: meniru pemakai nyata yang update myVote setelah vote.
class _Host extends StatefulWidget {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  int? _myVote;

  @override
  Widget build(BuildContext context) {
    return _wrap(
      VoteButtons(
        upvotes: 3,
        downvotes: 1,
        myVote: _myVote,
        onVote: (value) async {
          setState(() => _myVote = _myVote == value ? null : value);
        },
      ),
    );
  }
}

Color _iconColor(WidgetTester tester, IconData icon) {
  return tester.widget<Icon>(find.byIcon(icon)).color!;
}

double _scaleOf(WidgetTester tester, {required bool up}) {
  final transition = tester.widget<ScaleTransition>(
    find.ancestor(
      of: find.byIcon(
        up ? FLucideIcons.arrowBigUp : FLucideIcons.arrowBigDown,
      ),
      matching: find.byType(ScaleTransition),
    ),
  );
  return transition.scale.value;
}

void main() {
  testWidgets('urutan tombol: downvote kiri, upvote kanan', (tester) async {
    await tester.pumpWidget(const _Host());
    await tester.pump();
    final downCenter = tester.getCenter(
      find.byIcon(FLucideIcons.arrowBigDown),
    );
    final upCenter = tester.getCenter(find.byIcon(FLucideIcons.arrowBigUp));
    expect(downCenter.dx, lessThan(upCenter.dx));
  });

  testWidgets('vote aktif: punch scale > 1 lalu kembali ke 1', (tester) async {
    await tester.pumpWidget(const _Host());
    await tester.pump();
    expect(_scaleOf(tester, up: true), 1.0);

    await tester.tap(find.byIcon(FLucideIcons.arrowBigUp));
    await tester.pump(); // rebuild dengan myVote = 1 -> punch mulai.
    await tester.pump(const Duration(milliseconds: 1));

    expect(_scaleOf(tester, up: true), greaterThan(1.0));

    await tester.pumpAndSettle();
    expect(_scaleOf(tester, up: true), 1.0);
  });

  testWidgets('un-vote: tidak ada punch (scale tetap 1)', (tester) async {
    await tester.pumpWidget(const _Host());
    await tester.pump();
    await tester.tap(find.byIcon(FLucideIcons.arrowBigUp));
    await tester.pumpAndSettle();
    expect(_scaleOf(tester, up: true), 1.0);

    await tester.tap(find.byIcon(FLucideIcons.arrowBigUp));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(_scaleOf(tester, up: true), 1.0);
  });

  // #245: indikator arah vote harus beda warna (bukan primary abu Zinc).
  testWidgets('myVote null: kedua panah mutedForeground', (tester) async {
    await tester.pumpWidget(
      _wrap(
        VoteButtons(
          upvotes: 2,
          downvotes: 1,
          myVote: null,
          onVote: (_) async {},
        ),
      ),
    );
    await tester.pump();
    final idle = _zincLight.colors.mutedForeground;
    expect(_iconColor(tester, FLucideIcons.arrowBigUp), idle);
    expect(_iconColor(tester, FLucideIcons.arrowBigDown), idle);
  });

  testWidgets('myVote 1: naik success, turun muted', (tester) async {
    await tester.pumpWidget(
      _wrap(
        VoteButtons(
          upvotes: 2,
          downvotes: 1,
          myVote: 1,
          onVote: (_) async {},
        ),
      ),
    );
    await tester.pump();
    expect(
      _iconColor(tester, FLucideIcons.arrowBigUp),
      _zincLight.colors.success,
    );
    expect(
      _iconColor(tester, FLucideIcons.arrowBigDown),
      _zincLight.colors.mutedForeground,
    );
  });

  testWidgets('myVote -1: turun destructive, naik muted', (tester) async {
    await tester.pumpWidget(
      _wrap(
        VoteButtons(
          upvotes: 2,
          downvotes: 1,
          myVote: -1,
          onVote: (_) async {},
        ),
      ),
    );
    await tester.pump();
    expect(
      _iconColor(tester, FLucideIcons.arrowBigDown),
      _zincLight.colors.destructive,
    );
    expect(
      _iconColor(tester, FLucideIcons.arrowBigUp),
      _zincLight.colors.mutedForeground,
    );
  });
}
