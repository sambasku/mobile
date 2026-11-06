import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../domain/entities/exploration_proposal.dart';
import '../../domain/exploration_reject_reasons.dart';
import '../../domain/failures/review_failure.dart';
import '../providers/exploration_review_providers.dart';
import '../providers/review_suggestions_providers.dart';
import '../widgets/exploration_reject_sheet.dart';
import '../widgets/exploration_revision_sheet.dart';

class ExplorationReviewDetailPage extends ConsumerStatefulWidget {
  const ExplorationReviewDetailPage({
    super.key,
    required this.domain,
    required this.id,
  });

  final ExplorationReviewDomain domain;
  final String id;

  @override
  ConsumerState<ExplorationReviewDetailPage> createState() =>
      _ExplorationReviewDetailPageState();
}

class _ExplorationReviewDetailPageState
    extends ConsumerState<ExplorationReviewDetailPage> {
  bool _busy = false;

  Future<void> _afterDecide(String toast) async {
    invalidateExplorationReview(ref, widget.domain);
    ref.invalidate(reviewHubHasPendingProvider);
    if (!mounted) return;
    showFToast(context: context, title: Text(toast));
    context.pop();
  }

  Future<void> _approve(ExplorationProposal item) async {
    if (_busy || !item.isPending) return;
    setState(() => _busy = true);
    final result = await ref
        .read(explorationReviewRepositoryProvider)
        .approve(item.domain, item.id);
    if (!mounted) return;
    setState(() => _busy = false);
    await result.fold(
      (failure) async {
        showFToast(context: context, title: Text(failure.message));
      },
      (_) => _afterDecide(
        AppLocalizations.of(context).reviewExploreApprovedToast,
      ),
    );
  }

  Future<void> _reject(ExplorationProposal item) async {
    if (_busy || !item.isPending) return;
    final picked = await showExplorationRejectSheet(
      context,
      domain: item.domain,
    );
    if (!mounted || picked == null) return;

    setState(() => _busy = true);
    final result = await ref.read(explorationReviewRepositoryProvider).reject(
      item.domain,
      item.id,
      reasonCode: picked.reasonCode,
      reasonText: picked.reasonText,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    await result.fold(
      (failure) async {
        showFToast(context: context, title: Text(failure.message));
      },
      (_) => _afterDecide(
        AppLocalizations.of(context).reviewExploreRejectedToast,
      ),
    );
  }

  Future<void> _requestRevision(ExplorationProposal item) async {
    if (_busy || !item.isPending || !item.domain.supportsRevision) return;
    final note = await showExplorationRevisionSheet(context);
    if (!mounted || note == null) return;

    setState(() => _busy = true);
    final result = await ref
        .read(explorationReviewRepositoryProvider)
        .requestRevision(item.domain, item.id, note: note);
    if (!mounted) return;
    setState(() => _busy = false);
    await result.fold(
      (failure) async {
        showFToast(context: context, title: Text(failure.message));
      },
      (_) => _afterDecide(
        AppLocalizations.of(context).reviewExploreRevisionToast,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async =
        ref.watch(explorationDetailProvider((widget.domain, widget.id)));
    final l10n = AppLocalizations.of(context);
    final item = async.asData?.value;

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.reviewExploreDetailTitle),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      footer: item != null && item.isPending
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FButton(
                            variant: FButtonVariant.outline,
                            onPress: _busy ? null : () => _reject(item),
                            child: Text(l10n.commonReject),
                          ),
                        ),
                        if (item.domain.supportsRevision) ...[
                          const Gap(8),
                          Expanded(
                            child: FButton(
                              variant: FButtonVariant.outline,
                              onPress:
                                  _busy ? null : () => _requestRevision(item),
                              child: Text(l10n.reviewExploreRequestRevision),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Gap(8),
                    FButton(
                      onPress: _busy ? null : () => _approve(item),
                      prefix: _busy ? const FCircularProgress() : null,
                      child: Text(
                        _busy
                            ? l10n.reviewExploreProcessing
                            : l10n.commonApprove,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      child: async.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (error, _) => Center(
          child: Text(
            error is ReviewFailure ? error.message : l10n.commonLoadFailed,
            textAlign: TextAlign.center,
          ),
        ),
        data: (proposal) => _ExplorationDetailContent(item: proposal),
      ),
    );
  }
}

class _ExplorationDetailContent extends StatelessWidget {
  const _ExplorationDetailContent({required this.item});

  final ExplorationProposal item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final kindLabel = explorationKindLabel(item.domain, item.kind, l10n);
    final imageUrls = _extractImageUrls(item.payload);
    final rows = _payloadRows(item.payload);

    return ListView(
      children: [
        Text(
          item.title,
          style: theme.typography.body.xl.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(4),
        Text(
          l10n.reviewExploreMetaKindDate(kindLabel, item.createdAtLabel),
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        if (item.wantsClaim) ...[
          const Gap(8),
          Text(
            l10n.reviewExploreWantsClaim,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.primary,
            ),
          ),
        ],
        if (item.fields.isNotEmpty) ...[
          const Gap(12),
          Text(
            l10n.reviewExploreFieldsLabel,
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(4),
          Text(item.fields.join(', '), style: theme.typography.body.sm),
        ],
        if (imageUrls.isNotEmpty) ...[
          const Gap(16),
          Text(
            l10n.reviewExploreImagesSection,
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: imageUrls.length,
              separatorBuilder: (_, _) => const Gap(8),
              itemBuilder: (context, index) {
                final url =
                    displayImageUrl(imageUrls[index]) ?? imageUrls[index];
                return SizedBox(
                  width: 96,
                  height: 96,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImageWithFallback(
                      imageUrl: url,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const Gap(16),
        Text(
          l10n.reviewExplorePayloadSection,
          style: theme.typography.body.md.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(8),
        if (rows.isEmpty)
          Text(
            '-',
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          )
        else
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.$1,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(2),
                  Text(row.$2, style: theme.typography.body.sm),
                ],
              ),
            ),
      ],
    );
  }
}

List<String> _extractImageUrls(Map<String, dynamic> payload) {
  final urls = <String>[];
  final images = payload['images'];
  if (images is List) {
    for (final raw in images) {
      if (raw is String && raw.trim().isNotEmpty) {
        urls.add(raw.trim());
      } else if (raw is Map) {
        final url = raw['url']?.toString();
        if (url != null && url.trim().isNotEmpty) urls.add(url.trim());
      }
    }
  }
  final posters = payload['poster_urls'];
  if (posters is List) {
    for (final raw in posters) {
      final url = raw?.toString();
      if (url != null && url.trim().isNotEmpty) urls.add(url.trim());
    }
  }
  for (final key in ['coverUrl', 'cover_url']) {
    final cover = payload[key]?.toString();
    if (cover != null && cover.trim().isNotEmpty) urls.add(cover.trim());
  }
  return urls.toSet().toList();
}

List<(String, String)> _payloadRows(Map<String, dynamic> payload) {
  const skip = {
    'images',
    'poster_urls',
    'coverUrl',
    'cover_url',
  };
  final rows = <(String, String)>[];
  for (final entry in payload.entries) {
    if (skip.contains(entry.key)) continue;
    final value = entry.value;
    if (value == null) continue;
    if (value is Map || value is List) {
      final text = value.toString();
      if (text.isEmpty || text == '[]' || text == '{}') continue;
      rows.add((entry.key, text));
      continue;
    }
    final text = value.toString().trim();
    if (text.isEmpty) continue;
    rows.add((entry.key, text));
  }
  return rows;
}
