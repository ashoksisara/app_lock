// Home screen — displays profile cards, service status toggle, and add-profile FAB
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../models/user_profile.dart';
import '../../shared/widgets/pin_verify_dialog.dart';
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
            : _buildProfileList(context, ref, colorScheme, profiles),
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
    WidgetRef ref,
    ColorScheme colorScheme,
    List<UserProfile> profiles,
  ) {
    final List<Color> cardColors = [
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];

    final Map<int, int> lockedCounts =
        ref.watch(lockedAppsCountProvider).value ?? {};

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge).copyWith(
        bottom: AppDimensions.paddingLarge + 80,
      ),
      itemCount: profiles.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppDimensions.paddingMedium),
      itemBuilder: (BuildContext context, int index) {
        final UserProfile profile = profiles[index];
        final int count = lockedCounts[profile.id] ?? 0;
        return ProfileCard(
          emoji: profile.emoji,
          name: profile.name,
          lockedAppsCount: count,
          backgroundColor: cardColors[index % cardColors.length],
          onTap: () => _showProfileSheet(context, ref, profile, colorScheme),
        );
      },
    );
  }

  void _showProfileSheet(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    ColorScheme colorScheme,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String formattedDate =
        '${profile.createdAt.day}/${profile.createdAt.month}/${profile.createdAt.year}';

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.cardRadius),
        ),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.paddingLarge,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    profile.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                Text(
                  profile.name,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall / 2),
                Text(
                  '${AppStrings.createdOn} $formattedDate',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                ListTile(
                  leading: const Icon(Icons.apps),
                  title: const Text(AppStrings.selectAppsFor),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final bool verified = await showPinVerifyDialog(
                      context,
                      profileId: profile.id!,
                      profileName: profile.name,
                      profileEmoji: profile.emoji,
                    );
                    if (!verified || !context.mounted) return;
                    Navigator.pushNamed(
                      context,
                      AppRoutes.appSelection,
                      arguments: profile.id,
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: colorScheme.error),
                  title: Text(
                    AppStrings.deleteProfile,
                    style: TextStyle(color: colorScheme.error),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final bool verified = await showPinVerifyDialog(
                      context,
                      profileId: profile.id!,
                      profileName: profile.name,
                      profileEmoji: profile.emoji,
                    );
                    if (!verified || !context.mounted) return;
                    _confirmDelete(context, ref, profile);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.deleteProfile),
          content: Text(AppStrings.deleteProfileConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                if (profile.id != null) {
                  await ref
                      .read(profileListProvider.notifier)
                      .deleteProfile(profile.id!);
                }
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(AppStrings.profileDeleted),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.paddingSmall),
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text(AppStrings.delete),
            ),
          ],
        );
      },
    );
  }
}
