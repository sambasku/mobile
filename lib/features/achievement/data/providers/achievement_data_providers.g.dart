// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(achievementRemoteDatasource)
final achievementRemoteDatasourceProvider =
    AchievementRemoteDatasourceProvider._();

final class AchievementRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          AchievementRemoteDatasource,
          AchievementRemoteDatasource,
          AchievementRemoteDatasource
        >
    with $Provider<AchievementRemoteDatasource> {
  AchievementRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<AchievementRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AchievementRemoteDatasource create(Ref ref) {
    return achievementRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AchievementRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AchievementRemoteDatasource>(value),
    );
  }
}

String _$achievementRemoteDatasourceHash() =>
    r'47e92fa518b9f8fac066e5bac9bfdccdb18e9d08';

@ProviderFor(achievementRepository)
final achievementRepositoryProvider = AchievementRepositoryProvider._();

final class AchievementRepositoryProvider
    extends
        $FunctionalProvider<
          AchievementRepository,
          AchievementRepository,
          AchievementRepository
        >
    with $Provider<AchievementRepository> {
  AchievementRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementRepositoryHash();

  @$internal
  @override
  $ProviderElement<AchievementRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AchievementRepository create(Ref ref) {
    return achievementRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AchievementRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AchievementRepository>(value),
    );
  }
}

String _$achievementRepositoryHash() =>
    r'9ff248382f48faf7181a51ee5989b19cd91f3b23';
