// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_contribution_domain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(listMyContributionsUseCase)
final listMyContributionsUseCaseProvider =
    ListMyContributionsUseCaseProvider._();

final class ListMyContributionsUseCaseProvider
    extends
        $FunctionalProvider<
          ListMyContributionsUseCase,
          ListMyContributionsUseCase,
          ListMyContributionsUseCase
        >
    with $Provider<ListMyContributionsUseCase> {
  ListMyContributionsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listMyContributionsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listMyContributionsUseCaseHash();

  @$internal
  @override
  $ProviderElement<ListMyContributionsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ListMyContributionsUseCase create(Ref ref) {
    return listMyContributionsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListMyContributionsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListMyContributionsUseCase>(value),
    );
  }
}

String _$listMyContributionsUseCaseHash() =>
    r'608cede003a2140ff3693241cf1e6006d7f0004a';

@ProviderFor(getMyContributionDetailUseCase)
final getMyContributionDetailUseCaseProvider =
    GetMyContributionDetailUseCaseProvider._();

final class GetMyContributionDetailUseCaseProvider
    extends
        $FunctionalProvider<
          GetMyContributionDetailUseCase,
          GetMyContributionDetailUseCase,
          GetMyContributionDetailUseCase
        >
    with $Provider<GetMyContributionDetailUseCase> {
  GetMyContributionDetailUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getMyContributionDetailUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getMyContributionDetailUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetMyContributionDetailUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetMyContributionDetailUseCase create(Ref ref) {
    return getMyContributionDetailUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetMyContributionDetailUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetMyContributionDetailUseCase>(
        value,
      ),
    );
  }
}

String _$getMyContributionDetailUseCaseHash() =>
    r'65eb9008c360e5c7fdcc37dae804da669c87027c';
