// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_status_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Status auth global (reaktif) dari AuthTokenStorage. Logout lewat sini
/// supaya Profile + router otomatis tahu user sudah jadi tamu.
///
/// keepAlive: sesi tidak boleh autoDispose saat pindah /login → / (gap
/// antar listener sempat cancel rebuild + sisakan cache isAuth:false).

@ProviderFor(AuthStatusNotifier)
final authStatusProvider = AuthStatusNotifierProvider._();

/// Status auth global (reaktif) dari AuthTokenStorage. Logout lewat sini
/// supaya Profile + router otomatis tahu user sudah jadi tamu.
///
/// keepAlive: sesi tidak boleh autoDispose saat pindah /login → / (gap
/// antar listener sempat cancel rebuild + sisakan cache isAuth:false).
final class AuthStatusNotifierProvider
    extends $AsyncNotifierProvider<AuthStatusNotifier, AuthStatusState> {
  /// Status auth global (reaktif) dari AuthTokenStorage. Logout lewat sini
  /// supaya Profile + router otomatis tahu user sudah jadi tamu.
  ///
  /// keepAlive: sesi tidak boleh autoDispose saat pindah /login → / (gap
  /// antar listener sempat cancel rebuild + sisakan cache isAuth:false).
  AuthStatusNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStatusNotifierHash();

  @$internal
  @override
  AuthStatusNotifier create() => AuthStatusNotifier();
}

String _$authStatusNotifierHash() =>
    r'aca0caacd1519040af7db05dacbc8905a312706b';

/// Status auth global (reaktif) dari AuthTokenStorage. Logout lewat sini
/// supaya Profile + router otomatis tahu user sudah jadi tamu.
///
/// keepAlive: sesi tidak boleh autoDispose saat pindah /login → / (gap
/// antar listener sempat cancel rebuild + sisakan cache isAuth:false).

abstract class _$AuthStatusNotifier extends $AsyncNotifier<AuthStatusState> {
  FutureOr<AuthStatusState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthStatusState>, AuthStatusState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthStatusState>, AuthStatusState>,
              AsyncValue<AuthStatusState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
