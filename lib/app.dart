import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/database_provider.dart';
import 'services/buddy_widget_sync.dart';
import 'theme/app_theme.dart';
import 'ui/challenges/challenges_screen.dart';
import 'ui/closet/closet_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/onboarding/onboarding_flow.dart';
import 'ui/progress/progress_screen.dart';
import 'ui/settings/settings_screen.dart';
import 'ui/shell/main_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    redirect: (context, state) async {
      final settings =
          await ref.read(settingsRepositoryProvider).getSettings();
      final done = settings?.onboardingDone ?? false;
      final onboarding = state.matchedLocation == '/onboarding';
      if (!done && !onboarding) return '/onboarding';
      if (done && onboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingFlow(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/closet',
        builder: (context, state) => const ClosetScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/challenges',
                builder: (context, state) => const ChallengesScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class LungBuddyApp extends ConsumerStatefulWidget {
  const LungBuddyApp({super.key});

  @override
  ConsumerState<LungBuddyApp> createState() => _LungBuddyAppState();
}

class _LungBuddyAppState extends ConsumerState<LungBuddyApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncWidget());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncWidget();
    }
  }

  Future<void> _syncWidget() async {
    await BuddyWidgetSync.syncFromRepos(
      settingsRepo: ref.read(settingsRepositoryProvider),
      smokeRepo: ref.read(smokeRepositoryProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Lung Buddy',
      theme: AppTheme.light(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
