import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../explore/domain/entities/region.dart';
import '../../../explore/presentation/providers/regions_providers.dart';
import '../../domain/entities/username_availability.dart';
import '../providers/edit_profile_providers.dart';
import '../../../../l10n/app_localizations.dart';

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

    useEffect(() {
      void listener() {
        ref.read(editProfileProvider.notifier).onUsernameChanged(username.text);
      }

      username.addListener(listener);
      return () => username.removeListener(listener);
    }, [username]);

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

    final canSubmit = state.canSubmitUsername &&
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
    final l10n = AppLocalizations.of(context);
    final canPickRegion = catalogReady && !state.isSubmitting;
    final canPickVillage = canPickRegion && regionId.value != null;

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.profileEditTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/profile'),
          ),
        ],
      ),
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: FButton(
            onPress: canSubmit ? submit : null,
            prefix: state.isSubmitting ? const FCircularProgress() : null,
            child: Text(l10n.commonSave),
          ),
        ),
      ),
      child: state.isLoading
          ? const Center(child: FCircularProgress())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                FTextField(
                  control: .managed(controller: username),
                  enabled: !state.isSubmitting,
                  label: Text(l10n.profileUsernameLabel),
                  hint: l10n.profileUsernameHint,
                  maxLength: 30,
                  textInputAction: .next,
                ),
                const Gap(6),
                _UsernameStatusLabel(
                  status: state.usernameStatus,
                  l10n: l10n,
                ),
                const Gap(12),
                FTextField(
                  control: .managed(controller: displayName),
                  enabled: !state.isSubmitting,
                  label: Text(l10n.profileDisplayNameLabel),
                  hint: l10n.profileDisplayNameHint,
                  maxLength: 100,
                  textInputAction: .next,
                ),
                const Gap(12),
                FTextField(
                  control: .managed(controller: bio),
                  enabled: !state.isSubmitting,
                  label: Text(l10n.profileBioLabel),
                  hint: l10n.profileBioHint,
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
                      title: l10n.profileDistrictLabel,
                      value: regionId.value,
                      options: kecamatan,
                      enabled: canPickRegion,
                      loading: catalogLoading,
                      catalogReady: catalogReady,
                      maxHeight: menuMaxHeight,
                      l10n: l10n,
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
                      title: l10n.profileVillageLabel,
                      value: villageId.value,
                      options: desa,
                      enabled: canPickVillage,
                      loading: catalogLoading,
                      catalogReady: catalogReady,
                      maxHeight: menuMaxHeight,
                      l10n: l10n,
                      onChange: (next) => villageId.value = next,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _UsernameStatusLabel extends StatelessWidget {
  const _UsernameStatusLabel({
    required this.status,
    required this.l10n,
  });

  final UsernameAvailabilityStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    if (status == UsernameAvailabilityStatus.idle ||
        status == UsernameAvailabilityStatus.current) {
      return const SizedBox.shrink();
    }

    if (status == UsernameAvailabilityStatus.checking) {
      return Row(
        children: [
          const FCircularProgress(size: .sm),
          const Gap(8),
          Text(
            l10n.profileUsernameChecking,
            style: context.theme.typography.body.sm.copyWith(
              color: colors.mutedForeground,
            ),
          ),
        ],
      );
    }

    final (text, color) = switch (status) {
      UsernameAvailabilityStatus.available => (
          l10n.profileUsernameAvailable,
          colors.primary,
        ),
      UsernameAvailabilityStatus.taken => (
          l10n.profileUsernameTaken,
          colors.destructive,
        ),
      UsernameAvailabilityStatus.reserved => (
          l10n.profileUsernameReserved,
          colors.destructive,
        ),
      UsernameAvailabilityStatus.invalid => (
          l10n.profileUsernameInvalid,
          colors.destructive,
        ),
      _ => (l10n.profileUsernameInvalid, colors.destructive),
    };

    return Text(
      text,
      style: context.theme.typography.body.sm.copyWith(color: color),
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
  required AppLocalizations l10n,
  required ValueChanged<String?> onChange,
}) {
  final known = options.where((r) => r.id == value).firstOrNull;
  final details = loading
      ? l10n.profileRegionLoading
      : !catalogReady
      ? l10n.profileRegionNotLoaded
      : (known?.name ?? value ?? l10n.profileNotFilled);
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
      FSelectTile(value: '', title: Text(l10n.profileNotFilled)),
      if (value != null && known == null && value.isNotEmpty)
        FSelectTile(value: value, title: Text(value)),
      for (final region in options)
        FSelectTile(value: region.id, title: Text(region.name)),
    ],
  );
}
