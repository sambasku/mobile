// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(voteRemoteDatasource)
final voteRemoteDatasourceProvider = VoteRemoteDatasourceProvider._();

final class VoteRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          VoteRemoteDatasource,
          VoteRemoteDatasource,
          VoteRemoteDatasource
        >
    with $Provider<VoteRemoteDatasource> {
  VoteRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voteRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voteRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<VoteRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VoteRemoteDatasource create(Ref ref) {
    return voteRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoteRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoteRemoteDatasource>(value),
    );
  }
}

String _$voteRemoteDatasourceHash() =>
    r'4be4068da357bba9acc51e7cc71d7a8a8da5cb42';

@ProviderFor(voteRepository)
final voteRepositoryProvider = VoteRepositoryProvider._();

final class VoteRepositoryProvider
    extends $FunctionalProvider<VoteRepository, VoteRepository, VoteRepository>
    with $Provider<VoteRepository> {
  VoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voteRepositoryHash();

  @$internal
  @override
  $ProviderElement<VoteRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VoteRepository create(Ref ref) {
    return voteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoteRepository>(value),
    );
  }
}

String _$voteRepositoryHash() => r'45c40a5dff01ccc2ee3085fee42a3f01250f255d';
