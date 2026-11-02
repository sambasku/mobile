import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

import '../domain/share_models.dart';
import '../../../l10n/app_localizations.dart';
import 'share_labels.dart';
import 'widgets/share_card_canvas.dart';

Future<void> showShareImageFullscreen(
  BuildContext context, {
  required ImageProvider image,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _FullscreenImagePage(image: image),
    ),
  );
}

Future<void> showShareCardFullscreen(
  BuildContext context, {
  required ShareCardData data,
  required ShareTemplateId template,
  required ShareRatioId ratio,
  required ShareEditorSettings settings,
  ImageProvider? imageProvider,
  String? videoUrl,
  bool videoIsFile = false,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _FullscreenCardPage(
        data: data,
        template: template,
        ratio: ratio,
        settings: settings,
        imageProvider: imageProvider,
        videoUrl: videoUrl,
        videoIsFile: videoIsFile,
      ),
    ),
  );
}

/// Editor posisi fullscreen. Mengembalikan settings baru jika user tap Selesai.
Future<ShareEditorSettings?> showShareLayoutEditor(
  BuildContext context, {
  required ShareCardData Function(ShareEditorSettings settings) buildData,
  required ShareTemplateId template,
  required ShareRatioId ratio,
  required ShareEditorSettings settings,
  ImageProvider? imageProvider,
  String? videoUrl,
  bool videoIsFile = false,
}) {
  return Navigator.of(context).push<ShareEditorSettings>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _LayoutEditorPage(
        buildData: buildData,
        template: template,
        ratio: ratio,
        initialSettings: settings,
        imageProvider: imageProvider,
        videoUrl: videoUrl,
        videoIsFile: videoIsFile,
      ),
    ),
  );
}

class _FullscreenImagePage extends StatelessWidget {
  const _FullscreenImagePage({required this.image});

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Image(image: image, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _FullscreenCardPage extends StatelessWidget {
  const _FullscreenCardPage({
    required this.data,
    required this.template,
    required this.ratio,
    required this.settings,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
  });

  final ShareCardData data;
  final ShareTemplateId template;
  final ShareRatioId ratio;
  final ShareEditorSettings settings;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(AppLocalizations.of(context).sharePreviewCardTitle),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3,
          child: AspectRatio(
            aspectRatio: ratio.width / ratio.height,
            child: FittedBox(
              fit: BoxFit.contain,
              child: ShareCardCanvas(
                data: data,
                template: template,
                ratio: ratio,
                settings: settings,
                imageProvider: imageProvider,
                videoUrl: videoUrl,
                videoIsFile: videoIsFile,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LayoutEditorPage extends StatefulWidget {
  const _LayoutEditorPage({
    required this.buildData,
    required this.template,
    required this.ratio,
    required this.initialSettings,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
  });

  final ShareCardData Function(ShareEditorSettings settings) buildData;
  final ShareTemplateId template;
  final ShareRatioId ratio;
  final ShareEditorSettings initialSettings;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;

  @override
  State<_LayoutEditorPage> createState() => _LayoutEditorPageState();
}

class _LayoutEditorPageState extends State<_LayoutEditorPage> {
  late ShareEditorSettings _settings;
  ShareTextElementId? _selected;
  bool _mediaSelected = false;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  void _onPan(ShareTextElementId id, Offset canvasDelta) {
    final current = _settings.layoutFor(id);
    setState(() {
      _selected = id;
      _mediaSelected = false;
      _settings = _settings.withLayout(
        id,
        current.copyWith(offset: current.offset + canvasDelta),
      );
    });
  }

  void _onPanMedia(Offset canvasDelta) {
    if (!widget.template.allowsMediaPan) return;
    final w = widget.ratio.width / 2;
    final h = widget.ratio.height / 2;
    final cur = _settings.mediaAlignment;
    setState(() {
      _mediaSelected = true;
      _selected = null;
      _settings = _settings.copyWith(
        mediaAlignment: Offset(
          (cur.dx - canvasDelta.dx / w).clamp(-1.0, 1.0),
          (cur.dy - canvasDelta.dy / h).clamp(-1.0, 1.0),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.buildData(_settings);
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final canPanMedia = widget.template.allowsMediaPan;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(AppLocalizations.of(context).shareLayoutEditorTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: AppLocalizations.of(context).shareCancel,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_settings),
            child: Text(
              AppLocalizations.of(context).shareDone,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              canPanMedia
                  ? l10n.shareLayoutHintPannable
                  : l10n.shareLayoutHintFixed,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: AspectRatio(
                  aspectRatio: widget.ratio.width / widget.ratio.height,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    clipBehavior: Clip.none,
                    child: ShareCardCanvas(
                      data: data,
                      template: widget.template,
                      ratio: widget.ratio,
                      settings: _settings,
                      imageProvider: widget.imageProvider,
                      videoUrl: widget.videoUrl,
                      videoIsFile: widget.videoIsFile,
                      layoutEditMode: true,
                      selectedElement: _selected,
                      mediaSelected: _mediaSelected,
                      onSelectElement: (id) => setState(() {
                        _selected = id;
                        _mediaSelected = false;
                      }),
                      onPanElement: _onPan,
                      onSelectMedia: canPanMedia
                          ? () => setState(() {
                              _mediaSelected = true;
                              _selected = null;
                            })
                          : null,
                      onPanMedia: canPanMedia ? _onPanMedia : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
            color: const Color(0xFF111111),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canPanMedia) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _mediaSelected = true;
                        _selected = null;
                      }),
                      child: FBadge(
                        variant: _mediaSelected
                            ? FBadgeVariant.primary
                            : FBadgeVariant.secondary,
                        child: Text(AppLocalizations.of(context).shareSectionBackdrop),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_selected != null) ...[
                  Text(
                    l10n.shareRotateLabel(
                      shareTextElementLabel(_selected!, l10n),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Slider(
                    value: _settings
                        .layoutFor(_selected!)
                        .rotationDeg
                        .clamp(-90, 90),
                    min: -90,
                    max: 90,
                    divisions: 18,
                    activeColor: const Color(0xFF38BDF8),
                    label:
                        '${_settings.layoutFor(_selected!).rotationDeg.round()}°',
                    onChanged: (v) {
                      final id = _selected!;
                      final cur = _settings.layoutFor(id);
                      setState(() {
                        _settings = _settings.withLayout(
                          id,
                          cur.copyWith(rotationDeg: v),
                        );
                      });
                    },
                  ),
                ]               else if (_mediaSelected)
                Text(
                  l10n.shareDragToCrop,
                  style: const TextStyle(color: Color(0x8AFFFFFF), fontSize: 13),
                )
              else
                Text(
                  canPanMedia
                      ? l10n.sharePickBackdropOrText
                      : l10n.sharePickTextElement,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 13,
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => setState(() {
                      _settings = _settings.resetLayouts();
                      _selected = null;
                      _mediaSelected = false;
                    }),
                    child: Text(AppLocalizations.of(context).shareResetPosition),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
