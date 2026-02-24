// Animated page position indicator with elongated active dot
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';

class OnboardingDotsIndicator extends StatelessWidget {
  final int activeIndex;

  const OnboardingDotsIndicator({
    super.key,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == activeIndex;

        return Padding(
          padding: EdgeInsets.only(
            right: index < 2 ? AppDimensions.paddingSmall : 0,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          ),
        );
      }),
    );
  }
}
