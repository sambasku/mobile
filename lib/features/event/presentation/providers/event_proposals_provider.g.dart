// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_proposals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventContributionApi)
final eventContributionApiProvider = EventContributionApiProvider._();

final class EventContributionApiProvider
    extends
        $FunctionalProvider<
          EventContributionApi,
          EventContributionApi,
          EventContributionApi
        >
    with $Provider<EventContributionApi> {
  EventContributionApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventContributionApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventContributionApiHash();

  @$internal
  @override
  $ProviderElement<EventContributionApi> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EventContributionApi create(Ref ref) {
    return eventContributionApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventContributionApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventContributionApi>(value),
    );
  }
}

String _$eventContributionApiHash() =>
    r'1ebf0acc666159581d227543faddddbf709ed6f6';

/// Daftar usulan acara milik user yang login.
///
/// Guest = state kosong (bukan error). Notifier, bukan setState, supaya
/// halaman bisa invalidate dari mana saja (mis. setelah notifikasi).

@ProviderFor(EventProposalsController)
final eventProposalsControllerProvider = EventProposalsControllerProvider._();

/// Daftar usulan acara milik user yang login.
///
/// Guest = state kosong (bukan error). Notifier, bukan setState, supaya
/// halaman bisa invalidate dari mana saja (mis. setelah notifikasi).
final class EventProposalsControllerProvider
    extends
        $AsyncNotifierProvider<
          EventProposalsController,
          List<EventContribution>
        > {
  /// Daftar usulan acara milik user yang login.
  ///
  /// Guest = state kosong (bukan error). Notifier, bukan setState, supaya
  /// halaman bisa invalidate dari mana saja (mis. setelah notifikasi).
  EventProposalsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventProposalsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventProposalsControllerHash();

  @$internal
  @override
  EventProposalsController create() => EventProposalsController();
}

String _$eventProposalsControllerHash() =>
    r'35b47eb38b4de8a2cee3b1c0aabb900c81871e7a';

/// Daftar usulan acara milik user yang login.
///
/// Guest = state kosong (bukan error). Notifier, bukan setState, supaya
/// halaman bisa invalidate dari mana saja (mis. setelah notifikasi).

abstract class _$EventProposalsController
    extends $AsyncNotifier<List<EventContribution>> {
  FutureOr<List<EventContribution>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<EventContribution>>,
              List<EventContribution>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<EventContribution>>,
                List<EventContribution>
              >,
              AsyncValue<List<EventContribution>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
