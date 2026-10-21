import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/review_contribution.dart';
import '../../review_router.dart';
import '../providers/review_providers.dart';

/// Buka sesi Setujui/Tolak untuk usulan pending milik satu kata.
///
/// Feed dan badge detail kata sama-sama lewat sini. Jangan buka
/// `/review/queue`: antrean itu memakai hideSkipped dan sering kosong
/// untuk usulan anonim (#179).
Future<void> openPendingWordReview(
  BuildContext context,
  WidgetRef ref,
  String wordId,
) async {
  final trimmed = wordId.trim();
  if (trimmed.isEmpty) return;

  final result = await ref
      .read(reviewRepositoryProvider)
      .list(status: 'pending', wordId: trimmed, limit: 20);
  if (!context.mounted) return;

  result.match(
    (failure) {
      final message = failure.isForbidden
          ? 'Kamu tidak berwenang meninjau usulan.'
          : failure.message;
      showFToast(
        context: context,
        title: Text(message),
        variant: FToastVariant.destructive,
      );
    },
    (page) {
      final item = _pickPendingWord(page.items, trimmed);
      if (item == null) {
        showFToast(
          context: context,
          title: const Text('Tidak ada usulan yang menunggu untuk kata ini.'),
        );
        return;
      }
      context.push(ReviewRouter.sessionPath(startId: item.id, wordId: trimmed));
    },
  );
}

/// Utamakan baris kata itu sendiri. Anak (makna, foto) hanya cadangan.
ReviewItem? _pickPendingWord(List<ReviewItem> items, String wordId) {
  for (final item in items) {
    if (item.entityType == 'word' && item.entityId == wordId) return item;
  }
  if (items.isEmpty) return null;
  return items.first;
}
