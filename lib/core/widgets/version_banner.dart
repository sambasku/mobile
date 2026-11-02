import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../features/onboarding/onboarding_router.dart';
import '../../flavors.dart';
import '../router/app_router.dart';

/// Banner versi di pojok kanan atas (pola jnn_mobile). Hanya staging.
class VersionBanner extends StatefulWidget {
  const VersionBanner({super.key, required this.child});

  final Widget child;

  @override
  State<VersionBanner> createState() => _VersionBannerState();
}

class _VersionBannerState extends State<VersionBanner> {
  // Cache future supaya FutureBuilder tidak refetch tiap rebuild.
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    if (!F.isStaging || F.hideDevChrome) return widget.child;

    return ListenableBuilder(
      listenable: AppRouter.router.routerDelegate,
      builder: (context, _) {
        // state melempar "Bad state: No element" sebelum match pertama ada.
        final config = AppRouter.router.routerDelegate.currentConfiguration;
        if (config.isNotEmpty &&
            config.uri.path == OnboardingRouter.onboarding.path) {
          return widget.child;
        }
        return _ribbon(context);
      },
    );
  }

  Widget _ribbon(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _packageInfo,
      builder: (context, snapshot) {
        // Selalu tampilkan ribbon; jangan return child saja saat loading
        // (itu yang bikin banner "hilang").
        final version = snapshot.hasData
            ? 'v${snapshot.data!.version}'
            : 'v…';

        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: IgnorePointer(
                  child: _BannerRibbon(version: version),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BannerRibbon extends StatelessWidget {
  const _BannerRibbon({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: const BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(6),
        ),
      ),
      child: Text(
        version,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 9,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
      ),
    );
  }
}
