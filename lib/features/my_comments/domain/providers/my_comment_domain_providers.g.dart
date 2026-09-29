// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_comment_domain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(listMyCommentsUseCase)
final listMyCommentsUseCaseProvider = ListMyCommentsUseCaseProvider._();

final class ListMyCommentsUseCaseProvider
    extends
        $FunctionalProvider<
          ListMyCommentsUseCase,
          ListMyCommentsUseCase,
          ListMyCommentsUseCase
        >
    with $Provider<ListMyCommentsUseCase> {
  ListMyCommentsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listMyCommentsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listMyCommentsUseCaseHash();

  @$internal
  @override
  $ProviderElement<ListMyCommentsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ListMyCommentsUseCase create(Ref ref) {
    return listMyCommentsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListMyCommentsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListMyCommentsUseCase>(value),
    );
  }
}

String _$listMyCommentsUseCaseHash() =>
    r'a09305d130e7e94d597d9786be483b0a7f500368';
