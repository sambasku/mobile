import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/word_detail_providers.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/widgets/audio_player_tile.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_deck_item.dart';
import 'package:sambasku_mobile/features/vote/presentation/widgets/vote_deck_word_card.dart';
import 'package:sambasku_mobile/shared/widgets/cached_network_image_with_fallback.dart';

const _item = VoteDeckItem(
  id: '01WORD0000000000000000000A',
  lemma: 'kalintiak',
  languageId: '01LANG',
  languageCode: 'sbs',
  wordType: 'word',
  status: 'published',
  isVerified: false,
  approvedAt: '2026-09-01T00:00:00.000Z',
  sense: 'ikan kecil',
);

const _detail = WordDetail(
  id: '01WORD0000000000000000000A',
  lemma: 'kalintiak',
  languageId: '01LANG',
  wordType: 'word',
  status: 'published',
  isVerified: false,
  isCorrected: false,
  audios: [WordAudio(id: 'a1', url: 'https://cdn.test/a1.m4a')],
  images: [WordImage(id: 'i1', url: 'https://cdn.test/i1.jpg', isPrimary: true)],
  meanings: [
    WordMeaning(
      id: 'm1',
      orderIndex: 0,
      wordClassName: 'Nomina',
      definition: 'ikan kecil di sungai',
      translations: [WordTranslation(text: 'ikan kecil', type: 'direct')],
      examples: [
        WordExample(
          id: 'e1',
          sourceSentence: 'kalintiak banyak di sungai',
          targetSentence: 'ikan kecil banyak di sungai',
        ),
      ],
    ),
    WordMeaning(
      id: 'm2',
      orderIndex: 1,
      wordClassName: 'Verba',
      translations: [WordTranslation(text: 'melompat', type: 'direct')],
    ),
  ],
);

Future<void> _pump(WidgetTester tester, Future<WordDetail> Function() load) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [wordDetailProvider(_item.id).overrideWith((ref) => load())],
      child: MaterialApp(
        home: FTheme(
          data: FThemes.zinc.light.touch,
          child: const Scaffold(
            body: SizedBox(width: 800, height: 900, child: VoteDeckWordCard(item: _item)),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('kartu menampilkan semua makna, contoh, audio, dan gambar', (tester) async {
    await _pump(tester, () async => _detail);

    expect(find.text('ikan kecil di sungai'), findsOneWidget);
    expect(find.text('→ melompat'), findsOneWidget);
    expect(find.text('1.'), findsOneWidget);
    expect(find.text('2.'), findsOneWidget);
    expect(find.text('kalintiak banyak di sungai'), findsOneWidget);
    expect(find.byType(AudioPlayerTile), findsOneWidget);
    expect(find.byType(CachedNetworkImageWithFallback), findsOneWidget);
  });

  testWidgets('selama detail dimuat, kartu tetap menampilkan lemma dan arti deck', (tester) async {
    await _pump(tester, () => Completer<WordDetail>().future);

    expect(find.text('kalintiak'), findsOneWidget);
    expect(find.text('ikan kecil'), findsOneWidget);
    expect(find.byType(AudioPlayerTile), findsNothing);
  });
}
