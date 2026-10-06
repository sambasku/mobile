import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/failures/review_failure.dart';
import 'review_providers.dart';

enum ReviewSubmitKind { approve, reject, skip }

enum ReviewSubmitJobStatus { queued, inFlight, done, failed, cancelled }

class ReviewSubmitJob {
  ReviewSubmitJob({
    required this.contributionId,
    required this.kind,
    this.comment,
  }) : status = ReviewSubmitJobStatus.queued;

  final String contributionId;
  final ReviewSubmitKind kind;
  final String? comment;
  ReviewSubmitJobStatus status;
}

/// Snapshot queue decide review untuk toast / reinsert.
class ReviewSubmitQueueState {
  const ReviewSubmitQueueState({
    this.pendingCount = 0,
    this.inFlightCount = 0,
    this.errorSeq = 0,
    this.errorMessage,
    this.failedContributionId,
    this.failedIsForbidden = false,
    this.failedIsAlreadyDecided = false,
  });

  final int pendingCount;
  final int inFlightCount;
  final int errorSeq;
  final String? errorMessage;
  final String? failedContributionId;
  final bool failedIsForbidden;
  final bool failedIsAlreadyDecided;

  ReviewSubmitQueueState copyWith({
    int? pendingCount,
    int? inFlightCount,
    int? errorSeq,
    String? errorMessage,
    String? failedContributionId,
    bool? failedIsForbidden,
    bool? failedIsAlreadyDecided,
    bool clearError = false,
  }) {
    return ReviewSubmitQueueState(
      pendingCount: pendingCount ?? this.pendingCount,
      inFlightCount: inFlightCount ?? this.inFlightCount,
      errorSeq: errorSeq ?? this.errorSeq,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      failedContributionId: clearError
          ? null
          : (failedContributionId ?? this.failedContributionId),
      failedIsForbidden: clearError
          ? false
          : (failedIsForbidden ?? this.failedIsForbidden),
      failedIsAlreadyDecided: clearError
          ? false
          : (failedIsAlreadyDecided ?? this.failedIsAlreadyDecided),
    );
  }
}

final reviewSubmitQueueProvider =
    NotifierProvider<ReviewSubmitQueue, ReviewSubmitQueueState>(
  ReviewSubmitQueue.new,
);

/// Antrian approve/reject in-memory: UI maju segera, worker kirim paralel.
class ReviewSubmitQueue extends Notifier<ReviewSubmitQueueState> {
  static const maxConcurrent = 3;

  final Queue<ReviewSubmitJob> _pending = Queue<ReviewSubmitJob>();
  final Map<String, ReviewSubmitJob> _byId = {};
  final Set<String> _inFlight = {};
  final Map<String, Future<void>> _inFlightFutures = {};

  @override
  ReviewSubmitQueueState build() => const ReviewSubmitQueueState();

  void enqueueApprove(String contributionId) {
    _enqueue(
      ReviewSubmitJob(
        contributionId: contributionId,
        kind: ReviewSubmitKind.approve,
      ),
    );
  }

  void enqueueReject(String contributionId, {required String comment}) {
    _enqueue(
      ReviewSubmitJob(
        contributionId: contributionId,
        kind: ReviewSubmitKind.reject,
        comment: comment,
      ),
    );
  }

  void enqueueSkip(String contributionId) {
    _enqueue(
      ReviewSubmitJob(
        contributionId: contributionId,
        kind: ReviewSubmitKind.skip,
      ),
    );
  }

  /// Batalkan job yang belum dikirim. `true` jika berhasil dibatalkan.
  bool cancelQueued(String contributionId) {
    final job = _byId[contributionId];
    if (job == null || job.status != ReviewSubmitJobStatus.queued) {
      return false;
    }
    job.status = ReviewSubmitJobStatus.cancelled;
    _pending.removeWhere((j) => j.contributionId == contributionId);
    _byId.remove(contributionId);
    _publishCounts();
    return true;
  }

  Future<void> waitUntilNotInFlight(String contributionId) async {
    final future = _inFlightFutures[contributionId];
    if (future != null) await future;
  }

  /// Tunggu sampai job [contributionId] tuntas: masih antre (queued) maupun
  /// sudah terkirim (in-flight). Dipakai caller yang perlu refetch state
  /// TERBARU dari server setelah keputusan — kalau invalidate dijalankan
  /// saat job masih antre, server belum menyimpan keputusan.
  Future<void> waitUntilDone(String contributionId) async {
    while (_byId.containsKey(contributionId) ||
        _inFlightFutures.containsKey(contributionId)) {
      final future = _inFlightFutures[contributionId];
      if (future != null) {
        await future;
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    }
  }

  void _enqueue(ReviewSubmitJob job) {
    final existing = _byId[job.contributionId];
    if (existing != null && existing.status == ReviewSubmitJobStatus.queued) {
      existing.status = ReviewSubmitJobStatus.cancelled;
      _pending.removeWhere((j) => j.contributionId == job.contributionId);
    }
    _pending.addLast(job);
    _byId[job.contributionId] = job;
    _publishCounts();
    Future.microtask(_pump);
  }

  void _publishCounts({
    String? errorMessage,
    String? failedContributionId,
    bool failedIsForbidden = false,
    bool failedIsAlreadyDecided = false,
    bool bumpError = false,
  }) {
    if (!ref.mounted) return;
    // Error sticky sampai bump berikutnya - jangan di-clear oleh _pump biasa.
    state = ReviewSubmitQueueState(
      pendingCount: _pending.length,
      inFlightCount: _inFlight.length,
      errorSeq: bumpError ? state.errorSeq + 1 : state.errorSeq,
      errorMessage: bumpError ? errorMessage : state.errorMessage,
      failedContributionId:
          bumpError ? failedContributionId : state.failedContributionId,
      failedIsForbidden:
          bumpError ? failedIsForbidden : state.failedIsForbidden,
      failedIsAlreadyDecided:
          bumpError ? failedIsAlreadyDecided : state.failedIsAlreadyDecided,
    );
  }

  void _pump() {
    if (!ref.mounted) return;
    while (_inFlight.length < maxConcurrent && _pending.isNotEmpty) {
      final job = _pending.removeFirst();
      if (job.status == ReviewSubmitJobStatus.cancelled) continue;
      _run(job);
    }
    _publishCounts();
  }

  void _run(ReviewSubmitJob job) {
    job.status = ReviewSubmitJobStatus.inFlight;
    _inFlight.add(job.contributionId);
    _publishCounts();

    final future = _execute(job);
    _inFlightFutures[job.contributionId] = future;
    future.whenComplete(() {
      _inFlight.remove(job.contributionId);
      _inFlightFutures.remove(job.contributionId);
      if (_byId[job.contributionId] == job &&
          job.status != ReviewSubmitJobStatus.queued) {
        _byId.remove(job.contributionId);
      }
      _pump();
    });
  }

  Future<void> _execute(ReviewSubmitJob job) async {
    final repo = ref.read(reviewRepositoryProvider);
    if (job.kind == ReviewSubmitKind.skip) {
      final result = await repo.skip(job.contributionId);
      result.match(
        (ReviewFailure failure) {
          job.status = ReviewSubmitJobStatus.failed;
          _publishCounts(
            errorMessage: failure.message,
            failedContributionId: job.contributionId,
            failedIsForbidden: failure.isForbidden,
            bumpError: true,
          );
        },
        (_) {
          job.status = ReviewSubmitJobStatus.done;
          ref.invalidate(reviewQueueHasPendingProvider);
          _publishCounts();
        },
      );
      return;
    }

    final result = switch (job.kind) {
      ReviewSubmitKind.approve => await repo.approve(job.contributionId),
      ReviewSubmitKind.reject => await repo.reject(
          job.contributionId,
          comment: job.comment ?? '',
        ),
      ReviewSubmitKind.skip =>
        throw StateError('skip ditangani sebelum switch'),
    };

    result.match(
      (ReviewFailure failure) {
        job.status = ReviewSubmitJobStatus.failed;
        // Already decided: kartu sudah di-drop lokal - biarkan saja.
        if (failure.isAlreadyDecided) {
          _publishCounts(
            errorMessage: failure.message,
            failedContributionId: job.contributionId,
            failedIsAlreadyDecided: true,
            bumpError: true,
          );
          return;
        }
        _publishCounts(
          errorMessage: failure.message,
          failedContributionId: job.contributionId,
          failedIsForbidden: failure.isForbidden,
          bumpError: true,
        );
      },
      (_) {
        job.status = ReviewSubmitJobStatus.done;
        _publishCounts();
      },
    );
  }
}
