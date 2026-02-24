// Profile setup wizard — step 1: avatar & name, step 2: set PIN, step 3: confirm PIN
import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import 'widgets/emoji_avatar_picker.dart';
import 'widgets/pin_setup_field.dart';
import 'widgets/step_indicator.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  static const int _currentStep = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(AppStrings.newProfile),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const StepIndicator(currentStep: _currentStep),
            Expanded(child: _buildCurrentStep(context)),
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (_currentStep) {
      case 2:
        return _buildStepTwo(context);
      case 3:
        return _buildStepThree(context);
      default:
        return _buildStepOne(context);
    }
  }

  Widget _buildStepOne(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const EmojiAvatarPicker(emoji: '🧑'),
            const SizedBox(height: AppDimensions.paddingLarge * 2),
            TextField(
              decoration: InputDecoration(
                labelText: AppStrings.profileName,
                hintText: AppStrings.profileNameHint,
                prefixIcon: const Icon(Icons.person),
                counterText: '0/20',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusMedium,
                  ),
                ),
              ),
              maxLength: 20,
              buildCounter: (
                BuildContext context, {
                required int currentLength,
                required bool isFocused,
                required int? maxLength,
              }) {
                return Text(
                  '$currentLength/$maxLength',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTwo(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.setYourPIN,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Text(
          AppStrings.setYourPINSub,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge * 2),
        const PinDots(filledCount: 2),
        const SizedBox(height: AppDimensions.paddingLarge * 2),
        const NumberPad(),
      ],
    );
  }

  Widget _buildStepThree(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.confirmYourPIN,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Text(
          AppStrings.confirmYourPINSub,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge * 2),
        const PinDots(filledCount: 0),
        const SizedBox(height: AppDimensions.paddingLarge * 2),
        const NumberPad(),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    final bool isFinalStep = _currentStep == 3;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {},
          icon: Icon(isFinalStep ? Icons.check : Icons.arrow_forward),
          label: Text(isFinalStep ? AppStrings.saveProfile : AppStrings.next),
        ),
      ),
    );
  }
}
