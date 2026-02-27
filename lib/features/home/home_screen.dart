// Home screen — displays profile cards, service status toggle, and add-profile FAB
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../models/user_profile.dart';
import 'providers/profile_providers.dart';
import 'widgets/profile_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AsyncValue<List<UserProfile>> profileState =
        ref.watch(profileListProvider);

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
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, _) => _buildErrorState(
          context,
          colorScheme,
          textTheme,
          onRetry: () => ref.invalidate(profileListProvider),
        ),
        data: (List<UserProfile> profiles) => profiles.isEmpty
            ? _buildEmptyState(colorScheme, textTheme)
            : _buildProfileList(context, colorScheme, profiles),
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
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
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

  Widget _buildErrorState(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: colorScheme.error,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              'Something went wrong',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileList(
    BuildContext context,
    ColorScheme colorScheme,
    List<UserProfile> profiles,
  ) {
    final List<Color> cardColors = [
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge).copyWith(
        bottom: AppDimensions.paddingLarge + 80,
      ),
      itemCount: profiles.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppDimensions.paddingMedium),
      itemBuilder: (BuildContext context, int index) {
        final UserProfile profile = profiles[index];
        return ProfileCard(
          emoji: profile.emoji,
          name: profile.name,
          lockedAppsCount: 0,
          backgroundColor: cardColors[index % cardColors.length],
          onTap: () {
            // TODO: Navigate to profile detail / app selection
          },
        );
      },
    );
  }
}
