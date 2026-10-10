import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/word_detail.dart';
import '../../domain/providers/dictionary_domain_providers.dart';

part 'categories_provider.g.dart';

/// Kategori/glosarium untuk filter A-Z (#50).
@riverpod
Future<List<WordCategory>> categories(Ref ref) async {
  final result = await ref.watch(listCategoriesUseCaseProvider).call();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (categories) => categories,
  );
}