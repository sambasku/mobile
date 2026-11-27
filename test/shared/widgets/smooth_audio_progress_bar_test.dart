import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:sambasku_mobile/shared/widgets/audio_player_surface.dart';
import 'package:sambasku_mobile/shared/widgets/smooth_audio_progress_bar.dart';
import 'package:sambasku_mobile/shared/widgets/thread_audio_player.dart';

double _widthFactorOf(WidgetTester tester) {
  final box = tester.widget<FractionallySizedBox>(
    find.byType(FractionallySizedBox),
  );
  return box.widthFactor ?? 0.0;
}

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        ...FLocalizations.localizationsDelegates,
      ],
      supportedLocales: const [Locale('id')],
      locale: const Locale('id'),
      home: FTheme(
        data: foruiPalettes['zinc']!.light.touch,
        child: Scaffold(
          body: Center(child: SizedBox(width: 240, child: child)),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('SmoothAudioProgressBar: interpolasi maju halus saat playing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SmoothAudioProgressBar(
          position: Duration(seconds: 2),
          duration: Duration(seconds: 10),
          isPlaying: true,
          color: Color(0xFF000000),
          trackColor: Color(0xFFCCCCCC),
          enabled: true,
        ),
      ),
    );
    await tester.pump();
    expect(_widthFactorOf(tester), closeTo(0.2, 0.01));

    // Tanpa update position baru dari stream, ticker memajukan bar +500ms -> ~0.25.
    await tester.pump(const Duration(milliseconds: 500));
    expect(_widthFactorOf(tester), greaterThan(0.23));
    expect(_widthFactorOf(tester), lessThan(0.27));
  });

  testWidgets('SmoothAudioProgressBar: berhenti saat paused', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SmoothAudioProgressBar(
          position: Duration(seconds: 3),
          duration: Duration(seconds: 10),
          isPlaying: false,
          color: Color(0xFF000000),
          trackColor: Color(0xFFCCCCCC),
          enabled: true,
        ),
      ),
    );
    await tester.pump();
    expect(_widthFactorOf(tester), closeTo(0.3, 0.001));

    await tester.pump(const Duration(milliseconds: 500));
    expect(_widthFactorOf(tester), closeTo(0.3, 0.001));
  });

  testWidgets('SmoothAudioProgressBar: tap seek panggil onSeek & update bar', (
    tester,
  ) async {
    double? sought;
    await tester.pumpWidget(
      _wrap(
        SmoothAudioProgressBar(
          position: Duration.zero,
          duration: const Duration(seconds: 10),
          isPlaying: false,
          color: const Color(0xFF000000),
          trackColor: const Color(0xFFCCCCCC),
          enabled: true,
          onSeek: (r) => sought = r,
        ),
      ),
    );
    await tester.pump();

    final bar = find.byType(SmoothAudioProgressBar);
    await tester.tapAt(tester.getCenter(bar));
    await tester.pump();

    expect(sought, closeTo(0.5, 0.05));
    expect(_widthFactorOf(tester), closeTo(0.5, 0.05));
  });

  testWidgets('ThreadAudioPlayer: memakai AudioPlayerSurface seragam lemma', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const ThreadAudioPlayer(
          url: 'https://example.com/a.mp3',
          durationMs: 12000,
          compact: false,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AudioPlayerSurface), findsOneWidget);
    expect(find.byIcon(FLucideIcons.play), findsOneWidget);
  });
}
