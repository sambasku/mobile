import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/network/connectivity_provider.dart';

/// Banner tipis di atas konten saat device offline. Animasi height supaya
/// layout tidak lompat. Dipasang sekali di App.builder - global untuk
/// semua tab. Konten tetap interaktif: banner bukan blocker.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(isOfflineProvider).value ?? false;
    final theme = context.theme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: offline
          ? Material(
              color: theme.colors.destructive,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        FLucideIcons.cloudOff,
                        size: 14,
                        color: Colors.white,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          'Kamu lagi offline. Nampilin data tersimpan.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.sm.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
