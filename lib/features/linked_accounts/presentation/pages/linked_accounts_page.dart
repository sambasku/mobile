import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_login_providers.dart';
import '../../../auth/presentation/widgets/social_icon_button.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../models/linked_accounts_state.dart';
import '../providers/linked_accounts_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Halaman Akun Terhubung - satu FTileGroup gaya profil, tile per provider.
///
/// Tile belum terhubung: tap = link. Tile terhubung: tap = confirm sheet
/// lepas tautan. Busy per provider tampil sebagai spinner di suffix.
class LinkedAccountsPage extends ConsumerWidget {
  const LinkedAccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(linkedAccountsProvider);
    final githubEnabled = ref.watch(githubAuthEnabledProvider);

    ref.listen(linkedAccountsProvider.select((s) => s.infoMessage), (_, next) {
      if (next == null || !context.mounted) return;
      showFToast(context: context, title: Text(next));
    });
    ref.listen(linkedAccountsProvider.select((s) => s.errorMessage), (_, next) {
      if (next == null || !context.mounted) return;
      if (ref.read(linkedAccountsProvider).errorCode == 'RATE_LIMITED') {
        showFToast(context: context, title: Text(next));
        ref.read(linkedAccountsProvider.notifier).clearError();
        return;
      }
      showAppErrorSheet(context, message: next).whenComplete(() {
        if (context.mounted) ref.read(linkedAccountsProvider.notifier).clearError();
      });
    });

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(AppLocalizations.of(context).linkedAccountsTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/profile'),
          ),
        ],
      ),
      child: state.isLoading
          ? const Center(child: FCircularProgress())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                FTileGroup(
                  label: Text(AppLocalizations.of(context).linkedAccountsSignInWith),
                  children: [
                    _ProviderTile(
                      assetPath: SocialIconButton.googleAsset,
                      title: AppLocalizations.of(context).providerGoogle,
                      linked: state.googleLinked,
                      linkedAt: state.googleLinkedAt,
                      busy: state.isBusy,
                      onTap: () => state.googleLinked
                          ? _confirmUnlink(context, ref,
                              providerName: AppLocalizations.of(context).providerGoogle,
                              onConfirm: () => ref
                                  .read(linkedAccountsProvider.notifier)
                                  .unlinkGoogle())
                          : ref
                              .read(linkedAccountsProvider.notifier)
                              .linkGoogle(),
                    ),
                    if (githubEnabled)
                      _ProviderTile(
                        assetPath: SocialIconButton.githubAsset,
                        title: AppLocalizations.of(context).providerGithub,
                        invertInDark: true,
                        linked: state.githubLinked,
                        linkedAt: state.githubLinkedAt,
                        busy: state.isBusy,
                        onTap: () => state.githubLinked
                            ? _confirmUnlink(context, ref,
                                providerName: AppLocalizations.of(context).providerGithub,
                                onConfirm: () => ref
                                    .read(linkedAccountsProvider.notifier)
                                    .unlinkGithub())
                            : ref
                                .read(linkedAccountsProvider.notifier)
                                .linkGithub(),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Future<void> _confirmUnlink(
    BuildContext context,
    WidgetRef ref, {
    required String providerName,
    required Future<void> Function() onConfirm,
  }) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      builder: (sheetContext) => Padding(
        padding: MediaQuery.of(sheetContext).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FTileGroup(
              children: [
                FTile(
                  title: Text(
                    AppLocalizations.of(
                      sheetContext,
                    ).linkedAccountsUnlinkTitle(providerName),
                  ),
                  subtitle: Text(
                    AppLocalizations.of(sheetContext).linkedAccountsUnlinkBody,
                  ),
                ),
                FTile(
                  title: const Text(''),
                  suffix: FButton(
                    variant: FButtonVariant.destructive,
                    onPress: () => Navigator.of(sheetContext).pop(true),
                    child: Text(
            AppLocalizations.of(sheetContext).linkedAccountsUnlink,
          ),
                  ),
                ),
                FTile(
                  title: const Text(''),
                  suffix: FButton(
                    onPress: () => Navigator.of(sheetContext).pop(false),
                    child: Text(AppLocalizations.of(sheetContext).commonCancel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (ok == true) await onConfirm();
  }
}

class _ProviderTile extends StatelessWidget with FTileMixin {
  const _ProviderTile({
    required this.assetPath,
    required this.title,
    required this.linked,
    required this.linkedAt,
    required this.busy,
    required this.onTap,
    this.invertInDark = false,
  });

  final String assetPath;
  final String title;
  final bool linked;

  /// ISO string dari GET /auth/providers; null bila belum terhubung.
  final String? linkedAt;
  final bool busy;
  final VoidCallback? onTap;

  /// GitHub mark hitam - putihkan di dark mode biar terlihat.
  final bool invertInDark;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final dark = theme.colors.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final subtitle = linked
        ? (linkedAt != null && formatLinkedDate(linkedAt!).isNotEmpty
              ? l10n.linkedAccountsLinkedSince(formatLinkedDate(linkedAt!))
              : l10n.linkedAccountsLinkedHint)
        : l10n.linkedAccountsNotLinked;
    return FTile(
      prefix: SvgPicture.asset(
        assetPath,
        width: 20,
        height: 20,
        colorFilter: invertInDark && dark
            ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
            : null,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      suffix: busy
          ? const FCircularProgress(size: .sm)
          : Icon(
              linked ? FLucideIcons.trash2 : FLucideIcons.plus,
              size: 16,
              color: linked ? theme.colors.destructive : null,
            ),
      onPress: busy ? null : onTap,
    );
  }
}
