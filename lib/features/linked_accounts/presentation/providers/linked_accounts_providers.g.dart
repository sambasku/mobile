// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linked_accounts_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LinkedAccountsNotifier)
final linkedAccountsProvider = LinkedAccountsNotifierProvider._();

final class LinkedAccountsNotifierProvider
    extends $NotifierProvider<LinkedAccountsNotifier, LinkedAccountsState> {
  LinkedAccountsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkedAccountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkedAccountsNotifierHash();

  @$internal
  @override
  LinkedAccountsNotifier create() => LinkedAccountsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkedAccountsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkedAccountsState>(value),
    );
  }
}

String _$linkedAccountsNotifierHash() =>
    r'f03d227c5263634de5f8bbfe30d6e60c901fbbeb';

abstract class _$LinkedAccountsNotifier extends $Notifier<LinkedAccountsState> {
  LinkedAccountsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LinkedAccountsState, LinkedAccountsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LinkedAccountsState, LinkedAccountsState>,
              LinkedAccountsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
