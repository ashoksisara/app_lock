// Home screen — displays profile cards, service status toggle, and add-profile FAB
import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import 'widgets/profile_card.dart';
import 'widgets/service_status_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isServiceActive = true;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.appName,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              AppStrings.appSubtitle,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: AppStrings.settingsTooltip,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            children: [
              ProfileCard(
                emoji: '🧑',
                name: 'Profile 1',
                lockedAppsCount: 3,
                backgroundColor: colorScheme.primaryContainer,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.profileSetup);
                },
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              ProfileCard(
                emoji: '🧒',
                name: 'Profile 2',
                lockedAppsCount: 5,
                backgroundColor: colorScheme.secondaryContainer,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.profileSetup);
                },
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              ServiceStatusTile(
                isActive: _isServiceActive,
                onToggle: (bool value) {
                  setState(() {
                    _isServiceActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.profileSetup);
        },
        icon: const Icon(Icons.person_add),
        label: const Text(AppStrings.addProfile),
      ),
    );
  }
}
