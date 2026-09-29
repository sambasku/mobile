// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_account_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeleteAccountNotifier)
final deleteAccountProvider = DeleteAccountNotifierProvider._();

final class DeleteAccountNotifierProvider
    extends $NotifierProvider<DeleteAccountNotifier, DeleteAccountState> {
  DeleteAccountNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteAccountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteAccountNotifierHash();

  @$internal
  @override
  DeleteAccountNotifier create() => DeleteAccountNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteAccountState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteAccountState>(value),
    );
  }
}

String _$deleteAccountNotifierHash() =>
    r'f69cbf0426ac0db3aec39c8aa0468201533e82d1';

abstract class _$DeleteAccountNotifier extends $Notifier<DeleteAccountState> {
  DeleteAccountState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DeleteAccountState, DeleteAccountState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DeleteAccountState, DeleteAccountState>,
              DeleteAccountState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
