import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/pronunciation_providers.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/widgets/audio_player_tile.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/widgets/pronunciation_section.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

Future<void> _pumpSection(
  WidgetTester tester, {
  required List<WordAudio> audios,
  String? exampleId,
  bool compact = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        wordDialectsProvider('lang-1').overrideWith(
          (ref) async => const <DialectOption>[],
        ),
      ],
      child: MaterialApp(
        theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          ...FLocalizations.localizationsDelegates,
        ],
        supportedLocales: const [Locale('id')],
        locale: const Locale('id'),
        builder: (context, child) => FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: FToaster(child: child!),
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: PronunciationSection(
              wordId: 'w-1',
              languageId: 'lang-1',
              audios: audios,
              exampleId: exampleId,
              compact: compact,
              spokenText: 'apam',
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const sampleAudio = WordAudio(
    id: 'a-1',
    url: 'https://example.com/apam.m4a',
    speakerName: 'Budi',
    durationMs: 2500,
    isPrimary: true,
  );

  testWidgets('lemma compact menampilkan Rekam pelafalan dengan tile kompak', (
    tester,
  ) async {
    await _pumpSection(tester, audios: const [], exampleId: null, compact: true);

    expect(find.text('Rekam pelafalan'), findsOneWidget);
    expect(find.text('Rekam audio contoh'), findsNothing);
    expect(find.byIcon(FLucideIcons.mic), findsOneWidget);
    expect(find.byType(FButton), findsNothing);
  });

  testWidgets('contoh kalimat menampilkan Rekam audio contoh dengan tile kompak', (
    tester,
  ) async {
    await _pumpSection(
      tester,
      audios: const [],
      exampleId: 'ex-1',
      compact: true,
    );

    expect(find.text('Rekam audio contoh'), findsOneWidget);
    expect(find.text('Rekam pelafalan'), findsNothing);
    expect(find.byIcon(FLucideIcons.mic), findsOneWidget);
    expect(find.byType(FButton), findsNothing);
  });

  testWidgets('tile rekam tampil seragam bersama AudioPlayerTile saat ada audio', (
    tester,
  ) async {
    await _pumpSection(
      tester,
      audios: const [sampleAudio],
      exampleId: null,
      compact: true,
    );

    expect(find.byType(AudioPlayerTile), findsOneWidget);
    expect(find.text('Rekam pelafalan'), findsOneWidget);
    expect(find.byIcon(FLucideIcons.mic), findsOneWidget);
    expect(find.byType(FButton), findsNothing);
  });
}
