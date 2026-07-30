
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/screens/splash_screen.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/main_layout.dart';
import '../ui/screens/map_screen.dart';
import '../ui/screens/notifications_screen.dart';
import '../ui/screens/routes_screen.dart';
import '../ui/screens/track_all_buses_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainLayout(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => MapScreen(busData: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/routes',
        builder: (context, state) => const RoutesScreen(),
      ),
      GoRoute(
        path: '/buses',
        builder: (context, state) => const TrackAllBusesScreen(),
      ),
    ],
  );
}
