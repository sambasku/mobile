import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/forui_palette_controller.dart';
import 'core/theme/forui_palettes.dart';
import 'core/theme/font_scale_controller.dart';
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
import 'shared/widgets/offline_banner.dart';

class App extends ConsumerWidget {
  const App({super.key});

  // ponytail: Forui kasih shape rounded ke bottom sheet tapi clipBehavior null
  // (= Clip.none), jadi Material anak full-bleed nutup sudut -> keliatan kotak.
  // Set antiAlias sekali di sini biar semua showModalBottomSheet seragam.
  static ThemeData _materialTheme(FThemeData f) {
    final theme = f.toApproximateMaterialTheme();
    return theme.copyWith(
      bottomSheetTheme: theme.bottomSheetTheme.copyWith(clipBehavior: Clip.antiAlias),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider);
    // Palet warna pilihan user (SharedPreferences) - default zinc
    final palette =
        foruiPalettes[ref.watch(foruiPaletteControllerProvider)] ??
        foruiPalettes[defaultPalette]!;
    // Skala teks pilihan user (aksesibilitas) - default 1.0.
    final fontScale = ref.watch(fontScaleControllerProvider);

    return MaterialApp.router(
      title: F.title,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _materialTheme(palette.light.touch),
      darkTheme: _materialTheme(palette.dark.touch),
      localizationsDelegates: FLocalizations.localizationsDelegates,
      supportedLocales: FLocalizations.supportedLocales,
      builder: (context, child) {
        // Forui tidak auto-switch brightness - pilih variant dari Theme Material
        final fTheme =
            (Theme.of(context).brightness == Brightness.dark
                ? palette.dark.touch
                : palette.light.touch)
            // Header lebih pendek dari default Forui (minHeight 62,
            // padding atas 8 bawah 10): hemat ~12px vertikal per layar.
            .copyWith(
              headerStyles: FVariantsDelta.delta([
                FVariantOperation.all(
                  FHeaderStyleDelta.delta(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: EdgeInsetsGeometryDelta.value(
                      const EdgeInsets.fromLTRB(12, 4, 12, 6),
                    ),
                    actionStyle: FHeaderActionStyleDelta.delta(
                      padding: EdgeInsetsGeometryDelta.value(
                        const EdgeInsets.all(5),
                      ),
                    ),
                  ),
                ),
              ]),
            );

        return FTheme(
          data: fTheme,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(fontScale),
            ),
            child: FToaster(
              child: Column(
                children: [
                  const OfflineBanner(),
                  Expanded(
                    child: VersionBanner(
                      child: DevToolOverlay(
                        inspectors: [
                          NetworkMonitorInspector(),
                          if (F.isStaging && !F.hideDevChrome)
                            ExceptionLogInspector(),
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
                ],
              ),
            ),
          ),
        );
      },
      routerConfig: AppRouter.router,
    );
  }
}