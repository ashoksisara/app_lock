// Reusable settings tile with three variants: navigation (arrow), toggle (switch), and info (trailing text)
import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showArrow;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final String? trailingText;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.showArrow = true,
    this.toggleValue,
    this.onToggleChanged,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.onSurfaceVariant),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: _buildTrailing(colorScheme, textTheme),
      onTap: toggleValue != null ? null : onTap ?? () {},
    );
  }

  Widget? _buildTrailing(ColorScheme colorScheme, TextTheme textTheme) {
    if (trailingText != null) {
      return Text(
        trailingText!,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (toggleValue != null) {
      return Switch(
        value: toggleValue!,
        onChanged: onToggleChanged,
      );
    }

    if (showArrow) {
      return Icon(
        Icons.chevron_right,
        color: colorScheme.onSurfaceVariant,
      );
    }

    return null;
  }
}
