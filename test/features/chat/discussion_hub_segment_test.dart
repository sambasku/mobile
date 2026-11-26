import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/chat/presentation/providers/chat_presence_provider.dart';
import 'package:sambasku_mobile/features/chat/presentation/widgets/discussion_hub_segment.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

class _FixedPresenceController extends ChatPresenceController {
  _FixedPresenceController(this._count);

  final int _count;

  @override
  int build() => _count;
}

Widget _wrap({
  required int index,
  required ValueChanged<int> onChanged,
  int presence = 0,
}) {
  return ProviderScope(
    overrides: [
      chatPresenceCountProvider.overrideWith(
        () => _FixedPresenceController(presence),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FTheme(
        data: foruiPalettes['zinc']!.light.touch,
        child: FScaffold(
          child: DiscussionHubSegment(index: index, onChanged: onChanged),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('render dua chip FBadge dengan ikon dan jumlah presence', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(index: 0, onChanged: (_) {}, presence: 7));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('discussion_hub_chips')), findsOneWidget);
    expect(find.byType(FTabs), findsNothing);

    final badges = tester.widgetList<FBadge>(find.byType(FBadge)).toList();
    expect(badges, hasLength(2));
    expect(badges[0].variant, FBadgeVariant.primary);
    expect(badges[1].variant, FBadgeVariant.secondary);

    expect(find.text('Chat (7)'), findsOneWidget);
    expect(find.text('Ruang Diskusi'), findsOneWidget);
    expect(find.byIcon(FLucideIcons.messageCircle), findsOneWidget);
    expect(find.byIcon(FLucideIcons.messagesSquare), findsOneWidget);
  });

  testWidgets('tap chip memanggil onChanged dengan indeks tujuan', (
    tester,
  ) async {
    final tapped = <int>[];
    await tester.pumpWidget(_wrap(index: 1, onChanged: tapped.add));
    await tester.pumpAndSettle();

    final badges = tester.widgetList<FBadge>(find.byType(FBadge)).toList();
    expect(badges[0].variant, FBadgeVariant.secondary);
    expect(badges[1].variant, FBadgeVariant.primary);

    await tester.tap(find.text('Chat (0)'));
    await tester.pump();
    await tester.tap(find.text('Ruang Diskusi'));
    await tester.pump();

    expect(tapped, [0, 1]);
  });
}
