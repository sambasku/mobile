// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_guide_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider prefs ter-inject (test bisa override dengan SharedPreferences.setMockInitialValues).

@ProviderFor(contributionGuidePrefs)
final contributionGuidePrefsProvider = ContributionGuidePrefsProvider._();

/// Provider prefs ter-inject (test bisa override dengan SharedPreferences.setMockInitialValues).

final class ContributionGuidePrefsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferences>,
          SharedPreferences,
          FutureOr<SharedPreferences>
        >
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  /// Provider prefs ter-inject (test bisa override dengan SharedPreferences.setMockInitialValues).
  ContributionGuidePrefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contributionGuidePrefsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contributionGuidePrefsHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return contributionGuidePrefs(ref);
  }
}

String _$contributionGuidePrefsHash() =>
    r'32a4437a8520ecd6311a617ff1dcffa85c7e5119';

/// Apakah guide swipe tab Kontribusi masih perlu ditampilkan.
///
/// Unread = belum ada flag lokal DAN flag server false. Tamu (belum login)
/// dianggap unread: sheet hanya tips UI, aman tampil.

@ProviderFor(contributionGuideUnread)
final contributionGuideUnreadProvider = ContributionGuideUnreadProvider._();

/// Apakah guide swipe tab Kontribusi masih perlu ditampilkan.
///
/// Unread = belum ada flag lokal DAN flag server false. Tamu (belum login)
/// dianggap unread: sheet hanya tips UI, aman tampil.

final class ContributionGuideUnreadProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Apakah guide swipe tab Kontribusi masih perlu ditampilkan.
  ///
  /// Unread = belum ada flag lokal DAN flag server false. Tamu (belum login)
  /// dianggap unread: sheet hanya tips UI, aman tampil.
  ContributionGuideUnreadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contributionGuideUnreadProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contributionGuideUnreadHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return contributionGuideUnread(ref);
  }
}

String _$contributionGuideUnreadHash() =>
    r'05efa2a869275b40253d4ec0a4988d96d82f51fc';
