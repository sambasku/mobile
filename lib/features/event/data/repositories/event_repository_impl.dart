import '../../domain/entities/event.dart';
import '../../domain/entities/event_comment.dart';
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
    DateTime? overlapsFrom,
    DateTime? overlapsTo,
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
      overlapsFrom: overlapsFrom,
      overlapsTo: overlapsTo,
    );
  }

  Future<Event?> getBySlug(String slug) => _datasource.fetchBySlug(slug);

  Future<({int goingCount, bool viewerGoing})> markGoing(String eventId) =>
      _datasource.markGoing(eventId);

  Future<({int goingCount, bool viewerGoing})> unmarkGoing(String eventId) =>
      _datasource.unmarkGoing(eventId);

  Future<List<EventCategoryRef>> categories() => _datasource.fetchCategories();

  Future<EventCommentPage> getComments(
    String eventId, {
    int limit = 20,
    String? cursor,
  }) => _datasource.fetchComments(eventId, limit: limit, cursor: cursor);

  Future<EventComment?> postComment(String eventId, String body) =>
      _datasource.postComment(eventId, body);

  Future<EventComment?> updateComment(String commentId, String body) =>
      _datasource.updateComment(commentId, body);

  Future<void> deleteComment(String commentId) =>
      _datasource.deleteComment(commentId);
}
