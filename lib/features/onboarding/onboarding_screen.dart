// Welcome onboarding screen with 3 swipeable pages explaining the app
import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import 'widgets/onboarding_bottom_bar.dart';
import 'widgets/onboarding_dots_indicator.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: PageController(),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    OnboardingPage(
                      illustrationEmoji: '\u{1F510}',
                      illustrationBgColor: colorScheme.primary,
                      title: AppStrings.onboardingTitle1,
                      description: AppStrings.onboardingDesc1,
                    ),
                    OnboardingPage(
                      illustrationEmoji: '\u{1F464}',
                      illustrationBgColor: colorScheme.secondary,
                      title: AppStrings.onboardingTitle2,
                      description: AppStrings.onboardingDesc2,
                    ),
                    OnboardingPage(
                      illustrationEmoji: '\u{1F6E1}\u{FE0F}',
                      illustrationBgColor: colorScheme.tertiary,
                      title: AppStrings.onboardingTitle3,
                      description: AppStrings.onboardingDesc3,
                    ),
                  ],
                ),
              ),
              const OnboardingDotsIndicator(activeIndex: 0),
              const SizedBox(height: AppDimensions.paddingMedium),
              const OnboardingBottomBar(currentPage: 0),
              const SizedBox(height: AppDimensions.paddingLarge),
            ],
          ),
          Positioned(
            top: mediaQuery.padding.top + AppDimensions.paddingLarge,
            right: AppDimensions.paddingMedium,
            child: TextButton(
              onPressed: () {},
              child: Text(
                AppStrings.skip,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
