import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../my_votes/presentation/providers/my_votes_providers.dart';
import '../../data/providers/vote_data_providers.dart';
import '../../domain/entities/vote_deck_item.dart';
import '../../domain/entities/vote_target.dart';
import '../../domain/failures/vote_failure.dart';
import '../../domain/providers/vote_domain_providers.dart';

/// Status job submit vote di background.
enum VoteSubmitJobStatus { queued, inFlight, done, failed, cancelled }

enum VoteSubmitKind { vote, skip }

class VoteSubmitJob {
  VoteSubmitJob({
    required this.item,
    required this.value,
    this.kind = VoteSubmitKind.vote,
  }) : status = VoteSubmitJobStatus.queued;

  final VoteDeckItem item;
  final int value;
  final VoteSubmitKind kind;
  VoteSubmitJobStatus status;

  String get wordId => item.id;
}

/// Snapshot queue untuk UI (error toast + reinsert kartu).
class VoteSubmitQueueState {
  const VoteSubmitQueueState({
    this.pendingCount = 0,
    this.inFlightCount = 0,
    this.errorSeq = 0,
    this.errorMessage,
    this.failedItem,
  });

  final int pendingCount;
  final int inFlightCount;
  final int errorSeq;
  final String? errorMessage;
  final VoteDeckItem? failedItem;

  VoteSubmitQueueState copyWith({
    int? pendingCount,
    int? inFlightCount,
    int? errorSeq,
    String? errorMessage,
    VoteDeckItem? failedItem,
    bool clearError = false,
  }) {
    return VoteSubmitQueueState(
      pendingCount: pendingCount ?? this.pendingCount,
      inFlightCount: inFlightCount ?? this.inFlightCount,
      errorSeq: errorSeq ?? this.errorSeq,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      failedItem: clearError ? null : (failedItem ?? this.failedItem),
    );
  }
}

final voteSubmitQueueProvider =
    NotifierProvider<VoteSubmitQueue, VoteSubmitQueueState>(
  VoteSubmitQueue.new,
);

/// Antrian submit vote in-memory: UI enqueue, worker kirim paralel terbatas.
class VoteSubmitQueue extends Notifier<VoteSubmitQueueState> {
  static const maxConcurrent = 3;

  final Queue<VoteSubmitJob> _pending = Queue<VoteSubmitJob>();
  final Map<String, VoteSubmitJob> _byWordId = {};
  final Set<String> _inFlight = {};
  final Map<String, Future<void>> _inFlightFutures = {};

  @override
  VoteSubmitQueueState build() => const VoteSubmitQueueState();

  bool isQueued(String wordId) {
    final job = _byWordId[wordId];
    return job != null && job.status == VoteSubmitJobStatus.queued;
  }

  bool isInFlight(String wordId) => _inFlight.contains(wordId);

  /// Batalkan job yang belum dikirim. `true` jika berhasil dibatalkan.
  bool cancelQueued(String wordId) {
    final job = _byWordId[wordId];
    if (job == null || job.status != VoteSubmitJobStatus.queued) {
      return false;
    }
    job.status = VoteSubmitJobStatus.cancelled;
    _pending.removeWhere((j) => j.wordId == wordId);
    _byWordId.remove(wordId);
    _publishCounts();
    return true;
  }

  /// Tunggu sampai job wordId tidak lagi in-flight (atau tidak ada).
  Future<void> waitUntilNotInFlight(String wordId) async {
    final future = _inFlightFutures[wordId];
    if (future != null) await future;
  }

  /// Enqueue vote; drop kartu sudah dilakukan caller (optimistic).
  void enqueue({
    required VoteDeckItem item,
    required int value,
  }) {
    // Ganti job queued sebelumnya untuk word yang sama (swipe ulang cepat).
    cancelQueued(item.id);
    final job = VoteSubmitJob(item: item, value: value);
    _pending.addLast(job);
    _byWordId[item.id] = job;
    _publishCounts();
    // Microtask: beri jendela cancel (rewind segera) sebelum POST.
    Future.microtask(_pump);
  }

  void enqueueSkip({required VoteDeckItem item}) {
    cancelQueued(item.id);
    final job = VoteSubmitJob(item: item, value: 0, kind: VoteSubmitKind.skip);
    _pending.addLast(job);
    _byWordId[item.id] = job;
    _publishCounts();
    Future.microtask(_pump);
  }

  /// Batalkan skip yang masih antre, atau DELETE jika POST sudah jalan.
  /// Null = berhasil (antre dibatalkan atau baris skip terhapus).
  Future<VoteFailure?> undoSkip(String wordId) async {
    if (cancelQueued(wordId)) return null;
    await waitUntilNotInFlight(wordId);
    final result = await ref.read(voteRepositoryProvider).unskipWord(wordId);
    return result.match((failure) => failure, (_) => null);
  }

  void _publishCounts({
    String? errorMessage,
    VoteDeckItem? failedItem,
    bool bumpError = false,
  }) {
    if (!ref.mounted) return;
    // Error sticky sampai bump berikutnya - jangan di-clear oleh _pump biasa.
    state = VoteSubmitQueueState(
      pendingCount: _pending.length,
      inFlightCount: _inFlight.length,
      errorSeq: bumpError ? state.errorSeq + 1 : state.errorSeq,
      errorMessage: bumpError ? errorMessage : state.errorMessage,
      failedItem: bumpError ? failedItem : state.failedItem,
    );
  }

  void _pump() {
    if (!ref.mounted) return;
    while (_inFlight.length < maxConcurrent && _pending.isNotEmpty) {
      final job = _pending.removeFirst();
      if (job.status == VoteSubmitJobStatus.cancelled) {
        continue;
      }
      _run(job);
    }
    _publishCounts();
  }

  void _run(VoteSubmitJob job) {
    job.status = VoteSubmitJobStatus.inFlight;
    _inFlight.add(job.wordId);
    _publishCounts();

    final future = _execute(job);
    _inFlightFutures[job.wordId] = future;
    future.whenComplete(() {
      _inFlight.remove(job.wordId);
      _inFlightFutures.remove(job.wordId);
      if (_byWordId[job.wordId] == job &&
          job.status != VoteSubmitJobStatus.queued) {
        _byWordId.remove(job.wordId);
      }
      _pump();
    });
  }

  Future<void> _execute(VoteSubmitJob job) async {
    if (job.kind == VoteSubmitKind.skip) {
      final result = await ref.read(voteRepositoryProvider).skipWord(job.wordId);
      result.match(
        (failure) {
          job.status = VoteSubmitJobStatus.failed;
          _publishCounts(
            errorMessage: failure.message,
            failedItem: job.item,
            bumpError: true,
          );
        },
        (_) {
          job.status = VoteSubmitJobStatus.done;
          _publishCounts();
        },
      );
      return;
    }

    final target = VoteTarget(type: 'word', id: job.wordId);
    final result = await ref.read(toggleVoteUseCaseProvider)(
      target: target,
      value: job.value,
    );

    result.match(
      (failure) {
        job.status = VoteSubmitJobStatus.failed;
        // Caller (UI) listen errorSeq → toast + reinsertFront.
        _publishCounts(
          errorMessage: failure.message,
          failedItem: job.item,
          bumpError: true,
        );
      },
      (_) {
        job.status = VoteSubmitJobStatus.done;
        AnalyticsService.instance.logVoteCast(
          targetType: target.type,
          direction: job.value,
        );
        ref.invalidate(myVotesListControllerProvider);
        _publishCounts();
      },
    );
  }
}
