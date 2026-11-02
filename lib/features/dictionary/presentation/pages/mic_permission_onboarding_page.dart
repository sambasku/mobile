import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../shared/utils/permission_helper.dart';

/// Halaman edukasi sebelum dialog izin mikrofon sistem.
/// Ditampilkan hanya jika izin belum diberikan.
class MicPermissionOnboardingPage extends StatefulWidget {
  const MicPermissionOnboardingPage({super.key});

  @override
  State<MicPermissionOnboardingPage> createState() =>
      _MicPermissionOnboardingPageState();
}

class _MicPermissionOnboardingPageState
    extends State<MicPermissionOnboardingPage> {
  bool _busy = false;

  Future<void> _continue() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final current = await Permission.microphone.status;
      if (!mounted) return;

      if (current.isGranted) {
        Navigator.of(context).pop(true);
        return;
      }

      if (current.isPermanentlyDenied) {
        showMicrophonePermissionDeniedDialog(context);
        return;
      }

      final status = await Permission.microphone.request();
      if (!mounted) return;

      if (status.isGranted) {
        Navigator.of(context).pop(true);
        return;
      }

      if (status.isPermanentlyDenied) {
        showMicrophonePermissionDeniedDialog(context);
        return;
      }

      showFToast(
        context: context,
        title: Text(AppLocalizations.of(context).dictMicPermissionTooltip),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return FScaffold(
      header: FHeader.nested(
        title: Text(AppLocalizations.of(context).dictMicPermissionTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: _busy ? null : () => Navigator.of(context).pop(false),
          ),
        ],
      ),
      childPad: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(8),
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: theme.colors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        FLucideIcons.mic,
                        size: 40,
                        color: theme.colors.primary,
                      ),
                    ),
                  ),
                  const Gap(24),
                  Text(
                    AppLocalizations.of(context).dictMicHeroTitle,
                    style: theme.typography.body.xl.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(10),
                  Text(
                    AppLocalizations.of(context).dictMicHeroBody,
                    style: theme.typography.body.md.copyWith(
                      color: theme.colors.mutedForeground,
                      height: 1.45,
                    ),
                  ),
                  const Gap(24),
                  Text(
                    AppLocalizations.of(context).dictMicFactsTitle,
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(12),
                  _RequirementRow(
                    icon: FLucideIcons.mic,
                    title: AppLocalizations.of(
                      context,
                    ).dictMicFactRequiredTitle,
                    body: AppLocalizations.of(context).dictMicFactRequiredBody,
                  ),
                  const Gap(12),
                  _RequirementRow(
                    icon: FLucideIcons.timer,
                    title: AppLocalizations.of(
                      context,
                    ).dictMicFactDurationTitle,
                    body: AppLocalizations.of(context).dictMicFactDurationBody,
                  ),
                  const Gap(12),
                  _RequirementRow(
                    icon: FLucideIcons.shieldCheck,
                    title: AppLocalizations.of(context).dictMicFactReviewTitle,
                    body: AppLocalizations.of(context).dictMicFactReviewBody,
                  ),
                  const Gap(12),
                  _RequirementRow(
                    icon: FLucideIcons.volume2,
                    title: AppLocalizations.of(
                      context,
                    ).dictMicFactOnlyRecordTitle,
                    body: AppLocalizations.of(
                      context,
                    ).dictMicFactOnlyRecordBody,
                  ),
                ],
              ),
            ),
          ),
          const Gap(12),
          FButton(
            onPress: _busy ? null : _continue,
            prefix: _busy ? null : const Icon(FLucideIcons.mic),
            child: Text(
              _busy
                  ? AppLocalizations.of(context).dictMicRequesting
                  : AppLocalizations.of(context).dictMicGrant,
            ),
          ),
          const Gap(8),
          FButton(
            variant: FButtonVariant.ghost,
            onPress: _busy ? null : () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).dictMicLater),
          ),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colors.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: theme.colors.primary),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(2),
              Text(
                body,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
