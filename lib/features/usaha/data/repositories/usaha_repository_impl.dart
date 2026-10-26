import '../../domain/entities/usaha.dart';
import '../datasources/usaha_remote_datasource.dart';

/// Repository katalog usaha (API publik). Tanpa cache lokal: data usaha
/// dikoreksi cepat, cache akan sajikan info usang.
class UsahaRepositoryImpl {
  UsahaRepositoryImpl(this._datasource);

  final UsahaRemoteDatasource _datasource;

  Future<UsahaPage> listPage({
    int limit = usahasPageSize,
    String? before,
    String? categoryId,
    String? regionId,
    String? villageId,
    String? kind,
    String? operationalStatus,
    String? q,
  }) {
    return _datasource.fetchPage(
      limit: limit,
      before: before,
      categoryId: categoryId,
      regionId: regionId,
      villageId: villageId,
      kind: kind,
      operationalStatus: operationalStatus,
      q: q,
    );
  }

  Future<Usaha?> getBySlug(String slug) => _datasource.fetchBySlug(slug);

  Future<List<UsahaCategoryRef>> categories() => _datasource.fetchCategories();

  Future<UsahaMine> mine() => _datasource.fetchMine();
}
