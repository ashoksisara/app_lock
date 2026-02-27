// Welcome onboarding screen with 3 swipeable pages explaining the app
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/routes.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import 'widgets/onboarding_bottom_bar.dart';
import 'widgets/onboarding_dots_indicator.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final int page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() => _currentPage = page);
    }
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  static const String _onboardingCompleteKey = 'onboarding_complete';

  Future<void> _completeOnboarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

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
                  controller: _pageController,
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
              OnboardingDotsIndicator(activeIndex: _currentPage),
              const SizedBox(height: AppDimensions.paddingMedium),
              OnboardingBottomBar(
                currentPage: _currentPage,
                onNext: _goToNextPage,
                onGetStarted: _completeOnboarding,
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
            ],
          ),
          Positioned(
            top: mediaQuery.padding.top + AppDimensions.paddingLarge,
            right: AppDimensions.paddingMedium,
            child: IgnorePointer(
              ignoring: _currentPage >= 2,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _currentPage < 2 ? 1.0 : 0.0,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    AppStrings.skip,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
