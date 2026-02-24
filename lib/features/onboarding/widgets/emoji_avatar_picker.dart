// Large emoji avatar with an edit badge, tappable to trigger avatar selection
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

class EmojiAvatarPicker extends StatelessWidget {
  final String emoji;
  final VoidCallback? onTap;

  const EmojiAvatarPicker({
    super.key,
    required this.emoji,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap ?? () {},
          child: SizedBox(
            width: AppDimensions.avatarSizeLarge,
            height: AppDimensions.avatarSizeLarge,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: AppDimensions.avatarSizeLarge / 2,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: colorScheme.primary,
                    child: Icon(
                      Icons.edit,
                      size: 14,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Text(
          AppStrings.tapToChangeAvatar,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
