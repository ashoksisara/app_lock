// List tile for a single installed app with checkbox selection
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';

class AppTile extends StatelessWidget {
  final String name;
  final String packageName;
  final String letter;
  final Color avatarColor;
  final bool isSelected;
  final Uint8List? icon;
  final VoidCallback? onTap;

  const AppTile({
    super.key,
    required this.name,
    required this.packageName,
    required this.letter,
    required this.avatarColor,
    required this.isSelected,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.4)
          : Colors.transparent,
      child: ListTile(
        leading: _buildLeading(textTheme),
        title: Text(name, style: textTheme.bodyLarge),
        subtitle: Text(
          packageName,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (_) => onTap?.call(),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLeading(TextTheme textTheme) {
    if (icon != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.appIconSize / 4),
        child: Image.memory(
          icon!,
          width: AppDimensions.appIconSize,
          height: AppDimensions.appIconSize,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      );
    }

    return CircleAvatar(
      radius: AppDimensions.appIconSize / 2,
      backgroundColor: avatarColor,
      child: Text(
        letter,
        style: textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
