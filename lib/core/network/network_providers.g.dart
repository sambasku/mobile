// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authTokenStorage)
final authTokenStorageProvider = AuthTokenStorageProvider._();

final class AuthTokenStorageProvider
    extends
        $FunctionalProvider<
          AuthTokenStorage,
          AuthTokenStorage,
          AuthTokenStorage
        >
    with $Provider<AuthTokenStorage> {
  AuthTokenStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authTokenStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authTokenStorageHash();

  @$internal
  @override
  $ProviderElement<AuthTokenStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthTokenStorage create(Ref ref) {
    return authTokenStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthTokenStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthTokenStorage>(value),
    );
  }
}

String _$authTokenStorageHash() => r'e130a4f875fd7c9d293071d8a77c099ae6cad05b';

/// Klien HTTP bersama. keepAlive: sheet Google/Facebook menaruh activity
/// di background selama beberapa detik. Provider autoDispose akan menutup
/// adapter di jeda itu (`Can't establish connection after the adapter was
/// closed`) sebelum POST /auth/google sempat jalan.

@ProviderFor(dio)
final dioProvider = DioProvider._();

/// Klien HTTP bersama. keepAlive: sheet Google/Facebook menaruh activity
/// di background selama beberapa detik. Provider autoDispose akan menutup
/// adapter di jeda itu (`Can't establish connection after the adapter was
/// closed`) sebelum POST /auth/google sempat jalan.

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Klien HTTP bersama. keepAlive: sheet Google/Facebook menaruh activity
  /// di background selama beberapa detik. Provider autoDispose akan menutup
  /// adapter di jeda itu (`Can't establish connection after the adapter was
  /// closed`) sebelum POST /auth/google sempat jalan.
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'95a82175518d683579f5927322344550c6d37fee';
