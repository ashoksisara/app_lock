// Root MaterialApp widget — sets up M3 theme, named routes, and global config
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../features/app_selection/providers/installed_apps_provider.dart';
import 'routes.dart';

class App extends ConsumerWidget {
  final bool onboardingDone;

  const App({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(installedAppsProvider);

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
      initialRoute: onboardingDone ? AppRoutes.home : AppRoutes.onboarding,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
