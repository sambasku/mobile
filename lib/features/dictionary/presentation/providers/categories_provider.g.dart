// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Kategori/glosarium untuk filter A-Z (#50).

@ProviderFor(categories)
final categoriesProvider = CategoriesProvider._();

/// Kategori/glosarium untuk filter A-Z (#50).

final class CategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WordCategory>>,
          List<WordCategory>,
          FutureOr<List<WordCategory>>
        >
    with
        $FutureModifier<List<WordCategory>>,
        $FutureProvider<List<WordCategory>> {
  /// Kategori/glosarium untuk filter A-Z (#50).
  CategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<WordCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WordCategory>> create(Ref ref) {
    return categories(ref);
  }
}

String _$categoriesHash() => r'fdec97eab059989978db049871be71bd1bb4e53d';
