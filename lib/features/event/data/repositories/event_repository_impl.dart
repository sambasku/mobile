import '../../domain/entities/event.dart';
import '../datasources/event_remote_datasource.dart';

/// Repository katalog acara (API publik).
///
/// Error apa pun dilempar ke caller (halaman yang menampilkan state
/// error). Tidak ada cache lokal: acara berubah cepat, jadi daftar
/// yang disimpan basi sebelum sempat dipakai.
class EventRepositoryImpl {
  EventRepositoryImpl(this._datasource);

  final EventRemoteDatasource _datasource;

  Future<EventPage> listPage({
    int limit = eventsPageSize,
    String? before,
    String? categoryId,
    String? villageId,
    String? regionId,
    String? placeId,
    String? q,
    bool notEnded = false,
    String? order,
  }) {
    return _datasource.fetchPage(
      limit: limit,
      before: before,
      categoryId: categoryId,
      villageId: villageId,
      regionId: regionId,
      placeId: placeId,
      q: q,
      notEnded: notEnded,
      order: order,
    );
  }

  Future<Event?> getBySlug(String slug) => _datasource.fetchBySlug(slug);

  Future<List<EventCategoryRef>> categories() => _datasource.fetchCategories();
}
