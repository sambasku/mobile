import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../shared/utils/error_bottom_sheet.dart';
import '../providers/edit_profile_providers.dart';

class EditProfilePage extends HookConsumerWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editProfileProvider);
    final username = useTextEditingController();
    final displayName = useTextEditingController();
    final bio = useTextEditingController();
    useListenable(username);
    useListenable(displayName);
    useListenable(bio);

    useEffect(() {
      Future.microtask(() async {
        final loaded = await ref.read(editProfileProvider.notifier).load();
        if (loaded == null || !context.mounted) return;
        username.text = loaded.username;
        displayName.text = loaded.displayName;
        bio.text = loaded.bio;
      });
      return null;
    }, const []);

    ref.listen(editProfileProvider.select((s) => s.successMessage), (_, next) {
      if (next == null || !context.mounted) return;
      showFToast(
        context: context,
        title: Text(next),
        variant: .primary,
      );
      if (context.mounted && context.canPop()) {
        context.pop();
      } else if (context.mounted) {
        context.go('/profile');
      }
    });

    ref.listen(editProfileProvider.select((s) => s.errorMessage), (_, next) {
      if (next == null || !context.mounted) return;
      showAppErrorSheet(context, message: next).whenComplete(() {
        if (context.mounted) {
          ref.read(editProfileProvider.notifier).clearError();
        }
      });
    });

    final canSubmit = _isValidUsername(username.text) &&
        displayName.text.trim().isNotEmpty &&
        displayName.text.trim().length <= 100 &&
        bio.text.trim().length <= 500 &&
        !state.isSubmitting &&
        !state.isLoading;

    void submit() => ref.read(editProfileProvider.notifier).submit(
          username: username.text.trim(),
          displayName: displayName.text,
          bio: bio.text,
        );

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Edit profil'),
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
              padding:
                  const EdgeInsets.symmetric(vertical: 8),
              children: [
                FTextField(
                  control: .managed(controller: username),
                  enabled: !state.isSubmitting,
                  label: const Text('Username'),
                  hint: 'a-z, 0-9, titik, underscore (3-30 karakter)',
                  maxLength: 30,
                  textInputAction: .next,
                ),
                const Gap(12),
                FTextField(
                  control: .managed(controller: displayName),
                  enabled: !state.isSubmitting,
                  label: const Text('Nama tampilan'),
                  hint: 'Nama yang tampil di profil publik',
                  maxLength: 100,
                  textInputAction: .next,
                ),
                const Gap(12),
                FTextField(
                  control: .managed(controller: bio),
                  enabled: !state.isSubmitting,
                  label: const Text('Bio'),
                  hint: 'Ceritakan singkat tentangmu (opsional)',
                  maxLength: 500,
                  maxLines: 4,
                  textInputAction: .done,
                  onSubmit: canSubmit ? (_) => submit() : null,
                ),
                const Gap(20),
                FButton(
                  onPress: canSubmit ? submit : null,
                  child: state.isSubmitting
                      ? const FCircularProgress()
                      : const Text('Simpan'),
                ),
              ],
            ),
    );
  }
}


bool _isValidUsername(String value) {
  return RegExp(r'^[a-z0-9._]{3,30}$').hasMatch(value);
}
