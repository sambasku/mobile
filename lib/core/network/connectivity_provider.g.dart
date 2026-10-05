// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Status koneksi: offline ketika tidak ada interface jaringan sama
/// sekali (wifi + mobile kosong). WiFi/cellular/ethernet dianggap online -
/// portal captive tidak terdeteksi, itu tanggung jawaban layer fetch.

@ProviderFor(connectivity)
final connectivityProvider = ConnectivityProvider._();

/// Status koneksi: offline ketika tidak ada interface jaringan sama
/// sekali (wifi + mobile kosong). WiFi/cellular/ethernet dianggap online -
/// portal captive tidak terdeteksi, itu tanggung jawaban layer fetch.

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
  /// Status koneksi: offline ketika tidak ada interface jaringan sama
  /// sekali (wifi + mobile kosong). WiFi/cellular/ethernet dianggap online -
  /// portal captive tidak terdeteksi, itu tanggung jawaban layer fetch.
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

String _$connectivityHash() => r'bf12454d78bf3189236d0c99e4f0d5afc772458f';

/// Stream bisa emmit kosong sesaat saat switching - debounce supaya banner
/// tidak kedip. Offline hanya bila hasil kosong bertahan > 2 detik.

@ProviderFor(isOffline)
final isOfflineProvider = IsOfflineProvider._();

/// Stream bisa emmit kosong sesaat saat switching - debounce supaya banner
/// tidak kedip. Offline hanya bila hasil kosong bertahan > 2 detik.

final class IsOfflineProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Stream bisa emmit kosong sesaat saat switching - debounce supaya banner
  /// tidak kedip. Offline hanya bila hasil kosong bertahan > 2 detik.
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
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return isOffline(ref);
  }
}

String _$isOfflineHash() => r'98ae55e518b3745c214bb33fc03f714f60813c4e';
