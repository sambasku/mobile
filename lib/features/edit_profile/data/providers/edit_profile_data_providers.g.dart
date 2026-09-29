// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_profile_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(editProfileRemoteDatasource)
final editProfileRemoteDatasourceProvider =
    EditProfileRemoteDatasourceProvider._();

final class EditProfileRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          EditProfileRemoteDatasource,
          EditProfileRemoteDatasource,
          EditProfileRemoteDatasource
        >
    with $Provider<EditProfileRemoteDatasource> {
  EditProfileRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editProfileRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editProfileRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<EditProfileRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EditProfileRemoteDatasource create(Ref ref) {
    return editProfileRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditProfileRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditProfileRemoteDatasource>(value),
    );
  }
}

String _$editProfileRemoteDatasourceHash() =>
    r'e9ea0235ee725efc232576fc97ae28bfa4b4b168';

@ProviderFor(editProfileRepository)
final editProfileRepositoryProvider = EditProfileRepositoryProvider._();

final class EditProfileRepositoryProvider
    extends
        $FunctionalProvider<
          EditProfileRepository,
          EditProfileRepository,
          EditProfileRepository
        >
    with $Provider<EditProfileRepository> {
  EditProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editProfileRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editProfileRepositoryHash();

  @$internal
  @override
  $ProviderElement<EditProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EditProfileRepository create(Ref ref) {
    return editProfileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditProfileRepository>(value),
    );
  }
}

String _$editProfileRepositoryHash() =>
    r'4353bee13a74edd2a2b70cbef710803ac4e69122';
