// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(commentRemoteDatasource)
final commentRemoteDatasourceProvider = CommentRemoteDatasourceProvider._();

final class CommentRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          CommentRemoteDatasource,
          CommentRemoteDatasource,
          CommentRemoteDatasource
        >
    with $Provider<CommentRemoteDatasource> {
  CommentRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commentRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commentRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<CommentRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CommentRemoteDatasource create(Ref ref) {
    return commentRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentRemoteDatasource>(value),
    );
  }
}

String _$commentRemoteDatasourceHash() =>
    r'78a32303bca4a24830821231b96a2dfd7247d617';

@ProviderFor(commentRepository)
final commentRepositoryProvider = CommentRepositoryProvider._();

final class CommentRepositoryProvider
    extends
        $FunctionalProvider<
          CommentRepository,
          CommentRepository,
          CommentRepository
        >
    with $Provider<CommentRepository> {
  CommentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commentRepositoryHash();

  @$internal
  @override
  $ProviderElement<CommentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CommentRepository create(Ref ref) {
    return commentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentRepository>(value),
    );
  }
}

String _$commentRepositoryHash() => r'3de8eb3100e01fe2100ed8a4b8f8d924e92d55f5';
