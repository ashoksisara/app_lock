// Single onboarding slide with layered illustration circles, title, and description
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';

class OnboardingPage extends StatelessWidget {
  final String illustrationEmoji;
  final Color illustrationBgColor;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.illustrationEmoji,
    required this.illustrationBgColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: AppDimensions.onboardingCircleOuter,
          height: AppDimensions.onboardingCircleOuter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: AppDimensions.onboardingCircleOuter,
                height: AppDimensions.onboardingCircleOuter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: illustrationBgColor.withValues(alpha: 0.1),
                ),
              ),
              Container(
                width: AppDimensions.onboardingCircleMiddle,
                height: AppDimensions.onboardingCircleMiddle,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: illustrationBgColor.withValues(alpha: 0.15),
                ),
              ),
              Container(
                width: AppDimensions.onboardingCircleInner,
                height: AppDimensions.onboardingCircleInner,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: illustrationBgColor.withValues(alpha: 0.2),
                ),
              ),
              Text(
                illustrationEmoji,
                style: const TextStyle(fontSize: 100),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
          ),
          child: Text(
            title,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge * 2,
          ),
          child: Text(
            description,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
