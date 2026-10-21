import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../explore/domain/entities/region.dart';
import '../../../explore/presentation/providers/regions_providers.dart';
import '../providers/edit_profile_providers.dart';

class EditProfilePage extends HookConsumerWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editProfileProvider);
    final username = useTextEditingController();
    final displayName = useTextEditingController();
    final bio = useTextEditingController();
    final regionId = useState<String?>(null);
    final villageId = useState<String?>(null);
    useListenable(username);
    useListenable(displayName);
    useListenable(bio);

    final regionsAsync = ref.watch(regionsProvider);
    final regions = regionsAsync.asData?.value;
    final catalogReady = regions != null;
    final catalogLoading = regionsAsync.isLoading && regions == null;

    useEffect(() {
      Future.microtask(() async {
        final loaded = await ref.read(editProfileProvider.notifier).load();
        if (loaded == null || !context.mounted) return;
        username.text = loaded.username;
        displayName.text = loaded.displayName;
        bio.text = loaded.bio;
        regionId.value = loaded.regionId;
        villageId.value = loaded.villageId;
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
          regionId: regionId.value,
          villageId: villageId.value,
        );

    final all = regions ?? const <Region>[];
    final kecamatan = all.where((r) => r.type == RegionType.kecamatan).toList()
      ..sort(_byName);
    final desa = all
        .where((r) => r.type == RegionType.desa && r.parentId == regionId.value)
        .toList()
      ..sort(_byName);
    final menuMaxHeight = math.max(
      320.0,
      MediaQuery.sizeOf(context).height * 0.45,
    );
    final canPickRegion = catalogReady && !state.isSubmitting;
    final canPickVillage = canPickRegion && regionId.value != null;

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
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                const Gap(12),
                FTileGroup(
                  children: [
                    _regionSelect(
                      key: ValueKey('kec-${regionId.value}'),
                      title: 'Kecamatan',
                      value: regionId.value,
                      options: kecamatan,
                      enabled: canPickRegion,
                      loading: catalogLoading,
                      catalogReady: catalogReady,
                      maxHeight: menuMaxHeight,
                      onChange: (next) {
                        regionId.value = next;
                        final stillValid = all.any(
                          (r) =>
                              r.type == RegionType.desa &&
                              r.parentId == next &&
                              r.id == villageId.value,
                        );
                        if (!stillValid) villageId.value = null;
                      },
                    ),
                    _regionSelect(
                      key: ValueKey('desa-${regionId.value}-${villageId.value}'),
                      title: 'Desa',
                      value: villageId.value,
                      options: desa,
                      enabled: canPickVillage,
                      loading: catalogLoading,
                      catalogReady: catalogReady,
                      maxHeight: menuMaxHeight,
                      onChange: (next) => villageId.value = next,
                    ),
                  ],
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

int _byName(Region a, Region b) =>
    a.name.toLowerCase().compareTo(b.name.toLowerCase());

FTileMixin _regionSelect({
  required Key key,
  required String title,
  required String? value,
  required List<Region> options,
  required bool enabled,
  required bool loading,
  required bool catalogReady,
  required double maxHeight,
  required ValueChanged<String?> onChange,
}) {
  final known = options.where((r) => r.id == value).firstOrNull;
  final details = loading
      ? 'Memuat wilayah...'
      : !catalogReady
          ? 'Wilayah belum termuat'
          : (known?.name ?? value ?? 'Tidak diisi');
  final sentinel = value ?? '';

  return FSelectMenuTile<String>(
    key: key,
    enabled: enabled,
    title: Text(title),
    details: Text(details),
    maxHeight: maxHeight,
    selectControl: FMultiValueControl.managedRadio(
      initial: sentinel,
      onChange: (values) {
        if (!enabled || values.length != 1) return;
        final next = values.first;
        onChange(next.isEmpty ? null : next);
      },
    ),
    menu: [
      const FSelectTile(value: '', title: Text('Tidak diisi')),
      if (value != null && known == null && value.isNotEmpty)
        FSelectTile(value: value, title: Text(value)),
      for (final region in options)
        FSelectTile(value: region.id, title: Text(region.name)),
    ],
  );
}

bool _isValidUsername(String value) {
  return RegExp(r'^[a-z0-9._]{3,30}$').hasMatch(value);
}
