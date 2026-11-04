import 'dart:io';

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

  Future<({List<UsahaImage> items, int total, int? nextOffset})> imagePage(
    String slug, {
    int offset = 0,
  }) =>
      _datasource.fetchImagePage(slug, offset: offset);

  Future<void> appendImages(String slug, List<String> urls) =>
      _datasource.appendImages(slug, urls);

  Future<String> uploadImage(File file) => _datasource.uploadImage(file);
}
