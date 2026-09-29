// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_vote_domain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(listMyVotesUseCase)
final listMyVotesUseCaseProvider = ListMyVotesUseCaseProvider._();

final class ListMyVotesUseCaseProvider
    extends
        $FunctionalProvider<
          ListMyVotesUseCase,
          ListMyVotesUseCase,
          ListMyVotesUseCase
        >
    with $Provider<ListMyVotesUseCase> {
  ListMyVotesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listMyVotesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listMyVotesUseCaseHash();

  @$internal
  @override
  $ProviderElement<ListMyVotesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ListMyVotesUseCase create(Ref ref) {
    return listMyVotesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListMyVotesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListMyVotesUseCase>(value),
    );
  }
}

String _$listMyVotesUseCaseHash() =>
    r'05138d2dba7f36cb0057acc6172bc2556b42a840';
