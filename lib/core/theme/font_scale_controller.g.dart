// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_scale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Faktor skala teks pilihan user. Nilai mengikuti konvensi aksesibilitas
/// (0.85 kecil, 1.0 normal, 1.15 besar, 1.3 sangat besar). Diterapkan di
/// App.builder lewat MediaQuery textScaler override.

@ProviderFor(FontScaleController)
final fontScaleControllerProvider = FontScaleControllerProvider._();

/// Faktor skala teks pilihan user. Nilai mengikuti konvensi aksesibilitas
/// (0.85 kecil, 1.0 normal, 1.15 besar, 1.3 sangat besar). Diterapkan di
/// App.builder lewat MediaQuery textScaler override.
final class FontScaleControllerProvider
    extends $NotifierProvider<FontScaleController, double> {
  /// Faktor skala teks pilihan user. Nilai mengikuti konvensi aksesibilitas
  /// (0.85 kecil, 1.0 normal, 1.15 besar, 1.3 sangat besar). Diterapkan di
  /// App.builder lewat MediaQuery textScaler override.
  FontScaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fontScaleControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fontScaleControllerHash();

  @$internal
  @override
  FontScaleController create() => FontScaleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$fontScaleControllerHash() =>
    r'db3010af5ef2e99155eec91060456fbf3e365606';

/// Faktor skala teks pilihan user. Nilai mengikuti konvensi aksesibilitas
/// (0.85 kecil, 1.0 normal, 1.15 besar, 1.3 sangat besar). Diterapkan di
/// App.builder lewat MediaQuery textScaler override.

abstract class _$FontScaleController extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
