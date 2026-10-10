import 'package:fpdart/fpdart.dart';

import '../entities/word_detail.dart';
import '../failures/dictionary_failure.dart';
import '../repositories/dictionary_repository.dart';

/// Daftar kategori/glosarium (GET /api/v1/categories) untuk filter
/// browse A-Z (#50).
class ListCategoriesUseCase {
  const ListCategoriesUseCase(this._repository);

  final DictionaryRepository _repository;

  Future<Either<DictionaryFailure, List<WordCategory>>> call() =>
      _repository.listCategories();
}