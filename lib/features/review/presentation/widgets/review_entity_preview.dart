import 'dart:async';
import '../../../dictionary/presentation/dictionary_labels.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../shared/reference/reference_data.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../contribution/domain/meaning_source.dart';
import '../../../dictionary/domain/entities/word_detail.dart';
import '../../../../shared/domain/word_type_options.dart';
import '../../domain/entities/review_contribution.dart';
import 'review_inline_type_editor.dart';

/// Preview baca-saja isi usulan - per jenis entity, bukan dump key:value.
class ReviewEntityPreview extends ConsumerWidget {
  const ReviewEntityPreview({
    super.key,
    required this.detail,
    this.scrollable = true,
  });

  final ReviewDetail detail;
  final bool scrollable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = detail.contribution.entityType;
    // Semua preview digulir: tinggi kartu berubah-ubah (jumlah baris action
    // bar ikut menentukan sisa ruang), dan isinya berasal dari DB - kata
    // dengan banyak makna atau definisi panjang akan lebih tinggi dari
    // kartu. Column telanjang meluap jadi error di dalam stack, bukan sekadar
    // terpotong.
    final content = switch (type) {
      'word' => _WordPreview(detail: detail),
      'word_image' => _ImagePreview(entity: detail.entity),
      'word_audio' => _AudioPreview(entity: detail.entity, label: AppLocalizations.of(context).reviewPreviewAudioProposal),
      'pronunciation' => _PronunciationPreview(entity: detail.entity),
      'example' => _ExamplePreview(entity: detail.entity),
      'meaning' => _MeaningPreview(entity: detail.entity),
      _ => _FieldPreview(entity: detail.entity),
    };

    if (scrollable) {
      return SingleChildScrollView(child: content);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = context.theme;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showPreviewSheet(context, content),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight - 32,
                  ),
                  // Konten bisa lebih tinggi dari kartu (DB: banyak makna /
                  // definisi panjang). SingleChildScrollView tanpa gesture
                  // memotong kelebihan itu tanpa memicu assert RenderFlex
                  // overflow - ClipRect saja tidak menahan assert di Column.
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: content,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colors.background.withValues(alpha: 0),
                        theme.colors.background.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        AppLocalizations.of(context).reviewPreviewTapToRead,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPreviewSheet(BuildContext context, Widget content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final theme = sheetContext.theme;
        return Material(
          color: theme.colors.background,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Gap(16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: content,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Kunci yang isinya id referensi - tidak pernah ditampilkan mentah, dan tidak
/// boleh ikutDibaca user jadi text field (bisa rusak kalau diketik).
const _referenceIdSuffixes = {
  '_id',
  '_ids',
  'provider_file_id',
};

bool _isReferenceIdKey(String key) =>
    _referenceIdSuffixes.any(key.endsWith) || key == 'provider_file_id';

/// Kunci boolean internal - dipakai untuk membentuk state (mis. definisi
/// placeholder), tidak ditampilkan sebagai "true"/"false".
bool _isFlagKey(String key) =>
    key == 'is_primary' ||
    key == 'is_verified' ||
    key == 'is_corrected' ||
    key == 'is_have_definition' ||
    key == 'is_have_translation';

/// Tampilan netral untuk field yang memang tidak ada isinya.
String _emptyValueLabel(AppLocalizations l10n) => l10n.commonEmptyField;

/// Shimmer saat data referensi (kelas kata/bahasa) masih dimuat.
///
/// Membungkus [child] yang sama dengan bentuk最终 akhir, jadi tinggi baris
/// tidak bergeser ketika nama id ter-resolve. Id mentah tidak pernah
/// ditampilkan selama proses ini - barisnya ber shimmer, bukan ULID.
class _Skeletonized extends StatelessWidget {
  const _Skeletonized({required this.loading, required this.child});

  final bool loading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!loading) return child;
    final theme = context.theme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = theme.colors.muted;
    PaintingEffect shimmerResolver(Brightness brightness) => ShimmerEffect(
      baseColor: isDark
          ? muted.withValues(alpha: 0.35)
          : const Color(0xFFE7E7EA),
      highlightColor: isDark
          ? muted.withValues(alpha: 0.55)
          : const Color(0xFFF4F4F5),
      duration: const Duration(milliseconds: 1500),
    );
    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effectResolver: shimmerResolver),
      child: IgnorePointer(child: Skeletonizer(enabled: true, child: child)),
    );
  }
}

Map<String, dynamic>? _childData(Map<String, dynamic> entity) {
  final data = entity['data'];
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return null;
}

String? _str(Map<String, dynamic>? map, String key) {
  final v = map?[key];
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

bool? _bool(Map<String, dynamic>? map, String key) {
  final v = map?[key];
  if (v is bool) return v;
  if (v == true || v == 'true' || v == 1) return true;
  if (v == false || v == 'false' || v == 0) return false;
  return null;
}

int? _int(Map<String, dynamic>? map, String key) {
  final v = map?[key];
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '');
}

String _formatDurationMs(int? ms, AppLocalizations l10n) {
  if (ms == null || ms <= 0) return '';
  final sec = (ms / 1000).round();
  if (sec < 60) return l10n.reviewPreviewDurationSec(sec);
  final min = sec ~/ 60;
  final rem = sec % 60;
  return rem == 0 ? l10n.reviewPreviewDurationMin(min) : l10n.reviewPreviewDurationMinSec(min, rem);
}

String _formatFileSize(int? bytes, AppLocalizations l10n) {
  if (bytes == null || bytes <= 0) return '';
  if (bytes < 1024) return l10n.reviewPreviewBytesB(bytes);
  if (bytes < 1024 * 1024) return l10n.reviewPreviewBytesKb((bytes / 1024).toStringAsFixed(1));
  return l10n.reviewPreviewBytesMb((bytes / (1024 * 1024)).toStringAsFixed(1));
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.muted.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.mutedForeground,
              ),
            ),
            const Gap(10),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    this.muted = false,
    this.emphasize = false,
    this.loading = false,
  });

  final String label;
  final String value;

  /// Nilai kosong ("Belum diisi") - tampil redup, bukan seperti isi sungguhan.
  final bool muted;

  /// Baris yang jadi penanda utama (mis. sumber makna KBBI vs manual).
  final bool emphasize;

  /// Nama referensi sedang dimuat - nilai ditampilkan sebagai shimmer.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: _Skeletonized(
              loading: loading,
              child: Text(
                value,
                style: theme.typography.body.sm.copyWith(
                  fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
                  color: muted ? theme.colors.mutedForeground : null,
                  fontStyle: muted ? FontStyle.italic : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WordPreview extends StatelessWidget {
  const _WordPreview({required this.detail});

  final ReviewDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final entity = detail.entity;
    final lemma = entity['lemma']?.toString() ?? '-';
    final wordType = entity['wordType']?.toString();
    final canEditType = detail.contribution.isPending;
    final notes = entity['notes']?.toString().trim();
    final usageLabels = knownUsageLabels(entity['usageLabels']);
    final meanings = entity['meanings'];
    final extras = _extras(AppLocalizations.of(context));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: AppLocalizations.of(context).reviewPreviewProposedWord,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lemma,
                style: theme.typography.body.lg.copyWith(fontWeight: FontWeight.w700),
              ),
              if (canEditType) ...[
                const Gap(8),
                ReviewInlineTypeEditor(detail: detail),
              ] else if (wordType != null && wordType.isNotEmpty) ...[
                const Gap(4),
                Text(
                  wordTypeOptionLabel(wordType),
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
              if (usageLabels.isNotEmpty) ...[
                const Gap(8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final code in usageLabels)
                      FBadge(
                        variant: isProminentUsageLabel(code)
                            ? FBadgeVariant.primary
                            : FBadgeVariant.secondary,
                        child: Text(usageLabelLabel(code, AppLocalizations.of(context))),
                      ),
                  ],
                ),
              ],
              if (notes != null && notes.isNotEmpty) ...[
                const Gap(8),
                Text(notes, style: theme.typography.body.sm),
              ],
            ],
          ),
        ),
        const Gap(12),
        _SectionCard(
          title: AppLocalizations.of(context).shareSectionMeaning,
          child: meanings is! List || meanings.isEmpty
              ? Text(
                  AppLocalizations.of(context).reviewPreviewNoMeaning,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < meanings.length; i++) ...[
                      if (i > 0) const Gap(12),
                      if (meanings[i] is Map) _MeaningBlock(raw: meanings[i] as Map),
                    ],
                  ],
                ),
        ),
        if (extras.isNotEmpty) ...[
          const Gap(12),
          _SectionCard(
            title: AppLocalizations.of(context).reviewPreviewCompleteness,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (label, values) in extras)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$label: ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: values.join(', ')),
                        ],
                      ),
                      style: theme.typography.body.sm,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Baris sinonim/antonim/variasi yang punya isi saja.
  List<(String, List<String>)> _extras(AppLocalizations l10n) {
    final entity = detail.entity;
    List<String> lemmas(String type) => [
      for (final r in _mapsOf(entity['relatedWords']))
        if (r['relationType'] == type && '${r['lemma'] ?? ''}'.isNotEmpty)
          '${r['lemma']}',
    ];
    final variants = [
      for (final v in _mapsOf(entity['variants']))
        if ('${v['form'] ?? ''}'.trim().isNotEmpty) '${v['form']}'.trim(),
    ];
    return [
      (l10n.reviewPreviewSynonyms, lemmas('synonym')),
      (l10n.reviewPreviewAntonyms, lemmas('antonym')),
      (l10n.reviewPreviewVariants, variants),
    ].where((row) => row.$2.isNotEmpty).toList();
  }
}

Iterable<Map> _mapsOf(Object? raw) => raw is List ? raw.whereType<Map>() : const [];

class _MeaningBlock extends StatelessWidget {
  const _MeaningBlock({required this.raw});

  final Map<dynamic, dynamic> raw;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final definition = raw['definition']?.toString() ?? '-';
    final translations = raw['translations'];
    String? terjemahan;
    if (translations is List && translations.isNotEmpty) {
      final first = translations.first;
      if (first is Map) {
        terjemahan = first['translationText']?.toString();
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(definition, style: theme.typography.body.sm),
        if (terjemahan != null && terjemahan.trim().isNotEmpty) ...[
          const Gap(4),
          Text(
            AppLocalizations.of(context).reviewPreviewTranslation(terjemahan),
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
        const Gap(4),
        Text(
          meaningSourceReviewLabel(
            raw['meaningSource']?.toString() ??
                raw['meaning_source']?.toString(),
          ),
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        for (final example in _mapsOf(raw['examples']))
          if ('${example['sourceSentence'] ?? ''}'.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 8),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '"${example['sourceSentence']}"',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                    if ('${example['targetSentence'] ?? ''}'.trim().isNotEmpty)
                      TextSpan(
                        text: ' - ${example['targetSentence']}',
                        style: TextStyle(color: theme.colors.mutedForeground),
                      ),
                  ],
                ),
                style: theme.typography.body.sm,
              ),
            ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.entity});

  final Map<String, dynamic> entity;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final data = _childData(entity);
    final url = _str(data, 'url');
    final alt = _str(data, 'alt_text');
    final primary = _bool(data, 'is_primary');
    final lemma = entity['wordLemma']?.toString();

    return _SectionCard(
      title: AppLocalizations.of(context).reviewPreviewProposedImage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (lemma != null && lemma.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                AppLocalizations.of(context).reviewPreviewForWord(lemma),
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          if (url == null)
            Text(
              AppLocalizations.of(context).reviewPreviewImageUrlMissing,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            )
          else
            GestureDetector(
              onTap: () => showImagePreview(context, urls: [url]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: CachedNetworkImageWithFallback(
                    imageUrl: displayImageUrl(url, width: 900) ?? url,
                    fallbackUrl: url,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          if (url != null) ...[
            const Gap(8),
            Text(
              AppLocalizations.of(context).reviewPreviewTapToEnlarge,
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const Gap(10),
          if (alt != null) _MetaRow(label: AppLocalizations.of(context).reviewPreviewAltText, value: alt),
          if (primary != null)
            _MetaRow(label: AppLocalizations.of(context).commonPrimary, value: primary ? AppLocalizations.of(context).commonYes : AppLocalizations.of(context).commonNo),
        ],
      ),
    );
  }
}

class _AudioPreview extends StatelessWidget {
  const _AudioPreview({required this.entity, required this.label});

  final Map<String, dynamic> entity;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final data = _childData(entity);
    final url = _str(data, 'url') ?? _str(data, 'audio_url');
    final speaker = _str(data, 'speaker_name');
    final duration = _formatDurationMs(_int(data, 'duration_ms'), AppLocalizations.of(context));
    final size = _formatFileSize(_int(data, 'file_size'), AppLocalizations.of(context));
    final mime = _str(data, 'mime_type');
    final primary = _bool(data, 'is_primary');
    final lemma = entity['wordLemma']?.toString();

    return _SectionCard(
      title: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (lemma != null && lemma.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                AppLocalizations.of(context).reviewPreviewForWord(lemma),
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          if (url == null)
            Text(
              AppLocalizations.of(context).reviewPreviewAudioFileMissing,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            )
          else
            _InlineAudioPlayer(url: url, speaker: speaker),
          const Gap(10),
          if (speaker != null) _MetaRow(label: AppLocalizations.of(context).reviewCorrectSpeaker, value: speaker),
          if (duration.isNotEmpty) _MetaRow(label: AppLocalizations.of(context).reviewPreviewDurasi, value: duration),
          if (size.isNotEmpty) _MetaRow(label: AppLocalizations.of(context).reviewPreviewUkuran, value: size),
          if (mime != null) _MetaRow(label: AppLocalizations.of(context).reviewPreviewTipe, value: mime),
          if (primary != null)
            _MetaRow(label: AppLocalizations.of(context).commonPrimary, value: primary ? AppLocalizations.of(context).commonYes : AppLocalizations.of(context).commonNo),
        ],
      ),
    );
  }
}

class _PronunciationPreview extends StatelessWidget {
  const _PronunciationPreview({required this.entity});

  final Map<String, dynamic> entity;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final data = _childData(entity);
    final value = _str(data, 'value');
    final notation = _str(data, 'notation');
    final speaker = _str(data, 'speaker_name');
    final notes = _str(data, 'notes');
    final audioUrl = _str(data, 'audio_url');
    final lemma = entity['wordLemma']?.toString();

    return _SectionCard(
      title: AppLocalizations.of(context).reviewPreviewProposedPronunciation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (lemma != null && lemma.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                AppLocalizations.of(context).reviewPreviewForWord(lemma),
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          if (value != null)
            Text(
              value,
              style: theme.typography.body.xl.copyWith(
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          if (notation != null) ...[
            const Gap(4),
            Text(
              AppLocalizations.of(context).reviewPreviewNotation(notation),
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
          if (speaker != null) ...[
            const Gap(8),
            _MetaRow(label: AppLocalizations.of(context).reviewCorrectSpeaker, value: speaker),
          ],
          if (notes != null) _MetaRow(label: AppLocalizations.of(context).historyFieldNotes, value: notes),
          if (audioUrl != null) ...[
            const Gap(8),
            _InlineAudioPlayer(url: audioUrl, speaker: speaker),
          ],
        ],
      ),
    );
  }
}

/// Baris "Untuk kata X" - dipakai semua preview entity anak.
class _LemmaHeader extends StatelessWidget {
  const _LemmaHeader(this.lemma);

  final String? lemma;

  @override
  Widget build(BuildContext context) {
    final text = lemma?.trim();
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        AppLocalizations.of(context).reviewPreviewForWord(text),
        style: context.theme.typography.body.sm.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      ),
    );
  }
}

/// Preview makna: definisi, kelas kata (nama), sumber makna, dan daftar
/// terjemahan. Id bahasa/kelas kata selalu diganti label; kalau tidak ketemu,
/// baris disembunyikan - ULID mentah tidak boleh sampai ke user.
class _MeaningPreview extends ConsumerWidget {
  const _MeaningPreview({required this.entity});

  final Map<String, dynamic> entity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final data = _childData(entity) ?? const <String, dynamic>{};
    final classesAsync = ref.watch(referenceWordClassesProvider);
    final languagesAsync = ref.watch(referenceLanguagesProvider);
    final classes = classesAsync.value ?? const [];
    final languages = languagesAsync.value ?? const [];
    // "Belum ketemu" (sudah selesai load) beda dari "sedang dimuat" - yang
    // kedua ini shimmering, bukan disembunyikan supaya tinggi tidak bergeser.
    final classLoading = classesAsync.isLoading && _str(data, 'word_class_id') != null;
    final languagesLoading = languagesAsync.isLoading;

    final rawDefinition = _str(data, 'definition');
    final isHaveDefinition = _bool(data, 'is_have_definition');
    // is_have_definition=false artinya definisi memang sengaja dikosongkan.
    final definitionMissing =
        isHaveDefinition == false ||
        rawDefinition == null ||
        rawDefinition == '-' ||
        rawDefinition.isEmpty;

    final className = wordClassNameFrom(classes, _str(data, 'word_class_id'));
    final sourceLabel = meaningSourceReviewLabel(_str(data, 'meaning_source'));

    final translations = <_TranslationRow>[];
    final rawTranslations = data['translations'];
    if (rawTranslations is List) {
      for (final raw in rawTranslations.whereType<Map>()) {
        final text = _str(_asMap(raw), 'translation_text');
        if (text == null) continue;
        final languageId = _str(_asMap(raw), 'language_id');
        translations.add(
          _TranslationRow(
            language: languageId == null
                ? null
                : languageNameFrom(languages, languageId),
            languageLoading: languageId != null && languagesLoading,
            text: text,
          ),
        );
      }
    }
    final isHaveTranslation = _bool(data, 'is_have_translation');
    final notes = _str(data, 'notes');

    return _SectionCard(
      title: AppLocalizations.of(context).reviewPreviewProposedMeaning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LemmaHeader(entity['wordLemma']?.toString()),
          _MetaRow(
            label: AppLocalizations.of(context).suggestDefinitionLabel,
            value: definitionMissing
              ? _emptyValueLabel(AppLocalizations.of(context))
              : rawDefinition,
            muted: definitionMissing,
          ),
          if (className != null)
            _MetaRow(label: AppLocalizations.of(context).suggestWordClassLabelShort, value: className)
          else if (classLoading)
            _MetaRow(label: AppLocalizations.of(context).suggestWordClassLabelShort, value: '', loading: true),
          _MetaRow(label: AppLocalizations.of(context).reviewPreviewSourceOfMeaning, value: sourceLabel, emphasize: true),
          const Gap(4),
          Text(
            AppLocalizations.of(context).reviewPreviewTranslationSection,
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(6),
          if (translations.isEmpty)
            _MeaningTranslationsEmpty(isHaveTranslation: isHaveTranslation)
          else
            for (final t in translations)
              _TranslationRowView(row: t, theme: theme),
          if (notes != null) ...[
            const Gap(4),
            _MetaRow(label: AppLocalizations.of(context).historyFieldNotes, value: notes),
          ],
        ],
      ),
    );
  }
}

Map<String, dynamic> _asMap(Map<dynamic, dynamic> raw) =>
    Map<String, dynamic>.from(raw);

class _TranslationRow {
  const _TranslationRow({
    required this.language,
    required this.text,
    this.languageLoading = false,
  });

  final String? language;
  final String text;
  final bool languageLoading;
}

class _TranslationRowView extends StatelessWidget {
  const _TranslationRowView({required this.row, required this.theme});

  final _TranslationRow row;
  final FThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (row.language != null || row.languageLoading)
            _Skeletonized(
              loading: row.languageLoading,
              child: Text(
                row.language ?? '',
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Text(row.text, style: theme.typography.body.sm),
        ],
      ),
    );
  }
}

/// Bedakan "tidak ada terjemahan" (wajar) dari "ditandai ada tapi kosong"
/// (inkonsistensi data yang perlu dilihat verifier).
class _MeaningTranslationsEmpty extends StatelessWidget {
  const _MeaningTranslationsEmpty({required this.isHaveTranslation});

  final bool? isHaveTranslation;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final (text, isWarning) = switch (isHaveTranslation) {
      false => (AppLocalizations.of(context).reviewPreviewTranslationEmptyDeliberate, false),
      true => (AppLocalizations.of(context).reviewPreviewTranslationMarkedEmpty, true),
      null => (AppLocalizations.of(context).reviewPreviewTranslationNone, false),
    };
    return Text(
      text,
      style: theme.typography.body.sm.copyWith(
        color: isWarning ? theme.colors.error : theme.colors.mutedForeground,
        fontWeight: isWarning ? FontWeight.w600 : null,
      ),
    );
  }
}

/// Preview contoh kalimat. Kunci payload API adalah `source_sentence` /
/// `target_sentence` - bukan `sentence_sambas`, jadi label dipetakan eksplisit.
class _ExamplePreview extends ConsumerWidget {
  const _ExamplePreview({required this.entity});

  final Map<String, dynamic> entity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = _childData(entity) ?? const <String, dynamic>{};
    final languagesAsync = ref.watch(referenceLanguagesProvider);
    final languages = languagesAsync.value ?? const [];
    final languagesLoading = languagesAsync.isLoading;

    final source = _str(data, 'source_sentence');
    final target = _str(data, 'target_sentence');
    final sourceType = _str(data, 'source_type');
    final notes = _str(data, 'notes');
    final sourceLangId = _str(data, 'source_language_id');
    final targetLangId = _str(data, 'target_language_id');
    final sourceLang = sourceLangId == null
        ? null
        : languageNameFrom(languages, sourceLangId);
    final targetLang = targetLangId == null
        ? null
        : languageNameFrom(languages, targetLangId);

    return _SectionCard(
      title: AppLocalizations.of(context).reviewPreviewProposedExample,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LemmaHeader(entity['wordLemma']?.toString()),
          if (source == null)
            _MetaRow(label: AppLocalizations.of(context).reviewPreviewSambasSentence, value: _emptyValueLabel(AppLocalizations.of(context)), muted: true)
          else
            _SentenceBlock(
              label: AppLocalizations.of(context).reviewPreviewSambasSentence,
              language: sourceLang,
              languageLoading: sourceLangId != null && languagesLoading,
              text: source,
            ),
          const Gap(8),
          if (target == null)
            _MetaRow(
              label: AppLocalizations.of(context).reviewPreviewTranslationSentence,
              value: _emptyValueLabel(AppLocalizations.of(context)),
              muted: true,
            )
          else
            _SentenceBlock(
              label: AppLocalizations.of(context).reviewPreviewTranslationSentence,
              language: targetLang,
              languageLoading: targetLangId != null && languagesLoading,
              text: target,
            ),
          if (sourceType != null) ...[
            const Gap(8),
            _MetaRow(label: AppLocalizations.of(context).reviewPreviewSourceType, value: sourceType),
          ],
          if (notes != null) ...[
            const Gap(4),
            _MetaRow(label: AppLocalizations.of(context).historyFieldNotes, value: notes),
          ],
        ],
      ),
    );
  }
}

/// Satu blok kalimat: label peran (sambas/terjemahan) selalu tampil supaya
/// reviewer tahu mana yang mana, nama bahasa jadi info tambahan.
class _SentenceBlock extends StatelessWidget {
  const _SentenceBlock({
    required this.label,
    required this.language,
    required this.text,
    this.languageLoading = false,
  });

  final String label;
  final String? language;
  final String text;
  final bool languageLoading;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typography.body.xs.copyWith(
            color: theme.colors.mutedForeground,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (language != null || languageLoading)
          _Skeletonized(
            loading: languageLoading,
            child: Text(
              language ?? '',
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
        const Gap(2),
        Text(text, style: theme.typography.body.sm),
      ],
    );
  }
}

/// Fallback untuk entity tanpa preview khusus (dan untuk tipe baru dari server).
///
/// Prinsipnya ketat agar bug lama tidak kembali diam-diam:
/// - id referensi, flag boolean, dan nilai null/kosong tidak pernah dirender;
/// - `List`/`Map` dirender per baris, bukan lewat `toString()`;
/// - kunci tanpa label Mapping dilewati, bukan ditampilkan mentah.
class _FieldPreview extends StatelessWidget {
  const _FieldPreview({required this.entity});

  final Map<String, dynamic> entity;

  static Map<String, String> _labels(AppLocalizations l10n) => {
    'definition': l10n.suggestDefinitionLabel,
    'value': l10n.reviewPreviewFieldValue,
    'notation': l10n.reviewCorrectNotation,
    'audio_url': l10n.reviewCorrectAudioUrl,
    'speaker_name': l10n.reviewCorrectSpeaker,
    'notes': l10n.historyFieldNotes,
    'url': l10n.reviewPreviewFieldUrl,
    'alt_text': l10n.reviewCorrectAltText,
    'source_sentence': l10n.reviewPreviewSambasSentence,
    'target_sentence': l10n.reviewPreviewTranslationSentence,
    'source_type': l10n.reviewPreviewSourceType,
    'duration_ms': l10n.reviewPreviewDurasi,
    'file_size': l10n.reviewPreviewUkuran,
    'mime_type': l10n.reviewPreviewTipe,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final labels = _labels(AppLocalizations.of(context));
    final data = _childData(entity);
    final rows = <Widget>[];

    for (final e in data?.entries ?? const <MapEntry<String, dynamic>>[]) {
      final key = e.key.toString();
      if (e.value == null) continue;
      if (_isReferenceIdKey(key) || _isFlagKey(key)) continue;
      if (key == 'meaning_source') {
        rows.add(
          _MetaRow(
            label: AppLocalizations.of(context).reviewPreviewSourceOfMeaning,
            value: meaningSourceReviewLabel(e.value.toString()),
            emphasize: true,
          ),
        );
        continue;
      }
      if (e.value is List || e.value is Map) {
        // Nilaimajemuk: satu baris per elemen, tidak pernah via toString().
        for (final line in _flattenComplex(e.value)) {
          rows.add(_MetaRow(label: labels[key] ?? AppLocalizations.of(context).reviewPreviewDetailLabel, value: line));
        }
        continue;
      }
      final text = e.value.toString().trim();
      if (text.isEmpty) continue;
      final label = labels[key];
      if (label == null) continue; // kunci tak dikenal: lewati, jangan raw
      rows.add(_MetaRow(label: label, value: text));
    }

    return _SectionCard(
      title: AppLocalizations.of(context).reviewPreviewProposalContent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LemmaHeader(entity['wordLemma']?.toString()),
          if (rows.isEmpty)
            Text(
              AppLocalizations.of(context).commonNoDetail,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            )
          else
            ...rows,
        ],
      ),
    );
  }
}

/// Rflatten nilai List/Map menjadi baris-baris teks yang bisa dibaca.
List<String> _flattenComplex(Object? value) {
  final out = <String>[];
  void walk(Object? node) {
    if (node is Map) {
      final scalars = node.values
          .map((v) => v is Map || v is List ? null : v?.toString().trim())
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toList();
      if (scalars.isNotEmpty) {
        out.add(scalars.join(' - '));
        return;
      }
      node.values.forEach(walk);
      return;
    }
    if (node is List) {
      node.forEach(walk);
      return;
    }
    final text = node?.toString().trim();
    if (text != null && text.isNotEmpty) out.add(text);
  }

  walk(value);
  return out;
}

/// Player audio ringkas khusus layar review (satu URL, tanpa Riverpod wordId).
class _InlineAudioPlayer extends StatefulWidget {
  const _InlineAudioPlayer({required this.url, this.speaker});

  final String url;
  final String? speaker;

  @override
  State<_InlineAudioPlayer> createState() => _InlineAudioPlayerState();
}

class _InlineAudioPlayerState extends State<_InlineAudioPlayer> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _sub;
  var _loading = false;
  var _playing = false;
  var _error = false;

  @override
  void initState() {
    super.initState();
    _sub = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _playing = state.playing;
        if (state.processingState == ProcessingState.completed) {
          _playing = false;
          unawaited(_player.seek(Duration.zero));
          unawaited(_player.pause());
        }
      });
    });
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel() ?? Future<void>.value());
    unawaited(() async {
      try {
        await _player.stop();
      } catch (_) {}
      try {
        await _player.dispose();
      } catch (_) {}
    }());
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_loading) return;
    final reload = _error || _player.audioSource == null;
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        // Muat ulang setelah error / sumber belum siap.
        if (reload) {
          await _player.stop();
          await _player.setUrl(widget.url);
        }
        await _player.play();
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
      try {
        await _player.stop();
      } catch (_) {}
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final label = widget.speaker?.trim().isNotEmpty == true
        ? widget.speaker!.trim()
        : AppLocalizations.of(context).reviewPreviewPlayRecording;

    return Material(
      color: theme.colors.background.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _toggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _loading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colors.primary,
                            ),
                          )
                        : Icon(
                            _error
                                ? FLucideIcons.circleAlert
                                : (_playing ? FLucideIcons.pause : FLucideIcons.play),
                            size: 18,
                            color: _error ? theme.colors.error : theme.colors.primary,
                          ),
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _error ? AppLocalizations.of(context).reviewPreviewPlayFailed : label,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _playing ? AppLocalizations.of(context).reviewPreviewPlaying : AppLocalizations.of(context).reviewPreviewTapToListen,
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
