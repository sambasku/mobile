import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../core/models/external_link.dart';
import 'app_update_provider.dart';

/// Banner info versi terbaru tersedia (issue mobile#196).
///
/// Non-blocking: bisa di-dismiss, muncul sekali per session (state lokal;
/// ponytail: simpan dismissed_version ke SharedPreferences kalau user
/// komplain banner muncul terus). CTA "Update" membuka store_url via
/// launchExternalUrl (UTM referal, rule external-link-utm).
class UpdateBanner extends ConsumerStatefulWidget {
  const UpdateBanner({super.key});

  @override
  ConsumerState<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends ConsumerState<UpdateBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final update = ref.watch(appUpdateProvider);
    return update.maybeWhen(
      data: (state) {
        if (state == null) return const SizedBox.shrink();
        final release = state.release;
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FAlert(
                variant: FAlertVariant.primary,
                title: Text('Versi ${release.version} sudah tersedia'),
                subtitle: Text(
                  'Update biar dapat fitur terbaru dan perbaikan bug ya.',
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: FButton(
                      size: FButtonSizeVariant.sm,
                      onPress: () => launchExternalUrl(release.storeUrl!),
                      child: const Text('Update sekarang'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FButton(
                    variant: FButtonVariant.ghost,
                    size: FButtonSizeVariant.sm,
                    onPress: () => setState(() => _dismissed = true),
                    child: const Text('Nanti'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
