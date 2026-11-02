import '../../domain/entities/cuisine.dart';
import '../datasources/cuisine_remote_datasource.dart';
import '../models/cuisine_dto.dart';

/// Repository katalog kuliner (API publik). Tanpa cache lokal: data
/// kuliner dikoreksi cepat lewat moderasi, cache akan sajikan info usang.
class CuisineRepositoryImpl {
  CuisineRepositoryImpl(this._datasource);

  final CuisineRemoteDatasource _datasource;

  Future<CuisinePage> listPage({
    int limit = cuisinesPageSize,
    String? before,
    String? categoryId,
    String? q,
  }) => _datasource.fetchPage(
    limit: limit,
    before: before,
    categoryId: categoryId,
    q: q,
  );

  Future<CuisineDtoItem?> getBySlug(String slug) => _datasource.fetchBySlug(slug);

  Future<CulinaryPlacePage> places({
    int limit = cuisinesPageSize,
    String? before,
    String? q,
    String? type,
    String? operationalStatus,
  }) => _datasource.fetchPlaces(
    limit: limit,
    before: before,
    q: q,
    type: type,
    operationalStatus: operationalStatus,
  );

  /// Seluruh kuliner (maks [cuisinesMaxPages] halaman) - dipakai halaman
  /// list yang masih filter client-side.
  Future<List<Cuisine>> getAll({String? q}) async {
    final items = <Cuisine>[];
    String? cursor;
    for (var page = 0; page < cuisinesMaxPages; page++) {
      final result = await listPage(before: cursor, q: q);
      items.addAll(result.items.map((e) => e.toEntity()));
      cursor = result.nextCursor;
      if (cursor == null) break;
    }
    return items;
  }
}
