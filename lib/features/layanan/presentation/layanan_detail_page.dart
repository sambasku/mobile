import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/external_link.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/providers/auth_status_providers.dart';
import '../layanan_router.dart';
import 'layanan_logo.dart';
import 'layanan_phone_actions.dart';
import 'layanan_providers.dart';

class LayananDetailPage extends ConsumerWidget {
  const LayananDetailPage({super.key, required this.slug});

  final String slug;

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
        final mapUrl = item.mapsUrl ??
            (item.lat != null && item.lng != null
                ? 'https://maps.google.com/?q=${item.lat},${item.lng}'
                : null);
        return FScaffold(
          header: FHeader.nested(
            title: Text(item.name),
            prefixes: [FHeaderAction.back(onPress: () => context.pop())],
          ),
          footer: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: FButton(
                onPress: () => callOrPickLayananPhones(
                  context,
                  phones: item.phones,
                ),
                child: Text(l10n.layananCall),
              ),
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              Center(
                child: LayananLogo(
                  logoUrl: item.logoUrl,
                  isAmbulance: item.isAmbulance,
                  size: 72,
                ),
              ),
              const SizedBox(height: 12),
              FTileGroup(
                label: Text(l10n.layananPhones),
                children: [
                  for (final phone in item.phones)
                    FTile(
                      title: Text(phone.phone),
                      subtitle: Text(
                        (phone.note ?? '').isEmpty
                            ? l10n.layananCall
                            : phone.note!,
                      ),
                      suffix: FButton(
                        onPress: () => callLayananPhone(phone.phone),
                        child: Text(l10n.layananCall),
                      ),
                      onPress: () => callLayananPhone(phone.phone),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              FTileGroup(
                children: [
                  if (item.regionName != null)
                    FTile(
                      title: Text(item.regionName!),
                      subtitle: Text(l10n.layananKecamatan),
                    ),
                  if ((item.addressText ?? '').isNotEmpty)
                    FTile(
                      title: Text(item.addressText!),
                      subtitle: Text(l10n.layananAddress),
                    ),
                  if ((item.note ?? '').isNotEmpty)
                    FTile(
                      title: Text(item.note!),
                      subtitle: Text(l10n.layananNote),
                    ),
                  for (final phone in item.phones)
                    if ((phone.whatsapp ?? '').isNotEmpty)
                      FTile(
                        title: Text(phone.whatsapp!),
                        subtitle: Text(
                          (phone.note ?? '').isEmpty
                              ? l10n.layananWhatsapp
                              : '${l10n.layananWhatsapp} · ${phone.note}',
                        ),
                        onPress: () =>
                            launchExternalUrl(Uri.parse(_wa(phone.whatsapp!))),
                      ),
                  if (mapUrl != null)
                    FTile(
                      title: Text(l10n.layananMap),
                      onPress: () => launchExternalUrl(Uri.parse(mapUrl)),
                    ),
                  FTile(
                    title: Text(l10n.layananProposeEdit),
                    onPress: () {
                      final authed =
                          ref.read(authStatusProvider).value?.isAuth ?? false;
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
        );
      },
    );
  }

  String _wa(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = '62${digits.substring(1)}';
    return 'https://wa.me/$digits';
  }
}
