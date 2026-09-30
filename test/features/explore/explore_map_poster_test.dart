import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/explore/presentation/widgets/explore_map_poster.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: FTheme(
    data: FThemes.zinc.light.touch,
    child: SizedBox(width: 360, height: 248, child: child),
  ),
);

void main() {
  testWidgets('loading placeholder shows no offline copy', (tester) async {
    await tester.pumpWidget(
      _wrap(const ExploreMapPoster(compact: false, loading: true)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Memuat peta...'), findsOneWidget);
    expect(find.textContaining('tidak bisa dimuat'), findsNothing);
    expect(find.bySemanticsLabel('Memuat peta'), findsOneWidget);
  });

  testWidgets('compact loading is icon only (hero has its own title)', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const ExploreMapPoster(loading: true)));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Memuat peta...'), findsNothing);
    expect(find.byIcon(FLucideIcons.map), findsOneWidget);
  });

  testWidgets('offline poster keeps its fallback copy', (tester) async {
    await tester.pumpWidget(_wrap(const ExploreMapPoster(compact: false)));

    expect(find.textContaining('tidak bisa dimuat'), findsOneWidget);
    expect(find.text('Memuat peta...'), findsNothing);
  });
}
