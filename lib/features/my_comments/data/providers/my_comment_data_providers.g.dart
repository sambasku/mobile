// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_comment_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myCommentRepository)
final myCommentRepositoryProvider = MyCommentRepositoryProvider._();

final class MyCommentRepositoryProvider
    extends
        $FunctionalProvider<
          MyCommentRepository,
          MyCommentRepository,
          MyCommentRepository
        >
    with $Provider<MyCommentRepository> {
  MyCommentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myCommentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myCommentRepositoryHash();

  @$internal
  @override
  $ProviderElement<MyCommentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MyCommentRepository create(Ref ref) {
    return myCommentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MyCommentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MyCommentRepository>(value),
    );
  }
}

String _$myCommentRepositoryHash() =>
    r'1d313f8a1e86cd5d57cea143513b6e5646aa798e';
