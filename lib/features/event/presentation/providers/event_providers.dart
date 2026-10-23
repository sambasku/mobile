import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/event_remote_datasource.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../domain/entities/event.dart';

part 'event_providers.g.dart';

@riverpod
EventRemoteDatasource eventRemoteDatasource(Ref ref) =>
    EventRemoteDatasource(ref.watch(dioProvider));

@riverpod
EventRepositoryImpl eventRepository(Ref ref) =>
    EventRepositoryImpl(ref.watch(eventRemoteDatasourceProvider));

/// Detail acara by slug. Null = 404 atau offline.
@riverpod
Future<Event?> eventBySlug(Ref ref, String slug) =>
    ref.watch(eventRepositoryProvider).getBySlug(slug);

/// Katalog kategori acara (published). Kosong = API gagal atau belum ada.
@riverpod
Future<List<EventCategoryRef>> eventCategories(Ref ref) =>
    ref.watch(eventRepositoryProvider).categories();

/// Agenda acara untuk satu tempat wisata (`?place_id=`).
///
/// Dipakai di detail wisata. Null = offline/error - section disembunyikan.
@riverpod
Future<List<Event>> eventsForPlace(Ref ref, String placeId) async {
  final page = await ref.watch(eventRepositoryProvider).listPage(
    placeId: placeId,
    notEnded: true,
    order: 'asc',
    limit: 10,
  );
  return page.events;
}

/// Agenda acara untuk satu desa (`?village_id=`).
///
/// Dipakai di detail desa. Null = offline/error - section disembunyikan.
@riverpod
Future<List<Event>> eventsForVillage(Ref ref, String villageId) async {
  final page = await ref.watch(eventRepositoryProvider).listPage(
    villageId: villageId,
    notEnded: true,
    order: 'asc',
    limit: 10,
  );
  return page.events;
}
