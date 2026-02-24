// Full-screen lock overlay shown when a locked app is opened
import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import 'widgets/lock_app_info.dart';
import 'widgets/number_pad.dart';
import 'widgets/pin_dots.dart';
import 'widgets/wrong_pin_message.dart';

class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            const LockAppInfo(
              appName: 'WhatsApp',
              appLetter: 'W',
              profileName: 'Profile 1',
            ),
            const Spacer(flex: 1),
            const LockPinDots(filledCount: 2),
            const SizedBox(height: AppDimensions.paddingSmall),
            const WrongPinMessage(isVisible: false),
            const Spacer(flex: 2),
            const LockNumberPad(),
            const Spacer(flex: 1),
            _buildBiometricsButton(context, colorScheme),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricsButton(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return TextButton(
      onPressed: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fingerprint,
            size: 28,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.useBiometrics,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}
