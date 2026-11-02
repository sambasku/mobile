import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../edit_profile/domain/providers/edit_profile_domain_providers.dart';

/// Toggle preferensi notifikasi leveling (streak + naik level).
/// Hanya tampil saat user login.
class NotificationPrefsSection extends ConsumerStatefulWidget {
  const NotificationPrefsSection({super.key});

  @override
  ConsumerState<NotificationPrefsSection> createState() =>
      _NotificationPrefsSectionState();
}

class _NotificationPrefsSectionState
    extends ConsumerState<NotificationPrefsSection> {
  bool? _streak;
  bool? _levelUp;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = ref.read(authStatusProvider).value;
    if (auth?.isAuth != true) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final result = await ref.read(getMyProfileUseCaseProvider).call();
    if (!mounted) return;
    result.fold(
      (_) {
        setState(() => _loading = false);
      },
      (profile) {
        setState(() {
          _streak = profile.notifyStreakReminder;
          _levelUp = profile.notifyLevelUp;
          _loading = false;
        });
      },
    );
  }

  Future<void> _save({bool? streak, bool? levelUp}) async {
    if (_saving) return;
    setState(() => _saving = true);
    final prevStreak = _streak;
    final prevLevel = _levelUp;
    if (streak != null) setState(() => _streak = streak);
    if (levelUp != null) setState(() => _levelUp = levelUp);

    final result = await ref.read(updateMyProfileUseCaseProvider).call(
          notifyStreakReminder: streak,
          notifyLevelUp: levelUp,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (failure) {
        setState(() {
          _streak = prevStreak;
          _levelUp = prevLevel;
        });
        showAppErrorSheet(context, message: failure.message);
      },
      (_) {
        final l10n = AppLocalizations.of(context);
        showFToast(
          context: context,
          title: Text(l10n.settingsNotifySaved),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authStatusProvider).value;
    if (auth?.isAuth != true) return const SizedBox.shrink();
    if (_loading || _streak == null || _levelUp == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FTileGroup(
            label: Text(l10n.settingsGroupNotifications),
            children: [
              FTile(
                title: const Text(''),
                suffix: const FCircularProgress(size: .sm),
              ),
            ],
          ),
          const Gap(8),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FTileGroup(
          label: Text(l10n.settingsGroupNotifications),
          children: [
            FTile(
              title: Text(l10n.settingsNotifyStreak),
              subtitle: Text(l10n.settingsNotifyStreakHint),
              suffix: FSwitch(
                value: _streak!,
                enabled: !_saving,
                onChange: (v) => _save(streak: v),
              ),
            ),
            FTile(
              title: Text(l10n.settingsNotifyLevelUp),
              subtitle: Text(l10n.settingsNotifyLevelUpHint),
              suffix: FSwitch(
                value: _levelUp!,
                enabled: !_saving,
                onChange: (v) => _save(levelUp: v),
              ),
            ),
          ],
        ),
        const Gap(8),
      ],
    );
  }
}
