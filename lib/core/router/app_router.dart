import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../features/about/about_router.dart';
import '../../features/activity/presentation/pages/activity_page.dart';
import '../../features/admin_analytics/admin_analytics_router.dart';
import '../../features/auth/auth_router.dart';
import '../../features/auth/presentation/providers/auth_status_providers.dart';
import '../../features/bookmark/bookmark_router.dart';
import '../../features/my_comments/my_comments_router.dart';
import '../../features/my_votes/my_votes_router.dart';
import '../../features/change_password/change_password_router.dart';
import '../../features/delete_account/delete_account_router.dart';
import '../../features/edit_profile/edit_profile_router.dart';
import '../../features/linked_accounts/linked_accounts_router.dart';
import '../../features/contribution/contribution_router.dart';
import '../../features/dictionary/dictionary_router.dart';
import '../../features/my_contributions/my_contributions_router.dart';
import '../../features/notification/notification_router.dart';
import '../../features/explore/explore_router.dart';
import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/dictionary/presentation/pages/home_search_page.dart';
import '../../features/dictionary/presentation/providers/latest_words_providers.dart';
import '../../features/dictionary/presentation/providers/word_of_day_providers.dart';
import '../../features/onboarding/data/onboarding_prefs.dart';
import '../../features/onboarding/onboarding_router.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/report_bug/report_bug_router.dart';
import '../../features/review/presentation/providers/review_suggestions_providers.dart';
import '../../features/review/review_router.dart';
import '../../features/search_miss/search_miss_router.dart';
import '../../features/discussion/discussion_router.dart';
import '../../features/user_profile/user_profile_router.dart';
import '../../features/verifier_application/verifier_application_router.dart';
import '../../shared/splash/splash_router.dart';
import '../network/auth_token_storage.dart';
import '../services/analytics_route_observer.dart';
import '../utils/tabfreeze_log.dart';

/// Router utama (pola jnn_mobile):
/// - redirect onboarding first-install + auth
/// - StatefulShellRoute = 4 tab: Home, Eksplorasi, Kontribusi, Profil
/// - cold start: onboarding jika belum selesai, selain itu HOME
class AppRouter {
  AppRouter._();

  /// Root navigator key - dipakai DevToolOverlay untuk push di atas GoRouter.
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final AuthTokenStorage _tokenStorage = AuthTokenStorage.instance;

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    observers: analyticsNavigatorObservers(),
    routes: [
      ...SplashRouter.routes,
      ...OnboardingRouter.routes,
      ...AuthRouter.routes,
      ...ChangePasswordRouter.routes,
      ...DeleteAccountRouter.routes,
      ...EditProfileRouter.routes,
      ...LinkedAccountsRouter.routes,
      ...AboutRouter.routes,
      ...DictionaryRouter.routes,
      ...ContributionRouter.routes,
      ...MyContributionsRouter.routes,
      ...NotificationRouter.routes,
      ...BookmarkRouter.routes,
      ...MyVotesRouter.routes,
      ...MyCommentsRouter.routes,
      ...UserProfileRouter.routes,
      ...VerifierApplicationRouter.routes,
      ...ReportBugRouter.routes,
      ...DiscussionRouter.routes,
      ...ReviewRouter.routes,
      ...AdminAnalyticsRouter.routes,
      ...SearchMissRouter.routes,
      ...ExploreRouter.routes,
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'HomeRouter.search',
                builder: (context, state) => const HomeSearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ExploreRouter.hub.path,
                name: ExploreRouter.hub.name,
                builder: (context, state) => const ExplorePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/action',
                name: 'ActionRouter.activity',
                builder: (context, state) => const ActivityPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'ProfileRouter.profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: _redirect,
    errorBuilder: (context, state) => FScaffold(
      childPad: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text('Halaman tidak ditemukan: ${state.error}'),
        ),
      ),
    ),
  );

  /// Tamu BOLEH pakai app (pencarian publik). Redirect:
  /// - onboarding belum selesai → /onboarding (kecuali deep link publik / auth)
  /// - onboarding selesai tapi masih di /onboarding → HOME
  /// - user sudah login tapi masih di /login → HOME
  /// - tamu di /profile → /login (hindari layout guest yang membingungkan)
  /// Register, verify-email, forgot/reset tidak di-redirect: daftar akun
  /// baru boleh terjadi meski sesi lama ada, dan tautan reset dari email
  /// harus tetap bisa dibuka.
  /// Deadline global: await apa pun di redirect yang macet (storage,
  /// jaringan) tidak boleh mengunci GoRouter selamanya - semua navigasi
  /// berikutnya diabaikan selama redirect pending. Fail-open (null) =
  /// navigasi tetap jalan.
  static Future<String?> _redirect(
    BuildContext context,
    GoRouterState state,
  ) {
    return _redirectInner(context, state).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        tfLog('redirect timeout ${state.uri.path} -> null (dilanjutkan)');
        return null;
      },
    );
  }

  static Future<String?> _redirectInner(
    BuildContext context,
    GoRouterState state,
  ) async {
    final loc = state.matchedLocation;
    final path = state.uri.path;
    final query = state.uri.query;

    // HTTPS / custom scheme: /hapus-akun → rute native hapus akun.
    if (path == '/hapus-akun' || loc == '/hapus-akun') {
      return query.isEmpty ? '/delete-account' : '/delete-account?$query';
    }

    // Link share tempat: /wisata/<slug> → detail Place (entry analytics: link).
    if (path.startsWith('/wisata/')) {
      final slug = path.substring('/wisata/'.length);
      if (slug.isNotEmpty) return '/explore/place/$slug?entry=link';
    }

    final onboardingDone = OnboardingPrefs.done;
    final isOnboarding = loc == OnboardingRouter.onboarding.path;
    final isDeepLinkFriendly = _isDeepLinkFriendlyPath(path);

    if (!onboardingDone && !isOnboarding && !isDeepLinkFriendly) {
      return OnboardingRouter.onboarding.path;
    }
    if (onboardingDone && isOnboarding) {
      return '/';
    }

    // Jangan await getIsAuth (prefs + Keychain) di setiap pop/push.
    // Hanya perlu saat gate login/profil - selain itu delay-nya terasa
    // sebagai lag back dari search-miss / ruang diskusi.
    final needsAuthGate = loc == AuthRouter.login.path ||
        loc == '/profile' ||
        path == '/profile';
    if (needsAuthGate) {
      final isAuth = await _tokenStorage.getIsAuthForGate();
      if (isAuth && loc == AuthRouter.login.path) {
        tfLog('redirect $loc -> / auth=true');
        return '/';
      }
      if (!isAuth && (loc == '/profile' || path == '/profile')) {
        tfLog('redirect $loc -> ${AuthRouter.login.path} auth=false');
        return AuthRouter.login.path;
      }
    }

    return null;
  }

  /// Path yang boleh dibuka dari deep link sebelum onboarding selesai.
  static bool _isDeepLinkFriendlyPath(String path) {
    if (path == AuthRouter.resetPassword.path ||
        path == AuthRouter.forgotPassword.path ||
        path == AuthRouter.verifyEmail.path ||
        path == AuthRouter.register.path ||
        path == AuthRouter.termsWebView.path ||
        path == DeleteAccountRouter.deleteAccount.path ||
        path == '/hapus-akun') {
      return true;
    }
    if (path.startsWith('/words/')) return true;
    if (path.startsWith('/huruf/')) return true;
    if (path.startsWith('/users/')) return true;
    if (path.startsWith('/wisata/')) return true;
    if (path.startsWith('/explore/place/')) return true;
    if (path.startsWith('/discussions')) return true;
    return false;
  }
}

/// Buka tab Profil: cek token storage (sama seperti redirect), baru goBranch.
Future<void> _openProfileBranch(
  BuildContext context,
  StatefulNavigationShell navigationShell,
) async {
  final ok = await AppRouter._tokenStorage.getIsAuthForGate();
  if (!context.mounted) return;
  if (!ok) {
    context.push(AuthRouter.login.path);
    return;
  }
  navigationShell.goBranch(3);
}

/// Shell 4 tab bottom navigation (Forui).
class _HomeShell extends ConsumerWidget {
  const _HomeShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingReview = ref.watch(reviewHubHasPendingProvider).value ?? false;
    // resizeToAvoidBottomInset false: keyboard tidak dorong bottom nav
    // (nested scaffold + inset = overflow / "geser drawer")
    // footerDecoration dikosongkan - FBottomNavigationBar sudah punya top border
    //
    // Overlay root (search-miss, discussion, …): pause ticker shell.
    // ModalRoute.isCurrent sering tetap true di dalam StatefulShellRoute,
    // jadi sinyalnya rootNavigator.canPop.
    // Jangan flip TickerMode di build overlay: resume subscription Riverpod
    // di situ memanggil setState pada ProviderScope (markNeedsBuild).
    return _DeferredShellTicker(
      child: RepaintBoundary(
        child: FScaffold(
          childPad: true,
          resizeToAvoidBottomInset: false,
          scaffoldStyle: .delta(footerDecoration: .value(const BoxDecoration())),
          footer: FBottomNavigationBar(
            index: navigationShell.currentIndex,
            onChange: (index) {
              // IndexedStack menyimpan fokus search → keyboard ikut "nempel"
              // saat ganti tab / setelah hot reload. Unfocus dulu.
              FocusManager.instance.primaryFocus?.unfocus();
              // Tamu ketuk Profil → login. Jangan andalkan authStatus.value saja:
              // saat AsyncLoading value bisa null → salah kirim ke login / tab macet.
              if (index == 3) {
                final authed =
                    ref.read(authStatusProvider).value?.isAuth ?? false;
                if (authed) {
                  navigationShell.goBranch(3);
                  return;
                }
                unawaited(_openProfileBranch(context, navigationShell));
                return;
              }
              final openingHome = index == 0 && navigationShell.currentIndex != 0;
              navigationShell.goBranch(index);
              if (openingHome) {
                // keepAlive + IndexedStack tidak membangun ulang Home, jadi
                // kata yang baru disetujui tetap tersembunyi sampai di-refresh.
                ref.invalidate(wordOfDayProvider);
                ref.read(latestWordsProvider.notifier).load();
              }
            },
            children: [
              const FBottomNavigationBarItem(
                icon: Icon(FLucideIcons.house),
                label: Text('Home'),
              ),
              const FBottomNavigationBarItem(
                icon: Icon(FLucideIcons.compass),
                label: Text('Eksplorasi'),
              ),
              const FBottomNavigationBarItem(
                icon: Icon(FLucideIcons.circlePlus),
                label: Text('Kontribusi'),
              ),
              FBottomNavigationBarItem(
                icon: pendingReview
                    ? const _ProfileNavIcon(showDot: true)
                    : const Icon(FLucideIcons.userRound),
                label: const Text('Profil'),
              ),
            ],
          ),
          child: navigationShell,
        ),
      ),
    );
  }
}

/// Ticker shell ikut route root, tapi perubahan `enabled` ditunda ke frame
/// berikut. `routerDelegate` memberitahu listener di tengah rebuild overlay;
/// flip sinkron di situ me-resume provider yang sedang di-pause dan
/// Riverpod 3 memanggil setState pada [UncontrolledProviderScope].
class _DeferredShellTicker extends StatefulWidget {
  const _DeferredShellTicker({required this.child});

  final Widget child;

  @override
  State<_DeferredShellTicker> createState() => _DeferredShellTickerState();
}

class _DeferredShellTickerState extends State<_DeferredShellTicker> {
  var _enabled = true;
  var _queued = false;

  @override
  void initState() {
    super.initState();
    AppRouter.router.routerDelegate.addListener(_onRouter);
    _onRouter();
  }

  @override
  void dispose() {
    AppRouter.router.routerDelegate.removeListener(_onRouter);
    super.dispose();
  }

  void _onRouter() {
    if (_queued) return;
    _queued = true;
    // addPostFrameCallback TIDAK menjadwalkan frame: notifikasi delegate
    // saat app idle bisa meninggalkan _enabled stale (shell ter-pause
    // permanen) sampai frame lain datang secara kebetulan.
    SchedulerBinding.instance.scheduleFrame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queued = false;
      if (!mounted) return;
      final obscured =
          AppRouter.rootNavigatorKey.currentState?.canPop() ?? false;
      final next = !obscured;
      if (next != _enabled) {
        final loc = AppRouter.router.routerDelegate.currentConfiguration.uri;
        tfLog('ticker enabled=$next canPop=$obscured loc=$loc');
        setState(() => _enabled = next);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TickerMode(enabled: _enabled, child: widget.child);
  }
}

class _ProfileNavIcon extends StatelessWidget {
  const _ProfileNavIcon({required this.showDot});

  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(FLucideIcons.userRound),
        if (showDot)
          const Positioned(
            right: -2,
            top: -2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFF59E0B),
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: 8, height: 8),
            ),
          ),
      ],
    );
  }
}
