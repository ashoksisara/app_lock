// Bottom bar switching between a circular next FAB and a full-width Get Started button
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

class OnboardingBottomBar extends StatelessWidget {
  final int currentPage;

  const OnboardingBottomBar({
    super.key,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLastPage = currentPage == 2;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingMedium,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isLastPage
            ? SizedBox(
                key: const ValueKey('get-started'),
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text(AppStrings.getStarted),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.cardRadius,
                      ),
                    ),
                  ),
                ),
              )
            : Row(
                key: const ValueKey('next-fab'),
                children: [
                  const Spacer(),
                  FloatingActionButton(
                    onPressed: () {},
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    child: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
      ),
    );
  }
}
