import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/i18n/l10n.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../domain/entities/exploration_proposal.dart';
import '../../domain/failures/review_failure.dart';
import '../../domain/repositories/exploration_review_repository.dart';
import 'review_repository_impl.dart';

class ExplorationReviewRepositoryImpl implements ExplorationReviewRepository {
  ExplorationReviewRepositoryImpl(this._dio);

  final Dio _dio;

  String _base(ExplorationReviewDomain domain) =>
      '/api/v1/admin/${domain.apiPathSegment}';

  @override
  Future<Either<ReviewFailure, List<ExplorationProposal>>> listPending(
    ExplorationReviewDomain domain,
  ) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        _base(domain),
        queryParameters: domain.listUsesStatusQuery
            ? const {'status': 'pending'}
            : null,
      );
      final data = asStringKeyMap(res.data?['data']);
      final rawItems = data['items'];
      final items = <ExplorationProposal>[];
      if (rawItems is List) {
        for (final raw in rawItems.whereType<Map>()) {
          items.add(_parseItem(domain, asStringKeyMap(raw)));
        }
      }
      return Either.right(items);
    } on DioException catch (error) {
      return Either.left(_mapDio(error, l10n.reviewExploreLoadFailed));
    } catch (error) {
      return Either.left(ReviewFailure(error.toString()));
    }
  }

  @override
  Future<Either<ReviewFailure, Unit>> approve(
    ExplorationReviewDomain domain,
    String id,
  ) async {
    try {
      await _dio.post<Map<String, dynamic>>('${_base(domain)}/$id/approve');
      return Either.right(unit);
    } on DioException catch (error) {
      return Either.left(_mapDio(error, l10n.reviewExploreApproveFailed));
    } catch (error) {
      return Either.left(ReviewFailure(error.toString()));
    }
  }

  @override
  Future<Either<ReviewFailure, Unit>> reject(
    ExplorationReviewDomain domain,
    String id, {
    required String reasonCode,
    String? reasonText,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '${_base(domain)}/$id/reject',
        data: {
          'reason_code': reasonCode,
          if (reasonText != null && reasonText.trim().isNotEmpty)
            'reason_text': reasonText.trim(),
        },
      );
      return Either.right(unit);
    } on DioException catch (error) {
      return Either.left(_mapDio(error, l10n.reviewExploreRejectFailed));
    } catch (error) {
      return Either.left(ReviewFailure(error.toString()));
    }
  }

  @override
  Future<Either<ReviewFailure, Unit>> requestRevision(
    ExplorationReviewDomain domain,
    String id, {
    required String note,
  }) async {
    if (!domain.supportsRevision) {
      return Either.left(ReviewFailure(l10n.reviewExploreRevisionUnsupported));
    }
    try {
      await _dio.post<Map<String, dynamic>>(
        '${_base(domain)}/$id/request-revision',
        data: {'note': note.trim()},
      );
      return Either.right(unit);
    } on DioException catch (error) {
      return Either.left(_mapDio(error, l10n.reviewExploreRevisionFailed));
    } catch (error) {
      return Either.left(ReviewFailure(error.toString()));
    }
  }
}

ExplorationProposal _parseItem(
  ExplorationReviewDomain domain,
  Map<String, dynamic> json,
) {
  final payload = asStringKeyMap(json['payload']);
  final fieldsRaw = json['fields'];
  final fields = fieldsRaw is List
      ? fieldsRaw.map((e) => e.toString()).toList()
      : const <String>[];
  final kind = json['kind']?.toString();
  final title = _titleFor(domain, json, payload);
  final subtitle = _subtitleFor(domain, json, kind);

  return ExplorationProposal(
    id: json['id']?.toString() ?? '',
    domain: domain,
    status: json['status']?.toString() ?? 'pending',
    kind: kind,
    title: title,
    subtitle: subtitle,
    createdAtLabel: _formatCreatedAt(json['created_at']),
    payload: payload,
    fields: fields,
    revisionNote: json['revision_note']?.toString(),
    wantsClaim: json['wants_claim'] == true,
  );
}

String _nonEmpty(Object? raw) {
  final text = raw?.toString().trim();
  if (text == null || text.isEmpty) return '';
  return text;
}

String _titleFor(
  ExplorationReviewDomain domain,
  Map<String, dynamic> json,
  Map<String, dynamic> payload,
) {
  switch (domain) {
    case ExplorationReviewDomain.usaha:
      final usahaName = _nonEmpty(json['usaha_name']);
      if (usahaName.isNotEmpty) return usahaName;
      final name = _nonEmpty(payload['name']);
      return name.isNotEmpty ? name : '-';
    case ExplorationReviewDomain.place:
    case ExplorationReviewDomain.event:
      final name = _nonEmpty(payload['name']);
      return name.isNotEmpty ? name : '-';
    case ExplorationReviewDomain.culinary:
      final cuisine = _nonEmpty(json['cuisine_name']);
      if (cuisine.isNotEmpty) return cuisine;
      final place = _nonEmpty(json['place_name']);
      if (place.isNotEmpty) return place;
      final name = _nonEmpty(payload['name']);
      return name.isNotEmpty ? name : '-';
  }
}

String? _subtitleFor(
  ExplorationReviewDomain domain,
  Map<String, dynamic> json,
  String? kind,
) {
  switch (domain) {
    case ExplorationReviewDomain.usaha:
      return kind;
    case ExplorationReviewDomain.culinary:
      return kind;
    case ExplorationReviewDomain.place:
      final category = asStringKeyMap(json['payload'])['category']?.toString();
      return category;
    case ExplorationReviewDomain.event:
      final location =
          asStringKeyMap(json['payload'])['location_text']?.toString();
      return location;
  }
}

String _formatCreatedAt(Object? raw) {
  if (raw == null) return '';
  if (raw is num) {
    final seconds = raw.toInt();
    final ms = seconds > 9999999999 ? seconds : seconds * 1000;
    return formatDateTime(DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true));
  }
  final text = raw.toString();
  if (text.isEmpty) return '';
  final asInt = int.tryParse(text);
  if (asInt != null) {
    final ms = asInt > 9999999999 ? asInt : asInt * 1000;
    return formatDateTime(DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true));
  }
  return formatDateTimeIso(text);
}

ReviewFailure _mapDio(DioException error, String fallback) {
  final data = error.response?.data;
  if (data is Map) {
    final message = data['message']?.toString();
    final code = data['error_code']?.toString() ?? data['code']?.toString();
    if (message != null && message.isNotEmpty) {
      return ReviewFailure(message, errorCode: code);
    }
  }
  return ReviewFailure(
    fallback,
    errorCode: error.response?.statusCode?.toString(),
  );
}
