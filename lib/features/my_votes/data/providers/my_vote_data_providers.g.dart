// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_vote_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myVoteRepository)
final myVoteRepositoryProvider = MyVoteRepositoryProvider._();

final class MyVoteRepositoryProvider
    extends
        $FunctionalProvider<
          MyVoteRepository,
          MyVoteRepository,
          MyVoteRepository
        >
    with $Provider<MyVoteRepository> {
  MyVoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myVoteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myVoteRepositoryHash();

  @$internal
  @override
  $ProviderElement<MyVoteRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MyVoteRepository create(Ref ref) {
    return myVoteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MyVoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MyVoteRepository>(value),
    );
  }
}

String _$myVoteRepositoryHash() => r'4d8a2facc1cd602827ae0ed2561e105b5b72091f';
