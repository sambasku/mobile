import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../data/onboarding_prefs.dart';

/// Onboarding first-install: welcome → fitur → izin notifikasi.
///
/// Tema mengikuti [MaterialApp.themeMode]: SharedPreferences jika ada,
/// selain itu [ThemeMode.system].
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;
  bool _busy = false;

  static const _slides = [
    (
      title: 'Selamat datang di SambasKu',
      body:
          'Kamus digital Sambas-Indonesia. Temukan arti kata, kenali cara bicara warga Sambas, dan ikut menjaga warisan kata.',
      icon: FLucideIcons.bookOpen,
    ),
    (
      title: 'Cari, usulkan, simpan',
      body:
          'Cari kata dengan cepat, usulkan kata baru atau perbaikan, dan simpan kata favorit biar gampang dibaca ulang.',
      icon: FLucideIcons.search,
    ),
    (
      title: 'Aktifkan notifikasi',
      body:
          'Kamu dapat kabar saat usulanmu disetujui. Izinkan notifikasi biar tidak ketinggalan.',
      icon: FLucideIcons.bell,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish({required bool requestPermission}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (requestPermission) {
        await NotificationService.requestPermissions();
      }
      await OnboardingPrefs.markDone();
      await AnalyticsService.instance.log(AnalyticsEvents.onboardingComplete);
      if (!mounted) return;
      context.go('/');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _next() {
    if (_index < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isLast = _index == _slides.length - 1;

    return FScaffold(
      childPad: false,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(50),
              const Center(child: BrandMark(size: 168)),
              const Gap(16),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final slide = _slides[i];
                    return _SlideContent(
                      title: slide.title,
                      body: slide.body,
                      icon: slide.icon,
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: active ? 22 : 8,
                    decoration: BoxDecoration(
                      color: active
                          ? theme.colors.primary
                          : theme.colors.mutedForeground.withValues(
                              alpha: 0.35,
                            ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              const Gap(24),
              if (!isLast)
                FButton(
                  onPress: _busy ? null : _next,
                  child: const Text('Lanjut'),
                )
              else ...[
                FButton(
                  onPress: _busy
                      ? null
                      : () => _finish(requestPermission: true),
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: FCircularProgress(),
                        )
                      : const Text('Izinkan notifikasi'),
                ),
                const Gap(10),
                FButton(
                  variant: .ghost,
                  onPress: _busy
                      ? null
                      : () => _finish(requestPermission: false),
                  child: const Text('Nanti'),
                ),
              ],
              const Gap(8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  const _SlideContent({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 1),
        Icon(icon, size: 56, color: theme.colors.primary),
        const Gap(28),
        Text(
          title,
          style: theme.typography.xl.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const Gap(14),
        Text(
          body,
          style: theme.typography.md.copyWith(
            color: theme.colors.mutedForeground,
            height: 1.45,
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}
