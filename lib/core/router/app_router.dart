import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/browse/presentation/browse_view.dart';
import '../../features/favorites_history/presentation/my_list_view.dart';
import '../../features/home/presentation/home_view.dart';
import '../../features/home/presentation/main_nav_view.dart';
import '../../features/onboarding/presentation/onboarding_view.dart';
import '../../features/player/presentation/views/player_view.dart';
import '../../features/search/presentation/search_view.dart';
import '../../features/settings/presentation/settings_view.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRouter {
  AppRouter._();

  static GoRouter createRouter({required bool showOnboarding}) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: showOnboarding ? '/onboarding' : '/home',
      routes: [
        // Onboarding
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingView(),
        ),
        // Player full-screen route with deep linking support: airwave://channel/{id}
        GoRoute(
          path: '/player/:id',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final channelId = state.pathParameters['id'] ?? '';
            return PlayerView(channelId: channelId);
          },
        ),
        // Bottom Navigation Branches
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainNavView(navigationShell: navigationShell);
          },
          branches: [
            // Branch 0: Home
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeView(),
                ),
              ],
            ),
            // Branch 1: Browse
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/browse',
                  builder: (context, state) => const BrowseView(),
                ),
              ],
            ),
            // Branch 2: Search
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/search',
                  builder: (context, state) => const SearchView(),
                ),
              ],
            ),
            // Branch 3: Library (My List / History)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/my-list',
                  builder: (context, state) => const MyListView(),
                ),
              ],
            ),
            // Branch 4: Settings
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  builder: (context, state) => const SettingsView(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
