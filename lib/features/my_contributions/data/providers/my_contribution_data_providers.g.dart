// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_contribution_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myContributionRepository)
final myContributionRepositoryProvider = MyContributionRepositoryProvider._();

final class MyContributionRepositoryProvider
    extends
        $FunctionalProvider<
          MyContributionRepository,
          MyContributionRepository,
          MyContributionRepository
        >
    with $Provider<MyContributionRepository> {
  MyContributionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myContributionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myContributionRepositoryHash();

  @$internal
  @override
  $ProviderElement<MyContributionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MyContributionRepository create(Ref ref) {
    return myContributionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MyContributionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MyContributionRepository>(value),
    );
  }
}

String _$myContributionRepositoryHash() =>
    r'f79345a4bb284d40dcf20451b10e564d45f793ed';
