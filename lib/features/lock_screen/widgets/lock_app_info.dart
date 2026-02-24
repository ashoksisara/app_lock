// Displays the locked app icon, name, profile chip, and unlock subtitle
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

class LockAppInfo extends StatelessWidget {
  final String appName;
  final String appLetter;
  final String profileName;

  const LockAppInfo({
    super.key,
    required this.appName,
    required this.appLetter,
    required this.profileName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: AppDimensions.lockAvatarSize / 2,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                appLetter,
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: colorScheme.error,
                child: Icon(
                  Icons.lock,
                  size: 12,
                  color: colorScheme.onError,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Text(
          appName,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '\u{1F512} $profileName${AppStrings.profileAppLabel}',
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Text(
          AppStrings.enterPINToUnlock,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
