// Card displaying a profile's emoji avatar, name, locked app count, and tap target
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

class ProfileCard extends StatelessWidget {
  final String emoji;
  final String name;
  final int lockedAppsCount;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const ProfileCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.lockedAppsCount,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 0.5,
      child: InkWell(
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Row(
            children: [
              _buildAvatar(colorScheme),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall / 2),
                    Text(
                      '$lockedAppsCount ${AppStrings.appsLocked}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme) {
    return SizedBox(
      width: AppDimensions.avatarSize,
      height: AppDimensions.avatarSize,
      child: Stack(
        children: [
          CircleAvatar(
            radius: AppDimensions.avatarSize / 2,
            backgroundColor: colorScheme.inversePrimary,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock,
                size: 14,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
