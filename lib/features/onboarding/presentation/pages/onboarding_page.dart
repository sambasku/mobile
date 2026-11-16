import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/speaker_status.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../data/onboarding_prefs.dart';
import '../../data/speaker_status_prefs.dart';
import '../../../../l10n/app_localizations.dart';

/// Onboarding first-install: welcome → fitur → status bahasa → izin notifikasi.
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
  SpeakerStatus? _speakerStatus;

  /// Index slide status bahasa (wajib pilih sebelum lanjut).
  static const _speakerIndex = 2;
  static const _slideCount = 4;

  List<({String title, String body, IconData icon})> _infoSlides(
    AppLocalizations l10n,
  ) => [
    (
      title: l10n.onboardingWelcomeTitle,
      body: l10n.onboardingWelcomeBody,
      icon: FLucideIcons.bookOpen,
    ),
    (
      title: l10n.onboardingFeatureTitle,
      body: l10n.onboardingFeatureBody,
      icon: FLucideIcons.search,
    ),
    (
      title: l10n.onboardingSpeakerTitle,
      body: l10n.onboardingSpeakerBody,
      icon: FLucideIcons.languages,
    ),
    (
      title: l10n.onboardingNotifTitle,
      body: l10n.onboardingNotifBody,
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
    if (_speakerStatus == null) return;
    setState(() => _busy = true);
    try {
      await SpeakerStatusPrefs.save(_speakerStatus!);
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
    if (_index == _speakerIndex && _speakerStatus == null) return;
    if (_index < _slideCount - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final slides = _infoSlides(l10n);
    final isLast = _index == slides.length - 1;
    final isSpeaker = _index == _speakerIndex;
    final canContinue = !isSpeaker || _speakerStatus != null;

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
                  itemCount: slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final slide = slides[i];
                    if (i == _speakerIndex) {
                      return _SpeakerSlide(
                        title: slide.title,
                        body: slide.body,
                        icon: slide.icon,
                        selected: _speakerStatus,
                        onSelect: (status) {
                          setState(() => _speakerStatus = status);
                        },
                      );
                    }
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
                children: List.generate(slides.length, (i) {
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
                  onPress: _busy || !canContinue ? null : _next,
                  child: Text(l10n.onboardingContinue),
                )
              else ...[
                FButton(
                  onPress: _busy || _speakerStatus == null
                      ? null
                      : () => _finish(requestPermission: true),
                  child: _busy
                      ? const FCircularProgress()
                      : Text(l10n.onboardingAllowNotif),
                ),
                const Gap(10),
                FButton(
                  variant: .ghost,
                  onPress: _busy || _speakerStatus == null
                      ? null
                      : () => _finish(requestPermission: false),
                  child: Text(l10n.onboardingLater),
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

class _SpeakerSlide extends StatelessWidget {
  const _SpeakerSlide({
    required this.title,
    required this.body,
    required this.icon,
    required this.selected,
    required this.onSelect,
  });

  final String title;
  final String body;
  final IconData icon;
  final SpeakerStatus? selected;
  final ValueChanged<SpeakerStatus> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 1),
        Icon(icon, size: 56, color: theme.colors.primary),
        const Gap(28),
        Text(
          title,
          style: theme.typography.body.xl.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const Gap(14),
        Text(
          body,
          style: theme.typography.body.md.copyWith(
            color: theme.colors.mutedForeground,
            height: 1.45,
          ),
        ),
        const Gap(24),
        FButton(
          variant: selected == SpeakerStatus.native ? .primary : .outline,
          onPress: () => onSelect(SpeakerStatus.native),
          child: Text(l10n.onboardingSpeakerNative),
        ),
        const Gap(10),
        FButton(
          variant: selected == SpeakerStatus.learner ? .primary : .outline,
          onPress: () => onSelect(SpeakerStatus.learner),
          child: Text(l10n.onboardingSpeakerLearner),
        ),
        const Spacer(flex: 2),
      ],
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
          style: theme.typography.body.xl.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const Gap(14),
        Text(
          body,
          style: theme.typography.body.md.copyWith(
            color: theme.colors.mutedForeground,
            height: 1.45,
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}
