// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventRemoteDatasource)
final eventRemoteDatasourceProvider = EventRemoteDatasourceProvider._();

final class EventRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          EventRemoteDatasource,
          EventRemoteDatasource,
          EventRemoteDatasource
        >
    with $Provider<EventRemoteDatasource> {
  EventRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<EventRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EventRemoteDatasource create(Ref ref) {
    return eventRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventRemoteDatasource>(value),
    );
  }
}

String _$eventRemoteDatasourceHash() =>
    r'37e72128b1a2e727d5e8c9f880051fabc39b13a6';

@ProviderFor(eventRepository)
final eventRepositoryProvider = EventRepositoryProvider._();

final class EventRepositoryProvider
    extends
        $FunctionalProvider<
          EventRepositoryImpl,
          EventRepositoryImpl,
          EventRepositoryImpl
        >
    with $Provider<EventRepositoryImpl> {
  EventRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventRepositoryHash();

  @$internal
  @override
  $ProviderElement<EventRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EventRepositoryImpl create(Ref ref) {
    return eventRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventRepositoryImpl>(value),
    );
  }
}

String _$eventRepositoryHash() => r'2b007e3715ef04b48be7a6e420f5c5bf13c348d2';

/// Detail acara by slug. Null = 404 atau offline.

@ProviderFor(eventBySlug)
final eventBySlugProvider = EventBySlugFamily._();

/// Detail acara by slug. Null = 404 atau offline.

final class EventBySlugProvider
    extends $FunctionalProvider<AsyncValue<Event?>, Event?, FutureOr<Event?>>
    with $FutureModifier<Event?>, $FutureProvider<Event?> {
  /// Detail acara by slug. Null = 404 atau offline.
  EventBySlugProvider._({
    required EventBySlugFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventBySlugProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventBySlugHash();

  @override
  String toString() {
    return r'eventBySlugProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Event?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Event?> create(Ref ref) {
    final argument = this.argument as String;
    return eventBySlug(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventBySlugProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventBySlugHash() => r'6edc6d25d1f6cfc0dc1127ffd756b73accbd7588';

/// Detail acara by slug. Null = 404 atau offline.

final class EventBySlugFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Event?>, String> {
  EventBySlugFamily._()
    : super(
        retry: null,
        name: r'eventBySlugProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Detail acara by slug. Null = 404 atau offline.

  EventBySlugProvider call(String slug) =>
      EventBySlugProvider._(argument: slug, from: this);

  @override
  String toString() => r'eventBySlugProvider';
}

/// Katalog kategori acara (published). Kosong = API gagal atau belum ada.

@ProviderFor(eventCategories)
final eventCategoriesProvider = EventCategoriesProvider._();

/// Katalog kategori acara (published). Kosong = API gagal atau belum ada.

final class EventCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventCategoryRef>>,
          List<EventCategoryRef>,
          FutureOr<List<EventCategoryRef>>
        >
    with
        $FutureModifier<List<EventCategoryRef>>,
        $FutureProvider<List<EventCategoryRef>> {
  /// Katalog kategori acara (published). Kosong = API gagal atau belum ada.
  EventCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<EventCategoryRef>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EventCategoryRef>> create(Ref ref) {
    return eventCategories(ref);
  }
}

String _$eventCategoriesHash() => r'4ef99d511930c3be3d086a2be1ad42e7405004b7';

/// Agenda acara untuk satu tempat wisata (`?place_id=`).
///
/// Dipakai di detail wisata. Null = offline/error - section disembunyikan.

@ProviderFor(eventsForPlace)
final eventsForPlaceProvider = EventsForPlaceFamily._();

/// Agenda acara untuk satu tempat wisata (`?place_id=`).
///
/// Dipakai di detail wisata. Null = offline/error - section disembunyikan.

final class EventsForPlaceProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Event>>,
          List<Event>,
          FutureOr<List<Event>>
        >
    with $FutureModifier<List<Event>>, $FutureProvider<List<Event>> {
  /// Agenda acara untuk satu tempat wisata (`?place_id=`).
  ///
  /// Dipakai di detail wisata. Null = offline/error - section disembunyikan.
  EventsForPlaceProvider._({
    required EventsForPlaceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventsForPlaceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventsForPlaceHash();

  @override
  String toString() {
    return r'eventsForPlaceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Event>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Event>> create(Ref ref) {
    final argument = this.argument as String;
    return eventsForPlace(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventsForPlaceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventsForPlaceHash() => r'0cef581dfe25f81a7a5620b1cef45ef9e54025dc';

/// Agenda acara untuk satu tempat wisata (`?place_id=`).
///
/// Dipakai di detail wisata. Null = offline/error - section disembunyikan.

final class EventsForPlaceFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Event>>, String> {
  EventsForPlaceFamily._()
    : super(
        retry: null,
        name: r'eventsForPlaceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Agenda acara untuk satu tempat wisata (`?place_id=`).
  ///
  /// Dipakai di detail wisata. Null = offline/error - section disembunyikan.

  EventsForPlaceProvider call(String placeId) =>
      EventsForPlaceProvider._(argument: placeId, from: this);

  @override
  String toString() => r'eventsForPlaceProvider';
}

/// Agenda acara untuk satu desa (`?village_id=`).
///
/// Dipakai di detail desa. Null = offline/error - section disembunyikan.

@ProviderFor(eventsForVillage)
final eventsForVillageProvider = EventsForVillageFamily._();

/// Agenda acara untuk satu desa (`?village_id=`).
///
/// Dipakai di detail desa. Null = offline/error - section disembunyikan.

final class EventsForVillageProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Event>>,
          List<Event>,
          FutureOr<List<Event>>
        >
    with $FutureModifier<List<Event>>, $FutureProvider<List<Event>> {
  /// Agenda acara untuk satu desa (`?village_id=`).
  ///
  /// Dipakai di detail desa. Null = offline/error - section disembunyikan.
  EventsForVillageProvider._({
    required EventsForVillageFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventsForVillageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventsForVillageHash();

  @override
  String toString() {
    return r'eventsForVillageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Event>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Event>> create(Ref ref) {
    final argument = this.argument as String;
    return eventsForVillage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventsForVillageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventsForVillageHash() => r'4743143eab023fca2f5805f6069f62abb2668b31';

/// Agenda acara untuk satu desa (`?village_id=`).
///
/// Dipakai di detail desa. Null = offline/error - section disembunyikan.

final class EventsForVillageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Event>>, String> {
  EventsForVillageFamily._()
    : super(
        retry: null,
        name: r'eventsForVillageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Agenda acara untuk satu desa (`?village_id=`).
  ///
  /// Dipakai di detail desa. Null = offline/error - section disembunyikan.

  EventsForVillageProvider call(String villageId) =>
      EventsForVillageProvider._(argument: villageId, from: this);

  @override
  String toString() => r'eventsForVillageProvider';
}
