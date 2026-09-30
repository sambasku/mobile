import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/share_models.dart';
import 'share_layout_edit_layer.dart';
import 'share_video_layer.dart';

/// Template kartu share (preview + PNG overlay).
class ShareCardCanvas extends StatelessWidget {
  const ShareCardCanvas({
    super.key,
    required this.data,
    required this.template,
    required this.ratio,
    required this.settings,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
    this.transparentBackdrop = false,
    this.layoutEditMode = false,
    this.selectedElement,
    this.mediaSelected = false,
    this.onSelectElement,
    this.onPanElement,
    this.onSelectMedia,
    this.onPanMedia,
  });

  final ShareCardData data;
  final ShareTemplateId template;
  final ShareRatioId ratio;
  final ShareEditorSettings settings;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;
  final bool transparentBackdrop;
  final bool layoutEditMode;
  final ShareTextElementId? selectedElement;
  final bool mediaSelected;
  final ValueChanged<ShareTextElementId>? onSelectElement;
  final void Function(ShareTextElementId id, Offset canvasDelta)? onPanElement;
  final VoidCallback? onSelectMedia;
  final void Function(Offset canvasDelta)? onPanMedia;

  @override
  Widget build(BuildContext context) {
    if (!layoutEditMode) return _buildCard(null);
    return ShareLayoutEditLayer(
      width: ratio.width,
      height: ratio.height,
      selected: selectedElement,
      mediaSelected: mediaSelected,
      mediaAlignment: settings.mediaAlignment,
      contentFloor: _textClearanceBottom(
        showWatermark: settings.showWatermark,
        hasCredit: data.creditLine != null,
        designBottom: 0,
        anchorBottom: template == ShareTemplateId.sisi ? 40 : 48,
      ),
      onSelectElement: onSelectElement,
      onPanElement: onPanElement,
      onSelectMedia: onSelectMedia,
      onPanMedia: onPanMedia,
      cardBuilder: _buildCard,
    );
  }

  Widget _buildCard(ShareCardHitKeyFor? hitKeyFor) {
    final layout = _LayoutCallbacks(
      editMode: layoutEditMode,
      selected: selectedElement,
      onSelect: onSelectElement,
      onPan: onPanElement,
      mediaAlignment: Alignment(
        settings.mediaAlignment.dx.clamp(-1.0, 1.0),
        settings.mediaAlignment.dy.clamp(-1.0, 1.0),
      ),
      mediaEdit: layoutEditMode && template.allowsMediaPan,
      mediaSelected: mediaSelected,
      onSelectMedia: onSelectMedia,
      onPanMedia: onPanMedia,
      hitKeyFor: hitKeyFor,
    );
    return SizedBox(
      width: ratio.width,
      height: ratio.height,
      child: switch (template) {
        ShareTemplateId.unsplash => _UnsplashCard(
          data: data,
          settings: settings,
          imageProvider: imageProvider,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
          layout: layout,
        ),
        ShareTemplateId.kamusEditorial => _KamusEditorialCard(
          data: data,
          settings: settings,
          imageProvider: imageProvider,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
          layout: layout,
        ),
        ShareTemplateId.posterHuruf => _PosterHurufCard(
          data: data,
          settings: settings,
          layout: layout,
        ),
        ShareTemplateId.polaroid => _PolaroidCard(
          data: data,
          settings: settings,
          imageProvider: imageProvider,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
          layout: layout,
        ),
        ShareTemplateId.sisi => _SisiCard(
          data: data,
          settings: settings,
          ratio: ratio,
          imageProvider: imageProvider,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
          layout: layout,
        ),
        ShareTemplateId.kaca => _KacaCard(
          data: data,
          settings: settings,
          imageProvider: imageProvider,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
          layout: layout,
        ),
        ShareTemplateId.kutipan => _KutipanCard(
          data: data,
          settings: settings,
          imageProvider: imageProvider,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
          layout: layout,
        ),
        ShareTemplateId.kartu => _KartuCard(
          data: data,
          settings: settings,
          imageProvider: imageProvider,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
          layout: layout,
        ),
      },
    );
  }
}

class _LayoutCallbacks {
  const _LayoutCallbacks({
    required this.editMode,
    required this.selected,
    required this.onSelect,
    required this.onPan,
    this.mediaAlignment = Alignment.center,
    this.mediaEdit = false,
    this.mediaSelected = false,
    this.onSelectMedia,
    this.onPanMedia,
    this.hitKeyFor,
  });

  final bool editMode;
  final ShareTextElementId? selected;
  final ValueChanged<ShareTextElementId>? onSelect;
  final void Function(ShareTextElementId id, Offset canvasDelta)? onPan;
  final Alignment mediaAlignment;
  final bool mediaEdit;
  final bool mediaSelected;
  final VoidCallback? onSelectMedia;
  final void Function(Offset canvasDelta)? onPanMedia;

  /// Kotak visual elemen, dipakai hit-test editor di atas gambar.
  final ShareCardHitKeyFor? hitKeyFor;
}

TextStyle _lemmaStyle({
  required ShareFontPair pair,
  required double size,
  required Color color,
}) {
  final base = switch (pair) {
    ShareFontPair.classic => GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: -0.5,
    ),
    ShareFontPair.editorial => GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: -0.3,
    ),
    ShareFontPair.modern => GoogleFonts.outfit(
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: -0.4,
    ),
  };
  return base.copyWith(color: color);
}

TextStyle _bodyStyle({
  required ShareFontPair pair,
  required double size,
  required Color color,
}) {
  final base = switch (pair) {
    ShareFontPair.classic => GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w500,
      height: 1.35,
    ),
    ShareFontPair.editorial => GoogleFonts.sourceSans3(
      fontSize: size,
      fontWeight: FontWeight.w500,
      height: 1.35,
    ),
    ShareFontPair.modern => GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: FontWeight.w500,
      height: 1.35,
    ),
  };
  return base.copyWith(color: color);
}

Widget _photoOrGradient({
  required ImageProvider? imageProvider,
  required List<Color> gradient,
  String? videoUrl,
  bool videoIsFile = false,
  bool transparentBackdrop = false,
  _LayoutCallbacks? layout,
}) {
  if (transparentBackdrop) {
    return const ColoredBox(color: Color(0x00000000));
  }
  final alignment = layout?.mediaAlignment ?? Alignment.center;
  Widget child;
  if (videoUrl != null && videoUrl.isNotEmpty) {
    child = ShareVideoLayer(
      url: videoUrl,
      isFile: videoIsFile,
      fallback: imageProvider,
      gradient: gradient,
      alignment: alignment,
    );
  } else if (imageProvider == null) {
    child = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
    );
  } else {
    child = Image(
      image: imageProvider,
      fit: BoxFit.cover,
      alignment: alignment,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
      ),
    );
  }
  if (layout == null || !layout.mediaEdit) return child;
  final framed = DecoratedBox(
    decoration: layout.mediaSelected
        ? BoxDecoration(
            border: Border.all(color: const Color(0xFF38BDF8), width: 6),
          )
        : const BoxDecoration(),
    position: DecorationPosition.foreground,
    child: child,
  );
  // Mode edit: ketukan ditangani lapisan di atas kartu, supaya teks menang
  // dari gambar yang menutupi seluruh latar.
  if (layout.hitKeyFor != null) return framed;
  return GestureDetector(
    onTap: layout.onSelectMedia,
    onPanStart: (_) => layout.onSelectMedia?.call(),
    onPanUpdate: (d) => layout.onPanMedia?.call(d.delta),
    child: framed,
  );
}

List<ShareSenseLine> _effectiveSenses(ShareCardData data) {
  if (data.senses.isNotEmpty) return data.senses;
  return [
    ShareSenseLine(
      wordClassCode: data.wordClassCode,
      padanan: data.padanan,
      definition: data.definition,
    ),
  ];
}

/// Kelas kata `[n]` sejajar deskripsi; multi-makna bernomor (maks. isi `senses`).
Widget _meaningCopyBlock({
  required ShareCardData data,
  required ShareEditorSettings settings,
  required _LayoutCallbacks layout,
  required ShareFontPair pair,
  required Color lemmaColor,
  required Color bodyColor,
  required double padananSize,
  required double definitionSize,
  int definitionMaxLines = 5,
  CrossAxisAlignment align = CrossAxisAlignment.start,
}) {
  if (!settings.showWordClass &&
      !settings.showPadanan &&
      !settings.showDefinition) {
    return const SizedBox.shrink();
  }

  final senses = _effectiveSenses(data);
  final numbered = settings.showAllMeanings && senses.length > 1;
  final rows = <Widget>[];
  for (var i = 0; i < senses.length; i++) {
    final sense = senses[i];
    final bracket = settings.showWordClass ? sense.wordClassBracket : null;
    final pad = settings.showPadanan ? (sense.padanan?.trim() ?? '') : '';
    final def = settings.showDefinition ? (sense.definition?.trim() ?? '') : '';
    if (bracket == null && pad.isEmpty && def.isEmpty) continue;
    if (rows.isNotEmpty) rows.add(const SizedBox(height: 14));
    rows.add(
      _senseRow(
        sense: sense,
        number: numbered ? i + 1 : null,
        settings: settings,
        pair: pair,
        lemmaColor: lemmaColor,
        bodyColor: bodyColor,
        padananSize: padananSize,
        definitionSize: definitionSize,
        definitionMaxLines: numbered ? 3 : definitionMaxLines,
        align: align,
      ),
    );
  }
  if (rows.isEmpty) return const SizedBox.shrink();

  final column = Column(
    crossAxisAlignment: align,
    mainAxisSize: MainAxisSize.min,
    children: rows,
  );

  // Multi: satu blok drag. Tunggal: teks mengikuti layout default.
  if (numbered) {
    return _laidOut(
      id: ShareTextElementId.definition,
      settings: settings,
      layout: layout,
      child: column,
    );
  }
  return _laidOut(
    id: ShareTextElementId.definition,
    settings: settings,
    layout: layout,
    child: column,
  );
}

Widget _senseRow({
  required ShareSenseLine sense,
  required int? number,
  required ShareEditorSettings settings,
  required ShareFontPair pair,
  required Color lemmaColor,
  required Color bodyColor,
  required double padananSize,
  required double definitionSize,
  required int definitionMaxLines,
  required CrossAxisAlignment align,
}) {
  final bracket = settings.showWordClass ? sense.wordClassBracket : null;
  final pad = settings.showPadanan ? (sense.padanan?.trim() ?? '') : '';
  final def = settings.showDefinition ? (sense.definition?.trim() ?? '') : '';
  final hasPad = pad.isNotEmpty;
  final hasDef = def.isNotEmpty;
  if (bracket == null && !hasPad && !hasDef) {
    return const SizedBox.shrink();
  }

  final lead = StringBuffer();
  if (number != null) lead.write('$number ');
  if (bracket != null) lead.write('$bracket ');
  final leadText = lead.toString();
  final textAlign = align == CrossAxisAlignment.center
      ? TextAlign.center
      : TextAlign.start;

  final padStyle = _bodyStyle(
    pair: pair,
    size: padananSize,
    color: lemmaColor,
  );
  final defStyle = _bodyStyle(
    pair: pair,
    size: definitionSize,
    color: bodyColor,
  );

  if (hasPad && hasDef) {
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$leadText→ $pad', textAlign: textAlign, style: padStyle),
        const SizedBox(height: 8),
        Text(
          def,
          textAlign: textAlign,
          maxLines: definitionMaxLines,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          style: defStyle,
        ),
      ],
    );
  }
  if (hasPad) {
    return Text('$leadText→ $pad', textAlign: textAlign, style: padStyle);
  }
  // `[n]` sejajar deskripsi
  return Text(
    '$leadText$def',
    textAlign: textAlign,
    maxLines: definitionMaxLines,
    overflow: TextOverflow.ellipsis,
    softWrap: true,
    style: defStyle,
  );
}

Widget _variantsUnderLemma({
  required ShareCardData data,
  required ShareFontPair pair,
  required Color color,
  required double size,
  TextAlign align = TextAlign.start,
}) {
  final line = data.variantsLine;
  final chip = Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Text(
      data.trustLabel,
      textAlign: align,
      style: _bodyStyle(pair: pair, size: size * 0.85, color: color),
    ),
  );
  if (line == null || line.isEmpty) return chip;
  return Column(
    crossAxisAlignment: align == TextAlign.center
        ? CrossAxisAlignment.center
        : align == TextAlign.end
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
    children: [
      chip,
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          line,
          textAlign: align,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _bodyStyle(pair: pair, size: size, color: color),
        ),
      ),
    ],
  );
}

Widget _watermark({required ShareCardData data, required ShareFontPair pair}) {
  final photo = data.photographer;
  final credit = data.creditLine;
  final radius = BorderRadius.circular(
    photo != null && photo.isNotEmpty ? 20 : 999,
  );

  return ClipRRect(
    borderRadius: radius,
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: radius,
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _WatermarkLogo(),
            if (credit != null) ...[
              const SizedBox(height: 8),
              Text(
                credit,
                style: _bodyStyle(
                  pair: pair,
                  size: 22,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// Wordmark putih untuk chip watermark (latar gelap/blur).
class _WatermarkLogo extends StatelessWidget {
  const _WatermarkLogo();

  static const _asset = 'assets/icons/logo_horizontal_dark.png';
  static const _visibleHeight = 58.0;

  @override
  Widget build(BuildContext context) {
    return const Image(
      image: AssetImage(_asset),
      height: _visibleHeight,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

/// Jarak dari tepi bawah kartu yang harus bebas teks.
///
/// Chip watermark (logo + kredit) menempel di kanan bawah. Tanpa sela ini,
/// baris terakhir menempati area yang sama.
double _textClearanceBottom({
  required bool showWatermark,
  required bool hasCredit,
  required double designBottom,
  double anchorBottom = 48,
}) {
  if (!showWatermark) return designBottom;
  const padV = 16.0;
  const creditGap = 8.0;
  const creditLine = 22.0 * 1.35;
  final chipHeight =
      padV * 2 +
      _WatermarkLogo._visibleHeight +
      (hasCredit ? creditGap + creditLine : 0) +
      2;
  const gap = 28.0;
  return math.max(designBottom, anchorBottom + chipHeight + gap);
}

/// Bungkus elemen agar bisa di-drag saat mode atur posisi.
///
/// Transform membungkus konten supaya posisi visual ikut offset. Di mode edit,
/// ketukan ditangani lapisan di atas kartu lewat [GlobalKey] di dalam transform,
/// jadi teks yang bertumpuk dengan gambar tetap yang terpilih.
Widget _laidOut({
  required ShareTextElementId id,
  required ShareEditorSettings settings,
  required _LayoutCallbacks layout,
  required Widget child,
}) {
  final l = settings.layoutFor(id);
  final selected = layout.selected == id;
  Widget inner = child;
  if (layout.editMode) {
    inner = DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: selected ? const Color(0xFF38BDF8) : Colors.white38,
          width: selected ? 3 : 1.5,
        ),
      ),
      child: child,
    );
  }

  if (!layout.editMode) {
    return Transform.translate(
      offset: l.offset,
      child: Transform.rotate(
        angle: l.rotationDeg * math.pi / 180,
        child: inner,
      ),
    );
  }

  return Transform.translate(
    offset: l.offset,
    child: Transform.rotate(
      angle: l.rotationDeg * math.pi / 180,
      child: KeyedSubtree(key: layout.hitKeyFor?.call(id), child: inner),
    ),
  );
}

class _UnsplashCard extends StatelessWidget {
  const _UnsplashCard({
    required this.data,
    required this.settings,
    required this.layout,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
    this.transparentBackdrop = false,
  });

  final ShareCardData data;
  final ShareEditorSettings settings;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;
  final bool transparentBackdrop;
  final _LayoutCallbacks layout;

  @override
  Widget build(BuildContext context) {
    final pair = settings.fontPair;
    final lemmaColor = settings.textColorId.lemma;
    final bodyColor = settings.textColorId.body;
    final lemmaSize = 120 * settings.lemmaFontScale;
    final bodySize = 40 * settings.bodyFontScale;
    final overlay = settings.overlayStrength.clamp(0.0, 1.0);
    final gradient = settings.backdropColors;

    return Stack(
      fit: StackFit.expand,
      children: [
        _photoOrGradient(
          imageProvider: imageProvider,
          gradient: gradient,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
          layout: layout,
        ),
        IgnorePointer(
          ignoring: layout.mediaEdit,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(0, 0, 0, 0.2 * overlay),
                  Colors.transparent,
                  Color.fromRGBO(0, 0, 0, 0.85 * overlay + 0.15),
                ],
                stops: const [0, 0.35, 1],
              ),
            ),
          ),
        ),
        IgnorePointer(
          ignoring: layout.mediaSelected,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              72,
              160,
              72,
              _textClearanceBottom(
                showWatermark: settings.showWatermark,
                hasCredit: data.creditLine != null,
                designBottom: 140,
              ),
            ),
            child: ClipRect(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _laidOut(
                            id: ShareTextElementId.lemma,
                            settings: settings,
                            layout: layout,
                            child: Text(
                              data.lemma,
                              style: _lemmaStyle(
                                pair: pair,
                                size: lemmaSize,
                                color: lemmaColor,
                              ),
                            ),
                          ),
                          _variantsUnderLemma(
                            data: data,
                            pair: pair,
                            color: lemmaColor,
                            size: 28 * settings.bodyFontScale,
                          ),
                          const SizedBox(height: 20),
                          _meaningCopyBlock(
                            data: data,
                            settings: settings,
                            layout: layout,
                            pair: pair,
                            lemmaColor: lemmaColor,
                            bodyColor: bodyColor,
                            padananSize: 44 * settings.bodyFontScale,
                            definitionSize: bodySize,
                            definitionMaxLines: 6,
                          ),
                          if (settings.showExample &&
                              data.exampleSentence != null &&
                              data.exampleSentence!.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _laidOut(
                              id: ShareTextElementId.example,
                              settings: settings,
                              layout: layout,
                              child: Text(
                                '"${data.exampleSentence}"',
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: _bodyStyle(
                                  pair: pair,
                                  size: 32 * settings.bodyFontScale,
                                  color: bodyColor,
                                ).copyWith(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (settings.showWatermark)
          Positioned(
            right: 48,
            bottom: 48,
            child: _watermark(data: data, pair: pair),
          ),
      ],
    );
  }
}

class _KamusEditorialCard extends StatelessWidget {
  const _KamusEditorialCard({
    required this.data,
    required this.settings,
    required this.layout,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
    this.transparentBackdrop = false,
  });

  final ShareCardData data;
  final ShareEditorSettings settings;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;
  final bool transparentBackdrop;
  final _LayoutCallbacks layout;

  static const _paper = Color(0xFFF3EDE2);
  static const _paperDark = Color(0xFF1C1917);

  @override
  Widget build(BuildContext context) {
    final pair = settings.fontPair;
    final dark = settings.textColorId.prefersDarkSurface;
    final bg = dark ? _paperDark : _paper;
    final lemmaColor = settings.textColorId.lemma;
    final bodyColor = settings.textColorId.body;
    final lemmaSize = 110 * settings.lemmaFontScale;
    final mutedHeader = bodyColor.withValues(alpha: 0.7);

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: bg,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              72,
              140,
              72,
              _textClearanceBottom(
                showWatermark: settings.showWatermark,
                hasCredit: data.creditLine != null,
                designBottom: 120,
              ),
            ),
            child: ClipRect(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KAMUS SAMBAS',
                              style:
                                  _bodyStyle(
                                    pair: pair,
                                    size: 20,
                                    color: mutedHeader,
                                  ).copyWith(
                                    letterSpacing: 3,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 28),
                            _laidOut(
                              id: ShareTextElementId.lemma,
                              settings: settings,
                              layout: layout,
                              child: Text(
                                data.lemma,
                                style: _lemmaStyle(
                                  pair: pair,
                                  size: lemmaSize,
                                  color: lemmaColor,
                                ),
                              ),
                            ),
                            _variantsUnderLemma(
                              data: data,
                              pair: pair,
                              color: lemmaColor,
                              size: 26 * settings.bodyFontScale,
                            ),
                          ],
                        ),
                      ),
                      if (imageProvider != null ||
                          (videoUrl != null && videoUrl!.isNotEmpty) ||
                          transparentBackdrop)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 220,
                            height: 220,
                            child: _photoOrGradient(
                              imageProvider: imageProvider,
                              gradient: const [
                                Color(0x22000000),
                                Color(0x22000000),
                              ],
                              videoUrl: videoUrl,
                              videoIsFile: videoIsFile,
                              transparentBackdrop: transparentBackdrop,
                              layout: layout,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Container(height: 2, color: bodyColor.withValues(alpha: 0.2)),
                  const SizedBox(height: 36),
                  _meaningCopyBlock(
                    data: data,
                    settings: settings,
                    layout: layout,
                    pair: pair,
                    lemmaColor: lemmaColor,
                    bodyColor: bodyColor,
                    padananSize: 36 * settings.bodyFontScale,
                    definitionSize: 42 * settings.bodyFontScale,
                    definitionMaxLines: 6,
                  ),
                  if (settings.showExample &&
                      data.exampleSentence != null &&
                      data.exampleSentence!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _laidOut(
                      id: ShareTextElementId.example,
                      settings: settings,
                      layout: layout,
                      child: Text(
                        '"${data.exampleSentence}"',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: _bodyStyle(
                          pair: pair,
                          size: 32 * settings.bodyFontScale,
                          color: bodyColor,
                        ).copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (settings.showWatermark)
          Positioned(
            right: 48,
            bottom: 48,
            child: _watermark(data: data, pair: pair),
          ),
      ],
    );
  }
}

class _PosterHurufCard extends StatelessWidget {
  const _PosterHurufCard({
    required this.data,
    required this.settings,
    required this.layout,
  });

  final ShareCardData data;
  final ShareEditorSettings settings;
  final _LayoutCallbacks layout;

  @override
  Widget build(BuildContext context) {
    final pair = settings.fontPair;
    final lemmaColor = settings.textColorId.lemma;
    final bodyColor = settings.textColorId.body;
    final lemmaSize = 180 * settings.lemmaFontScale;
    final gradient = settings.backdropColors;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            64,
            160,
            64,
            _textClearanceBottom(
              showWatermark: settings.showWatermark,
              hasCredit: data.creditLine != null,
              designBottom: 140,
            ),
          ),
          child: ClipRect(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                _laidOut(
                  id: ShareTextElementId.lemma,
                  settings: settings,
                  layout: layout,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      data.lemma,
                      style: _lemmaStyle(
                        pair: pair,
                        size: lemmaSize,
                        color: lemmaColor,
                      ),
                    ),
                  ),
                ),
                _variantsUnderLemma(
                  data: data,
                  pair: pair,
                  color: lemmaColor,
                  size: 32 * settings.bodyFontScale,
                ),
                const Spacer(),
                _meaningCopyBlock(
                  data: data,
                  settings: settings,
                  layout: layout,
                  pair: pair,
                  lemmaColor: lemmaColor,
                  bodyColor: bodyColor,
                  padananSize: 48 * settings.bodyFontScale,
                  definitionSize: 34 * settings.bodyFontScale,
                  definitionMaxLines: 6,
                ),
              ],
            ),
          ),
        ),
        if (settings.showWatermark)
          Positioned(
            right: 48,
            bottom: 48,
            child: _watermark(data: data, pair: pair),
          ),
      ],
    );
  }
}

class _PolaroidCard extends StatelessWidget {
  const _PolaroidCard({
    required this.data,
    required this.settings,
    required this.layout,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
    this.transparentBackdrop = false,
  });

  final ShareCardData data;
  final ShareEditorSettings settings;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;
  final bool transparentBackdrop;
  final _LayoutCallbacks layout;

  @override
  Widget build(BuildContext context) {
    final pair = settings.fontPair;
    final dark = settings.textColorId.prefersDarkSurface;
    final pageBg = dark ? const Color(0xFF292524) : const Color(0xFFE7E5E4);
    final lemmaColor = settings.textColorId.lemma;
    final bodyColor = settings.textColorId.body;
    final lemmaSize = 80 * settings.lemmaFontScale;
    final gradient = settings.backdropColors;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: pageBg,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              80,
              140,
              80,
              _textClearanceBottom(
                showWatermark: settings.showWatermark,
                hasCredit: data.creditLine != null,
                designBottom: 120,
              ),
            ),
            child: ClipRect(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(36, 36, 36, 28),
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF1C1917) : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRect(
                              child: _photoOrGradient(
                                imageProvider: imageProvider,
                                gradient: gradient,
                                videoUrl: videoUrl,
                                videoIsFile: videoIsFile,
                                transparentBackdrop: transparentBackdrop,
                                layout: layout,
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          _laidOut(
                            id: ShareTextElementId.lemma,
                            settings: settings,
                            layout: layout,
                            child: Text(
                              data.lemma,
                              textAlign: TextAlign.center,
                              style: _lemmaStyle(
                                pair: pair,
                                size: lemmaSize,
                                color: lemmaColor,
                              ),
                            ),
                          ),
                          _variantsUnderLemma(
                            data: data,
                            pair: pair,
                            color: lemmaColor,
                            size: 24 * settings.bodyFontScale,
                            align: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          _meaningCopyBlock(
                            data: data,
                            settings: settings,
                            layout: layout,
                            pair: pair,
                            lemmaColor: lemmaColor,
                            bodyColor: bodyColor,
                            padananSize: 34 * settings.bodyFontScale,
                            definitionSize: 32 * settings.bodyFontScale,
                            definitionMaxLines: 4,
                            align: CrossAxisAlignment.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
        if (settings.showWatermark)
          Positioned(
            right: 48,
            bottom: 48,
            child: _watermark(data: data, pair: pair),
          ),
      ],
    );
  }
}

class _SisiCard extends StatelessWidget {
  const _SisiCard({
    required this.data,
    required this.settings,
    required this.ratio,
    required this.layout,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
    this.transparentBackdrop = false,
  });

  final ShareCardData data;
  final ShareEditorSettings settings;
  final ShareRatioId ratio;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;
  final bool transparentBackdrop;
  final _LayoutCallbacks layout;

  @override
  Widget build(BuildContext context) {
    final pair = settings.fontPair;
    final dark = settings.textColorId.prefersDarkSurface;
    final panel = dark ? const Color(0xFF1C1917) : const Color(0xFFF5F0E8);
    final lemmaColor = settings.textColorId.lemma;
    final bodyColor = settings.textColorId.body;
    final gradient = settings.backdropColors;
    final media = ClipRect(
      child: _photoOrGradient(
        imageProvider: imageProvider,
        gradient: gradient,
        videoUrl: videoUrl,
        videoIsFile: videoIsFile,
        transparentBackdrop: transparentBackdrop,
      ),
    );
    final text = ColoredBox(
      color: panel,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          56,
          64,
          56,
          _textClearanceBottom(
            showWatermark: settings.showWatermark,
            hasCredit: data.creditLine != null,
            designBottom: 120,
            anchorBottom: 40,
          ),
        ),
        child: ClipRect(
          child: _stackedCopy(
            data: data,
            settings: settings,
            layout: layout,
            pair: pair,
            lemmaColor: lemmaColor,
            bodyColor: bodyColor,
            lemmaSize: 88 * settings.lemmaFontScale,
            align: CrossAxisAlignment.start,
          ),
        ),
      ),
    );
    final split = ratio.prefersSideSplit
        ? Row(
            children: [
              Expanded(flex: 5, child: media),
              Expanded(flex: 5, child: text),
            ],
          )
        : Column(
            children: [
              Expanded(flex: 11, child: media),
              Expanded(flex: 9, child: text),
            ],
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        split,
        if (settings.showWatermark)
          Positioned(
            right: 40,
            bottom: 40,
            child: _watermark(data: data, pair: pair),
          ),
      ],
    );
  }
}

class _KacaCard extends StatelessWidget {
  const _KacaCard({
    required this.data,
    required this.settings,
    required this.layout,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
    this.transparentBackdrop = false,
  });

  final ShareCardData data;
  final ShareEditorSettings settings;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;
  final bool transparentBackdrop;
  final _LayoutCallbacks layout;

  @override
  Widget build(BuildContext context) {
    final pair = settings.fontPair;
    final lemmaColor = settings.textColorId.lemma;
    final bodyColor = settings.textColorId.body;
    final overlay = settings.overlayStrength.clamp(0.0, 1.0);
    final gradient = settings.backdropColors;

    return Stack(
      fit: StackFit.expand,
      children: [
        _photoOrGradient(
          imageProvider: imageProvider,
          gradient: gradient,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
          layout: layout,
        ),
        IgnorePointer(
          ignoring: layout.mediaEdit,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color.fromRGBO(0, 0, 0, 0.55 * overlay + 0.12),
                ],
              ),
            ),
          ),
        ),
        IgnorePointer(
          ignoring: layout.mediaSelected,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              56,
              80,
              56,
              _textClearanceBottom(
                showWatermark: settings.showWatermark,
                hasCredit: data.creditLine != null,
                designBottom: 120,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(48, 44, 48, 44),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(
                        alpha: 0.22 + 0.28 * overlay,
                      ),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                    child: ClipRect(
                      child: _stackedCopy(
                        data: data,
                        settings: settings,
                        layout: layout,
                        pair: pair,
                        lemmaColor: lemmaColor,
                        bodyColor: bodyColor,
                        lemmaSize: 96 * settings.lemmaFontScale,
                        align: CrossAxisAlignment.start,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (settings.showWatermark)
          Positioned(
            right: 48,
            bottom: 48,
            child: _watermark(data: data, pair: pair),
          ),
      ],
    );
  }
}

class _KutipanCard extends StatelessWidget {
  const _KutipanCard({
    required this.data,
    required this.settings,
    required this.layout,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
    this.transparentBackdrop = false,
  });

  final ShareCardData data;
  final ShareEditorSettings settings;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;
  final bool transparentBackdrop;
  final _LayoutCallbacks layout;

  @override
  Widget build(BuildContext context) {
    final pair = settings.fontPair;
    final lemmaColor = settings.textColorId.lemma;
    final bodyColor = settings.textColorId.body;
    final overlay = settings.overlayStrength.clamp(0.0, 1.0);
    final gradient = settings.backdropColors;

    return Stack(
      fit: StackFit.expand,
      children: [
        _photoOrGradient(
          imageProvider: imageProvider,
          gradient: gradient,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
          layout: layout,
        ),
        IgnorePointer(
          ignoring: layout.mediaEdit,
          child: ColoredBox(
            color: Color.fromRGBO(0, 0, 0, 0.35 * overlay + 0.28),
          ),
        ),
        IgnorePointer(
          ignoring: layout.mediaSelected,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              72,
              160,
              72,
              _textClearanceBottom(
                showWatermark: settings.showWatermark,
                hasCredit: data.creditLine != null,
                designBottom: 160,
              ),
            ),
            child: ClipRect(
              child: Column(
                children: [
                  Text(
                    '"',
                    style: _lemmaStyle(
                      pair: pair,
                      size: 160,
                      color: lemmaColor.withValues(alpha: 0.55),
                    ).copyWith(height: 0.7),
                  ),
                  const Spacer(),
                  _laidOut(
                    id: ShareTextElementId.lemma,
                    settings: settings,
                    layout: layout,
                    child: Text(
                      data.lemma,
                      textAlign: TextAlign.center,
                      style: _lemmaStyle(
                        pair: pair,
                        size: 108 * settings.lemmaFontScale,
                        color: lemmaColor,
                      ),
                    ),
                  ),
                  _variantsUnderLemma(
                    data: data,
                    pair: pair,
                    color: lemmaColor,
                    size: 28 * settings.bodyFontScale,
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _meaningCopyBlock(
                    data: data,
                    settings: settings,
                    layout: layout,
                    pair: pair,
                    lemmaColor: lemmaColor,
                    bodyColor: bodyColor,
                    padananSize: 42 * settings.bodyFontScale,
                    definitionSize: 34 * settings.bodyFontScale,
                    definitionMaxLines: 5,
                    align: CrossAxisAlignment.center,
                  ),
                  const Spacer(),
                  if (settings.showExample &&
                      data.exampleSentence != null &&
                      data.exampleSentence!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _laidOut(
                      id: ShareTextElementId.example,
                      settings: settings,
                      layout: layout,
                      child: Text(
                        '"${data.exampleSentence}"',
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: _bodyStyle(
                          pair: pair,
                          size: 28 * settings.bodyFontScale,
                          color: bodyColor.withValues(alpha: 0.9),
                        ).copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (settings.showWatermark)
          Positioned(
            right: 48,
            bottom: 48,
            child: _watermark(data: data, pair: pair),
          ),
      ],
    );
  }
}

class _KartuCard extends StatelessWidget {
  const _KartuCard({
    required this.data,
    required this.settings,
    required this.layout,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
    this.transparentBackdrop = false,
  });

  final ShareCardData data;
  final ShareEditorSettings settings;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;
  final bool transparentBackdrop;
  final _LayoutCallbacks layout;

  @override
  Widget build(BuildContext context) {
    final pair = settings.fontPair;
    final dark = settings.textColorId.prefersDarkSurface;
    final paper = dark ? const Color(0xFF1C1917) : const Color(0xFFFFFBF5);
    final lemmaColor = settings.textColorId.lemma;
    final bodyColor = settings.textColorId.body;
    final gradient = settings.backdropColors;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: paper,
          child: Column(
            children: [
              Expanded(
                flex: 9,
                child: ClipRect(
                  child: _photoOrGradient(
                    imageProvider: imageProvider,
                    gradient: gradient,
                    videoUrl: videoUrl,
                    videoIsFile: videoIsFile,
                    transparentBackdrop: transparentBackdrop,
                    layout: layout,
                  ),
                ),
              ),
              Expanded(
                flex: 11,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    64,
                    48,
                    64,
                    _textClearanceBottom(
                      showWatermark: settings.showWatermark,
                      hasCredit: data.creditLine != null,
                      designBottom: 120,
                    ),
                  ),
                  child: ClipRect(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _laidOut(
                          id: ShareTextElementId.lemma,
                          settings: settings,
                          layout: layout,
                          child: Text(
                            data.lemma,
                            style: _lemmaStyle(
                              pair: pair,
                              size: 92 * settings.lemmaFontScale,
                              color: lemmaColor,
                            ),
                          ),
                        ),
                        _variantsUnderLemma(
                          data: data,
                          pair: pair,
                          color: lemmaColor,
                          size: 26 * settings.bodyFontScale,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 2,
                          color: bodyColor.withValues(alpha: 0.22),
                        ),
                        const SizedBox(height: 24),
                        _meaningCopyBlock(
                          data: data,
                          settings: settings,
                          layout: layout,
                          pair: pair,
                          lemmaColor: lemmaColor,
                          bodyColor: bodyColor,
                          padananSize: 36 * settings.bodyFontScale,
                          definitionSize: 36 * settings.bodyFontScale,
                          definitionMaxLines: 6,
                        ),
                        if (settings.showExample &&
                            data.exampleSentence != null &&
                            data.exampleSentence!.isNotEmpty) ...[
                          const Spacer(),
                          _laidOut(
                            id: ShareTextElementId.example,
                            settings: settings,
                            layout: layout,
                            child: Text(
                              data.exampleSentence!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: _bodyStyle(
                                pair: pair,
                                size: 28 * settings.bodyFontScale,
                                color: bodyColor.withValues(alpha: 0.85),
                              ).copyWith(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (settings.showWatermark)
          Positioned(
            right: 48,
            bottom: 48,
            child: _watermark(data: data, pair: pair),
          ),
      ],
    );
  }
}

Widget _stackedCopy({
  required ShareCardData data,
  required ShareEditorSettings settings,
  required _LayoutCallbacks layout,
  required ShareFontPair pair,
  required Color lemmaColor,
  required Color bodyColor,
  required double lemmaSize,
  required CrossAxisAlignment align,
}) {
  return Column(
    crossAxisAlignment: align,
    children: [
      const Spacer(),
      _laidOut(
        id: ShareTextElementId.lemma,
        settings: settings,
        layout: layout,
        child: Text(
          data.lemma,
          style: _lemmaStyle(pair: pair, size: lemmaSize, color: lemmaColor),
        ),
      ),
      _variantsUnderLemma(
        data: data,
        pair: pair,
        color: lemmaColor,
        size: 26 * settings.bodyFontScale,
        align: align == CrossAxisAlignment.center
            ? TextAlign.center
            : TextAlign.start,
      ),
      const SizedBox(height: 16),
      _meaningCopyBlock(
        data: data,
        settings: settings,
        layout: layout,
        pair: pair,
        lemmaColor: lemmaColor,
        bodyColor: bodyColor,
        padananSize: 38 * settings.bodyFontScale,
        definitionSize: 32 * settings.bodyFontScale,
        align: align,
      ),
      if (settings.showExample &&
          data.exampleSentence != null &&
          data.exampleSentence!.isNotEmpty) ...[
        const SizedBox(height: 16),
        _laidOut(
          id: ShareTextElementId.example,
          settings: settings,
          layout: layout,
          child: Text(
            data.exampleSentence!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: _bodyStyle(
              pair: pair,
              size: 26 * settings.bodyFontScale,
              color: bodyColor.withValues(alpha: 0.85),
            ).copyWith(fontStyle: FontStyle.italic),
          ),
        ),
      ],
      const Spacer(),
    ],
  );
}
