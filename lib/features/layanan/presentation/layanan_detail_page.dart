import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/external_link.dart';
import '../../../core/widgets/image_preview.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/profile_hero_shell.dart';
import '../../../shared/widgets/profile_identity_header.dart';
import '../../auth/presentation/providers/auth_status_providers.dart';
import '../domain/layanan.dart';
import '../layanan_router.dart';
import 'layanan_phone_actions.dart';
import 'layanan_providers.dart';

class LayananDetailPage extends ConsumerWidget {
  const LayananDetailPage({super.key, required this.slug});

  final String slug;

  static const _whatsappAsset = 'assets/svg/whatsapp.svg';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(layananBySlugProvider(slug));
    return async.when(
      loading: () => FScaffold(
        header: FHeader.nested(
          title: Text(l10n.layananTitle),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: const Center(child: FCircularProgress()),
      ),
      error: (_, _) => FScaffold(
        header: FHeader.nested(
          title: Text(l10n.layananTitle),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: Center(child: Text(l10n.layananLoadFailed)),
      ),
      data: (item) {
        if (item == null) {
          return FScaffold(
            header: FHeader.nested(
              title: Text(l10n.layananTitle),
              prefixes: [FHeaderAction.back(onPress: () => context.pop())],
            ),
            child: Center(child: Text(l10n.layananNotFound)),
          );
        }
        return _LayananDetailBody(item: item);
      },
    );
  }
}

class _LayananDetailBody extends ConsumerWidget {
  const _LayananDetailBody({required this.item});

  final LayananEntry item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final width = MediaQuery.sizeOf(context).width;
    final logoUrl = (item.logoUrl ?? '').trim();
    final hasLogo = logoUrl.isNotEmpty;
    final address = (item.addressText ?? '').trim();
    final note = (item.note ?? '').trim();
    final mapUrl = item.mapsUrl ??
        (item.lat != null && item.lng != null
            ? 'https://maps.google.com/?q=${item.lat},${item.lng}'
            : null);
    final categoryLabel =
        item.isAmbulance ? l10n.layananAmbulance : l10n.layananFire;
    final region = (item.regionName ?? '').trim();
    // Bio: alamat; kalau kosong pakai kecamatan supaya blok identitas tidak
    // kosong di bawah nama (sama ritme bio profil publik).
    final bio = address.isNotEmpty
        ? address
        : (region.isNotEmpty ? region : null);

    return FScaffold(
      // Full-bleed cover seperti profil publik.
      childPad: false,
      child: ProfileHeroShell(
        showBack: true,
        onBack: () => context.pop(),
        backLabel: l10n.commonBack,
        coverHeight: ProfileIdentityHeader.coverHeightOf(
          ProfileHeaderVariant.compact,
          width,
        ),
        title: item.name,
        scrollView: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ProfileIdentityHeader(
                variant: ProfileHeaderVariant.compact,
                displayName: item.name,
                avatarUrl: hasLogo ? logoUrl : null,
                bio: bio,
                onAvatarTap: hasLogo
                    ? () => showImagePreview(context, urls: [logoUrl])
                    : null,
                actions: [
                  FBadge(
                    variant: FBadgeVariant.secondary,
                    child: Text(categoryLabel),
                  ),
                  if (region.isNotEmpty && address.isNotEmpty)
                    FBadge(
                      variant: FBadgeVariant.outline,
                      child: Text(region),
                    ),
                ],
                footer: note.isEmpty
                    ? null
                    : Text(
                        note,
                        style: theme.typography.body.sm.copyWith(height: 1.45),
                      ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ContactSection(phones: item.phones),
                    const Gap(18),
                    FTileGroup(
                      children: [
                        if (mapUrl != null)
                          FTile(
                            prefix: Icon(
                              FLucideIcons.mapPin,
                              size: 18,
                              color: theme.colors.primary,
                            ),
                            title: Text(l10n.layananMap),
                            suffix: Icon(
                              FLucideIcons.chevronRight,
                              size: 16,
                              color: theme.colors.mutedForeground,
                            ),
                            onPress: () =>
                                launchExternalUrl(Uri.parse(mapUrl)),
                          ),
                        FTile(
                          prefix: Icon(
                            FLucideIcons.pencil,
                            size: 18,
                            color: theme.colors.primary,
                          ),
                          title: Text(l10n.layananProposeEdit),
                          suffix: Icon(
                            FLucideIcons.chevronRight,
                            size: 16,
                            color: theme.colors.mutedForeground,
                          ),
                          onPress: () {
                            final authed = ref
                                    .read(authStatusProvider)
                                    .value
                                    ?.isAuth ??
                                false;
                            if (!authed) {
                              context.push('/login');
                              return;
                            }
                            context.push(
                              LayananRouter.contributePath(
                                regionId: item.regionId,
                                layananId: item.id,
                                category: item.category,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Telepon + WhatsApp (nomor WA otomatis dari telepon).
class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.phones});

  final List<LayananPhone> phones;

  static const _whatsappAsset = LayananDetailPage._whatsappAsset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    if (phones.isEmpty) {
      return Text(
        l10n.layananCategoryEmpty,
        style: theme.typography.body.sm.copyWith(
          color: theme.colors.mutedForeground,
        ),
      );
    }

    final rows = <FTile>[];
    for (final phone in phones) {
      final number = phone.phone.trim();
      if (number.isEmpty) continue;
      final note = (phone.note ?? '').trim();
      rows.add(
        FTile(
          prefix: Icon(
            FLucideIcons.phone,
            size: 18,
            color: theme.colors.primary,
          ),
          title: Text(number),
          subtitle: note.isEmpty ? Text(l10n.layananCall) : Text(note),
          suffix: Icon(
            FLucideIcons.chevronRight,
            size: 16,
            color: theme.colors.mutedForeground,
          ),
          onPress: () => callLayananPhone(number),
        ),
      );
      rows.add(
        FTile(
          prefix: SvgPicture.asset(_whatsappAsset, width: 18, height: 18),
          title: Text(l10n.layananWhatsapp),
          subtitle: Text(number),
          suffix: Icon(
            FLucideIcons.externalLink,
            size: 16,
            color: theme.colors.mutedForeground,
          ),
          onPress: () => launchExternalUrl(Uri.parse(_waUrl(number))),
        ),
      );
    }

    return FTileGroup(children: rows);
  }

  String _waUrl(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = '62${digits.substring(1)}';
    return 'https://wa.me/$digits';
  }
}
