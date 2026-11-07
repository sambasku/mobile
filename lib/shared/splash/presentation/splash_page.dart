import 'dart:async';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/widgets/brand_logo.dart';
import '../../../l10n/app_localizations.dart';

/// Splash branded: latar full-bleed, BrandMark di zona atas, slot Area
/// sponsor (follow-up), spinner + tagline di kaki.
///
/// Layout mirror [docs/demos/splash-sponsor-demo.html]: space flex di
/// tengah, blok bawah bergradasi di SafeArea.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  /// Minimal tampil sebelum navigasi.
  static const minDwell = Duration(milliseconds: 1500);

  /// Fade + scale logo BrandMark saja.
  static const logoAnim = Duration(milliseconds: 900);

  /// Tinggi slot Area sponsor (label + 1–2 baris logo) - diisi plan follow-up.
  static const sponsorSlotHeight = 72.0;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
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
      duration: SplashPage.logoAnim,
    );
    _logoFade = CurvedAnimation(
      parent: _logoCtrl,
      curve: Curves.easeOutCubic,
    );
    _logoScale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutCubic),
    );
    // Lepas native splash di frame pertama supaya SplashPage Flutter
    // (BrandMark + spinner + tagline) sempat terlihat. Sebelumnya remove()
    // dipanggil bareng go('/') - native menutupi seluruh dwell.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
      if (!mounted) return;
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      if (reduceMotion) {
        _logoCtrl.value = 1;
      } else {
        unawaited(_logoCtrl.forward());
      }
      unawaited(_bootstrap());
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final started = DateTime.now();
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = info.version);
    } catch (_) {
      // Versi gagal = tagline tanpa angka; splash tetap jalan.
    }
    final elapsed = DateTime.now().difference(started);
    final remaining = SplashPage.minDwell - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark
        ? 'assets/images/splashscreen_dark.png'
        : 'assets/images/splashscreen_white.png';
    final ink = dark ? const Color(0xFFFAFAF9) : const Color(0xFF1C1917);
    // Gradasi kaki: putih (light) / hitam (dark) - mirror .sponsor di demo.
    final fade = dark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final version = _version;
    final tagline = version == null
        ? l10n.splashTaglinePending
        : l10n.splashTagline(version);

    return ColoredBox(
      color: fade,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            bg,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const SizedBox.expand(),
          ),
          SafeArea(
            child: Column(
              children: [
                // Zona kosong atas: gap atas + logo lebih besar, sedikit turun.
                const Gap(56),
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: const BrandMark(size: 200),
                  ),
                ),
                const Spacer(),
                DecoratedBox(
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Area sponsor - mirror splash-sponsor-demo.html.
                        // Isi: label "Didukung oleh" + stack Mustika…Tembaga
                        // (plan follow-up).
                        const SizedBox(
                          height: SplashPage.sponsorSlotHeight,
                          width: double.infinity,
                        ),
                        const Gap(8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // .loader (bukan default loaderCircle): putaran
                            // lebih kentara. Warna ink supaya kontras di kaki
                            // splash. TickerMode paksa aktif - jaring jika
                            // ancestor sempat mematikan ticker.
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
                        const Gap(24),
                      ],
                    ),
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
