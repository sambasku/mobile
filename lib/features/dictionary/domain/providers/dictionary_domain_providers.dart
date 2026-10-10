import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/dictionary_data_providers.dart';
import '../usecases/get_word_by_id_use_case.dart';
import '../usecases/get_word_by_lemma_use_case.dart';
import '../usecases/get_word_of_day_use_case.dart';
import '../usecases/list_categories_use_case.dart';
import '../usecases/list_latest_words_use_case.dart';
import '../usecases/list_words_use_case.dart';
import '../usecases/search_words_use_case.dart';

part 'dictionary_domain_providers.g.dart';

@riverpod
SearchWordsUseCase searchWordsUseCase(Ref ref) =>
    SearchWordsUseCase(ref.watch(dictionaryRepositoryProvider));

@riverpod
ListWordsUseCase listWordsUseCase(Ref ref) =>
    ListWordsUseCase(ref.watch(dictionaryRepositoryProvider));

@riverpod
ListLatestWordsUseCase listLatestWordsUseCase(Ref ref) =>
    ListLatestWordsUseCase(ref.watch(dictionaryRepositoryProvider));

@riverpod
GetWordByIdUseCase getWordByIdUseCase(Ref ref) =>
    GetWordByIdUseCase(ref.watch(dictionaryRepositoryProvider));

@riverpod
GetWordByLemmaUseCase getWordByLemmaUseCase(Ref ref) =>
    GetWordByLemmaUseCase(ref.watch(dictionaryRepositoryProvider));

@riverpod
GetWordOfDayUseCase getWordOfDayUseCase(Ref ref) =>
    GetWordOfDayUseCase(ref.watch(dictionaryRepositoryProvider));

@riverpod
ListCategoriesUseCase listCategoriesUseCase(Ref ref) =>
    ListCategoriesUseCase(ref.watch(dictionaryRepositoryProvider));
