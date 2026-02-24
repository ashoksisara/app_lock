// Step progress indicator showing active, completed, and inactive dots with a step label
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingMedium,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalSteps, (int index) {
              final int step = index + 1;
              final bool isCompleted = step < currentStep;
              final bool isActive = step == currentStep;

              return Padding(
                padding: EdgeInsets.only(
                  right: index < totalSteps - 1
                      ? AppDimensions.paddingSmall
                      : 0,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isActive ? 32 : 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isActive || isCompleted
                        ? colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: isActive || isCompleted
                        ? null
                        : Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          size: 8,
                          color: colorScheme.onPrimary,
                        )
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            '${AppStrings.stepOf} $currentStep of $totalSteps',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
