// Animated bar showing how many apps are currently selected
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

class SelectedCountBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onClearAll;

  const SelectedCountBar({
    super.key,
    required this.selectedCount,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: selectedCount > 0 ? AppDimensions.selectedCountBarHeight : 0,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
        ),
        child: Row(
          children: [
            Text(
              '$selectedCount ${AppStrings.appsSelected}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onClearAll,
              child: Text(
                AppStrings.clearAll,
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
