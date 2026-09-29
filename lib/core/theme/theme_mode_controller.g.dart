// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Preferensi tema: toggle menyimpan light/dark/system ke SharedPreferences.
///
/// [preload] wajib dipanggil di main sebelum runApp supaya frame pertama
/// tidak flash ke ThemeMode.system (ikut device) lalu jump ke nilai prefs.

@ProviderFor(ThemeModeController)
final themeModeControllerProvider = ThemeModeControllerProvider._();

/// Preferensi tema: toggle menyimpan light/dark/system ke SharedPreferences.
///
/// [preload] wajib dipanggil di main sebelum runApp supaya frame pertama
/// tidak flash ke ThemeMode.system (ikut device) lalu jump ke nilai prefs.
final class ThemeModeControllerProvider
    extends $NotifierProvider<ThemeModeController, ThemeMode> {
  /// Preferensi tema: toggle menyimpan light/dark/system ke SharedPreferences.
  ///
  /// [preload] wajib dipanggil di main sebelum runApp supaya frame pertama
  /// tidak flash ke ThemeMode.system (ikut device) lalu jump ke nilai prefs.
  ThemeModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeControllerHash();

  @$internal
  @override
  ThemeModeController create() => ThemeModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeControllerHash() =>
    r'bdfbf208ba3827617210966e9e0554998566cfbd';

/// Preferensi tema: toggle menyimpan light/dark/system ke SharedPreferences.
///
/// [preload] wajib dipanggil di main sebelum runApp supaya frame pertama
/// tidak flash ke ThemeMode.system (ikut device) lalu jump ke nilai prefs.

abstract class _$ThemeModeController extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
