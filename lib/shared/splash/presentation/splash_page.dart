import 'dart:async';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/network/auth_token_storage.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../features/about/data/datasources/about_api_datasource.dart';
import '../../../features/about/presentation/providers/about_api_providers.dart';
import '../../../l10n/app_localizations.dart';
import 'splash_sponsor_slot.dart';

/// Splash branded: latar full-bleed, BrandMark di zona atas, slot sponsor
/// dari API (fail-soft kosong), spinner + tagline di kaki.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  /// Minimal tampil sebelum navigasi.
  static const minDwell = Duration(milliseconds: 1500);

  /// Tahan splash setelah logo sponsor muncul supaya sempat terlihat.
  static const sponsorHold = Duration(seconds: 2);

  /// Batas tunggu semua logo sponsor termuat.
  static const precacheTimeout = Duration(seconds: 6);

  /// Fade + scale logo BrandMark saja.
  static const logoAnim = Duration(milliseconds: 900);

  /// Tinggi slot Area sponsor (label + stack Mustika/Intan/Emas).
  static const sponsorSlotHeight = 170.0;

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  String? _version;
  List<SplashSponsorLogo> _logos = const [];
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: SplashPage.logoAnim);
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutCubic);
    _logoScale = Tween<double>(
      begin: 0.92,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutCubic));
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
    // Warm Keystore/gate cache di splash supaya tap Profil setelah home
    // tidak kena fail-closed timeout cold-start (#301).
    await Future.wait<void>([_loadVersion(), _loadSponsors(), _warmAuthGate()]);
    final elapsed = DateTime.now().difference(started);
    final remaining = SplashPage.minDwell - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    if (!mounted) return;
    context.go('/');
  }

  Future<void> _warmAuthGate() async {
    try {
      await AuthTokenStorage.instance.getIsAuthForGate();
    } catch (_) {
      // Fail-soft: gate tetap dicek saat tab Profil / redirect.
    }
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = info.version);
    } catch (_) {
      // Versi gagal = tagline tanpa angka; splash tetap jalan.
    }
  }

  Future<void> _loadSponsors() async {
    try {
      final items = await ref
          .read(aboutApiDatasourceProvider)
          .fetchSplashSponsorships();
      final logos = await Future.wait([for (final s in items) _toLogo(s)]);
      if (!mounted) return;
      final shown = [for (final logo in logos) ?logo];
      await _precacheLogos(shown);
      if (!mounted) return;
      setState(() => _logos = shown);
      // Semua logo sudah termuat; tahan supaya sempat terlihat sebelum home.
      if (shown.isNotEmpty) {
        await Future<void>.delayed(SplashPage.sponsorHold);
      }
    } catch (_) {
      // Fail-soft: slot kosong.
    }
  }

  /// Tunggu semua logo termuat. Batas [SplashPage.precacheTimeout] supaya
  /// jaringan lambat tidak menahan splash selamanya.
  Future<void> _precacheLogos(List<SplashSponsorLogo> logos) async {
    if (logos.isEmpty) return;
    await Future.wait([
      for (final logo in logos)
        precacheImage(
          logo.imageUrl.startsWith('assets/')
              ? AssetImage(logo.imageUrl)
              : CachedNetworkImageProvider(logo.imageUrl),
          context,
        ).catchError((Object _) {}),
    ]).timeout(SplashPage.precacheTimeout, onTimeout: () => const []);
  }

  Future<SplashSponsorLogo?> _toLogo(AboutSponsorship s) async {
    final url = s.logoUrl?.trim();
    if (url == null || url.isEmpty) return null;
    final tier = switch (s.tier) {
      'mustika' => SplashSponsorTier.mustika,
      'intan' => SplashSponsorTier.intan,
      'emas' => SplashSponsorTier.emas,
      _ => null,
    };
    if (tier == null) return null;
    final aspect = await _detectLogoAspect(url);
    return SplashSponsorLogo(
      tier: tier,
      imageUrl: url,
      name: s.name,
      aspect: aspect,
    );
  }

  /// Square bila rasio dekat 1:1; selain itu landscape. Timeout → landscape.
  Future<SplashSponsorLogoAspect> _detectLogoAspect(String url) async {
    try {
      final provider = NetworkImage(url);
      final stream = provider.resolve(ImageConfiguration.empty);
      final completer = Completer<SplashSponsorLogoAspect>();
      late final ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, _) {
          final w = info.image.width.toDouble();
          final h = info.image.height.toDouble();
          final ratio = h == 0 ? 1.0 : w / h;
          final aspect = (ratio >= 0.85 && ratio <= 1.15)
              ? SplashSponsorLogoAspect.square
              : SplashSponsorLogoAspect.landscape;
          if (!completer.isCompleted) completer.complete(aspect);
          stream.removeListener(listener);
        },
        onError: (_, _) {
          if (!completer.isCompleted) {
            completer.complete(SplashSponsorLogoAspect.landscape);
          }
          stream.removeListener(listener);
        },
      );
      stream.addListener(listener);
      return await completer.future.timeout(
        const Duration(milliseconds: 800),
        onTimeout: () => SplashSponsorLogoAspect.landscape,
      );
    } catch (_) {
      return SplashSponsorLogoAspect.landscape;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark
        ? 'assets/images/splashscreen_dark.png'
        : 'assets/images/splashscreen_white.png';
    final ink = dark ? const Color(0xFFFAFAF9) : const Color(0xFF1C1917);
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
                const Gap(56),
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: const BrandMark(size: kBrandMarkHeroSize),
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
                        SizedBox(
                          height: SplashPage.sponsorSlotHeight,
                          width: double.infinity,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: SplashSponsorSlot(logos: _logos, dark: dark),
                          ),
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
