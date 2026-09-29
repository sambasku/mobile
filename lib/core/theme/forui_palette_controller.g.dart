// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forui_palette_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Palet warna forui pilihan user: persist ke SharedPreferences.
///
/// [preload] di main sebelum runApp - sama seperti ThemeModeController,
/// supaya frame pertama tidak flash ke [defaultPalette].

@ProviderFor(ForuiPaletteController)
final foruiPaletteControllerProvider = ForuiPaletteControllerProvider._();

/// Palet warna forui pilihan user: persist ke SharedPreferences.
///
/// [preload] di main sebelum runApp - sama seperti ThemeModeController,
/// supaya frame pertama tidak flash ke [defaultPalette].
final class ForuiPaletteControllerProvider
    extends $NotifierProvider<ForuiPaletteController, String> {
  /// Palet warna forui pilihan user: persist ke SharedPreferences.
  ///
  /// [preload] di main sebelum runApp - sama seperti ThemeModeController,
  /// supaya frame pertama tidak flash ke [defaultPalette].
  ForuiPaletteControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foruiPaletteControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foruiPaletteControllerHash();

  @$internal
  @override
  ForuiPaletteController create() => ForuiPaletteController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$foruiPaletteControllerHash() =>
    r'3b1020cc0b0a3a5b98fdf0dac28516e863f72684';

/// Palet warna forui pilihan user: persist ke SharedPreferences.
///
/// [preload] di main sebelum runApp - sama seperti ThemeModeController,
/// supaya frame pertama tidak flash ke [defaultPalette].

abstract class _$ForuiPaletteController extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
