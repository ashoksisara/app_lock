// Home screen — displays profile cards, service status toggle, and add-profile FAB
import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO: Replace with real profile list from provider
  final List<dynamic> _profiles = [];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.appName,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
      body: _profiles.isEmpty
          ? _buildEmptyState(colorScheme, textTheme)
          : _buildProfileList(colorScheme),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.profileSetup);
        },
        icon: const Icon(Icons.person_add),
        label: const Text(AppStrings.addProfile),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer.withOpacity(0.4),
              ),
              child: Icon(
                Icons.person_add_outlined,
                size: 56,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            Text(
              AppStrings.noProfilesTitle,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              AppStrings.noProfilesDescription,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileList(ColorScheme colorScheme) {
    // TODO: Build profile cards from real data
    return const SizedBox.shrink();

    // ServiceStatusTile commented out for now
    // ServiceStatusTile(
    //   isActive: _isServiceActive,
    //   onToggle: (bool value) {
    //     setState(() {
    //       _isServiceActive = value;
    //     });
    //   },
    // ),
  }
}
