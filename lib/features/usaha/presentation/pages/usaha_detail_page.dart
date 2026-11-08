import 'dart:async';

import 'package:fpdart/fpdart.dart' hide State;
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/models/external_link.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/attachment_images_field.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/contributor_appreciation.dart';
import '../../../../shared/widgets/option_picker_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../contribution/data/providers/contribution_data_providers.dart';
import '../../domain/entities/usaha.dart';
import '../../usaha_router.dart';
import '../providers/usaha_providers.dart';
import '../usaha_labels.dart';
import '../widgets/usaha_ui.dart';

/// Detail usaha by slug (katalog + kontak + klaim/lapor).
class UsahaDetailPage extends ConsumerWidget {
  const UsahaDetailPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final usahaAsync = ref.watch(usahaBySlugProvider(slug));

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.usahaTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(UsahaRouter.list.path),
          ),
        ],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.flag),
            onPress: () => _openReportSheet(context, ref),
          ),
        ],
      ),
      child: usahaAsync.when(
        loading: () => const Center(child: FCircularProgress(size: .sm)),
        error: (_, _) => const _ErrorBody(),
        data: (usaha) {
          if (usaha == null) return const _NotFoundBody();
          final hasPendingClaim =
              ref
                  .watch(usahaClaimsControllerProvider)
                  .asData
                  ?.value
                  .any(
                    (c) =>
                        c.usahaSlug == usaha.slug &&
                        c.status == UsahaClaimStatus.pending,
                  ) ??
              false;
          return _Body(
            usaha: usaha,
            hasPendingClaim: hasPendingClaim,
            onClaim: () => _openClaimSheet(context, ref),
            onSeeClaims: () => context.push(UsahaRouter.claims.path),
          );
        },
      ),
    );
  }

  /// Klaim pengelolaan - wajib login.
  Future<void> _openClaimSheet(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final authed = ref.read(authStatusProvider).value?.isAuth == true;
    if (!authed) {
      final goLogin = await showModalBottomSheet<bool>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (ctx) => SafeArea(
          top: false,
          child: FTileGroup(
            children: [
              FTile(
                title: Text(l10n.usahaLoginFirstTitle),
                subtitle: Text(l10n.usahaClaimLoginBody),
              ),
              FTile(
                title: Text(l10n.authLoginAction),
                onPress: () => Navigator.pop(ctx, true),
              ),
              FTile(
                title: Text(l10n.authLater),
                onPress: () => Navigator.pop(ctx, false),
              ),
            ],
          ),
        ),
      );
      if (goLogin == true && context.mounted) context.push('/login');
      return;
    }
    final result = await showModalBottomSheet<List<Map<String, String>>>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => const _ClaimSheet(),
    );
    if (result == null || result.isEmpty || !context.mounted) return;
    // Sheet sudah menutup; submit di luar sheet supaya error tampil di
    // halaman, bukan di dalam sheet yang sedang animasi tutup.
    try {
      await ref
          .read(usahaContributionApiProvider)
          .claim(slug, evidenceImages: result);
      ref.invalidate(usahaClaimsControllerProvider);
      unawaited(AnalyticsService.instance.logUsahaClaimSubmit(slug: slug));
      if (!context.mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        builder: (ctx) => SafeArea(
          top: false,
          child: FTileGroup(
            children: [
              FTile(
                title: Text(l10n.usahaClaimSent),
                subtitle: Text(l10n.usahaClaimSentBody),
              ),
              FTile(
                title: Text(l10n.usahaSeeClaims),
                onPress: () {
                  Navigator.pop(ctx);
                  context.push(UsahaRouter.claims.path);
                },
              ),
            ],
          ),
        ),
      );
    } on UsahaException catch (e) {
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        message: e.message,
        title: l10n.usahaClaimFailed,
      );
    }
  }

  /// Laporkan info usaha yang salah/usang.
  Future<void> _openReportSheet(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final authed = ref.read(authStatusProvider).value?.isAuth == true;
    if (!authed) {
      await showAppErrorSheet(
        context,
        title: l10n.usahaLoginFirstTitle,
        message: l10n.usahaReportLoginBody,
      );
      return;
    }
    final picked = await showOptionPickerSheet<String>(
      context,
      title: l10n.usahaReportTitle,
      icon: FLucideIcons.flag,
      subtitle: l10n.usahaReportSubtitle,
      items: [
        for (final code in usahaReportReasonCodes)
          OptionPickerItem(
            value: code,
            label: usahaReportReasonLabel(l10n, code),
          ),
      ],
    );
    if (picked == null || !context.mounted) return;
    try {
      await ref
          .read(usahaContributionApiProvider)
          .report(slug, reasonCode: picked);
      unawaited(AnalyticsService.instance.logUsahaReportSubmit(slug: slug));
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        title: l10n.usahaReportSent,
        message: l10n.usahaReportSentBody,
      );
    } on UsahaException catch (e) {
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        message: e.message,
        title: l10n.usahaReportFailed,
      );
    }
  }
}

class _Body extends StatefulWidget {
  const _Body({
    required this.usaha,
    required this.hasPendingClaim,
    required this.onClaim,
    required this.onSeeClaims,
  });

  final Usaha usaha;
  final bool hasPendingClaim;
  final VoidCallback onClaim;
  final VoidCallback onSeeClaims;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      if (!mounted) return;
      unawaited(
        AnalyticsService.instance.logUsahaOpen(slug: widget.usaha.slug),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final usaha = widget.usaha;
    final onClaim = widget.onClaim;
    final onSeeClaims = widget.onSeeClaims;
    final hasPendingClaim = widget.hasPendingClaim;
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final cover = usaha.coverUrl;
    final badge = usahaOperationalBadge(l10n, usaha.operationalStatus);

    // Icon di title (bukan prefix): Forui ItemContentLayout selalu
    // center-vertikal prefix - alamat multi-baris jadi icon melayang di tengah.
    final locationTiles = <FTile>[
      if (usaha.region case final region?)
        _locationTile(
          icon: FLucideIcons.mapPinned,
          title: l10n.usahaLocationDistrict,
          subtitle: region.name,
        ),
      if (usaha.village case final village?)
        _locationTile(
          icon: FLucideIcons.mapPin,
          title: l10n.usahaLocationVillage,
          subtitle: village.name,
        ),
      if (usaha.addressText case final address?
          when address.trim().isNotEmpty)
        _locationTile(
          icon: FLucideIcons.house,
          title: l10n.usahaLocationAddress,
          subtitle: address,
          subtitleMaxLines: 3,
          titleSpacing: 8,
        ),
    ];

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (cover != null && cover.isNotEmpty) ...[
          GestureDetector(
            onTap: () => showImagePreview(context, urls: [cover]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: CachedNetworkImageWithFallback(
                  imageUrl: displayImageUrl(cover, width: 900) ?? cover,
                  fallbackUrl: cover,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const Gap(12),
        ],
        Text(
          usaha.name,
          style: theme.typography.body.xl.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        const Gap(8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ?badge,
            if (usaha.category case final category?)
              FBadge(
                variant: FBadgeVariant.secondary,
                child: Text(category.name),
              ),
            FBadge(
              variant: FBadgeVariant.outline,
              child: Text(usahaKindLabel(l10n, usaha.kind)),
            ),
            if (usaha.isManaged)
              FBadge(
                variant: FBadgeVariant.secondary,
                child: Text(l10n.usahaManagedByOwner),
              ),
          ],
        ),
        // Meta atas: apresiasi sebelum deskripsi / lokasi.
        if (usaha.manager case final manager?
            when usaha.author?.id == manager.id)
          ContributorAppreciationSection(
            label: l10n.usahaProposedAndManagedBy,
            contributors: [
              ContributorCredit(
                username: manager.username,
                displayName: manager.displayName,
              ),
            ],
          )
        else ...[
          if (usaha.manager case final manager?)
            ContributorAppreciationSection(
              label: l10n.usahaManagedByLabel,
              contributors: [
                ContributorCredit(
                  username: manager.username,
                  displayName: manager.displayName,
                ),
              ],
            ),
          if (usaha.author case final author?)
            ContributorAppreciationSection(
              label: l10n.usahaContributorProposedBy,
              contributors: [
                ContributorCredit(
                  username: author.username,
                  displayName: author.displayName,
                ),
              ],
            ),
        ],
        if (usaha.description != null) ...[
          const Gap(14),
          Text(
            usaha.description!,
            style: theme.typography.body.sm.copyWith(height: 1.5),
          ),
        ],
        if (usaha.operationalStatus ==
            UsahaOperationalStatus.permanentlyClosed) ...[
          const Gap(14),
          FAlert(
            title: Text(l10n.usahaClosedPermanentlyTitle),
            subtitle: Text(l10n.usahaClosedPermanentlyBody),
          ),
        ],
        if (locationTiles.isNotEmpty) ...[
          const Gap(18),
          FTileGroup(children: locationTiles),
        ],
        const Gap(18),
        _ContactSection(usaha: usaha),
        const Gap(18),
        if (usaha.images.isNotEmpty) ...[
          const Gap(12),
          _UsahaPhotoGrid(slug: usaha.slug, images: usaha.images),
        ],
        FTileGroup(
          label: Text(l10n.usahaActionSection),
          children: [
            FTile(
              prefix: const Icon(FLucideIcons.map, size: 18),
              title: Text(l10n.usahaActionViewOnMap),
              suffix: const Icon(FLucideIcons.chevronRight, size: 16),
              onPress: () {
                if (!usaha.hasCoordinates) {
                  showUsahaNoCoordinates(context);
                  return;
                }
                context.push(UsahaRouter.mapPath(usaha.slug));
              },
            ),
            FTile(
              prefix: const Icon(FLucideIcons.imagePlus, size: 18),
              title: Text(l10n.usahaActionAddPhoto),
              suffix: const Icon(FLucideIcons.chevronRight, size: 16),
              onPress: () => context.push(UsahaRouter.photosPath(usaha.slug)),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.pencil, size: 18),
              title: Text(l10n.usahaActionSuggestEdit),
              suffix: const Icon(FLucideIcons.chevronRight, size: 16),
              onPress: () =>
                  context.push(UsahaRouter.editPath(usaha.slug)),
            ),
            if (!usaha.isManaged)
              FTile(
                prefix: const Icon(FLucideIcons.keyRound, size: 18),
                title: Text(
                  hasPendingClaim
                      ? l10n.usahaSeeClaims
                      : l10n.usahaFormClaim,
                ),
                subtitle: hasPendingClaim
                    ? null
                    : Text(l10n.usahaManageClaimBody),
                onPress: hasPendingClaim ? onSeeClaims : onClaim,
              ),
          ],
        ),
        if (usaha.items.isNotEmpty) ...[
          const Gap(20),
          Text(
            l10n.usahaCatalog,
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
          for (final item in usaha.items) ...[
            _ItemTile(item: item),
            const Gap(8),
          ],
        ],
      ],
    );
  }
}

/// Tile lokasi dengan icon top-aligned (Forui prefix selalu di-center).
FTile _locationTile({
  required IconData icon,
  required String title,
  required String subtitle,
  int subtitleMaxLines = 1,
  double titleSpacing = 3,
}) {
  const iconSize = 18.0;
  const iconGap = 10.0;
  return FTile(
    style: .delta(contentStyle: .delta(titleSpacing: titleSpacing)),
    title: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: iconSize),
        const Gap(iconGap),
        Expanded(child: Text(title)),
      ],
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(left: iconSize + iconGap),
      child: Text(
        subtitle,
        maxLines: subtitleMaxLines,
        overflow: TextOverflow.ellipsis,
        style: subtitleMaxLines > 1 ? const TextStyle(height: 1.45) : null,
      ),
    ),
  );
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.usaha});

  final Usaha usaha;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final rows = <FTile>[];

    void add({
      required Widget prefix,
      required String title,
      required bool present,
      Uri? uri,
    }) {
      if (!present) return;
      rows.add(
        FTile(
          prefix: prefix,
          title: Text(title),
          suffix: uri == null
              ? null
              : const Icon(FLucideIcons.externalLink, size: 16),
          onPress: uri == null ? null : () => launchExternalUrl(uri),
        ),
      );
    }

    final phone = usaha.phone?.trim();
    add(
      prefix: Icon(FLucideIcons.phone, size: 18, color: theme.colors.primary),
      title: phone ?? '',
      present: phone != null && phone.isNotEmpty,
      uri: phone == null || phone.isEmpty
          ? null
          : Uri(scheme: 'tel', path: _digits(phone)),
    );

    final wa = usaha.whatsapp?.trim();
    add(
      prefix: Icon(
        FLucideIcons.phoneCall,
        size: 18,
        color: theme.colors.primary,
      ),
      title: l10n.usahaContactWhatsapp,
      present: wa != null && wa.isNotEmpty,
      uri: wa == null || wa.isEmpty
          ? null
          : Uri.parse('https://wa.me/${_waNumber(wa)}'),
    );

    final website = usaha.website?.trim();
    add(
      prefix: Icon(FLucideIcons.globe, size: 18, color: theme.colors.primary),
      title: l10n.usahaContactWebsite,
      present: website != null && website.isNotEmpty,
      uri: _https(website),
    );

    final social = usaha.socialUrl?.trim();
    add(
      prefix: Icon(FLucideIcons.link, size: 18, color: theme.colors.primary),
      title: l10n.usahaContactSocial,
      present: social != null && social.isNotEmpty,
      uri: _https(social),
    );

    final mapsUri = usahaGoogleMapsUri(usaha);
    add(
      prefix: Icon(FLucideIcons.mapPin, size: 18, color: theme.colors.primary),
      title: l10n.usahaContactMap,
      present: mapsUri != null,
      uri: mapsUri,
    );

    if (rows.isEmpty) {
      return Text(
        l10n.usahaContactEmpty,
        style: theme.typography.body.sm.copyWith(
          color: theme.colors.mutedForeground,
        ),
      );
    }

    return FTileGroup(children: rows);
  }

  static Uri? _https(String? raw) {
    if (raw == null) return null;
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.scheme.toLowerCase() != 'https') return null;
    return uri;
  }

  static String _digits(String raw) => raw.replaceAll(RegExp(r'[^0-9+]'), '');

  /// `08xx` -> `628xx` untuk tautan wa.me.
  static String _waNumber(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('62')) return digits;
    if (digits.startsWith('0')) return '62${digits.substring(1)}';
    return digits;
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item});

  final UsahaItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final image = item.imageUrl;
    return FTileGroup(
      children: [
        FTile(
          prefix: image == null
              ? Icon(FLucideIcons.tags, size: 18, color: theme.colors.primary)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CachedNetworkImageWithFallback(
                      imageUrl: displayImageUrl(image, width: 160) ?? image,
                      fallbackUrl: image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
          title: Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: item.description == null
              ? null
              : Text(
                  item.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
          suffix: Text(
            usahaPriceLabel(l10n, item),
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          onPress: image == null
              ? null
              : () => showImagePreview(context, urls: [image]),
        ),
      ],
    );
  }
}

class _UsahaPhotoGrid extends StatelessWidget {
  const _UsahaPhotoGrid({required this.slug, required this.images});

  static const _previewCount = 3;

  final String slug;
  final List<UsahaImage> images;

  @override
  Widget build(BuildContext context) {
    final shown = images.length <= _previewCount
        ? images
        : images.sublist(0, _previewCount);
    final hidden = images.length - shown.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const Gap(4),
              Expanded(
                child: GestureDetector(
                  onTap: () => showImagePreview(
                    context,
                    urls: [for (final im in images) im.url],
                    initialIndex: i,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImageWithFallback(
                        imageUrl:
                            displayImageUrl(shown[i].url, width: 400) ??
                            shown[i].url,
                        fallbackUrl: shown[i].url,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (hidden > 0) ...[
          const Gap(8),
          FButton(
            variant: FButtonVariant.outline,
            onPress: () => context.push(UsahaRouter.photosPath(slug)),
            child: Text(AppLocalizations.of(context).usahaPhotosTitle),
          ),
        ],
      ],
    );
  }
}

const _claimEvidenceFolder = '/usaha-claims';

/// Sheet bukti klaim (multi-gambar ImageKit). Return daftar wire images.
class _ClaimSheet extends ConsumerStatefulWidget {
  const _ClaimSheet();

  @override
  ConsumerState<_ClaimSheet> createState() => _ClaimSheetState();
}

class _ClaimSheetState extends ConsumerState<_ClaimSheet> {
  List<AttachmentImageSlot> _images = const [];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.usahaClaimSheetTitle,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(6),
              Text(
                l10n.usahaClaimSheetBody,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(12),
              AttachmentImagesField(
                enabled: true,
                maxImages: 5,
                maxSizeMb: 5,
                images: _images,
                onChanged: (next) => setState(() => _images = next),
                upload: (file, {required bool isPrimary}) async {
                  final result = await ref
                      .read(privateImageUploadServiceProvider)
                      .uploadFile(file, folder: _claimEvidenceFolder);
                  return result.fold(
                    (f) => Either.left(
                      AttachmentUploadFailure(
                        f.message,
                        errorCode: f.errorCode,
                      ),
                    ),
                    (dto) => Either.right(
                      AttachmentUploadedImage(
                        url: dto.url,
                        providerFileId: dto.providerFileId,
                        isPrimary: isPrimary,
                      ),
                    ),
                  );
                },
              ),
              const Gap(16),
              FButton(
                onPress: () {
                  if (_images.any((s) => s.uploading)) {
                    showAppErrorSheet(
                      context,
                      title: l10n.usahaClaimEvidenceShortTitle,
                      message: l10n.usahaFormWaitUpload,
                    );
                    return;
                  }
                  final ready = _images
                      .where((s) => s.isReady)
                      .map((s) => s.uploaded!)
                      .toList();
                  if (ready.isEmpty) {
                    showAppErrorSheet(
                      context,
                      title: l10n.usahaClaimEvidenceShortTitle,
                      message: l10n.usahaClaimEvidenceShort,
                    );
                    return;
                  }
                  Navigator.pop(context, [
                    for (final img in ready)
                      {
                        'url': img.url,
                        'provider_file_id': img.providerFileId,
                      },
                  ]);
                },
                child: Text(l10n.usahaClaimSubmit),
              ),
              const Gap(8),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () => Navigator.pop(context),
                child: Text(l10n.commonCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotFoundBody extends StatelessWidget {
  const _NotFoundBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FLucideIcons.store,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              l10n.usahaNotFound,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.go(UsahaRouter.list.path),
              child: Text(l10n.usahaSeeList),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FLucideIcons.circleAlert,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              l10n.usahaLoadFailed,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.go(UsahaRouter.list.path),
              child: Text(l10n.usahaSeeList),
            ),
          ],
        ),
      ),
    );
  }
}
