import 'package:material_ui/material_ui.dart'
    hide GlobalMaterialLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show
        GlobalMaterialLocalizations,
        GlobalWidgetsLocalizations,
        GlobalCupertinoLocalizations;
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'core/i18n/app_locale.dart';
import 'core/i18n/locale_controller.dart';
import 'core/router/app_router.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/forui_palette_controller.dart';
import 'core/theme/forui_palettes.dart';
import 'core/theme/font_scale_controller.dart';
import 'core/theme/theme_mode_controller.dart';
import 'core/widgets/version_banner.dart';
import 'features/app_update/presentation/update_banner.dart';
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
  static ThemeData materialTheme(FThemeData f) {
    final theme = f.toApproximateMaterialTheme();
    return theme.copyWith(
      bottomSheetTheme: theme.bottomSheetTheme.copyWith(
        clipBehavior: Clip.antiAlias,
      ),
    );
  }

  static ThemeData _materialTheme(FThemeData f) => materialTheme(f);

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
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        ...FLocalizations.localizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
// Registry locale (MOBILE-I18N): id + id_SBS, keduanya LTR.
// Sebelumnya dipakai seluruh daftar locale Forui, termasuk locale RTL
// (ar/fa/he/ur/ps) - di perangkat ber-locale RTL, Directionality dari
// Localizations membalik semua Row sehingga tombol Setujui/Tolak di
// Area Verifikator jadi terbalik (#189).
supportedLocales: [
  for (final l in AppLocale.all) l.toLocale(),
],
locale: ref.watch(localeControllerProvider).toLocale(),
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

        return SkeletonizerConfig(
          // Skeletonizer 3.0.0 pakai platformBrightness (tema OS), bukan
          // Theme app - OS dark + app light bikin skeleton hitam. Kunci ke
          // brightness tema Material supaya shimmer ikut tema app.
          data: SkeletonizerConfigData(
            brightness: Theme.of(context).brightness,
          ),
          child: FTheme(
            data: fTheme,
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(fontScale)),
              child: FToaster(
                  child: Column(
                    children: [
                      const OfflineBanner(),
                      // Cek versi terbaru (issue mobile#196): banner update
                      // non-blocking di atas shell. UpdateBanner sendiri yang
                      // memutuskan tampil/tidak (versi sama / offline = hilang).
                      const UpdateBanner(),
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
          ),
        );
      },
      routerConfig: AppRouter.router,
    );
  }
}
