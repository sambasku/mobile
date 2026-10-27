import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/models/external_link.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/option_picker_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
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
          return _Body(
            usaha: usaha,
            onClaim: () => _openClaimSheet(context, ref),
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
    final result = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => const _ClaimSheet(),
    );
    if (result == null || !context.mounted) return;
    // Sheet sudah menutup; submit di luar sheet supaya error tampil di
    // halaman, bukan di dalam sheet yang sedang animasi tutup.
    try {
      await ref
          .read(usahaContributionApiProvider)
          .claim(slug, contactEvidence: result);
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

class _Body extends StatelessWidget {
  const _Body({required this.usaha, required this.onClaim});

  final Usaha usaha;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final cover = usaha.coverUrl;
    final badge = usahaOperationalBadge(l10n, usaha.operationalStatus);

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (cover != null && cover.isNotEmpty) ...[
          ClipRRect(
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
        const Gap(18),
        _ContactSection(usaha: usaha),
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
        const Gap(20),
        FTileGroup(
          children: [
            FTile(
              prefix: const Icon(FLucideIcons.keyRound, size: 18),
              title: Text(l10n.usahaFormClaim),
              subtitle: Text(l10n.usahaManageClaimBody),
              onPress: onClaim,
            ),
          ],
        ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.usaha});

  final Usaha usaha;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final rows = <FTile>[];

    void add(IconData icon, String label, String? value, Uri? uri) {
      if (value == null || value.trim().isEmpty) return;
      rows.add(
        FTile(
          prefix: Icon(icon, size: 18, color: theme.colors.primary),
          title: Text(label),
          subtitle: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis),
          suffix: uri == null
              ? null
              : const Icon(FLucideIcons.externalLink, size: 16),
          onPress: uri == null ? null : () => launchExternalUrl(uri),
        ),
      );
    }

    add(
      FLucideIcons.phone,
      l10n.usahaContactPhone,
      usaha.phone,
      usaha.phone == null
          ? null
          : Uri(scheme: 'tel', path: _digits(usaha.phone!)),
    );
    add(
      FLucideIcons.messageCircle,
      l10n.usahaContactWhatsapp,
      usaha.whatsapp,
      usaha.whatsapp == null
          ? null
          : Uri.parse('https://wa.me/${_waNumber(usaha.whatsapp!)}'),
    );
    add(
      FLucideIcons.globe,
      l10n.usahaContactWebsite,
      usaha.website,
      _https(usaha.website),
    );
    add(
      FLucideIcons.link,
      l10n.usahaContactSocial,
      usaha.socialUrl,
      _https(usaha.socialUrl),
    );
    add(
      FLucideIcons.mapPin,
      l10n.usahaContactMap,
      usaha.mapsUrl ?? usaha.addressText,
      _https(usaha.mapsUrl),
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
        ),
      ],
    );
  }
}

/// Sheet bukti klaim. Return teks bukti kontak (null = batal).
class _ClaimSheet extends StatefulWidget {
  const _ClaimSheet();

  @override
  State<_ClaimSheet> createState() => _ClaimSheetState();
}

class _ClaimSheetState extends State<_ClaimSheet> {
  final _evidence = TextEditingController();

  @override
  void dispose() {
    _evidence.dispose();
    super.dispose();
  }

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
              FTextField.multiline(
                control: FTextFieldControl.managed(controller: _evidence),
                label: Text(l10n.usahaClaimEvidence),
                hint: l10n.usahaClaimEvidenceHint,
                maxLines: 4,
              ),
              const Gap(16),
              FButton(
                onPress: () {
                  final text = _evidence.text.trim();
                  if (text.length < 5) {
                    showAppErrorSheet(
                      context,
                      title: l10n.usahaClaimEvidenceShortTitle,
                      message: l10n.usahaClaimEvidenceShort,
                    );
                    return;
                  }
                  Navigator.pop(context, text);
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
