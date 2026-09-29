// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_reset_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthResetNotifier)
final authResetProvider = AuthResetNotifierProvider._();

final class AuthResetNotifierProvider
    extends $NotifierProvider<AuthResetNotifier, AuthResetState> {
  AuthResetNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authResetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authResetNotifierHash();

  @$internal
  @override
  AuthResetNotifier create() => AuthResetNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthResetState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthResetState>(value),
    );
  }
}

String _$authResetNotifierHash() => r'4bfd48cc3ef5d60356cb2854d2eb8f0d4a68c75c';

abstract class _$AuthResetNotifier extends $Notifier<AuthResetState> {
  AuthResetState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthResetState, AuthResetState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthResetState, AuthResetState>,
              AuthResetState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
