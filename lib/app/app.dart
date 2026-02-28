// Root MaterialApp widget — sets up M3 theme, named routes, and global config
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/providers/theme_provider.dart';
import '../features/app_selection/providers/installed_apps_provider.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import 'routes.dart';

class App extends ConsumerWidget {
  final bool onboardingDone;

  const App({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(installedAppsProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.seedColor,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.seedColor,
        brightness: Brightness.dark,
      ),
      themeMode: themeMode,
      home: onboardingDone
          ? const HomeScreen()
          : const OnboardingScreen(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
