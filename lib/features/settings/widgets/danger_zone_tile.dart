// Destructive-action tile styled with error colors for the Danger Zone section
import 'package:flutter/material.dart';

class DangerZoneTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const DangerZoneTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.error),
      title: Text(
        title,
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: colorScheme.onErrorContainer.withValues(alpha: 0.7),
              ),
            )
          : null,
      onTap: onTap ?? () {},
    );
  }
}
