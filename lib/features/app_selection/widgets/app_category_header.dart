// Section label used to group apps by category
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';

class AppCategoryHeader extends StatelessWidget {
  final String title;

  const AppCategoryHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.paddingMedium,
        top: AppDimensions.paddingMedium,
        bottom: AppDimensions.paddingSmall,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
            ),
      ),
    );
  }
}
