import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../contribution/domain/meaning_source.dart';
import '../../domain/entities/review_contribution.dart';

/// Preview baca-saja isi usulan - per jenis entity, bukan dump key:value.
class ReviewEntityPreview extends StatelessWidget {
  const ReviewEntityPreview({super.key, required this.detail});

  final ReviewDetail detail;

  @override
  Widget build(BuildContext context) {
    final type = detail.contribution.entityType;
    return switch (type) {
      'word' => _WordPreview(entity: detail.entity),
      'word_image' => _ImagePreview(entity: detail.entity),
      'word_audio' => _AudioPreview(entity: detail.entity, label: 'Audio usulan'),
      'pronunciation' => _PronunciationPreview(entity: detail.entity),
      'example' => _FieldPreview(
          entity: detail.entity,
          labels: _exampleLabels,
        ),
      'meaning' => _FieldPreview(
          entity: detail.entity,
          labels: _meaningLabels,
        ),
      _ => _FieldPreview(entity: detail.entity, labels: const {}),
    };
  }
}

const _exampleLabels = {
  'sentence_sambas': 'Kalimat Sambas',
  'sentence_translation': 'Terjemahan',
  'source': 'Sumber',
  'notes': 'Catatan',
};

const _meaningLabels = {
  'definition': 'Definisi',
  'word_class_id': 'Kelas kata',
  'meaning_source': 'Sumber makna',
  'notes': 'Catatan',
};

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

String _formatDurationMs(int? ms) {
  if (ms == null || ms <= 0) return '';
  final sec = (ms / 1000).round();
  if (sec < 60) return '$sec dtk';
  final min = sec ~/ 60;
  final rem = sec % 60;
  return rem == 0 ? '$min m' : '$min m $rem dtk';
}

String _formatFileSize(int? bytes) {
  if (bytes == null || bytes <= 0) return '';
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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
              style: theme.typography.sm.copyWith(
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
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

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
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.typography.sm.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _WordPreview extends StatelessWidget {
  const _WordPreview({required this.entity});

  final Map<String, dynamic> entity;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final lemma = entity['lemma']?.toString() ?? '-';
    final wordType = entity['wordType']?.toString();
    final notes = entity['notes']?.toString().trim();
    final meanings = entity['meanings'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: 'Kata yang diusulkan',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lemma,
                style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
              ),
              if (wordType != null && wordType.isNotEmpty) ...[
                const Gap(4),
                Text(
                  wordType,
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
              if (notes != null && notes.isNotEmpty) ...[
                const Gap(8),
                Text(notes, style: theme.typography.sm),
              ],
            ],
          ),
        ),
        const Gap(12),
        _SectionCard(
          title: 'Makna',
          child: meanings is! List || meanings.isEmpty
              ? Text(
                  'Tidak ada makna.',
                  style: theme.typography.sm.copyWith(
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
      ],
    );
  }
}

class _MeaningBlock extends StatelessWidget {
  const _MeaningBlock({required this.raw});

  final Map<dynamic, dynamic> raw;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final definition = raw['definition']?.toString() ?? '-';
    final translations = raw['translations'];
    String? padanan;
    if (translations is List && translations.isNotEmpty) {
      final first = translations.first;
      if (first is Map) {
        padanan = first['translationText']?.toString();
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(definition, style: theme.typography.sm),
        if (padanan != null && padanan.trim().isNotEmpty) ...[
          const Gap(4),
          Text(
            'Padanan: $padanan',
            style: theme.typography.sm.copyWith(
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
          style: theme.typography.sm.copyWith(
            color: theme.colors.mutedForeground,
            fontWeight: FontWeight.w600,
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
      title: 'Gambar yang diusulkan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (lemma != null && lemma.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Untuk kata “$lemma”',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          if (url == null)
            Text(
              'URL gambar tidak tersedia.',
              style: theme.typography.sm.copyWith(
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
              'Ketuk untuk perbesar',
              style: theme.typography.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const Gap(10),
          if (alt != null) _MetaRow(label: 'Alt text', value: alt),
          if (primary != null)
            _MetaRow(label: 'Utama', value: primary ? 'Ya' : 'Tidak'),
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
    final duration = _formatDurationMs(_int(data, 'duration_ms'));
    final size = _formatFileSize(_int(data, 'file_size'));
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
                'Untuk kata “$lemma”',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          if (url == null)
            Text(
              'File audio tidak tersedia.',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            )
          else
            _InlineAudioPlayer(url: url, speaker: speaker),
          const Gap(10),
          if (speaker != null) _MetaRow(label: 'Penutur', value: speaker),
          if (duration.isNotEmpty) _MetaRow(label: 'Durasi', value: duration),
          if (size.isNotEmpty) _MetaRow(label: 'Ukuran', value: size),
          if (mime != null) _MetaRow(label: 'Tipe', value: mime),
          if (primary != null)
            _MetaRow(label: 'Utama', value: primary ? 'Ya' : 'Tidak'),
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
      title: 'Pelafalan yang diusulkan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (lemma != null && lemma.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Untuk kata “$lemma”',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          if (value != null)
            Text(
              value,
              style: theme.typography.xl.copyWith(
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          if (notation != null) ...[
            const Gap(4),
            Text(
              'Notasi: $notation',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
          if (speaker != null) ...[
            const Gap(8),
            _MetaRow(label: 'Penutur', value: speaker),
          ],
          if (notes != null) _MetaRow(label: 'Catatan', value: notes),
          if (audioUrl != null) ...[
            const Gap(8),
            _InlineAudioPlayer(url: audioUrl, speaker: speaker),
          ],
        ],
      ),
    );
  }
}

class _FieldPreview extends StatelessWidget {
  const _FieldPreview({required this.entity, required this.labels});

  final Map<String, dynamic> entity;
  final Map<String, String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final data = _childData(entity);
    final lemma = entity['wordLemma']?.toString();
    final entries = <MapEntry<String, String>>[];
    if (data != null) {
      for (final e in data.entries) {
        final key = e.key.toString();
        if (e.value == null) continue;
        final text = e.value.toString().trim();
        if (text.isEmpty) continue;
        if (key == 'is_primary') {
          entries.add(MapEntry(labels[key] ?? 'Utama', e.value == true ? 'Ya' : 'Tidak'));
          continue;
        }
        if (key == 'meaning_source') {
          entries.add(
            MapEntry(labels[key] ?? key, meaningSourceReviewLabel(text)),
          );
          continue;
        }
        entries.add(MapEntry(labels[key] ?? key, text));
      }
    }

    return _SectionCard(
      title: 'Isi usulan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (lemma != null && lemma.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Untuk kata “$lemma”',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          if (entries.isEmpty)
            Text(
              'Tidak ada detail.',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            )
          else
            for (final e in entries) _MetaRow(label: e.key, value: e.value),
        ],
      ),
    );
  }
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
        : 'Putar rekaman';

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
                      _error ? 'Gagal memutar - ketuk lagi' : label,
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _playing ? 'Sedang diputar' : 'Ketuk untuk mendengar',
                      style: theme.typography.xs.copyWith(
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
