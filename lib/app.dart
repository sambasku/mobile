import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/forui_palette_controller.dart';
import 'core/theme/forui_palettes.dart';
import 'core/theme/theme_mode_controller.dart';
import 'core/widgets/version_banner.dart';
import 'flavors.dart';
import 'shared/dev_tool/api_host/api_host_inspector.dart';
import 'shared/dev_tool/dev_tool.dart';
import 'shared/dev_tool/exception_log/exception_log_inspector.dart';
import 'shared/dev_tool/onboarding/onboarding_inspector.dart';
import 'shared/dev_tool/storage_inspector/response_cache_inspector.dart';
import 'shared/dev_tool/storage_inspector/secure_storage_inspector.dart';
import 'shared/dev_tool/storage_inspector/shared_pref_inspector.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider);
    // Palet warna pilihan user (SharedPreferences) - default zinc
    final palette =
        foruiPalettes[ref.watch(foruiPaletteControllerProvider)] ??
        foruiPalettes[defaultPalette]!;

    return MaterialApp.router(
      title: F.title,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: palette.light.touch.toApproximateMaterialTheme(),
      darkTheme: palette.dark.touch.toApproximateMaterialTheme(),
      localizationsDelegates: FLocalizations.localizationsDelegates,
      supportedLocales: FLocalizations.supportedLocales,
      builder: (context, child) {
        // Forui tidak auto-switch brightness - pilih variant dari Theme Material
        final fTheme = Theme.of(context).brightness == Brightness.dark
            ? palette.dark.touch
            : palette.light.touch;

        return FTheme(
          data: fTheme,
          child: FToaster(
            child: VersionBanner(
              child: DevToolOverlay(
                inspectors: [
                  if (F.isStaging && !F.hideDevChrome) ExceptionLogInspector(),
                  NetworkMonitorInspector(),
                  ApiHostInspector(),
                  SharedPrefInspector(),
                  SecureStorageInspector(),
                  ResponseCacheInspector(),
                  DevToolGroup(
                    name: 'UI',
                    description: 'Tool UI lainnya',
                    icon: FLucideIcons.layoutDashboard,
                    color: const Color(0xFF7C3AED),
                    children: [OnboardingInspector()],
                  ),
                ],
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
      routerConfig: AppRouter.router,
    );
  }
}
