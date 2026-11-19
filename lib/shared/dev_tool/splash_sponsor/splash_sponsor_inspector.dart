import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/router/app_router.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../l10n/app_localizations.dart';
import '../../splash/presentation/splash_sponsor_slot.dart';
import '../dev_tool_inspector.dart';

/// DevTool: simulasi slot splash sponsor (Phase 0) - tanpa API.
class SplashSponsorInspector extends DevToolInspector {
  @override
  Color get color => const Color(0xFFCA8A04);

  @override
  String get description =>
      'Simulasi splash sponsor: jumlah tier + logo random';

  @override
  IconData get icon => FLucideIcons.image;

  @override
  String get name => 'Splash sponsor';

  @override
  Widget buildPage(BuildContext context) => const _SplashSponsorDevPage();
}

class _SplashSponsorDevPage extends StatefulWidget {
  const _SplashSponsorDevPage();

  @override
  State<_SplashSponsorDevPage> createState() => _SplashSponsorDevPageState();
}

/// Mode warna holder logo di DevTool.
enum _HolderBgMode { theme, white, dark }

class _SplashSponsorDevPageState extends State<_SplashSponsorDevPage> {
  int _mustika = 2;
  int _intan = 3;
  int _emas = 5;
  int _seed = 1;
  bool _forceDark = false;
  _HolderBgMode _holderMode = _HolderBgMode.theme;
  MockSplashImageRatio _imageRatio = MockSplashImageRatio.square;
  bool _transparentPng = true;

  Color? get _holderOverride => switch (_holderMode) {
    _HolderBgMode.theme => null,
    _HolderBgMode.white => const Color(0xFFFFFFFF),
    _HolderBgMode.dark => const Color(0xFF1C1917),
  };

  List<SplashSponsorLogo> _logos() => buildMockSplashSponsors(
        mustika: _mustika,
        intan: _intan,
        emas: _emas,
        seed: _seed,
        ratio: _imageRatio,
        transparentPng: _transparentPng,
      );

  void _fillMax() {
    setState(() {
      _mustika = SplashSponsorTier.mustika.maxCount;
      _intan = SplashSponsorTier.intan.maxCount;
      _emas = SplashSponsorTier.emas.maxCount;
    });
  }

  void _clear() {
    setState(() {
      _mustika = 0;
      _intan = 0;
      _emas = 0;
    });
  }

  void _reshuffle() {
    setState(() => _seed = DateTime.now().millisecondsSinceEpoch % 100000);
  }

  Future<void> _openPreview() async {
    final logos = _logos();
    final nav = AppRouter.rootNavigatorKey.currentState;
    if (nav == null) return;
    await nav.push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _SplashSponsorPreviewPage(
          logos: logos,
          forceDark: _forceDark,
          logoBackground: _holderOverride,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logos = _logos();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Text(
          'Preview slot splash tanpa API. Cap deck: Mustika 2, Intan 3, Emas 5. '
          'Logo dari picsum (random).',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        const Gap(16),
        _CountTile(
          label: _imageRatio == MockSplashImageRatio.square
              ? 'Mustika (56×56)'
              : 'Mustika (100×60)',
          value: _mustika,
          max: SplashSponsorTier.mustika.maxCount,
          onChanged: (v) => setState(() => _mustika = v),
        ),
        _CountTile(
          label: _imageRatio == MockSplashImageRatio.square
              ? 'Intan (40×40)'
              : 'Intan (68×40)',
          value: _intan,
          max: SplashSponsorTier.intan.maxCount,
          onChanged: (v) => setState(() => _intan = v),
        ),
        _CountTile(
          label: _imageRatio == MockSplashImageRatio.square
              ? 'Emas (28×28, 1 baris)'
              : 'Emas (44×26, 1 baris)',
          value: _emas,
          max: SplashSponsorTier.emas.maxCount,
          onChanged: (v) => setState(() => _emas = v),
        ),
        const Gap(8),
        FTile(
          title: const Text('Paksa tema gelap'),
          subtitle: const Text('Splash + default holder logo'),
          suffix: FSwitch(
            value: _forceDark,
            onChange: (v) => setState(() => _forceDark = v),
          ),
        ),
        FTile(
          title: const Text('PNG transparan'),
          subtitle: const Text(
            'Sample lokal (alpha). Off = picsum foto opaque',
          ),
          suffix: FSwitch(
            value: _transparentPng,
            onChange: (v) => setState(() => _transparentPng = v),
          ),
        ),
        const Gap(8),
        Text(
          'Warna holder logo',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const Gap(6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final mode in _HolderBgMode.values)
              FButton(
                size: FButtonSizeVariant.sm,
                variant: _holderMode == mode ? .primary : .outline,
                onPress: () => setState(() => _holderMode = mode),
                child: Text(switch (mode) {
                  _HolderBgMode.theme => 'Ikut tema',
                  _HolderBgMode.white => 'Putih',
                  _HolderBgMode.dark => 'Gelap',
                }),
              ),
          ],
        ),
        const Gap(12),
        Text(
          'Rasio gambar mock',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const Gap(6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final ratio in MockSplashImageRatio.values)
              FButton(
                size: FButtonSizeVariant.sm,
                variant: _imageRatio == ratio ? .primary : .outline,
                onPress: () => setState(() => _imageRatio = ratio),
                child: Text(switch (ratio) {
                  MockSplashImageRatio.landscape => 'Landscape ~3:2',
                  MockSplashImageRatio.square => 'Kotak 1:1',
                  MockSplashImageRatio.mixed => 'Campur',
                }),
              ),
          ],
        ),
        const Gap(12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FButton(
              size: FButtonSizeVariant.sm,
              onPress: _fillMax,
              child: const Text('Isi penuh'),
            ),
            FButton(
              size: FButtonSizeVariant.sm,
              variant: .outline,
              onPress: _clear,
              child: const Text('Kosongkan'),
            ),
            FButton(
              size: FButtonSizeVariant.sm,
              variant: .outline,
              onPress: _reshuffle,
              child: const Text('Acak gambar'),
            ),
          ],
        ),
        const Gap(20),
        FButton(
          onPress: _openPreview,
          child: Text('Tampilkan splash (${logos.length} logo)'),
        ),
        const Gap(24),
        Text(
          'Cuplikan slot (inline)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const Gap(8),
        ColoredBox(
          color: _forceDark ? const Color(0xFF0C0A09) : const Color(0xFFFAFAF9),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
            child: SplashSponsorSlot(
              logos: logos,
              dark: _forceDark,
              logoBackground: _holderOverride,
            ),
          ),
        ),
      ],
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            onPressed: value <= 0 ? null : () => onChanged(value - 1),
            icon: const Icon(FLucideIcons.minus),
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: value >= max ? null : () => onChanged(value + 1),
            icon: const Icon(FLucideIcons.plus),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

/// Splash mock fullscreen - tidak auto-navigate; tutup dengan tombol.
class _SplashSponsorPreviewPage extends StatefulWidget {
  const _SplashSponsorPreviewPage({
    required this.logos,
    required this.forceDark,
    this.logoBackground,
  });

  final List<SplashSponsorLogo> logos;
  final bool forceDark;
  final Color? logoBackground;

  @override
  State<_SplashSponsorPreviewPage> createState() =>
      _SplashSponsorPreviewPageState();
}

class _SplashSponsorPreviewPageState extends State<_SplashSponsorPreviewPage>
    with SingleTickerProviderStateMixin {
  String? _version;
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoFade = CurvedAnimation(
      parent: _logoCtrl,
      curve: Curves.easeOutCubic,
    );
    _logoScale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutCubic),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _logoCtrl.forward();
    });
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.forceDark;
    final l10n = AppLocalizations.of(context);
    final bg = dark
        ? 'assets/images/splashscreen_dark.png'
        : 'assets/images/splashscreen_white.png';
    final ink = dark ? const Color(0xFFFAFAF9) : const Color(0xFF1C1917);
    final fade = dark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final version = _version;
    final tagline = version == null
        ? l10n.splashTaglinePending
        : l10n.splashTagline(version);

    return Theme(
      data: Theme.of(context).copyWith(
        brightness: dark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: fade,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              bg,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => const SizedBox.expand(),
            ),
            // Konten atas (tombol + brand) dalam SafeArea.
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        FLucideIcons.x,
                        color: ink.withValues(alpha: 0.85),
                      ),
                      tooltip: 'Tutup',
                    ),
                  ),
                  const Gap(8),
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: const BrandMark(size: 248),
                    ),
                  ),
                  const Spacer(),
                  // Cadangan tinggi footer overlay (gradasi + slot + tagline).
                  const SizedBox(height: 280),
                ],
              ),
            ),
            // Gradasi kaki full-width (edge-to-edge); konten tetap ber-inset.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      fade.withValues(alpha: 0),
                      fade.withValues(alpha: 0.88),
                      fade.withValues(alpha: 0.96),
                    ],
                    stops: const [0, 0.28, 1],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SplashSponsorSlot(
                          logos: widget.logos,
                          dark: dark,
                          logoBackground: widget.logoBackground,
                        ),
                        const Gap(8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TickerMode(
                              enabled: true,
                              child: FCircularProgress.loader(
                                size: .sm,
                                style: FCircularProgressStyleDelta.delta(
                                  iconStyle: IconThemeDataDelta.delta(
                                    color: ink.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                            ),
                            const Gap(10),
                            Flexible(
                              child: Text(
                                tagline,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ink.withValues(alpha: 0.85),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
