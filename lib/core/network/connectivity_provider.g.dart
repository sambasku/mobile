// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Status koneksi: seed dari [checkConnectivity] lalu ikut
/// [onConnectivityChanged]. Tanpa seed, subscribe stream saja sering
/// tidak dapat status awal - banner bisa stuck offline walau sudah online.

@ProviderFor(connectivity)
final connectivityProvider = ConnectivityProvider._();

/// Status koneksi: seed dari [checkConnectivity] lalu ikut
/// [onConnectivityChanged]. Tanpa seed, subscribe stream saja sering
/// tidak dapat status awal - banner bisa stuck offline walau sudah online.

final class ConnectivityProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConnectivityResult>>,
          List<ConnectivityResult>,
          Stream<List<ConnectivityResult>>
        >
    with
        $FutureModifier<List<ConnectivityResult>>,
        $StreamProvider<List<ConnectivityResult>> {
  /// Status koneksi: seed dari [checkConnectivity] lalu ikut
  /// [onConnectivityChanged]. Tanpa seed, subscribe stream saja sering
  /// tidak dapat status awal - banner bisa stuck offline walau sudah online.
  ConnectivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityHash();

  @$internal
  @override
  $StreamProviderElement<List<ConnectivityResult>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ConnectivityResult>> create(Ref ref) {
    return connectivity(ref);
  }
}

String _$connectivityHash() => r'eefd785e359e634d28a1063f9fe9340faa0aa029';

/// Offline hanya bila hasil offline bertahan > 2 detik (anti kedip saat
/// switching radio). Online langsung clear. Loading/error tidak dianggap
/// offline (bug lama: `next.value ?? []` bikin null = offline permanen).

@ProviderFor(IsOffline)
final isOfflineProvider = IsOfflineProvider._();

/// Offline hanya bila hasil offline bertahan > 2 detik (anti kedip saat
/// switching radio). Online langsung clear. Loading/error tidak dianggap
/// offline (bug lama: `next.value ?? []` bikin null = offline permanen).
final class IsOfflineProvider extends $NotifierProvider<IsOffline, bool> {
  /// Offline hanya bila hasil offline bertahan > 2 detik (anti kedip saat
  /// switching radio). Online langsung clear. Loading/error tidak dianggap
  /// offline (bug lama: `next.value ?? []` bikin null = offline permanen).
  IsOfflineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOfflineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOfflineHash();

  @$internal
  @override
  IsOffline create() => IsOffline();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isOfflineHash() => r'00cc0596907ad885cba94899454dec7d67c23dca';

/// Offline hanya bila hasil offline bertahan > 2 detik (anti kedip saat
/// switching radio). Online langsung clear. Loading/error tidak dianggap
/// offline (bug lama: `next.value ?? []` bikin null = offline permanen).

abstract class _$IsOffline extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
