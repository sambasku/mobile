import 'package:flutter/material.dart';
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
        title: const Text('Izin mikrofon diperlukan untuk merekam pelafalan'),
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
        title: const Text('Izin mikrofon'),
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
                    'Rekam pelafalan butuh akses mikrofon',
                    style: theme.typography.xl.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(10),
                  Text(
                    'Sebelum merekam, SambasKu meminta izin mikrofon. '
                    'Ini hanya dipakai untuk fitur pelafalan - bukan untuk '
                    'menyadap atau merekam di latar belakang.',
                    style: theme.typography.md.copyWith(
                      color: theme.colors.mutedForeground,
                      height: 1.45,
                    ),
                  ),
                  const Gap(24),
                  Text(
                    'Yang perlu Anda ketahui',
                    style: theme.typography.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(12),
                  const _RequirementRow(
                    icon: FLucideIcons.mic,
                    title: 'Izin mikrofon wajib',
                    body:
                        'Tanpa izin, tombol rekam tidak bisa mulai. Anda bisa '
                        'mencabut izin kapan saja di Pengaturan perangkat.',
                  ),
                  const Gap(12),
                  const _RequirementRow(
                    icon: FLucideIcons.timer,
                    title: 'Maksimal 60 detik',
                    body:
                        'Cukup untuk lemma atau contoh kalimat. Format suara '
                        'AAC/m4a - tanpa video.',
                  ),
                  const Gap(12),
                  const _RequirementRow(
                    icon: FLucideIcons.shieldCheck,
                    title: 'Ditinjau sebelum tayang',
                    body:
                        'Rekaman dikirim ke server SambasKu dan masuk antrean '
                        'review. Nama penutur opsional - boleh kirim tanpa nama.',
                  ),
                  const Gap(12),
                  const _RequirementRow(
                    icon: FLucideIcons.volume2,
                    title: 'Hanya saat Anda rekam',
                    body:
                        'Mikrofon aktif hanya selama sesi rekam di layar ini. '
                        'Tidak merekam diam-diam.',
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
              _busy ? 'Meminta izin…' : 'Lanjutkan & izinkan mikrofon',
            ),
          ),
          const Gap(8),
          FButton(
            variant: FButtonVariant.ghost,
            onPress: _busy ? null : () => Navigator.of(context).pop(false),
            child: const Text('Nanti saja'),
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
                style: theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(2),
              Text(
                body,
                style: theme.typography.sm.copyWith(
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
