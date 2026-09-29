import 'package:fpdart/fpdart.dart';

import '../entities/word_detail.dart';
import '../entities/word_of_day.dart';
import '../entities/word_summary.dart';
import '../failures/dictionary_failure.dart';

abstract interface class DictionaryRepository {
  /// Pencarian kata (cursor-based). [searchIn] 'lemma' = Sambas->Indonesia
  /// (default), 'translation' = Indonesia->Sambas (reverse).
  Future<Either<DictionaryFailure, WordSearchPage>> searchWords({
    required String query,
    required int limit,
    String? cursor,
    String searchIn = 'lemma',
  });

  /// Detail kata by id. 404 WORD_NOT_FOUND → Failure.
  /// [forceRefresh] = hard miss L1 (pull-to-refresh).
  Future<Either<DictionaryFailure, WordDetail>> getWordById(
    String id, {
    bool forceRefresh = false,
  });

  /// Detail kata published by lemma (URL publik web / deep link).
  /// [forceRefresh] = hard miss L1 (pull-to-refresh).
  Future<Either<DictionaryFailure, WordDetail>> getWordByLemma(
    String lemma, {
    bool forceRefresh = false,
  });

  /// Kata hari ini. Right(null) = korpus published kosong (bukan error).
  /// [forceRefresh] = hard miss L1 (pull-to-refresh).
  Future<Either<DictionaryFailure, WordOfDay?>> getWordOfDay({
    bool forceRefresh = false,
  });

  /// Daftar semua kata A-Z (18-api-list-words.md). Cursor komposit
  /// opaque; [q] = filter contains server-side; [letter] = prefix A-Z;
  /// [isVerified] diteruskan ke query bila diisi (browse huruf = true).
  Future<Either<DictionaryFailure, WordSearchPage>> listWords({
    required String q,
    required int limit,
    String? cursor,
    String? letter,
    bool? isVerified,
  });

  /// Feed beranda: kata published urut waktu persetujuan.
  /// [forceRefresh] = hard miss L1 untuk halaman pertama (pull-to-refresh).
  Future<Either<DictionaryFailure, WordSearchPage>> listLatest({
    required int limit,
    String? cursor,
    bool forceRefresh = false,
  });
}
