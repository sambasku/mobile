import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/network/failover/infra_failure.dart';
import '../../domain/failures/dictionary_failure.dart';
import 'lemma_data_source_kind.dart';
import 'lemma_sticky_store.dart';

bool _isBusinessFailureCode(String? code) {
  if (code == null || code.isEmpty) return false;
  return code == 'WORD_NOT_FOUND' ||
      code == 'NOT_FOUND' ||
      code == 'VALIDATION_ERROR' ||
      code == 'UNAUTHORIZED' ||
      code == 'FORBIDDEN' ||
      code == 'RATE_LIMITED' ||
      code == 'ALREADY_EXISTS';
}

/// Routing hybrid API → SQLite untuk baca korpus.
class LemmaHybridGate {
  LemmaHybridGate({
    required this.sticky,
    required this.isOffline,
    this.onSource,
  });

  final LemmaStickyStore sticky;
  final bool Function() isOffline;
  final void Function(LemmaDataSourceKind kind)? onSource;

  bool get preferLocal => isOffline() || sticky.isActive;

  Future<Either<DictionaryFailure, T>> read<T>({
    required Duration budget,
    required Future<Either<DictionaryFailure, T>> Function() remote,
    required Future<T?> Function() local,
    required String localUnavailableMessage,
    String localUnavailableCode = 'LOCAL_UNAVAILABLE',
  }) async {
    Future<Either<DictionaryFailure, T>> fromLocal() async {
      try {
        final value = await local();
        if (value == null) {
          return Either.left(
            DictionaryFailure(
              localUnavailableMessage,
              errorCode: localUnavailableCode,
            ),
          );
        }
        onSource?.call(LemmaDataSourceKind.local);
        return Either.right(value);
      } catch (_) {
        return Either.left(
          DictionaryFailure(
            localUnavailableMessage,
            errorCode: localUnavailableCode,
          ),
        );
      }
    }

    if (isOffline() || sticky.isActive) {
      return fromLocal();
    }

    try {
      final result = await remote().timeout(budget);
      return await result.match(
        (failure) async {
          if (_isBusinessFailureCode(failure.errorCode)) {
            return Either<DictionaryFailure, T>.left(failure);
          }
          sticky.activate();
          return fromLocal();
        },
        (value) async {
          sticky.clear();
          onSource?.call(LemmaDataSourceKind.remote);
          return Either<DictionaryFailure, T>.right(value);
        },
      );
    } on TimeoutException {
      sticky.activate();
      return fromLocal();
    } on DioException catch (e) {
      if (isInfraFailure(e)) {
        sticky.activate();
        return fromLocal();
      }
      final code = e.response?.data is Map
          ? (e.response!.data as Map)['error_code']?.toString()
          : null;
      if (_isBusinessFailureCode(code)) {
        return Either.left(
          DictionaryFailure(
            e.message ?? localUnavailableMessage,
            errorCode: code,
          ),
        );
      }
      sticky.activate();
      return fromLocal();
    } catch (_) {
      sticky.activate();
      return fromLocal();
    }
  }
}
