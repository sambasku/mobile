// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_domain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(toggleBookmarkUseCase)
final toggleBookmarkUseCaseProvider = ToggleBookmarkUseCaseProvider._();

final class ToggleBookmarkUseCaseProvider
    extends
        $FunctionalProvider<
          ToggleBookmarkUseCase,
          ToggleBookmarkUseCase,
          ToggleBookmarkUseCase
        >
    with $Provider<ToggleBookmarkUseCase> {
  ToggleBookmarkUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'toggleBookmarkUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$toggleBookmarkUseCaseHash();

  @$internal
  @override
  $ProviderElement<ToggleBookmarkUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ToggleBookmarkUseCase create(Ref ref) {
    return toggleBookmarkUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToggleBookmarkUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToggleBookmarkUseCase>(value),
    );
  }
}

String _$toggleBookmarkUseCaseHash() =>
    r'4c8c72e58d218dba7355524ee775ca60e5ecee73';

@ProviderFor(getMyBookmarksUseCase)
final getMyBookmarksUseCaseProvider = GetMyBookmarksUseCaseProvider._();

final class GetMyBookmarksUseCaseProvider
    extends
        $FunctionalProvider<
          GetMyBookmarksUseCase,
          GetMyBookmarksUseCase,
          GetMyBookmarksUseCase
        >
    with $Provider<GetMyBookmarksUseCase> {
  GetMyBookmarksUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getMyBookmarksUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getMyBookmarksUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetMyBookmarksUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetMyBookmarksUseCase create(Ref ref) {
    return getMyBookmarksUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetMyBookmarksUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetMyBookmarksUseCase>(value),
    );
  }
}

String _$getMyBookmarksUseCaseHash() =>
    r'1bd5bccd429fe59091d8917726a6fac31a7ec1d0';

@ProviderFor(getBookmarkStatusesUseCase)
final getBookmarkStatusesUseCaseProvider =
    GetBookmarkStatusesUseCaseProvider._();

final class GetBookmarkStatusesUseCaseProvider
    extends
        $FunctionalProvider<
          GetBookmarkStatusesUseCase,
          GetBookmarkStatusesUseCase,
          GetBookmarkStatusesUseCase
        >
    with $Provider<GetBookmarkStatusesUseCase> {
  GetBookmarkStatusesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getBookmarkStatusesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getBookmarkStatusesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetBookmarkStatusesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetBookmarkStatusesUseCase create(Ref ref) {
    return getBookmarkStatusesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetBookmarkStatusesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetBookmarkStatusesUseCase>(value),
    );
  }
}

String _$getBookmarkStatusesUseCaseHash() =>
    r'3ac2c25c3662fdf37bb676375f99880ad7a9bda0';
