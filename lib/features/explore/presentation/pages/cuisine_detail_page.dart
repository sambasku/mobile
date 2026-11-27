import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/models/external_link.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_number.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../shared/entity_comments/entity_comment.dart';
import '../../../../shared/entity_comments/entity_comments_section.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/contributor_appreciation.dart';
import '../../../auth/auth_router.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/culinary_contribution_api.dart';
import '../../domain/entities/cuisine.dart';
import '../../explore_router.dart';
import '../providers/cuisine_providers.dart';
import '../widgets/culinary_action_sheets.dart';

const _heroAspect = 16 / 10;

void _back(BuildContext context) =>
    context.canPop() ? context.pop() : context.go('/explore');

/// Detail satu cuisine: hero gambar + atribusi, deskripsi, bahan,
/// cara penyajian, dan section "Sumber" bila sources[] terisi.
class CuisineDetailPage extends ConsumerWidget {
  const CuisineDetailPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuisineAsync = ref.watch(cuisineBySlugProvider(slug));
    final item = cuisineAsync.value?.toEntity();
    if (item != null) {
      // Log cuisine_open sekali saat detail tampil (bukan di build stateless
      // kartu list - bisa multi-fire).
      unawaited(AnalyticsService.instance.logCuisineOpen(slug: item.slug));
      return _Body(item: item);
    }

    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        prefixes: [FHeaderAction.back(onPress: () => _back(context))],
      ),
      child: cuisineAsync.isLoading ? const _Skeleton() : const _ErrorBody(),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Bone(width: double.infinity),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone(width: 240, height: 26),
                Gap(10),
                Bone(width: 120, height: 22),
                Gap(16),
                Bone(width: double.infinity, height: 16),
                Gap(6),
                Bone(width: double.infinity, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FAlert(
          title: Text(l10n.exploreNotFoundTitle),
          subtitle: Text(
            l10n.exploreNotFoundBody,
            style: context.theme.typography.body.sm,
          ),
        ),
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.item});

  final Cuisine item;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      if (!mounted) return;
      unawaited(_recordView());
    });
  }

  Future<void> _recordView() async {
    try {
      await ref
          .read(cuisineRepositoryProvider)
          .recordView(widget.item.slug);
    } catch (_) {
      // best-effort
    }
  }

  Future<void> _report() async {
    if (await culinaryNeedsAuth(context, ref)) return;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (!mounted) return;
    final reason = await showCulinaryReasonSheet(context, isPlace: false);
    if (reason == null || !mounted) return;
    try {
      await ref
          .read(culinaryContributionApiProvider)
          .reportCuisine(widget.item.slug, reasonCode: reason);
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        title: l10n.usahaReportSent,
        message: l10n.cuisineDetailReportSentBody,
      );
    } on CulinaryException catch (e) {
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        title: l10n.culinaryReportFailed,
        message: e.message,
      );
    }
  }

  void _addPhoto() {
    final authed = ref.read(authStatusProvider).value?.isAuth == true;
    if (!authed) {
      context.push(AuthRouter.login.path);
      return;
    }
    context.push(ExploreRouter.cuisineAddPhotoPath(widget.item.slug));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final topInset = MediaQuery.paddingOf(context).top;
    final item = widget.item;
    final loggedIn = ref.watch(authStatusProvider).value?.isAuth == true;

    return FScaffold(
      childPad: false,
      // EntryBar sudah punya top border - jangan dobel dengan footerDecoration.
      scaffoldStyle: .delta(
        footerDecoration: .value(const BoxDecoration()),
      ),
      footer: EntityCommentEntryBar(
        target: EntityCommentTarget.cuisine,
        entityId: item.id,
      ),
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _Hero(images: item.images),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.typography.body.xl.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const Gap(8),
                    // Region disembunyikan: promosi kuliner di level
                    // kabupaten, tidak perlu badge "Sambas" per item.
                    Text(
                      item.description,
                      style: theme.typography.body.sm.copyWith(height: 1.5),
                    ),
                    if (item.author case final author?)
                      ContributorAppreciationSection(
                        label: l10n.usahaContributorProposedBy,
                        contributors: [
                          ContributorCredit(
                            username: author.username,
                            displayName: author.displayName,
                          ),
                        ],
                      ),
                    if (item.ingredients.isNotEmpty) ...[
                      const Gap(20),
                      Text(
                        l10n.cuisineDetailIngredients,
                        style: theme.typography.body.md.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final bahan in item.ingredients)
                            FBadge(
                              variant: FBadgeVariant.outline,
                              child: Text(bahan),
                            ),
                        ],
                      ),
                    ],
                    if (item.servingSuggestion != null) ...[
                      const Gap(20),
                      Text(
                        l10n.cuisineDetailServing,
                        style: theme.typography.body.md.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        item.servingSuggestion!,
                        style: theme.typography.body.sm.copyWith(height: 1.5),
                      ),
                    ],
                    if (item.sources.isNotEmpty) ...[
                      const Gap(20),
                      for (final s in item.sources)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: _CreditLine(
                            label: l10n.cuisineDetailSource,
                            name: s.name,
                            nameUrl: s.address,
                            license: s.license,
                            licenseUrl: s.licenseUrl,
                          ),
                        ),
                    ],
                    const Gap(20),
                    FTileGroup(
                      label: Text(l10n.cuisineDetailHelpTitle),
                      children: [
                        FTile(
                          prefix: const Icon(FLucideIcons.imagePlus, size: 18),
                          title: Text(l10n.cuisineActionAddPhoto),
                          subtitle: Text(
                            loggedIn
                                ? l10n.cuisineAddPhotoBody
                                : l10n.placeAddPhotoLoginGate,
                          ),
                          suffix: const Icon(
                            FLucideIcons.chevronRight,
                            size: 16,
                          ),
                          onPress: _addPhoto,
                        ),
                        FTile(
                          prefix: const Icon(FLucideIcons.pencil, size: 18),
                          title: Text(l10n.culinarySuggestEdit),
                          subtitle: Text(
                            l10n.cuisineDetailSuggestEditBody,
                          ),
                          suffix: const Icon(
                            FLucideIcons.chevronRight,
                            size: 16,
                          ),
                          onPress: () async {
                            if (await culinaryNeedsAuth(context, ref)) return;
                            if (!context.mounted) return;
                            await showCulinaryEditSheet(
                              context,
                              ref,
                              target: CulinaryEditTarget.cuisine(
                                id: item.id,
                                name: item.name,
                                description: item.description,
                                ingredients: item.ingredients,
                              ),
                            );
                          },
                        ),
                        FTile(
                          prefix: const Icon(FLucideIcons.history, size: 18),
                          title: Text(l10n.historyTitle),
                          subtitle: Text(l10n.cuisineHistoryBody),
                          suffix: const Icon(
                            FLucideIcons.chevronRight,
                            size: 16,
                          ),
                          onPress: () => context.push(
                            ExploreRouter.cuisineHistoryPath(item.slug),
                          ),
                        ),
                        FTile(
                          prefix: const Icon(FLucideIcons.flag, size: 18),
                          title: Text(l10n.usahaReportTitle),
                          subtitle: Text(l10n.cuisineDetailReportBody),
                          suffix: const Icon(
                            FLucideIcons.chevronRight,
                            size: 16,
                          ),
                          onPress: _report,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: topInset + 8,
            left: 12,
            child: _HeroButton(
              icon: const Icon(FLucideIcons.arrowLeft, size: 20),
              tooltip: AppLocalizations.of(context).commonBack,
              onTap: () => _back(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        foregroundColor: Colors.white,
      ),
      icon: icon,
    );
  }
}

/// #281: carousel multi-foto (mirror wisata `_Carousel`).
class _Hero extends StatefulWidget {
  const _Hero({required this.images});

  final List<PlaceImage> images;

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final images = widget.images;
    if (images.isEmpty) {
      return AspectRatio(
        aspectRatio: _heroAspect,
        child: ColoredBox(
          color: theme.colors.muted,
          child: Icon(
            FLucideIcons.image,
            size: 48,
            color: theme.colors.mutedForeground,
          ),
        ),
      );
    }

    final attribution = images[_index].attribution;
    final hero = AspectRatio(
      aspectRatio: _heroAspect,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final img = images[i];
              return GestureDetector(
                onTap: () => showImagePreview(
                  context,
                  urls: [for (final im in images) im.url],
                  credits: [for (final im in images) im.attribution],
                  initialIndex: i,
                ),
                child: CachedNetworkImageWithFallback(
                  imageUrl: displayImageUrl(img.url, width: 1200) ?? img.url,
                  fallbackUrl: img.url,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment(0, -0.3),
                  colors: [Colors.black45, Colors.transparent],
                ),
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${formatRibuan(_index + 1)}/${formatRibuan(images.length)}',
                  style: theme.typography.body.xs.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (attribution == null) return hero;
    return Column(
      children: [
        hero,
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: _CreditLine(
            label: AppLocalizations.of(context).sharePhoto,
            name: attribution.name,
            nameUrl: attribution.url,
            license: attribution.license,
            licenseUrl: attribution.licenseUrl,
          ),
        ),
      ],
    );
  }
}

void _open(String? url) {
  final uri = url == null ? null : Uri.tryParse(url);
  if (uri == null || !uri.isScheme('https')) return;
  // Timeout: handler external di sebagian ROM bisa menggantung.
  launchExternalUrl(
    uri,
  ).timeout(const Duration(seconds: 8), onTimeout: () => false);
}

/// Kredit satu baris: "Label: nama · lisensi". Nama & lisensi bisa di-tap.
class _CreditLine extends StatelessWidget {
  const _CreditLine({
    required this.label,
    required this.name,
    this.nameUrl,
    this.license,
    this.licenseUrl,
  });

  final String label;
  final String name;
  final String? nameUrl;
  final String? license;
  final String? licenseUrl;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final muted = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
    );
    final license = this.license;

    return Row(
      children: [
        Text('$label: ', style: muted),
        Flexible(
          child: GestureDetector(
            onTap: () => _open(nameUrl),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: muted.copyWith(
                color: theme.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (license != null) ...[
          Text(' · ', style: muted),
          GestureDetector(
            onTap: () => _open(licenseUrl),
            child: Text(
              license,
              style: muted.copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ],
      ],
    );
  }
}
