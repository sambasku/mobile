import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gal/gal.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../shared/utils/file_persist_helper.dart';
import '../../../../shared/utils/permission_helper.dart';
import '../../dictionary/domain/entities/word_detail.dart';
import '../data/share_background_repository.dart';
import '../domain/share_models.dart';
import 'share_card_renderer.dart';
import 'share_fullscreen.dart';
import 'share_image_explorer_sheet.dart';
import 'share_solid_color_sheet.dart';
import 'widgets/share_card_canvas.dart';
import 'widgets/share_skeleton.dart';

/// Buka sheet share kartu dari detail kata.
Future<void> showWordShareSheet(
  BuildContext context, {
  required WordDetail detail,
  required ShareBackgroundRepository backgrounds,
}) {
  AnalyticsService.instance.log(
    AnalyticsEvents.shareStart,
    params: {'word_id': detail.id},
  );
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    clipBehavior: Clip.none,
    builder: (sheetContext) {
      return _WordShareSheetBody(detail: detail, backgrounds: backgrounds);
    },
  );
}

String buildShareQuery(WordDetail detail, WordMeaning meaning) {
  final padanan = pickPadanan(meaning) ?? '';
  final category = detail.categories.isNotEmpty
      ? detail.categories.first.name
      : '';
  final parts = [padanan, category]
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'indonesia culture';
  return parts.join(' ');
}

String? pickPadanan(WordMeaning meaning) {
  final direct = meaning.translations.where((t) => t.type == 'direct');
  if (direct.isNotEmpty) return direct.first.text;
  if (meaning.translations.isNotEmpty) return meaning.translations.first.text;
  return null;
}

ShareSenseLine senseLineFromMeaning(WordMeaning meaning) {
  final definition = meaning.definition?.trim();
  return ShareSenseLine(
    wordClassCode: meaning.wordClassCode,
    padanan: pickPadanan(meaning),
    definition: (definition == null || definition.isEmpty || definition == '-')
        ? null
        : definition,
  );
}

/// Maks. 3 makna untuk kartu; urut `orderIndex` naik.
List<ShareSenseLine> senseLinesForCard(
  List<WordMeaning> meanings, {
  required bool allMeanings,
  required WordMeaning selected,
  int max = 3,
}) {
  if (!allMeanings || meanings.length <= 1) {
    return [senseLineFromMeaning(selected)];
  }
  final sorted = [...meanings]
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  return sorted.take(max).map(senseLineFromMeaning).toList(growable: false);
}

ShareCardData buildCardData({
  required WordDetail detail,
  required WordMeaning meaning,
  required ShareEditorSettings settings,
  String? photographer,
  String? provider,
  bool isVideo = false,
}) {
  final senses = senseLinesForCard(
    detail.meanings,
    allMeanings: settings.showAllMeanings,
    selected: meaning,
  );
  return ShareCardData(
    lemma: detail.lemma,
    wordClassName: meaning.wordClassName,
    wordClassCode: meaning.wordClassCode,
    definition: meaning.definition,
    padanan: pickPadanan(meaning),
    senses: senses,
    exampleSentence: settings.showExample && meaning.examples.isNotEmpty
        ? meaning.examples.first.sourceSentence
        : null,
    photographer: photographer,
    provider: provider,
    isVideo: isVideo,
    variantsLine: spellingVariantsLine(detail),
    isVerified: detail.isVerified,
  );
}

String? spellingVariantsLine(WordDetail detail) {
  final seen = <String>{detail.lemma.trim().toLowerCase()};
  final parts = <String>[];
  for (final v in detail.variants) {
    final form = v.form.trim();
    if (form.isEmpty) continue;
    if (!seen.add(form.toLowerCase())) continue;
    parts.add(form);
  }
  if (parts.isEmpty) return null;
  return parts.join(' / ');
}

class _WordShareSheetBody extends StatefulWidget {
  const _WordShareSheetBody({
    required this.detail,
    required this.backgrounds,
  });

  final WordDetail detail;
  final ShareBackgroundRepository backgrounds;

  @override
  State<_WordShareSheetBody> createState() => _WordShareSheetBodyState();
}

class _WordShareSheetBodyState extends State<_WordShareSheetBody> {
  final GlobalKey _repaintKey = GlobalKey();
  final GlobalKey _overlayKey = GlobalKey();
  final GlobalKey _pngFallbackKey = GlobalKey();

  late int _meaningIndex;
  ShareTemplateId _template = ShareTemplateId.unsplash;
  ShareRatioId _ratio = ShareRatioId.story;
  ShareEditorSettings _settings = const ShareEditorSettings();
  ShareBgSource _bgSource = ShareBgSource.stock;

  bool _loadingBg = true;
  bool _sharing = false;
  bool _saving = false;
  bool _degraded = false;
  List<ShareBackground> _bgItems = const [];
  int? _selectedBgIndex;
  File? _localImageFile;
  File? _localVideoFile;
  String? _wordImageUrl;

  WordMeaning get _meaning {
    final meanings = widget.detail.meanings;
    if (meanings.isEmpty) {
      return const WordMeaning(id: '', orderIndex: 0);
    }
    final i = _meaningIndex.clamp(0, meanings.length - 1);
    return meanings[i];
  }

  List<WordImage> get _wordImages {
    // Exclude: gambar pending (tidak ada URL asli) dan gambar kekerasan
    // (tidak auto-pilih sebagai latar kartu berbagi).
    final images = [
      for (final img in widget.detail.images)
        if (!img.isPendingReview && !img.hasViolenceWarning) img,
    ];
    images.sort((a, b) {
      if (a.isPrimary == b.isPrimary) return 0;
      return a.isPrimary ? -1 : 1;
    });
    return images;
  }

  ImageProvider? get _imageProvider {
    if (_template.forcesNoPhoto || _bgSource == ShareBgSource.none) {
      return null;
    }
    switch (_bgSource) {
      case ShareBgSource.device:
        final f = _localImageFile;
        return f != null ? FileImage(f) : null;
      case ShareBgSource.wordImage:
        final u = _wordImageUrl;
        return u != null && u.isNotEmpty
            ? CachedNetworkImageProvider(u)
            : null;
      case ShareBgSource.stock:
        final item = _selectedStock;
        if (item == null) return null;
        return CachedNetworkImageProvider(item.thumbUrl);
      case ShareBgSource.none:
        return null;
    }
  }

  ShareBackground? get _selectedStock {
    final i = _selectedBgIndex;
    if (i == null || i < 0 || i >= _bgItems.length) return null;
    return _bgItems[i];
  }

  bool get _isVideoBackground {
    if (_template.forcesNoPhoto || _bgSource == ShareBgSource.none) {
      return false;
    }
    if (_bgSource == ShareBgSource.device) return _localVideoFile != null;
    return _selectedStock?.isVideo == true;
  }

  String? get _videoUrl {
    if (!_isVideoBackground) return null;
    if (_bgSource == ShareBgSource.device) return _localVideoFile?.path;
    return _selectedStock?.url;
  }

  bool get _videoIsFile =>
      _bgSource == ShareBgSource.device && _localVideoFile != null;

  String? get _photographer {
    if (_bgSource != ShareBgSource.stock) return null;
    final i = _selectedBgIndex;
    if (i == null || i < 0 || i >= _bgItems.length) return null;
    final name = _bgItems[i].photographer;
    return name.isEmpty ? null : name;
  }

  String? get _stockProvider {
    if (_photographer == null) return null;
    return _selectedStock?.provider;
  }

  ShareCardData get _cardData => buildCardData(
    detail: widget.detail,
    meaning: _meaning,
    settings: _settings,
    photographer: _photographer,
    provider: _stockProvider,
    isVideo: _isVideoBackground && _bgSource == ShareBgSource.stock,
  );

  @override
  void initState() {
    super.initState();
    final meanings = widget.detail.meanings;
    if (meanings.isEmpty) {
      _meaningIndex = 0;
    } else {
      var best = 0;
      for (var i = 1; i < meanings.length; i++) {
        if (meanings[i].orderIndex < meanings[best].orderIndex) best = i;
      }
      _meaningIndex = best;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBackgrounds(1));
  }

  Future<void> _loadBackgrounds(int page) async {
    setState(() => _loadingBg = true);
    final q = buildShareQuery(widget.detail, _meaning);
    final orientation = _ratio.stockOrientation;
    final results = await Future.wait([
      widget.backgrounds.listBackgrounds(
        q,
        page: page,
        sort: 'relevant',
        provider: 'pixabay',
        media: 'photo',
        orientation: orientation,
        limit: 3,
      ),
      widget.backgrounds.listBackgrounds(
        q,
        page: page,
        sort: 'relevant',
        provider: 'pixabay',
        media: 'video',
        orientation: orientation,
        limit: 3,
      ),
    ]);
    if (!mounted) return;

    final items = [
      for (final r in results) ...r.items,
    ];
    final degraded = results.every((r) => r.degraded || r.items.isEmpty) &&
        items.isEmpty;

    setState(() {
      _loadingBg = false;
      _degraded = degraded;
      if (items.isEmpty) {
        _bgItems = const [];
        _selectedBgIndex = null;
        if (_bgSource == ShareBgSource.stock) {
          _bgSource = ShareBgSource.none;
        }
      } else {
        _bgItems = items;
        _selectedBgIndex = 0;
        if (!_template.forcesNoPhoto && _bgSource == ShareBgSource.none) {
          _bgSource = ShareBgSource.stock;
        }
      }
    });

    if (degraded && mounted) {
      showFToast(
        context: context,
        title: const Text(
          'Latar stok tidak tersedia. Pakai tanpa latar, galeri, kamera, atau gambar kata.',
        ),
      );
    }
  }

  Future<void> _pickSolidColor() async {
    final picked = await showShareSolidColorSheet(
      context,
      initial: _settings.solidColor,
    );
    if (!mounted || picked == null) return;
    setState(() {
      _settings = _settings.copyWith(
        backdropKind: ShareBackdropKind.solid,
        solidColor: picked,
      );
    });
  }

  Future<void> _openImageExplorer() async {
    if (_template.forcesNoPhoto) return;
    final selected = await showShareMediaExplorer(
      context,
      backgrounds: widget.backgrounds,
      initialVideo: _isVideoBackground,
    );
    if (!mounted || selected == null) return;
    setState(() {
      final existing = _bgItems.indexWhere((e) => e.url == selected.url);
      if (existing >= 0) {
        _selectedBgIndex = existing;
      } else {
        _bgItems = [selected, ..._bgItems];
        _selectedBgIndex = 0;
      }
      _bgSource = ShareBgSource.stock;
      _localImageFile = null;
      _localVideoFile = null;
      _wordImageUrl = null;
    });
  }

  Future<void> _pickFromSource(ImageSource source) async {
    if (_template.forcesNoPhoto) return;
    final picker = ImagePicker();
    try {
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          if (mounted) showPermissionDeniedDialog(context);
          return;
        }
        final picked = await picker.pickImage(source: source);
        if (picked == null || !mounted) return;
        final persisted = await copyToUniqueTempPath(File(picked.path));
        if (!mounted) return;
        setState(() {
          _localImageFile = persisted;
          _localVideoFile = null;
          _bgSource = ShareBgSource.device;
          _wordImageUrl = null;
        });
        return;
      }

      final choice = await showModalBottomSheet<String>(
        context: context,
        builder: (ctx) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_outlined),
                  title: const Text('Foto'),
                  onTap: () => Navigator.pop(ctx, 'photo'),
                ),
                ListTile(
                  leading: const Icon(Icons.videocam_outlined),
                  title: const Text('Video'),
                  onTap: () => Navigator.pop(ctx, 'video'),
                ),
              ],
            ),
          );
        },
      );
      if (choice == null || !mounted) return;
      if (choice == 'video') {
        final picked = await picker.pickVideo(source: ImageSource.gallery);
        if (picked == null || !mounted) return;
        final persisted = await copyToUniqueTempPath(File(picked.path));
        if (!mounted) return;
        setState(() {
          _localVideoFile = persisted;
          _localImageFile = null;
          _bgSource = ShareBgSource.device;
          _wordImageUrl = null;
        });
        return;
      }
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null || !mounted) return;
      final persisted = await copyToUniqueTempPath(File(picked.path));
      if (!mounted) return;
      setState(() {
        _localImageFile = persisted;
        _localVideoFile = null;
        _bgSource = ShareBgSource.device;
        _wordImageUrl = null;
      });
    } catch (e, st) {
      debugPrint('[SharePick] $e\n$st');
      if (!mounted) return;
      showFToast(
        context: context,
        title: Text(
          source == ImageSource.camera
              ? 'Gagal membuka kamera'
              : 'Gagal memilih dari galeri',
        ),
        variant: FToastVariant.destructive,
      );
    }
  }

  Future<void> _onShare() async {
    if (_sharing || _saving) return;
    setState(() => _sharing = true);
    try {
      final provider = _imageProvider;
      if (provider != null) {
        await precacheImage(provider, context);
      }
      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : const Rect.fromLTWH(0, 0, 1, 1);
      if (_isVideoBackground && _videoUrl != null) {
        try {
          await shareCardAsVideo(
            overlayKey: _overlayKey,
            videoUrl: _videoUrl!,
            videoIsFile: _videoIsFile,
            caption: _cardData.caption,
            sharePositionOrigin: origin,
          );
        } catch (e) {
          debugPrint('[ShareVideo] $e');
          if (mounted) {
            showFToast(
              context: context,
              title: const Text(
                'Video tidak bisa diekspor. Dibagikan sebagai foto.',
              ),
            );
          }
          await shareCardAsPng(
            repaintKey: _pngFallbackKey,
            caption: _cardData.caption,
            sharePositionOrigin: origin,
          );
        }
      } else {
        await shareCardAsPng(
          repaintKey: _repaintKey,
          caption: _cardData.caption,
          sharePositionOrigin: origin,
        );
      }
      AnalyticsService.instance.log(
        AnalyticsEvents.shareComplete,
        params: {'word_id': widget.detail.id},
      );
    } catch (e) {
      if (!mounted) return;
      showFToast(
        context: context,
        title: Text('Gagal membagikan: $e'),
        variant: FToastVariant.destructive,
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _onSave() async {
    if (_saving || _sharing) return;
    setState(() => _saving = true);
    try {
      final provider = _imageProvider;
      if (provider != null) {
        await precacheImage(provider, context);
      }
      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;

      var saved = false;
      if (_isVideoBackground && _videoUrl != null) {
        try {
          saved = await saveCardVideoToGallery(
            overlayKey: _overlayKey,
            videoUrl: _videoUrl!,
            videoIsFile: _videoIsFile,
          );
        } catch (e) {
          debugPrint('[ShareVideo] $e');
          if (mounted) {
            showFToast(
              context: context,
              title: const Text(
                'Video tidak bisa diekspor. Disimpan sebagai foto.',
              ),
            );
          }
          saved = await saveCardToGallery(repaintKey: _pngFallbackKey);
        }
      } else {
        saved = await saveCardToGallery(repaintKey: _repaintKey);
      }
      if (!mounted) return;
      if (!saved) {
        showPermissionDeniedDialog(context);
        return;
      }
      showFToast(
        context: context,
        title: const Text('Tersimpan di galeri'),
      );
    } on GalException catch (e) {
      if (!mounted) return;
      if (e.type == GalExceptionType.accessDenied) {
        showPermissionDeniedDialog(context);
        return;
      }
      showFToast(
        context: context,
        title: Text('Gagal menyimpan: ${e.type.message}'),
        variant: FToastVariant.destructive,
      );
    } catch (e) {
      if (!mounted) return;
      showFToast(
        context: context,
        title: Text('Gagal menyimpan: $e'),
        variant: FToastVariant.destructive,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openLayoutEditor() async {
    final updated = await showShareLayoutEditor(
      context,
      buildData: (settings) => buildCardData(
        detail: widget.detail,
        meaning: _meaning,
        settings: settings,
        photographer: _photographer,
        provider: _stockProvider,
        isVideo: _isVideoBackground && _bgSource == ShareBgSource.stock,
      ),
      template: _template,
      ratio: _ratio,
      settings: _settings,
      imageProvider: _imageProvider,
      videoUrl: _videoUrl,
      videoIsFile: _videoIsFile,
    );
    if (!mounted || updated == null) return;
    setState(() => _settings = updated);
  }

  void _openCardFullscreen() {
    showShareCardFullscreen(
      context,
      data: _cardData,
      template: _template,
      ratio: _ratio,
      settings: _settings,
      imageProvider: _imageProvider,
      videoUrl: _videoUrl,
      videoIsFile: _videoIsFile,
    );
  }

  void _openImageFullscreen(ImageProvider image) {
    showShareImageFullscreen(context, image: image);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final media = MediaQuery.of(context);
    final chipSelected = theme.colors.primary;
    final chipMuted = theme.colors.mutedForeground;

    Widget styleChip({
      required String label,
      required bool selected,
      required ValueChanged<bool> onSelected,
    }) {
      return GestureDetector(
        onTap: () => onSelected(true),
        child: FBadge(
          variant: selected
              ? FBadgeVariant.primary
              : FBadgeVariant.secondary,
          child: Text(label),
        ),
      );
    }

    Widget labeledChipRow({
      required String title,
      required List<Widget> chips,
    }) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 44,
            child: Text(
              title,
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < chips.length; i++) ...[
                    if (i > 0) const Gap(6),
                    chips[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    }

    // FSwitch.leadingLabel memakai Table + IntrinsicColumnWidth di kedua
    // kolom, jadi switch menempel di samping label. Row + Expanded
    // mendorong switch ke tepi kanan (pola settings Forui).
    Widget settingsSwitchRow({
      required String label,
      required bool value,
      required ValueChanged<bool> onChange,
      bool enabled = true,
    }) {
      return Row(
        children: [
          Expanded(child: Text(label, style: theme.typography.sm)),
          FSwitch(
            semanticsLabel: label,
            value: value,
            enabled: enabled,
            onChange: onChange,
          ),
        ],
      );
    }

    final canExplore = !_template.forcesNoPhoto;

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: media.size.height * 0.94,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Bagikan kartu',
                      style: theme.typography.lg.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: theme.colors.foreground,
                    ),
                  ),
                ],
              ),
            ),
            // Preview-first: ambil ruang utama
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: _ratio.width / _ratio.height,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _loadingBg
                                ? const ShareCardPreviewSkeleton()
                                : GestureDetector(
                                    onTap: _openCardFullscreen,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: RepaintBoundary(
                                        key: _repaintKey,
                                        child: ShareCardCanvas(
                                          data: _cardData,
                                          template: _template,
                                          ratio: _ratio,
                                          settings: _settings,
                                          imageProvider: _imageProvider,
                                          videoUrl: _videoUrl,
                                          videoIsFile: _videoIsFile,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    if (!_loadingBg) ...[
                      _OffscreenCaptureBox(
                        boundaryKey: _overlayKey,
                        ratio: _ratio,
                        child: ShareCardCanvas(
                          data: _cardData,
                          template: _template,
                          ratio: _ratio,
                          settings: _settings,
                          transparentBackdrop: true,
                        ),
                      ),
                      _OffscreenCaptureBox(
                        boundaryKey: _pngFallbackKey,
                        ratio: _ratio,
                        child: ShareCardCanvas(
                          data: _cardData,
                          template: _template,
                          ratio: _ratio,
                          settings: _settings,
                          imageProvider: _imageProvider,
                        ),
                      ),
                    ],
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      enabled: !_loadingBg,
                      leading: Icon(
                        Icons.open_with,
                        color: theme.colors.foreground,
                      ),
                      title: Text(
                        'Atur posisi',
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        _template.allowsMediaPan
                            ? 'Geser teks atau crop gambar / video'
                            : 'Buka fullscreen untuk geser / putar teks',
                        style: theme.typography.sm.copyWith(
                          color: chipMuted,
                          fontSize: 11,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: chipMuted,
                      ),
                      onTap: _loadingBg ? null : _openLayoutEditor,
                    ),
                  ],
                ),
              ),
            ),
            // Kontrol + editor (selalu terbuka)
            Expanded(
              flex: 6,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                children: [
                  Text(
                    'Latar',
                    style: theme.typography.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(8),
                  if (_loadingBg)
                    SizedBox(
                      height: 76,
                      child: ShareSkeleton(
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (var i = 0; i < 6; i++) ...[
                              Bone(
                                width: 72,
                                height: 72,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              if (i < 5) const Gap(8),
                            ],
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 76,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _SourceChip(
                            label: 'Tanpa\nlatar',
                            selected: _bgSource == ShareBgSource.none ||
                                _template.forcesNoPhoto,
                            selectedBorder: chipSelected,
                            gradient: _settings.backdropColors,
                            onTap: () => setState(() {
                              _bgSource = ShareBgSource.none;
                            }),
                          ),
                          const Gap(8),
                          _SourceChip(
                            label: 'Explorer',
                            selected: false,
                            selectedBorder: chipSelected,
                            icon: Icons.travel_explore,
                            onTap: canExplore ? _openImageExplorer : null,
                          ),
                          const Gap(8),
                          _SourceChip(
                            label: 'Galeri',
                            selected: _bgSource == ShareBgSource.device &&
                                (_localImageFile != null ||
                                    _localVideoFile != null),
                            selectedBorder: chipSelected,
                            icon: _localVideoFile != null
                                ? Icons.videocam_outlined
                                : Icons.photo_outlined,
                            onTap: _template.forcesNoPhoto
                                ? null
                                : () => _pickFromSource(ImageSource.gallery),
                            onLongPress: _localImageFile != null
                                ? () => _openImageFullscreen(
                                      FileImage(_localImageFile!),
                                    )
                                : null,
                            preview: _localImageFile != null
                                ? FileImage(_localImageFile!)
                                : null,
                          ),
                          const Gap(8),
                          _SourceChip(
                            label: 'Kamera',
                            selected: false,
                            selectedBorder: chipSelected,
                            icon: Icons.camera_alt_outlined,
                            onTap: _template.forcesNoPhoto
                                ? null
                                : () => _pickFromSource(ImageSource.camera),
                          ),
                          const Gap(8),
                          for (final img in _wordImages) ...[
                            _SourceChip(
                              label: 'Kata',
                              selected: _bgSource == ShareBgSource.wordImage &&
                                  _wordImageUrl == img.url,
                              selectedBorder: chipSelected,
                              preview: CachedNetworkImageProvider(img.url),
                              onTap: _template.forcesNoPhoto
                                  ? null
                                  : () => setState(() {
                                      _bgSource = ShareBgSource.wordImage;
                                      _wordImageUrl = img.url;
                                      _localImageFile = null;
                                      _localVideoFile = null;
                                    }),
                              onLongPress: () => _openImageFullscreen(
                                CachedNetworkImageProvider(img.url),
                              ),
                            ),
                            const Gap(8),
                          ],
                          for (var i = 0; i < _bgItems.length; i++) ...[
                            _SourceChip(
                              label: _bgItems[i].isVideo
                                  ? 'Video'
                                  : shareProviderLabel(_bgItems[i].provider),
                              selected: _bgSource == ShareBgSource.stock &&
                                  _selectedBgIndex == i &&
                                  !_template.forcesNoPhoto,
                              selectedBorder: chipSelected,
                              preview: CachedNetworkImageProvider(
                                _bgItems[i].thumbUrl,
                              ),
                              showPlay: _bgItems[i].isVideo,
                              onTap: _template.forcesNoPhoto
                                  ? null
                                  : () => setState(() {
                                      _bgSource = ShareBgSource.stock;
                                      _selectedBgIndex = i;
                                      _localImageFile = null;
                                      _localVideoFile = null;
                                      _wordImageUrl = null;
                                    }),
                              onLongPress: () => _openImageFullscreen(
                                CachedNetworkImageProvider(
                                  _bgItems[i].thumbUrl,
                                ),
                              ),
                            ),
                            const Gap(8),
                          ],
                        ],
                      ),
                    ),
                  if (_degraded && _bgItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Latar stok tidak tersedia. Pakai tanpa latar, galeri, kamera, atau gambar kata.',
                        style: theme.typography.sm.copyWith(color: chipMuted),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Tahan thumb untuk preview fullscreen · Explorer untuk cari gambar atau video',
                      style: theme.typography.sm.copyWith(
                        color: chipMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Gap(12),
                  labeledChipRow(
                    title: 'Gaya',
                    chips: ShareTemplateId.values.map((t) {
                      return styleChip(
                        label: t.label,
                        selected: _template == t,
                        onSelected: (_) {
                          setState(() {
                            _template = t;
                            if (t.forcesNoPhoto) {
                              _bgSource = ShareBgSource.none;
                            } else if (_bgSource == ShareBgSource.none &&
                                _bgItems.isNotEmpty) {
                              _bgSource = ShareBgSource.stock;
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const Gap(8),
                  labeledChipRow(
                    title: 'Rasio',
                    chips: ShareRatioId.values.map((r) {
                      return styleChip(
                        label: r.label,
                        selected: _ratio == r,
                        onSelected: (_) => setState(() => _ratio = r),
                      );
                    }).toList(),
                  ),
                  if (widget.detail.meanings.length > 1) ...[
                    const Gap(8),
                    labeledChipRow(
                      title: 'Makna',
                      chips: [
                        styleChip(
                          label: 'Semua',
                          selected: _settings.showAllMeanings,
                          onSelected: (_) {
                            setState(() {
                              _settings = _settings.copyWith(
                                showAllMeanings: true,
                              );
                            });
                          },
                        ),
                        for (var i = 0; i < widget.detail.meanings.length; i++)
                          styleChip(
                            label: widget.detail.meanings[i].wordClassBracket ??
                                widget.detail.meanings[i].wordClassName ??
                                'Makna ${i + 1}',
                            selected: !_settings.showAllMeanings &&
                                _meaningIndex == i,
                            onSelected: (_) {
                              setState(() {
                                _meaningIndex = i;
                                _settings = _settings.copyWith(
                                  showAllMeanings: false,
                                );
                              });
                              _loadBackgrounds(1);
                            },
                          ),
                      ],
                    ),
                  ],
                  const Gap(16),
                  Text(
                    'Editor',
                    style: theme.typography.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(8),
                  labeledChipRow(
                    title: 'Font',
                    chips: ShareFontPair.values.map((f) {
                      return styleChip(
                        label: f.label,
                        selected: _settings.fontPair == f,
                        onSelected: (_) => setState(() {
                          _settings = _settings.copyWith(fontPair: f);
                        }),
                      );
                    }).toList(),
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text(
                          'Warna',
                          style: theme.typography.sm.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final c in ShareTextColorId.values) ...[
                                GestureDetector(
                                  onTap: () => setState(() {
                                    _settings =
                                        _settings.copyWith(textColorId: c);
                                  }),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: c.lemma,
                                      border: Border.all(
                                        color: _settings.textColorId == c
                                            ? chipSelected
                                            : theme.colors.border,
                                        width: _settings.textColorId == c
                                            ? 2.5
                                            : 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text(
                          'Gradasi',
                          style: theme.typography.sm.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final g in ShareGradientId.values) ...[
                                GestureDetector(
                                  onTap: () => setState(() {
                                    _settings = _settings.copyWith(
                                      gradientId: g,
                                      backdropKind: ShareBackdropKind.gradient,
                                    );
                                  }),
                                  child: Container(
                                    width: 40,
                                    height: 32,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      gradient: LinearGradient(
                                        colors: g.colors,
                                      ),
                                      border: Border.all(
                                        color: _settings.backdropKind ==
                                                    ShareBackdropKind.gradient &&
                                                _settings.gradientId == g
                                            ? chipSelected
                                            : theme.colors.border,
                                        width: _settings.backdropKind ==
                                                    ShareBackdropKind.gradient &&
                                                _settings.gradientId == g
                                            ? 2.5
                                            : 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              GestureDetector(
                                onTap: _pickSolidColor,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _settings.solidColor,
                                    border: Border.all(
                                      color: _settings.backdropKind ==
                                              ShareBackdropKind.solid
                                          ? chipSelected
                                          : theme.colors.border,
                                      width: _settings.backdropKind ==
                                              ShareBackdropKind.solid
                                          ? 2.5
                                          : 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Text('Ukuran lemma', style: theme.typography.sm),
                  Slider(
                    value: _settings.lemmaFontScale.clamp(0.7, 1.8),
                    min: 0.7,
                    max: 1.8,
                    divisions: 5,
                    activeColor: chipSelected,
                    label: _settings.lemmaFontScale.toStringAsFixed(2),
                    onChanged: (v) => setState(() {
                      _settings = _settings.copyWith(lemmaFontScale: v);
                    }),
                  ),
                  Text('Ukuran teks deskripsi', style: theme.typography.sm),
                  Slider(
                    value: _settings.bodyFontScale.clamp(0.7, 1.6),
                    min: 0.7,
                    max: 1.6,
                    divisions: 5,
                    activeColor: chipSelected,
                    label: _settings.bodyFontScale.toStringAsFixed(2),
                    onChanged: (v) => setState(() {
                      _settings = _settings.copyWith(bodyFontScale: v);
                    }),
                  ),
                  if (_template.usesOverlay) ...[
                    Text('Ketebalan overlay', style: theme.typography.sm),
                    Slider(
                      value: _settings.overlayStrength,
                      min: 0,
                      max: 1,
                      divisions: 20,
                      activeColor: chipSelected,
                      label: _settings.overlayStrength.toStringAsFixed(2),
                      onChanged: (v) => setState(() {
                        _settings = _settings.copyWith(overlayStrength: v);
                      }),
                    ),
                  ],
                  settingsSwitchRow(
                    label: 'Tampilkan kelas kata',
                    value: _settings.showWordClass,
                    onChange: (v) => setState(() {
                      _settings = _settings.copyWith(showWordClass: v);
                    }),
                  ),
                  const Gap(8),
                  settingsSwitchRow(
                    label: 'Tampilkan terjemahan',
                    value: _settings.showPadanan,
                    onChange: (v) => setState(() {
                      _settings = _settings.copyWith(showPadanan: v);
                    }),
                  ),
                  const Gap(8),
                  settingsSwitchRow(
                    label: 'Tampilkan definisi',
                    value: _settings.showDefinition,
                    onChange: (v) => setState(() {
                      _settings = _settings.copyWith(showDefinition: v);
                    }),
                  ),
                  const Gap(8),
                  settingsSwitchRow(
                    label: 'Tampilkan contoh kalimat',
                    value:
                        _settings.showExample && _meaning.examples.isNotEmpty,
                    enabled: _meaning.examples.isNotEmpty,
                    onChange: (v) => setState(() {
                      _settings = _settings.copyWith(showExample: v);
                    }),
                  ),
                  const Gap(8),
                  settingsSwitchRow(
                    label: 'Tampilkan watermark SambasKu',
                    value: _settings.showWatermark,
                    onChange: (v) => setState(() {
                      _settings = _settings.copyWith(showWatermark: v);
                    }),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(height: 1, color: theme.colors.border),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: FButton(
                            variant: FButtonVariant.outline,
                            onPress: (_saving || _sharing || _loadingBg)
                                ? null
                                : _onSave,
                            prefix: _saving ? const FCircularProgress() : null,
                            child: const Text('Simpan'),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: FButton(
                            onPress: (_sharing || _saving || _loadingBg)
                                ? null
                                : _onShare,
                            prefix: _sharing ? const FCircularProgress() : null,
                            child: const Text('Bagikan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({
    required this.label,
    required this.selected,
    this.onTap,
    this.onLongPress,
    this.preview,
    this.icon,
    this.gradient,
    this.selectedBorder,
    this.showPlay = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ImageProvider? preview;
  final IconData? icon;
  final List<Color>? gradient;
  final Color? selectedBorder;
  final bool showPlay;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final border = selected
        ? (selectedBorder ?? theme.colors.primary)
        : theme.colors.border;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: selected ? 2.5 : 1),
            gradient: preview == null && gradient != null
                ? LinearGradient(colors: gradient!)
                : null,
            color: preview == null && gradient == null
                ? theme.colors.secondary
                : null,
            image: preview != null
                ? DecorationImage(image: preview!, fit: BoxFit.cover)
                : null,
          ),
          child: preview == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null)
                      Icon(
                        icon,
                        size: 22,
                        color: gradient != null
                            ? Colors.white
                            : theme.colors.foreground,
                      ),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: gradient != null
                            ? Colors.white
                            : theme.colors.foreground,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : (showPlay
                    ? const Icon(Icons.play_circle_fill, color: Colors.white)
                    : null),
        ),
      ),
    );
  }
}

/// Kartu di luar viewport tapi tetap dipaint, supaya `toImage` punya layer.
class _OffscreenCaptureBox extends StatelessWidget {
  const _OffscreenCaptureBox({
    required this.boundaryKey,
    required this.ratio,
    required this.child,
  });

  final GlobalKey boundaryKey;
  final ShareRatioId ratio;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0,
      height: 0,
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: ratio.width,
        maxWidth: ratio.width,
        minHeight: ratio.height,
        maxHeight: ratio.height,
        child: Transform.translate(
          offset: const Offset(-10000, 0),
          child: IgnorePointer(
            child: RepaintBoundary(
              key: boundaryKey,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
