// Named route definitions and route generator for app navigation
import 'package:flutter/material.dart';

import '../features/app_selection/app_selection_screen.dart';
import '../features/home/home_screen.dart';
import '../features/lock_screen/lock_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/profile_setup_screen.dart';
import '../features/settings/settings_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String settings = '/settings';
  static const String profileSetup = '/profile-setup';
  static const String appSelection = '/app-selection';
  static const String lockScreen = '/lock-screen';
  static const String onboarding = '/onboarding';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      case settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      case profileSetup:
        return MaterialPageRoute(
          builder: (_) => const ProfileSetupScreen(),
        );
      case appSelection:
        final int profileId = routeSettings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => AppSelectionScreen(profileId: profileId),
        );
      case lockScreen:
        return MaterialPageRoute(
          builder: (_) => const LockScreen(),
        );
      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
    }
  }
}
