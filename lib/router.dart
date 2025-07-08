
import 'package:go_router/go_router.dart';

import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/app_blocker_screen.dart'; // Ensure this file exports the correct class name
import 'screens/history_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/',          builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding',builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/auth',      builder: (_, __) => const AuthScreen()),
    GoRoute(path: '/signup',    builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/home',      builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/blocker',   builder: (_, __) => const AppBlockerScreen()), // Make sure 'AppBlockerScreen' is the correct class name as defined in app_blocker_screen.dart
    GoRoute(path: '/history',   builder: (_, __) => const HistoryScreen()),
  ],
);