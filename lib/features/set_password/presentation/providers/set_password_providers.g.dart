// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_password_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SetPasswordNotifier)
final setPasswordProvider = SetPasswordNotifierProvider._();

final class SetPasswordNotifierProvider
    extends $NotifierProvider<SetPasswordNotifier, SetPasswordState> {
  SetPasswordNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setPasswordProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setPasswordNotifierHash();

  @$internal
  @override
  SetPasswordNotifier create() => SetPasswordNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetPasswordState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetPasswordState>(value),
    );
  }
}

String _$setPasswordNotifierHash() =>
    r'4b7aa49d6756b8af5f838653936adf7654f10b62';

abstract class _$SetPasswordNotifier extends $Notifier<SetPasswordState> {
  SetPasswordState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SetPasswordState, SetPasswordState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SetPasswordState, SetPasswordState>,
              SetPasswordState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
