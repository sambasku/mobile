import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/review/domain/entities/review_contribution.dart';
import 'package:sambasku_mobile/features/review/presentation/widgets/review_entity_preview.dart';
import 'package:sambasku_mobile/shared/reference/reference_data.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Id berbentuk ULID seperti yang dikirim API. Kalau salah satu bocor ke layar,
// test ini gagal - itulah regresi yang Originally dilaporkan.
const _classId = '01JQ7ZC3K9M4XQ2VN8B1TLDA';
const _langJawa = '01JQ7ZC3K9M4XQ2VN8B1TLDB';
const _langInggris = '01JQ7ZC3K9M4XQ2VN8B1TLDC';

const _classes = [
  ReferenceItem(id: _classId, name: 'Nomina', code: 'n'),
  ReferenceItem(
    id: '01JQ7ZC3K9M4XQ2VN8B1TLDD',
    name: 'Verba',
    code: 'v',
    alias: 'kata kerja',
  ),
];

const _languages = [
  ReferenceItem(
    id: _langJawa,
    name: 'Jawa',
    code: 'jv',
    nativeName: 'ꦧꦱꦗꦮ',
  ),
  ReferenceItem(
    id: _langInggris,
    name: 'Inggris',
    code: 'en',
    nativeName: 'English',
  ),
];

ReviewDetail _detail(String entityType, Map<String, dynamic> entity) {
  return ReviewDetail(
    contribution: ReviewItem(
      id: 'c1',
      contributorUsername: 'kontributor',
      entityType: entityType,
      entityId: 'e1',
      action: 'create',
      status: 'pending',
      createdAt: '2026-01-01T00:00:00.000Z',
    ),
    entity: entity,
  );
}

/// Payload `meaning` persis bentuk dari `contribution.repository.impl.ts`.
Map<String, dynamic> _meaningEntity({
  String definition = 'Makna dari kamus',
  bool? isHaveDefinition,
  String? meaningSource = 'kbbi',
  List<Map<String, dynamic>>? translations,
  bool? isHaveTranslation,
}) {
  return {
    'id': '01JQ7ZC3K9M4XQ2VN8B1TLDE',
    'wordId': '01JQ7ZC3K9M4XQ2VN8B1TLDF',
    'wordLemma': 'nulis',
    'status': 'pending_review',
    'data': {
      'word_class_id': _classId,
      'definition': definition,
      'is_have_definition': ?isHaveDefinition,
      'is_have_translation': ?isHaveTranslation,
      'meaning_source': meaningSource,
      'translations':
          translations ??
          [
            {
              'language_id': _langJawa,
              'translation_text': 'nulis',
              'translation_type': 'padanan',
            },
            {
              'language_id': _langInggris,
              'translation_text': 'write',
              'translation_type': 'padanan',
            },
          ],
    },
  };
}

Map<String, dynamic> _exampleEntity() {
  return {
    'id': '01JQ7ZC3K9M4XQ2VN8B1TLDG',
    'wordId': '01JQ7ZC3K9M4XQ2VN8B1TLDF',
    'wordLemma': 'nulis',
    'status': 'pending_review',
    'data': {
      'source_language_id': _langJawa,
      'source_sentence': 'aku nulis surat',
      'target_language_id': _langInggris,
      'target_sentence': 'I write a letter',
      'source_type': 'other',
      'notes': 'catatan contoh',
    },
  };
}

void main() {
  Future<void> pumpPreview(
    WidgetTester tester,
    ReviewDetail detail,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          referenceWordClassesProvider.overrideWith((ref) async => _classes),
          referenceLanguagesProvider.overrideWith((ref) async => _languages),
        ],
        child: MaterialApp(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: ReviewEntityPreview(detail: detail),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Semua teks yang benar-benar tampil di widget.
  String visibleText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .join('\n');

  group('saat data referensi belum selesai dimuat', () {
    Future<void> pumpLoading(WidgetTester tester, ReviewDetail detail) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            referenceWordClassesProvider.overrideWith(
              (ref) => Completer<List<ReferenceItem>>().future,
            ),
            referenceLanguagesProvider.overrideWith(
              (ref) => Completer<List<ReferenceItem>>().future,
            ),
          ],
          child: MaterialApp(
            theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
            localizationsDelegates: FLocalizations.localizationsDelegates,
            supportedLocales: FLocalizations.supportedLocales,
            home: FTheme(
              data: FThemes.zinc.light.touch,
              child: Scaffold(
                body: SingleChildScrollView(
                  child: SizedBox(
                    width: 400,
                    child: ReviewEntityPreview(detail: detail),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('baris kelas kata tetap ada sebagai shimmer, bukan ULID', (
      tester,
    ) async {
      await pumpLoading(tester, _detail('meaning', _meaningEntity()));
      await tester.pump(const Duration(milliseconds: 300));

      // Baris tidak hilang -> tinggi layout tidak bergeser.
      expect(find.text('Kelas kata'), findsOneWidget);
      expect(find.byType(SkeletonizerConfig), findsWidgets);
      // ULID tidak boleh bocor selama loading.
      expect(find.textContaining(_classId), findsNothing);
      expect(find.textContaining('01JQ7ZC'), findsNothing);
    });

    testWidgets('nama bahasa tiap terjemahan shimmering', (tester) async {
      await pumpLoading(tester, _detail('meaning', _meaningEntity()));
      await tester.pump(const Duration(milliseconds: 300));

      // Teks terjemahan tetap terbaca walau nama bahasanya belum dimuat.
      expect(find.text('write'), findsOneWidget);
      expect(find.textContaining(_langInggris), findsNothing);
      expect(find.byType(SkeletonizerConfig), findsWidgets);
    });

    testWidgets('shimmer hilang setelah referensi ter-resolve', (
      tester,
    ) async {
      await pumpPreview(tester, _detail('meaning', _meaningEntity()));
      expect(find.text('Nomina'), findsOneWidget);
      expect(find.byType(SkeletonizerConfig), findsNothing);
    });
  });

  group('preview makna', () {
    testWidgets('menampilkan nama kelas kata, bukan ULID', (tester) async {
      await pumpPreview(tester, _detail('meaning', _meaningEntity()));
      final text = visibleText(tester);

      expect(text, contains('Nomina'));
      expect(text, isNot(contains(_classId)));
      expect(find.textContaining('01JQ7ZC'), findsNothing);
    });

    testWidgets('menampilkan setiap terjemahan sebagai baris dengan nama bahasa', (
      tester,
    ) async {
      await pumpPreview(tester, _detail('meaning', _meaningEntity()));
      final text = visibleText(tester);

      expect(text, contains('Jawa'));
      expect(text, contains('nulis'));
      expect(text, contains('Inggris'));
      expect(text, contains('write'));
      // Tidak ada repr Dart dari List<Map>.
      expect(text, isNot(contains('language_id')));
      expect(text, isNot(contains('translation_text')));
      expect(find.textContaining('{'), findsNothing);
    });

    testWidgets('menampilkan provenance KBBI dan manual', (tester) async {
      await pumpPreview(tester, _detail('meaning', _meaningEntity()));
      expect(find.text('Dari KBBI'), findsOneWidget);

      await pumpPreview(
        tester,
        _detail(
          'meaning',
          _meaningEntity(meaningSource: 'kbbi_edited'),
        ),
      );
      expect(find.text('Dari KBBI (diubah)'), findsOneWidget);

      await pumpPreview(
        tester,
        _detail('meaning', _meaningEntity(meaningSource: 'manual')),
      );
      expect(find.text('Ketik manual'), findsOneWidget);
    });

    testWidgets('definisi placeholder ditampilkan sebagai "Belum diisi"', (
      tester,
    ) async {
      await pumpPreview(
        tester,
        _detail(
          'meaning',
          _meaningEntity(definition: '-', isHaveDefinition: false),
        ),
      );
      final text = visibleText(tester);

      expect(text, contains('Belum diisi'));
      // Character placeholder tidak boleh bocor.
      expect(text, isNot(contains('Definisi\n-')));
    });

    testWidgets('flag boolean internal tidak tampil sebagai true/false', (
      tester,
    ) async {
      await pumpPreview(
        tester,
        _detail(
          'meaning',
          _meaningEntity(isHaveDefinition: true, isHaveTranslation: true),
        ),
      );
      final text = visibleText(tester);

      expect(text, isNot(contains('is_have_definition')));
      expect(text, isNot(contains('is_have_translation')));
    });

    testWidgets('terjemahan kosong tapi ditandai ada = penanda inkonsistensi', (
      tester,
    ) async {
      await pumpPreview(
        tester,
        _detail(
          'meaning',
          _meaningEntity(translations: const [], isHaveTranslation: true),
        ),
      );
      expect(
        find.text('Ditandai ada terjemahan, tetapi belum diisi.'),
        findsOneWidget,
      );
    });

    testWidgets('terjemangan kosong dan sengaja tidak diisi', (tester) async {
      await pumpPreview(
        tester,
        _detail(
          'meaning',
          _meaningEntity(translations: const [], isHaveTranslation: false),
        ),
      );
      expect(
        find.text('Kontributor sengaja tidak mengisi terjemahan.'),
        findsOneWidget,
      );
    });
  });

  group('preview contoh kalimat', () {
    testWidgets('menampilkan kedua kalimat dengan nama bahasa', (tester) async {
      await pumpPreview(tester, _detail('example', _exampleEntity()));
      final text = visibleText(tester);

      expect(text, contains('Kalimat sambas'));
      expect(text, contains('Kalimat terjemahan'));
      expect(text, contains('aku nulis surat'));
      expect(text, contains('I write a letter'));
      expect(text, contains('Jawa'));
      expect(text, contains('Inggris'));
    });

    testWidgets('tidak membocorkan ULID bahasa maupun kunci mentah', (
      tester,
    ) async {
      await pumpPreview(tester, _detail('example', _exampleEntity()));
      final text = visibleText(tester);

      expect(text, isNot(contains(_langJawa)));
      expect(text, isNot(contains(_langInggris)));
      expect(text, isNot(contains('source_language_id')));
      expect(text, isNot(contains('target_language_id')));
      expect(text, isNot(contains('source_sentence')));
      expect(find.textContaining('01JQ7ZC'), findsNothing);
    });

    testWidgets('menampilkan jenis sumber dan catatan', (tester) async {
      await pumpPreview(tester, _detail('example', _exampleEntity()));
      final text = visibleText(tester);

      expect(text, contains('Jenis sumber'));
      expect(text, contains('other'));
      expect(text, contains('catatan contoh'));
    });

    testWidgets('kalimat kosong ditandai "Belum diisi"', (tester) async {
      await pumpPreview(
        tester,
        _detail('example', {
          'wordLemma': 'nulis',
          'data': {'source_language_id': _langJawa, 'source_sentence': ''},
        }),
      );
      // Kedua peran kosong pada fixture ini, jadi dua baris "Belum diisi".
      expect(find.text('Belum diisi'), findsNWidgets(2));
    });
  });

  group('fallback entity tanpa preview khusus', () {
    testWidgets('nilai List<Map> dirender per baris, tidak via toString', (
      tester,
    ) async {
      await pumpPreview(
        tester,
        _detail('tipe_baru', {
          'wordLemma': 'nulis',
          'data': {
            'notes': 'catatan',
            'translations': [
              {
                'language_id': _langJawa,
                'translation_text': 'nulis',
              },
            ],
          },
        }),
      );
      final text = visibleText(tester);

      expect(text, contains('catatan'));
      expect(find.textContaining('{'), findsNothing);
      expect(text, isNot(contains('language_id')));
    });

    testWidgets('kunci tak dikenal dilewati, tidak ditampilkan mentah', (
      tester,
    ) async {
      await pumpPreview(
        tester,
        _detail('tipe_baru', {
          'wordLemma': 'nulis',
          'data': {
            'notes': 'catatan',
            'mystery_field': 'nilai_rahasia',
          },
        }),
      );
      final text = visibleText(tester);

      expect(text, isNot(contains('mystery_field')));
      expect(text, isNot(contains('nilai_rahasia')));
    });
  });
}
