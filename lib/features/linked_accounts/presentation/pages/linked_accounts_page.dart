import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_login_providers.dart';
import '../providers/linked_accounts_providers.dart';

class LinkedAccountsPage extends ConsumerWidget {
  const LinkedAccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(linkedAccountsProvider);
    final githubEnabled = ref.watch(githubAuthEnabledProvider);

    ref.listen(linkedAccountsProvider.select((s) => s.infoMessage), (_, next) {
      if (next == null) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
    });

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Akun Terhubung'),
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
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ),
              children: [
                FTileGroup(
                  label: const Text('Google'),
                  children: [
                    FTile(
                      prefix: const Icon(FLucideIcons.link),
                      title: const Text('Google'),
                      subtitle: Text(
                        state.googleLinked
                            ? 'Terhubung - bisa dipakai untuk masuk'
                            : 'Belum terhubung',
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                if (state.googleLinked)
                  FButton(
                    onPress: state.isBusy
                        ? null
                        : () async {
                            final ok = await _confirmUnlink(
                              context,
                              title: 'Lepas Google?',
                              body:
                                  'Kamu tetap bisa masuk dengan email dan password atau provider lain.',
                            );
                            if (ok == true) {
                              await ref
                                  .read(linkedAccountsProvider.notifier)
                                  .unlinkGoogle();
                            }
                          },
                    child: state.isBusy
                        ? const FCircularProgress()
                        : const Text('Lepas tautan Google'),
                  )
                else
                  FButton(
                    onPress: state.isBusy
                        ? null
                        : () => ref
                              .read(linkedAccountsProvider.notifier)
                              .linkGoogle(),
                    child: state.isBusy
                        ? const FCircularProgress()
                        : const Text('Hubungkan Google'),
                  ),
                if (githubEnabled) ...[
                  const Gap(24),
                  FTileGroup(
                    label: const Text('GitHub'),
                    children: [
                      FTile(
                        prefix: const Icon(FLucideIcons.link),
                        title: const Text('GitHub'),
                        subtitle: Text(
                          state.githubLinked
                              ? 'Terhubung - bisa dipakai untuk masuk'
                              : 'Belum terhubung',
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  if (state.githubLinked)
                    FButton(
                      onPress: state.isBusy
                          ? null
                          : () async {
                              final ok = await _confirmUnlink(
                                context,
                                title: 'Lepas GitHub?',
                                body:
                                    'Kamu tetap bisa masuk dengan email dan password atau provider lain.',
                              );
                              if (ok == true) {
                                await ref
                                    .read(linkedAccountsProvider.notifier)
                                    .unlinkGithub();
                              }
                            },
                      child: state.isBusy
                          ? const FCircularProgress()
                          : const Text('Lepas tautan GitHub'),
                    )
                  else
                    FButton(
                      onPress: state.isBusy
                          ? null
                          : () => ref
                                .read(linkedAccountsProvider.notifier)
                                .linkGithub(),
                      child: state.isBusy
                          ? const FCircularProgress()
                          : const Text('Hubungkan GitHub'),
                    ),
                ],
                if (state.errorMessage != null) ...[
                  const Gap(16),
                  Text(
                    state.errorMessage!,
                    style: TextStyle(color: context.theme.colors.destructive),
                  ),
                ],
              ],
            ),
    );
  }

  Future<bool?> _confirmUnlink(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Lepas'),
          ),
        ],
      ),
    );
  }
}
